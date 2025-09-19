import 'package:equatable/equatable.dart';

import 'package:sistema_tickets_edis/domain/entities/ticket.dart';
import 'package:sistema_tickets_edis/domain/value_objects/date_range.dart';

/// Filter parameters for ticket queries.
class TicketFilter extends Equatable {
  const TicketFilter({
    this.status,
    this.category,
    this.assignedTechnicianId,
    this.dateRange,
    this.requesterId,
  });

  final TicketStatus? status;
  final TicketCategory? category;
  final int? assignedTechnicianId;
  final DateRange? dateRange;
  final int? requesterId;

  TicketFilter copyWith({
    TicketStatus? status,
    TicketCategory? category,
    int? assignedTechnicianId,
    DateRange? dateRange,
    int? requesterId,
  }) {
    return TicketFilter(
      status: status ?? this.status,
      category: category ?? this.category,
      assignedTechnicianId: assignedTechnicianId ?? this.assignedTechnicianId,
      dateRange: dateRange ?? this.dateRange,
      requesterId: requesterId ?? this.requesterId,
    );
  }

  @override
  List<Object?> get props =>
      <Object?>[status, category, assignedTechnicianId, dateRange, requesterId];
}
