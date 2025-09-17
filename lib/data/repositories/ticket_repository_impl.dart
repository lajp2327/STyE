import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import 'package:sistema_tickets_edis/core/errors/failure.dart';
import 'package:sistema_tickets_edis/core/notifications/local_notification_service.dart';
import 'package:sistema_tickets_edis/core/pdf/alta_document_service.dart';
import 'package:sistema_tickets_edis/data/local/database/app_database.dart';
import 'package:sistema_tickets_edis/domain/entities/alta_document_result.dart';
import 'package:sistema_tickets_edis/domain/entities/catalog.dart';
import 'package:sistema_tickets_edis/domain/entities/report_summary.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket_event.dart';
import 'package:sistema_tickets_edis/domain/entities/technician.dart';
import 'package:sistema_tickets_edis/domain/entities/user.dart';
import 'package:sistema_tickets_edis/domain/repositories/ticket_repository.dart';
import 'package:sistema_tickets_edis/domain/services/ticket_workflow_service.dart';
import 'package:sistema_tickets_edis/domain/value_objects/ticket_filters.dart';

class TicketRepositoryImpl implements TicketRepository {
  TicketRepositoryImpl({
    required AppDatabase database,
    required TicketWorkflowService workflowService,
    required LocalNotificationService notificationService,
    required AltaDocumentService altaDocumentService,
  }) : _database = database,
       _workflowService = workflowService,
       _notificationService = notificationService,
       _altaDocumentService = altaDocumentService,
       _dao = database.ticketDao;

  final AppDatabase _database;
  final TicketWorkflowService _workflowService;
  final LocalNotificationService _notificationService;
  final AltaDocumentService _altaDocumentService;
  final TicketDao _dao;
  final Uuid _uuid = const Uuid();

  @override
  Stream<List<Ticket>> watchTickets({
    TicketFilter filter = const TicketFilter(),
  }) {
    return _dao.watchTickets().map((List<TicketWithRelations> rows) {
      final List<Ticket> mapped = rows
          .map(_mapTicket)
          .where((Ticket ticket) => _matchesFilter(ticket, filter))
          .toList();
      return mapped;
    });
  }

  @override
  Future<Ticket> createTicket(TicketDraft draft) async {
    final DateTime now = DateTime.now();
    final String folio =
        'T-${now.millisecondsSinceEpoch}-${_uuid.v4().substring(0, 4)}';
    final UserRow requester = await _dao.ensureUser(
      name: draft.requester.name,
      email: draft.requester.email,
    );
    final TicketsCompanion insert = TicketsCompanion.insert(
      folio: folio,
      title: draft.title,
      description: draft.description,
      category: draft.category.code,
      status: TicketStatus.nuevo.name,
      requesterId: requester.id,
      assignedTechnicianId: const Value.absent(),
      createdAt: Value<DateTime>(now),
      updatedAt: Value<DateTime>(now),
      resolvedAt: const Value.absent(),
      closedAt: const Value.absent(),
      altaJson: Value<String?>(
        draft.altaDetails == null
            ? null
            : jsonEncode(draft.altaDetails!.toJson()),
      ),
      metadataJson: Value<String>(jsonEncode(draft.metadata)),
    );
    final int id = await _dao.insertTicket(insert);
    await _dao.insertEvent(
      TicketEventsCompanion.insert(
        ticketId: id,
        type: TicketEventType.created.name,
        author: draft.requester.name,
        message: 'Ticket creado en ${draft.category.label}',
        metadataJson: Value<String>(
          jsonEncode(<String, dynamic>{'folio': folio}),
        ),
        createdAt: Value<DateTime>(now),
      ),
    );
    final Ticket ticket = (await findTicket(id))!;
    await _notificationService.showTicketCreated(ticket);
    return ticket;
  }

  @override
  Future<Ticket?> findTicket(int id) async {
    final TicketWithRelations? row = await _dao.findTicket(id);
    if (row == null) {
      return null;
    }
    return _mapTicket(row);
  }

  @override
  Stream<List<TicketEvent>> watchTicketHistory(int ticketId) {
    return _dao
        .watchEvents(ticketId)
        .map(
          (List<TicketEventRow> rows) =>
              rows.map((TicketEventRow row) => row.toDomain()).toList(),
        );
  }

  @override
  Future<void> addComment({
    required int ticketId,
    required String message,
    required String author,
    Map<String, dynamic>? metadata,
  }) async {
    await _ensureTicketExists(ticketId);
    await _dao.insertEvent(
      TicketEventsCompanion.insert(
        ticketId: ticketId,
        type: TicketEventType.comment.name,
        author: author,
        message: message,
        metadataJson: Value<String>(
          jsonEncode(metadata ?? <String, dynamic>{}),
        ),
      ),
    );
  }

  @override
  Future<void> assignTechnician({
    required int ticketId,
    required Technician technician,
    String? comment,
  }) async {
    final Ticket ticket = await _ensureTicketExists(ticketId);
    await _dao.assignTechnician(
      ticketId: ticketId,
      technicianId: technician.id,
    );
    final String message = comment ?? 'Asignado a ${technician.name}';
    await _dao.insertEvent(
      TicketEventsCompanion.insert(
        ticketId: ticketId,
        type: TicketEventType.assignment.name,
        author: 'Coordinador',
        message: message,
        metadataJson: Value<String>(
          jsonEncode(<String, dynamic>{'technicianId': technician.id}),
        ),
      ),
    );
    final Ticket? updated = await findTicket(ticketId);
    if (updated != null) {
      await _notificationService.showAssignment(updated, technician.name);
    }
  }

  @override
  Future<void> updateStatus({
    required int ticketId,
    required TicketStatus nextStatus,
    String author = 'Sistema',
    String? comment,
  }) async {
    final Ticket ticket = await _ensureTicketExists(ticketId);
    _workflowService.assertTransition(ticket.status, nextStatus);

    final DateTime now = DateTime.now();
    final DateTime? resolvedAt = nextStatus == TicketStatus.resuelto
        ? now
        : ticket.resolvedAt;
    final DateTime? closedAt = nextStatus == TicketStatus.cerrado
        ? now
        : ticket.closedAt;
    await _dao.updateTicketStatus(
      ticketId: ticketId,
      status: nextStatus.name,
      resolvedAt: resolvedAt,
      closedAt: closedAt,
    );

    final String message =
        comment ?? 'Estado actualizado a ${nextStatus.label}';
    final Map<String, dynamic> metadata = <String, dynamic>{
      'from': ticket.status.name,
      'to': nextStatus.name,
    };
    final TicketEvent event = TicketEvent(
      id: 0,
      ticketId: ticketId,
      type: TicketEventType.statusChanged,
      message: message,
      author: author,
      createdAt: now,
      metadata: metadata,
    );
    await _dao.insertEvent(
      TicketEventsCompanion.insert(
        ticketId: ticketId,
        type: TicketEventType.statusChanged.name,
        author: author,
        message: message,
        metadataJson: Value<String>(jsonEncode(metadata)),
        createdAt: Value<DateTime>(now),
      ),
    );
    final Ticket? updated = await findTicket(ticketId);
    if (updated != null) {
      await _notificationService.showStatusChanged(updated, event);
    }
  }

  @override
  Future<AltaDocumentResult> generateAltaDocuments(int ticketId) async {
    final Ticket ticket = await _ensureTicketExists(ticketId);
    if (!ticket.isAltaRmFg || ticket.altaDetails == null) {
      throw const PersistenceFailure(
        'El ticket no corresponde al flujo RM/FG.',
      );
    }
    final AltaDocumentResult result = await _altaDocumentService
        .generateRmFgDocuments(ticket);
    await _dao.insertDmfExport(
      ticketId: ticketId,
      pdfPath: result.pdfPath,
      csvPath: result.csvPath,
    );
    await _dao.insertEvent(
      TicketEventsCompanion.insert(
        ticketId: ticketId,
        type: TicketEventType.documentGenerated.name,
        author: 'Sistema',
        message: 'Documentos RM/FG generados',
        metadataJson: Value<String>(
          jsonEncode(<String, dynamic>{
            'pdfPath': result.pdfPath,
            'csvPath': result.csvPath,
          }),
        ),
      ),
    );
    return result;
  }

  @override
  Future<List<CatalogEntry>> getCatalogEntries(CatalogType type) async {
    final List<CatalogEntryRow> rows = await _dao.getCatalogEntries(type.code);
    return rows.map((CatalogEntryRow row) => row.toDomain()).toList();
  }

  @override
  Stream<List<Technician>> watchTechnicians() {
    return _dao.watchTechnicians().map(
      (List<TechnicianRow> rows) =>
          rows.map((TechnicianRow row) => row.toDomain()).toList(),
    );
  }

  @override
  Future<ReportSummary> loadReportSummary({TicketFilter? filter}) async {
    final TicketFilter effectiveFilter = filter ?? const TicketFilter();
    final List<Ticket> tickets = (await _dao.getAllTickets())
        .map(_mapTicket)
        .where((Ticket ticket) => _matchesFilter(ticket, effectiveFilter))
        .toList();
    final Map<int, List<TicketEventRow>> eventsMap = await _dao
        .eventsByTicketIds(tickets.map((Ticket e) => e.id).toList());

    final Map<TicketCategory, int> byCategory = <TicketCategory, int>{};
    final Map<TicketStatus, int> byStatus = <TicketStatus, int>{};
    final Map<Technician, int> byTechnician = <Technician, int>{};
    final Map<TicketStatus, Duration> statusTotals = <TicketStatus, Duration>{};
    final Map<TicketStatus, int> statusCounts = <TicketStatus, int>{};
    Duration totalResolution = Duration.zero;
    int resolvedCount = 0;

    for (final Ticket ticket in tickets) {
      byCategory[ticket.category] = (byCategory[ticket.category] ?? 0) + 1;
      byStatus[ticket.status] = (byStatus[ticket.status] ?? 0) + 1;
      if (ticket.assignedTechnician != null) {
        byTechnician[ticket.assignedTechnician!] =
            (byTechnician[ticket.assignedTechnician!] ?? 0) + 1;
      }
      if (ticket.resolutionTime != null) {
        totalResolution += ticket.resolutionTime!;
        resolvedCount += 1;
      }
      final List<TicketEvent> events =
          (eventsMap[ticket.id] ?? <TicketEventRow>[])
              .map((TicketEventRow row) => row.toDomain())
              .toList();
      final Map<TicketStatus, Duration> durations = _workflowService
          .calculateDurations(events, closedAt: ticket.closedAt);
      durations.forEach((TicketStatus status, Duration duration) {
        statusTotals[status] =
            (statusTotals[status] ?? Duration.zero) + duration;
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      });
    }

    Duration? averageResolution;
    if (resolvedCount > 0) {
      averageResolution = Duration(
        milliseconds: (totalResolution.inMilliseconds / resolvedCount).round(),
      );
    }

    final Map<TicketStatus, Duration> statusAverages =
        <TicketStatus, Duration>{};
    statusTotals.forEach((TicketStatus status, Duration total) {
      final int count = statusCounts[status] ?? 1;
      statusAverages[status] = Duration(
        milliseconds: (total.inMilliseconds / count).round(),
      );
    });

    return ReportSummary(
      byCategory: byCategory,
      byStatus: byStatus,
      byTechnician: byTechnician,
      averageResolution: averageResolution,
      statusDurations: statusAverages,
    );
  }

  Ticket _mapTicket(TicketWithRelations data) {
    final Technician? technician = data.technician?.toDomain();
    final User requester = data.requester.toDomain();
    return Ticket.fromDatabase(
      id: data.ticket.id,
      folio: data.ticket.folio,
      title: data.ticket.title,
      description: data.ticket.description,
      category: data.ticket.category,
      status: data.ticket.status,
      requester: requester,
      technician: technician,
      createdAt: data.ticket.createdAt,
      updatedAt: data.ticket.updatedAt,
      resolvedAt: data.ticket.resolvedAt,
      closedAt: data.ticket.closedAt,
      altaJson: data.ticket.altaJson,
      metadataJson: data.ticket.metadataJson,
    );
  }

  bool _matchesFilter(Ticket ticket, TicketFilter filter) {
    if (filter.status != null && ticket.status != filter.status) {
      return false;
    }
    if (filter.category != null && ticket.category != filter.category) {
      return false;
    }
    if (filter.assignedTechnicianId != null &&
        ticket.assignedTechnician?.id != filter.assignedTechnicianId) {
      return false;
    }
    if (filter.dateRange != null &&
        !filter.dateRange!.contains(ticket.createdAt)) {
      return false;
    }
    return true;
  }

  Future<Ticket> _ensureTicketExists(int ticketId) async {
    final Ticket? ticket = await findTicket(ticketId);
    if (ticket == null) {
      throw NotFoundFailure('Ticket $ticketId no encontrado');
    }
    return ticket;
  }
}
