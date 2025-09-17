import 'package:equatable/equatable.dart';

import 'package:sistema_tickets_edis/domain/entities/ticket.dart';
import 'package:sistema_tickets_edis/domain/entities/technician.dart';

/// Aggregated reporting information for the dashboard.
class ReportSummary extends Equatable {
  const ReportSummary({
    required this.byCategory,
    required this.byStatus,
    required this.byTechnician,
    required this.averageResolution,
    required this.statusDurations,
  });

  final Map<TicketCategory, int> byCategory;
  final Map<TicketStatus, int> byStatus;
  final Map<Technician, int> byTechnician;
  final Duration? averageResolution;
  final Map<TicketStatus, Duration> statusDurations;

  @override
  List<Object?> get props => <Object?>[
        byCategory,
        byStatus,
        byTechnician,
        averageResolution,
        statusDurations,
      ];
}
