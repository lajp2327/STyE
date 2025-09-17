import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sistema_tickets_edis/features/reports/presentation/views/report_page.dart';
import 'package:sistema_tickets_edis/features/settings/presentation/views/settings_page.dart';
import 'package:sistema_tickets_edis/features/ticket_dashboard/presentation/views/ticket_dashboard_page.dart';
import 'package:sistema_tickets_edis/features/ticket_detail/presentation/views/ticket_detail_page.dart';
import 'package:sistema_tickets_edis/features/ticket_form/presentation/views/ticket_form_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      floatingActionButton: navigationShell.currentIndex == 0
          ? SafeArea(
              minimum: const EdgeInsets.only(bottom: 16, right: 16),
              top: false,
              child: FloatingActionButton.extended(
                onPressed: () => context.go('/tickets/new'),
                icon: const Icon(
                  Icons.add,
                  semanticLabel: 'Crear ticket',
                ),
                label: const Text('Nuevo ticket'),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (int index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.confirmation_number_outlined),
                selectedIcon: Icon(Icons.confirmation_number),
                label: 'Tickets',
              ),
              NavigationDestination(
                icon: Icon(Icons.insert_chart_outlined),
                selectedIcon: Icon(Icons.insert_chart),
                label: 'Reportes',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Ajustes',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/tickets',
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) =>
            AppShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: '/tickets',
                name: 'dashboard',
                pageBuilder: (BuildContext context, GoRouterState state) =>
                    const NoTransitionPage<void>(child: TicketDashboardPage()),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'new',
                    name: 'ticket-new',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (BuildContext context, GoRouterState state) =>
                        const TicketFormPage(),
                  ),
                  GoRoute(
                    path: ':id',
                    name: 'ticket-detail',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (BuildContext context, GoRouterState state) {
                      final int ticketId = int.parse(
                        state.pathParameters['id']!,
                      );
                      return TicketDetailPage(ticketId: ticketId);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/reports',
                name: 'reports',
                pageBuilder: (BuildContext context, GoRouterState state) =>
                    const NoTransitionPage<void>(child: ReportPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/settings',
                name: 'settings',
                pageBuilder: (BuildContext context, GoRouterState state) =>
                    const NoTransitionPage<void>(child: SettingsPage()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
