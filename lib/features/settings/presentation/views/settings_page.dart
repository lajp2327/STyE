import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sistema_tickets_edis/app/providers.dart';
import 'package:sistema_tickets_edis/domain/entities/session_user.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SessionUser? session = ref.watch(currentSessionProvider);
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return CustomScrollView(
      slivers: <Widget>[
        const SliverAppBar.large(title: Text('Ajustes')),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: scheme.primaryContainer,
                      child: Icon(
                        Icons.person_outline,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(session?.user.name ?? 'Invitado'),
                    subtitle: Text(session?.user.email ?? 'Sin correo registrado'),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Cerrar sesión'),
                    subtitle: const Text('Termina tu sesión y vuelve al inicio'),
                    onTap: () async {
                      await ref.read(authRepositoryProvider).logout();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
