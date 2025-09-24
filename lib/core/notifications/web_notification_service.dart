import 'dart:async';
import 'dart:html' as html;

import 'package:sistema_tickets_edis/domain/entities/ticket.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket_event.dart';

import 'notification_service.dart';

class WebNotificationService implements NotificationService {
  final List<Timer> _timers = <Timer>[];

  bool get _supported => html.Notification.supported;

  bool get _permissionGranted => html.Notification.permission == 'granted';

  @override
  Future<void> initialize() async {
    if (!_supported) {
      return;
    }
    if (html.Notification.permission == 'default') {
      await html.Notification.requestPermission();
    }
  }

  @override
  Future<void> showTicketCreated(Ticket ticket) async {
    await _ensurePermission();
    _show(
      'Nuevo ticket ${ticket.folio}',
      '${ticket.requesterName}: ${ticket.title}',
    );
  }

  @override
  Future<void> showStatusChanged(Ticket ticket, TicketEvent event) async {
    await _ensurePermission();
    _show(
      'Ticket ${ticket.folio} ${ticket.status.label}',
      event.message,
    );
  }

  @override
  Future<void> showAssignment(Ticket ticket, String technicianName) async {
    await _ensurePermission();
    _show(
      'Asignado a $technicianName',
      'Ticket ${ticket.folio} asignado.',
    );
  }

  @override
  Future<void> scheduleReminder({
    required int ticketId,
    required DateTime when,
    String? message,
  }) async {
    if (!_supported) {
      return;
    }
    await _ensurePermission();
    if (!_permissionGranted) {
      return;
    }
    final Duration delay = when.difference(DateTime.now());
    if (delay.isNegative || delay.inSeconds == 0) {
      _show('Seguimiento ticket', message ?? 'Revisión pendiente del ticket #$ticketId');
      return;
    }
    _timers.add(
      Timer(delay, () {
        _show(
          'Seguimiento ticket',
          message ?? 'Revisión pendiente del ticket #$ticketId',
        );
      }),
    );
  }

  @override
  void registerFcmTokenHandler(Future<void> Function(String token) handler) {
    // No-op en web.
  }

  Future<void> _ensurePermission() async {
    if (!_supported) {
      return;
    }
    if (!_permissionGranted) {
      await html.Notification.requestPermission();
    }
  }

  void _show(String title, String body) {
    if (!_supported || !_permissionGranted) {
      return;
    }
    html.Notification(title, body: body);
  }
}
