import 'package:flutter/material.dart';

import 'package:sistema_tickets_edis/domain/entities/ticket.dart';
import 'package:sistema_tickets_edis/features/shared/presentation/widgets/status_chip.dart';

class TicketCard extends StatelessWidget {
  const TicketCard({required this.ticket, required this.onTap, super.key});

  final Ticket ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          ticket.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            StatusChip(status: ticket.status, compact: true),
                            AbsorbPointer(
                              child: AssistChip(
                                onPressed: () {},
                                icon: const Icon(Icons.category_outlined),
                                label: Text(ticket.category.label),
                              ),
                            ),
                            AbsorbPointer(
                              child: InputChip(
                                onPressed: () {},
                                avatar: const Icon(Icons.person_outline, size: 18),
                                label: Text(ticket.requesterName),
                              ),
                            ),
                            if (ticket.assignedTechnician != null)
                              AbsorbPointer(
                                child: InputChip(
                                  onPressed: () {},
                                  avatar: const Icon(Icons.engineering, size: 18),
                                  label: Text(ticket.assignedTechnician!.name),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        'Folio ${ticket.folio}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        localizations.formatShortDate(ticket.createdAt),
                        style: theme.textTheme.labelMedium,
                      ),
                      Text(
                        localizations.formatTimeOfDay(
                          TimeOfDay.fromDateTime(ticket.createdAt),
                        ),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      if (ticket.resolvedAt != null) ...<Widget>[
                        const SizedBox(height: 8),
                        Text(
                          'Resuelto ${localizations.formatShortDate(ticket.resolvedAt!)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.tertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                ticket.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
