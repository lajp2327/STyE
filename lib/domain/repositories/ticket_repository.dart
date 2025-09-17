import 'package:sistema_tickets_edis/domain/entities/alta_document_result.dart';
import 'package:sistema_tickets_edis/domain/entities/catalog.dart';
import 'package:sistema_tickets_edis/domain/entities/report_summary.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket_event.dart';
import 'package:sistema_tickets_edis/domain/entities/technician.dart';
import 'package:sistema_tickets_edis/domain/value_objects/ticket_filters.dart';

/// Contract for ticket persistence and querying.
abstract class TicketRepository {
  Stream<List<Ticket>> watchTickets({TicketFilter filter = const TicketFilter()});

  Future<Ticket> createTicket(TicketDraft draft);

  Future<Ticket?> findTicket(int id);

  Stream<List<TicketEvent>> watchTicketHistory(int ticketId);

  Future<void> addComment({
    required int ticketId,
    required String message,
    required String author,
    Map<String, dynamic>? metadata,
  });

  Future<void> assignTechnician({
    required int ticketId,
    required Technician technician,
    String? comment,
  });

  Future<void> updateStatus({
    required int ticketId,
    required TicketStatus nextStatus,
    String author,
    String? comment,
  });

  Future<AltaDocumentResult> generateAltaDocuments(int ticketId);

  Future<List<CatalogEntry>> getCatalogEntries(CatalogType type);

  Stream<List<Technician>> watchTechnicians();

  Future<ReportSummary> loadReportSummary({TicketFilter? filter});
}
