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
    final String createdAtLabel =
        '${localizations.formatMediumDate(ticket.createdAt)} · ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(ticket.createdAt))}';
    final String updatedAtLabel =
        '${localizations.formatMediumDate(ticket.updatedAt)} · ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(ticket.updatedAt))}';
    final String? resolvedLabel = ticket.resolvedAt != null
        ? '${localizations.formatMediumDate(ticket.resolvedAt!)} · ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(ticket.resolvedAt!))}'
        : null;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            StatusChip(status: ticket.status),
                            _MetadataBadge(
                              icon: Icons.category_outlined,
                              label: ticket.category.label,
                              dense: true,
                              backgroundColor:
                                  scheme.secondaryContainer.withOpacity(0.6),
                              foregroundColor: scheme.onSecondaryContainer,
                            ),
                            if (ticket.isAltaRmFg)
                              _MetadataBadge(
                                icon: Icons.picture_as_pdf_outlined,
                                label: 'Alta RM/FG',
                                dense: true,
                                backgroundColor:
                                    scheme.tertiaryContainer.withOpacity(0.6),
                                foregroundColor: scheme.onTertiaryContainer,
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          ticket.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 208,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        _MetadataBadge(
                          icon: Icons.confirmation_number_outlined,
                          label: 'Folio ${ticket.folio}',
                          dense: true,
                          backgroundColor: scheme.primaryContainer,
                          foregroundColor: scheme.onPrimaryContainer,
                        ),
                        const SizedBox(height: 12),
                        _MetadataTile(
                          icon: Icons.calendar_month_outlined,
                          label: createdAtLabel,
                          foregroundColor: scheme.onSurfaceVariant,
                        ),
                        if (resolvedLabel != null) ...<Widget>[
                          const SizedBox(height: 6),
                          _MetadataTile(
                            icon: Icons.task_alt_outlined,
                            label: 'Resuelto $resolvedLabel',
                            foregroundColor: scheme.tertiary,
                            bold: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  _MetadataBadge(
                    icon: Icons.person_outline,
                    label: ticket.requesterName,
                  ),
                  if (ticket.assignedTechnician != null)
                    _MetadataBadge(
                      icon: Icons.engineering,
                      label: ticket.assignedTechnician!.name,
                    ),
                  _MetadataBadge(
                    icon: Icons.schedule_outlined,
                    label: 'Actualizado $updatedAtLabel',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                ticket.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetadataBadge extends StatelessWidget {
  const _MetadataBadge({
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.dense = false,
  });

  final IconData icon;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color bg = backgroundColor ?? scheme.surfaceVariant.withOpacity(0.4);
    final Color fg = foregroundColor ?? scheme.onSurfaceVariant;
    return Container(
      padding: dense
          ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(dense ? 16 : 20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetadataTile extends StatelessWidget {
  const _MetadataTile({
    required this.icon,
    required this.label,
    this.foregroundColor,
    this.bold = false,
  });

  final IconData icon;
  final String label;
  final Color? foregroundColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = foregroundColor ?? theme.colorScheme.onSurfaceVariant;
    final TextStyle? style = (bold ? theme.textTheme.labelLarge : theme.textTheme.labelMedium)
        ?.copyWith(
      color: color,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
    );
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 220),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: style,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
