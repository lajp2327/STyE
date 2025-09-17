import 'package:sistema_tickets_edis/domain/entities/ticket.dart';
import 'package:sistema_tickets_edis/domain/repositories/ticket_repository.dart';

/// Use case that persists a new ticket and its initial event.
class CreateTicket {
  const CreateTicket(this._repository);

  final TicketRepository _repository;

  Future<Ticket> call(TicketDraft draft) => _repository.createTicket(draft);
}
