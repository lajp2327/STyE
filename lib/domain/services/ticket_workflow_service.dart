import 'package:collection/collection.dart';

import 'package:sistema_tickets_edis/core/errors/failure.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket_event.dart';

/// Encapsulates workflow rules and analytics for ticket life cycle.
class TicketWorkflowService {
  TicketWorkflowService();

  final Map<TicketStatus, Set<TicketStatus>> _transitions = <TicketStatus, Set<TicketStatus>>{
    TicketStatus.nuevo: <TicketStatus>{TicketStatus.enRevision},
    TicketStatus.enRevision: <TicketStatus>{TicketStatus.enProceso, TicketStatus.resuelto},
    TicketStatus.enProceso: <TicketStatus>{TicketStatus.enRevision, TicketStatus.resuelto},
    TicketStatus.resuelto: <TicketStatus>{TicketStatus.enProceso, TicketStatus.cerrado},
    TicketStatus.cerrado: const <TicketStatus>{},
  };

  bool canTransition(TicketStatus from, TicketStatus to) => _transitions[from]?.contains(to) ?? false;

  void assertTransition(TicketStatus from, TicketStatus to) {
    if (!canTransition(from, to)) {
      throw InvalidTicketTransitionFailure(from: from.name, to: to.name);
    }
  }

  /// Computes duration spent in each status based on event history.
  Map<TicketStatus, Duration> calculateDurations(List<TicketEvent> events, {DateTime? closedAt}) {
    if (events.isEmpty) {
      return <TicketStatus, Duration>{};
    }
    final List<TicketEvent> sorted = events.sorted((TicketEvent a, TicketEvent b) => a.createdAt.compareTo(b.createdAt));
    final Map<TicketStatus, Duration> totals = <TicketStatus, Duration>{};

    TicketStatus? currentStatus;
    DateTime? currentStart;

    for (final TicketEvent event in sorted) {
      if (event.type == TicketEventType.statusChanged) {
        final String? previous = event.metadata['from'] as String?;
        final String? next = event.metadata['to'] as String?;
        if (previous != null && currentStatus == null) {
          currentStatus = TicketStatus.fromName(previous);
          currentStart = event.createdAt;
        }
        if (currentStatus != null && currentStart != null) {
          final Duration elapsed = event.createdAt.difference(currentStart);
          totals[currentStatus] = (totals[currentStatus] ?? Duration.zero) + elapsed;
        }
        if (next != null) {
          currentStatus = TicketStatus.fromName(next);
          currentStart = event.createdAt;
        }
      }
    }

    if (currentStatus != null && currentStart != null) {
      final DateTime end = closedAt ?? sorted.last.createdAt;
      final Duration elapsed = end.difference(currentStart);
      totals[currentStatus] = (totals[currentStatus] ?? Duration.zero) + elapsed;
    }
    return totals;
  }

  /// Suggests the next statuses available from the given state.
  Iterable<TicketStatus> nextOptions(TicketStatus status) => _transitions[status] ?? const <TicketStatus>{};
}
