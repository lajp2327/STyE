import 'package:flutter/material.dart';

import 'package:sistema_tickets_edis/domain/entities/ticket.dart';

Future<TicketCategory?> showNewTicketEntrySheet(BuildContext context) {
  return showModalBottomSheet<TicketCategory>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: false,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (BuildContext context) => const _TicketEntrySheet(),
  );
}

class _TicketEntrySheet extends StatelessWidget {
  const _TicketEntrySheet();

  static const List<_TicketEntryDefinition> _definitions =
      <_TicketEntryDefinition>[
    _TicketEntryDefinition(
      category: TicketCategory.altaNoParteRmFg,
      icon: Icons.inventory_2_outlined,
      title: 'Alta de número de parte (RM/FG)',
      description:
          'Captura los datos técnicos para solicitar un nuevo número de parte.',
    ),
    _TicketEntryDefinition(
      category: TicketCategory.soporteEdi,
      icon: Icons.cloud_sync_outlined,
      title: 'Soporte EDI',
      description:
          'Reporta incidencias con transacciones o integraciones electrónicas.',
    ),
    _TicketEntryDefinition(
      category: TicketCategory.incidenciaUsuario,
      icon: Icons.report_problem_outlined,
      title: 'Incidencia de usuario',
      description:
          '¿Algo dejó de funcionar? Registra la incidencia y el equipo te apoyará.',
    ),
    _TicketEntryDefinition(
      category: TicketCategory.solicitudTi,
      icon: Icons.handyman_outlined,
      title: 'Solicitud TI',
      description:
          'Solicita accesos, configuraciones o acompañamiento del equipo de TI.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nuevo ticket',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 6),
            Text(
              'Selecciona el tipo de solicitud para personalizar la captura.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            ..._definitions.map(
              (_TicketEntryDefinition definition) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: _TicketEntryOption(
                  definition: definition,
                  accent: _accentColorFor(definition.category, scheme),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _accentColorFor(TicketCategory category, ColorScheme scheme) {
    switch (category) {
      case TicketCategory.altaNoParteRmFg:
        return scheme.primary;
      case TicketCategory.soporteEdi:
        return scheme.tertiary;
      case TicketCategory.incidenciaUsuario:
        return scheme.error;
      case TicketCategory.solicitudTi:
        return scheme.secondary;
    }
  }
}

class _TicketEntryDefinition {
  const _TicketEntryDefinition({
    required this.category,
    required this.icon,
    required this.title,
    required this.description,
  });

  final TicketCategory category;
  final IconData icon;
  final String title;
  final String description;
}

class _TicketEntryOption extends StatelessWidget {
  const _TicketEntryOption({
    required this.definition,
    required this.accent,
  });

  final _TicketEntryDefinition definition;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.of(context).pop(definition.category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: scheme.surfaceVariant.withOpacity(0.22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withOpacity(0.45), width: 1.2),
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(definition.icon, color: accent, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    definition.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    definition.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
