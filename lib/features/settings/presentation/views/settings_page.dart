import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sistema_tickets_edis/app/providers.dart';
import 'package:sistema_tickets_edis/domain/entities/session_user.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  void _showComingSoon(BuildContext context) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Pronto podrás configurar esta opción desde la aplicación.'),
      ),
    );
  }

  Widget _buildCapabilityChip(
    ThemeData theme,
    Color accent,
    IconData icon,
    String label,
  ) {
    return Chip(
      avatar: Icon(icon, size: 18, color: accent),
      label: Text(label),
      backgroundColor: accent.withOpacity(0.16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      labelStyle: theme.textTheme.bodySmall?.copyWith(
        color: accent,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SessionUser? session = ref.watch(currentSessionProvider);
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final bool darkModeEnabled = themeMode == ThemeMode.dark;
    final bool isAdmin = session?.role.isAdmin ?? false;
    final Color accent = isAdmin ? scheme.primary : scheme.secondary;
    final Color accentContainer = isAdmin ? scheme.primaryContainer : scheme.secondaryContainer;
    final IconData roleIcon = isAdmin ? Icons.shield_person_outlined : Icons.badge_outlined;
    final String roleLabel = isAdmin ? 'Administrador TI' : 'Usuario';

    final List<Widget> capabilityChips = isAdmin
        ? <Widget>[
            _buildCapabilityChip(
              theme,
              accent,
              Icons.engineering_outlined,
              'Gestiona asignaciones',
            ),
            _buildCapabilityChip(
              theme,
              accent,
              Icons.query_stats_outlined,
              'Accede a reportes globales',
            ),
          ]
        : <Widget>[
            _buildCapabilityChip(
              theme,
              accent,
              Icons.inbox_outlined,
              'Visualiza tus solicitudes',
            ),
            _buildCapabilityChip(
              theme,
              accent,
              Icons.notifications_active_outlined,
              'Recibe avisos de avance',
            ),
          ];

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
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          accentContainer.withOpacity(0.6),
                          accent.withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: scheme.surface,
                              child: Icon(roleIcon, color: accent, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    session?.user.name ?? 'Invitado',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    (session?.user.email ?? '').isNotEmpty
                                        ? session!.user.email!
                                        : 'Sin correo registrado',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.surface.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(roleIcon, size: 18, color: accent),
                                  const SizedBox(width: 6),
                                  Text(
                                    roleLabel,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isAdmin
                              ? 'Coordina la mesa de ayuda, asigna técnicos y modifica estados en tiempo real.'
                              : 'Consulta y da seguimiento a tus solicitudes desde un panel simplificado.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface.withOpacity(0.9),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: capabilityChips,
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: <Widget>[
                            OutlinedButton.icon(
                              onPressed: () => _showComingSoon(context),
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Editar perfil'),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: () => _showComingSoon(context),
                              icon: const Icon(Icons.history_toggle_off_outlined),
                              label: const Text('Actividad reciente'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Column(
                    children: <Widget>[
                      SwitchListTile.adaptive(
                        value: darkModeEnabled,
                        onChanged: (bool value) =>
                            ref.read(themeModeProvider.notifier).toggleDarkMode(value),
                        secondary: Icon(
                          darkModeEnabled
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                        ),
                        title: const Text('Modo oscuro'),
                        subtitle: const Text('Optimiza el brillo para ambientes con poca luz.'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.notifications_active_outlined),
                        title: const Text('Notificaciones'),
                        subtitle: const Text('Personaliza avisos y recordatorios'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _showComingSoon(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.language_outlined),
                        title: const Text('Idioma y región'),
                        subtitle: const Text('Español (México)'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _showComingSoon(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: const Icon(Icons.help_center_outlined),
                        title: const Text('Centro de ayuda'),
                        subtitle: const Text('Guías rápidas y preguntas frecuentes'),
                        trailing: const Icon(Icons.open_in_new_rounded),
                        onTap: () => _showComingSoon(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.mail_outline),
                        title: const Text('Escríbenos a soporte'),
                        subtitle: const Text('soporte@mmpg.com.mx'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _showComingSoon(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  color: scheme.errorContainer.withOpacity(0.4),
                  child: ListTile(
                    leading: Icon(Icons.logout, color: scheme.error),
                    title: Text(
                      'Cerrar sesión',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: const Text('Termina tu sesión y vuelve al inicio'),
                    trailing: Icon(Icons.arrow_forward_ios_rounded, color: scheme.error),
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
