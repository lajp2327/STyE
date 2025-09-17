import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:sistema_tickets_edis/domain/entities/ticket.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket_event.dart';

/// Wrapper around [FlutterLocalNotificationsPlugin] with domain-specific helpers.
class LocalNotificationService {
  LocalNotificationService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void> Function(String token)? onFcmToken;

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestSoundPermission: true,
          requestBadgePermission: true,
        );
    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );
    await _plugin.initialize(settings);
  }

  NotificationDetails _defaultDetails() {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'tickets_channel',
          'Tickets TI',
          importance: Importance.high,
          priority: Priority.high,
        );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentSound: true,
    );
    return const NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  Future<void> showTicketCreated(Ticket ticket) {
    return _plugin.show(
      ticket.id,
      'Nuevo ticket ${ticket.folio}',
      '${ticket.requesterName}: ${ticket.title}',
      _defaultDetails(),
    );
  }

  Future<void> showStatusChanged(Ticket ticket, TicketEvent event) {
    return _plugin.show(
      ticket.id * 100,
      'Ticket ${ticket.folio} ${ticket.status.label}',
      event.message,
      _defaultDetails(),
    );
  }

  Future<void> showAssignment(Ticket ticket, String technicianName) {
    return _plugin.show(
      ticket.id * 200,
      'Asignado a $technicianName',
      'Ticket ${ticket.folio} asignado.',
      _defaultDetails(),
    );
  }

  Future<void> scheduleReminder({
    required int ticketId,
    required DateTime when,
    String? message,
  }) {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(when, tz.local);
    return _plugin.zonedSchedule(
      ticketId * 300,
      'Seguimiento ticket',
      message ?? 'Revisión pendiente del ticket #$ticketId',
      scheduledDate,
      _defaultDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Stores a callback that will be triggered when an FCM token is available.
  void registerFcmTokenHandler(Future<void> Function(String token) handler) {
    onFcmToken = handler;
  }
}
