import 'package:sistema_tickets_edis/domain/entities/ticket.dart';
import 'package:sistema_tickets_edis/domain/repositories/ticket_repository.dart';

/// Advances the workflow for a ticket.
class UpdateTicketStatus {
  const UpdateTicketStatus(this._repository);

  final TicketRepository _repository;

  Future<void> call({
    required int ticketId,
    required TicketStatus nextStatus,
    String author = 'Sistema',
    String? comment,
  }) {
    return _repository.updateStatus(
      ticketId: ticketId,
      nextStatus: nextStatus,
      author: author,
      comment: comment,
    );
  }
}
