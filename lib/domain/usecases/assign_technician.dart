import 'package:sistema_tickets_edis/domain/entities/technician.dart';
import 'package:sistema_tickets_edis/domain/repositories/ticket_repository.dart';

/// Assigns a technician to a ticket.
class AssignTechnician {
  const AssignTechnician(this._repository);

  final TicketRepository _repository;

  Future<void> call({
    required int ticketId,
    required Technician technician,
    String? comment,
  }) {
    return _repository.assignTechnician(
      ticketId: ticketId,
      technician: technician,
      comment: comment,
    );
  }
}
