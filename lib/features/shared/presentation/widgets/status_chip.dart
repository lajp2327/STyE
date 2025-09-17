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
          fontWeight: FontWeight.w700,
          color: statusColor,
        );
    return Chip(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 6 : 10,
      ),
      avatar: Icon(
        Icons.brightness_1,
        size: compact ? 10 : 12,
        color: statusColor,
        semanticLabel: 'Estado ${status.label}',
      ),
      side: BorderSide(color: statusColor.withOpacity(0.3)),
      backgroundColor: statusColor.withOpacity(0.14),
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
