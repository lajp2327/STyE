import 'package:sistema_tickets_edis/domain/repositories/ticket_repository.dart';

/// Appends a comment to the ticket history.
class AddTicketComment {
  const AddTicketComment(this._repository);

  final TicketRepository _repository;

  Future<void> call({
    required int ticketId,
    required String message,
    required String author,
    Map<String, dynamic>? metadata,
  }) {
    return _repository.addComment(
      ticketId: ticketId,
      message: message,
      author: author,
      metadata: metadata,
    );
  }
}
