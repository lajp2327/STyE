import 'package:flutter/material.dart';

import 'package:sistema_tickets_edis/features/shared/presentation/widgets/empty_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        const SliverAppBar.large(title: Text('Ajustes')),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: const EmptyState(
              title: 'Ajustes en desarrollo',
              message: 'Próximamente podrás configurar preferencias y notificaciones.',
              icon: Icons.tune,
            ),
          ),
        ),
      ],
    );
  }
}
