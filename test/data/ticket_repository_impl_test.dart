import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sistema_tickets_edis/core/errors/failure.dart';
import 'package:sistema_tickets_edis/core/notifications/local_notification_service.dart';
import 'package:sistema_tickets_edis/core/pdf/alta_document_service.dart';
import 'package:sistema_tickets_edis/data/local/database/app_database.dart';
import 'package:sistema_tickets_edis/data/repositories/ticket_repository_impl.dart';
import 'package:sistema_tickets_edis/domain/entities/alta_document_result.dart';
import 'package:sistema_tickets_edis/domain/entities/catalog.dart';
import 'package:sistema_tickets_edis/domain/entities/report_summary.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket_event.dart';
import 'package:sistema_tickets_edis/domain/entities/technician.dart';
import 'package:sistema_tickets_edis/domain/repositories/ticket_repository.dart';
import 'package:sistema_tickets_edis/domain/services/ticket_workflow_service.dart';

import '../fixtures/user_fixtures.dart';

class FakeLocalNotificationService extends LocalNotificationService {
  FakeLocalNotificationService() : super(FlutterLocalNotificationsPlugin());

  @override
  Future<void> initialize() async {}

  @override
  Future<void> showTicketCreated(Ticket ticket) async {}

  @override
  Future<void> showStatusChanged(Ticket ticket, TicketEvent event) async {}

  @override
  Future<void> showAssignment(Ticket ticket, String technicianName) async {}

  @override
  Future<void> scheduleReminder({
    required int ticketId,
    required DateTime when,
    String? message,
  }) async {}
}

class FakeAltaDocumentService extends AltaDocumentService {
  FakeAltaDocumentService()
    : super(
        directoryBuilder: () async =>
            await Directory.systemTemp.createTemp('alta_test'),
      );

  @override
  Future<AltaDocumentResult> generateRmFgDocuments(Ticket ticket) async {
    return AltaDocumentResult(
      pdfPath: '/tmp/${ticket.folio}.pdf',
      csvPath: '/tmp/${ticket.folio}.csv',
    );
  }
}

void main() {
  late AppDatabase database;
  late TicketRepository repository;
  late FakeLocalNotificationService notifications;
  late FakeAltaDocumentService altaDocuments;
  late TicketWorkflowService workflow;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
    notifications = FakeLocalNotificationService();
    altaDocuments = FakeAltaDocumentService();
    workflow = TicketWorkflowService();
    repository = TicketRepositoryImpl(
      database: database,
      workflowService: workflow,
      notificationService: notifications,
      altaDocumentService: altaDocuments,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('crea tickets y registra evento inicial', () async {
    final Ticket ticket = await repository.createTicket(
      TicketDraft(
        title: 'Prueba',
        description: 'Descripción',
        requester: buildUser(name: 'Usuario'),
        category: TicketCategory.soporteEdi,
      ),
    );

    expect(ticket.id, greaterThan(0));
    final List<TicketEvent> history = await repository
        .watchTicketHistory(ticket.id)
        .first;
    expect(history, hasLength(1));
    expect(history.first.type, TicketEventType.created);
  });

  test('actualiza estatus respetando el workflow', () async {
    final Ticket ticket = await repository.createTicket(
      TicketDraft(
        title: 'Cambio',
        description: 'Validar workflow',
        requester: buildUser(name: 'Supervisor'),
        category: TicketCategory.solicitudTi,
      ),
    );

    await repository.updateStatus(
      ticketId: ticket.id,
      nextStatus: TicketStatus.enRevision,
      author: 'Supervisor',
    );
    final Ticket updated = (await repository.findTicket(ticket.id))!;
    expect(updated.status, TicketStatus.enRevision);

    expect(
      repository.updateStatus(
        ticketId: ticket.id,
        nextStatus: TicketStatus.cerrado,
      ),
      throwsA(isA<Failure>()),
    );
  });

  test('genera documentos RM/FG y agrega evento', () async {
    final List<CatalogEntry> clientes = await repository.getCatalogEntries(
      CatalogType.cliente,
    );
    final List<CatalogEntry> destinos = await repository.getCatalogEntries(
      CatalogType.destino,
    );
    final List<CatalogEntry> materiales = await repository.getCatalogEntries(
      CatalogType.material,
    );
    final List<CatalogEntry> normas = await repository.getCatalogEntries(
      CatalogType.norma,
    );
    final List<CatalogEntry> quim = await repository.getCatalogEntries(
      CatalogType.propiedadesQuimicas,
    );
    final List<CatalogEntry> mec = await repository.getCatalogEntries(
      CatalogType.propiedadesMecanicas,
    );
    final List<CatalogEntry> partes = await repository.getCatalogEntries(
      CatalogType.numeroParte,
    );

    final Ticket ticket = await repository.createTicket(
      TicketDraft(
        title: 'Alta RM/FG',
        description: 'Generar documentos',
        requester: buildUser(name: 'Coordinador'),
        category: TicketCategory.altaNoParteRmFg,
        altaDetails: TicketAltaDetails(
          cliente: clientes.first,
          destino: destinos.first,
          material: materiales.first,
          norma: normas.first,
          propiedadesQuimicas: quim.first,
          propiedadesMecanicas: mec.first,
          numeroParte: partes.first,
        ),
      ),
    );

    final AltaDocumentResult result = await repository.generateAltaDocuments(
      ticket.id,
    );
    expect(result.pdfPath, contains('.pdf'));

    final List<TicketEvent> history = await repository
        .watchTicketHistory(ticket.id)
        .first;
    expect(
      history.where(
        (TicketEvent event) => event.type == TicketEventType.documentGenerated,
      ),
      isNotEmpty,
    );
  });

  test('resume métricas de reportes', () async {
    final Ticket ticketA = await repository.createTicket(
      TicketDraft(
        title: 'Ticket A',
        description: 'Reportes',
        requester: buildUser(name: 'Ana'),
        category: TicketCategory.incidenciaUsuario,
      ),
    );
    final Ticket ticketB = await repository.createTicket(
      TicketDraft(
        title: 'Ticket B',
        description: 'Reportes',
        requester: buildUser(name: 'Luis'),
        category: TicketCategory.soporteEdi,
      ),
    );

    final Technician technician =
        (await repository.watchTechnicians().first).first;
    await repository.assignTechnician(
      ticketId: ticketA.id,
      technician: technician,
    );
    await repository.updateStatus(
      ticketId: ticketA.id,
      nextStatus: TicketStatus.enRevision,
      author: 'Supervisor',
    );
    await repository.updateStatus(
      ticketId: ticketA.id,
      nextStatus: TicketStatus.enProceso,
      author: 'Supervisor',
    );
    await repository.updateStatus(
      ticketId: ticketA.id,
      nextStatus: TicketStatus.resuelto,
      author: 'Supervisor',
    );

    final ReportSummary summary = await repository.loadReportSummary();
    expect(summary.byCategory[ticketA.category], greaterThanOrEqualTo(1));
    expect(summary.byStatus[TicketStatus.resuelto], greaterThanOrEqualTo(1));
    expect(summary.byTechnician[technician], greaterThanOrEqualTo(1));
  });
}
