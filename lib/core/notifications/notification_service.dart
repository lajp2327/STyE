import 'package:sistema_tickets_edis/domain/entities/ticket.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket_event.dart';

/// Contrato genérico para enviar notificaciones al usuario final.
abstract class NotificationService {
  Future<void> initialize();

  Future<void> showTicketCreated(Ticket ticket);

  Future<void> showStatusChanged(Ticket ticket, TicketEvent event);

  Future<void> showAssignment(Ticket ticket, String technicianName);

  Future<void> scheduleReminder({
    required int ticketId,
    required DateTime when,
    String? message,
  });

  void registerFcmTokenHandler(Future<void> Function(String token) handler) {}
}
