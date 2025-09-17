import 'package:sistema_tickets_edis/domain/entities/alta_document_result.dart';
import 'package:sistema_tickets_edis/domain/repositories/ticket_repository.dart';

/// Generates RM/FG artifacts for the provided ticket.
class GenerateRmFgDocuments {
  const GenerateRmFgDocuments(this._repository);

  final TicketRepository _repository;

  Future<AltaDocumentResult> call(int ticketId) => _repository.generateAltaDocuments(ticketId);
}
