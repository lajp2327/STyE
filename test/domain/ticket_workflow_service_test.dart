import 'package:flutter_test/flutter_test.dart';

import 'package:sistema_tickets_edis/core/errors/failure.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket_event.dart';
import 'package:sistema_tickets_edis/domain/services/ticket_workflow_service.dart';

void main() {
  final TicketWorkflowService service = TicketWorkflowService();

  test('permite transiciones válidas', () {
    expect(
      service.canTransition(TicketStatus.nuevo, TicketStatus.enRevision),
      isTrue,
    );
    expect(
      service.canTransition(TicketStatus.enRevision, TicketStatus.enProceso),
      isTrue,
    );
  });

  test('lanza excepción en transición inválida', () {
    expect(
      () =>
          service.assertTransition(TicketStatus.nuevo, TicketStatus.enProceso),
      throwsA(isA<InvalidTicketTransitionFailure>()),
    );
  });

  test('calcula duraciones por estado', () {
    final DateTime start = DateTime(2024, 1, 1, 8, 0, 0);
    final List<TicketEvent> events = <TicketEvent>[
      TicketEvent(
        id: 1,
        ticketId: 1,
        type: TicketEventType.statusChanged,
        message: 'Nuevo → Revisión',
        author: 'tester',
        createdAt: start,
        metadata: <String, dynamic>{
          'from': TicketStatus.nuevo.name,
          'to': TicketStatus.enRevision.name,
        },
      ),
      TicketEvent(
        id: 2,
        ticketId: 1,
        type: TicketEventType.statusChanged,
        message: 'Revisión → Proceso',
        author: 'tester',
        createdAt: start.add(const Duration(hours: 2)),
        metadata: <String, dynamic>{
          'from': TicketStatus.enRevision.name,
          'to': TicketStatus.enProceso.name,
        },
      ),
      TicketEvent(
        id: 3,
        ticketId: 1,
        type: TicketEventType.statusChanged,
        message: 'Proceso → Resuelto',
        author: 'tester',
        createdAt: start.add(const Duration(hours: 5)),
        metadata: <String, dynamic>{
          'from': TicketStatus.enProceso.name,
          'to': TicketStatus.resuelto.name,
        },
      ),
    ];

    final Map<TicketStatus, Duration> durations = service.calculateDurations(
      events,
      closedAt: start.add(const Duration(hours: 8)),
    );

    expect(durations[TicketStatus.nuevo], anyOf(isNull, equals(Duration.zero)));
    expect(durations[TicketStatus.enRevision], const Duration(hours: 2));
    expect(durations[TicketStatus.enProceso], const Duration(hours: 3));
    expect(durations[TicketStatus.resuelto], const Duration(hours: 3));
  });
}
