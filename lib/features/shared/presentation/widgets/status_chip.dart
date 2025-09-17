import 'package:flutter/material.dart';

import 'package:sistema_tickets_edis/domain/entities/ticket.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({required this.status, this.compact = false, super.key});

  final TicketStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color statusColor = statusColorFor(status, scheme);
    final TextStyle? style = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: statusColor,
        );
    return Chip(
      visualDensity:
          compact ? VisualDensity.compact : VisualDensity.comfortable,
      side: BorderSide(color: statusColor.withOpacity(0.4)),
      backgroundColor: statusColor.withOpacity(0.12),
      label: Text(status.label, style: style),
    );
  }
}

Color statusColorFor(TicketStatus status, ColorScheme scheme) {
  switch (status) {
    case TicketStatus.nuevo:
      return scheme.primary;
    case TicketStatus.enRevision:
      return scheme.tertiary;
    case TicketStatus.enProceso:
      return scheme.secondary;
    case TicketStatus.resuelto:
      return scheme.inversePrimary;
    case TicketStatus.cerrado:
      return scheme.outline;
  }
}
