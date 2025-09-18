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

class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool isTicketsTab = navigationShell.currentIndex == 0;
    final bool fabVisible =
        isTicketsTab && ref.watch(dashboardFabVisibilityProvider);

    return Scaffold(
      body: navigationShell,
      floatingActionButton: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(right: 12, bottom: 16),
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          offset: fabVisible ? Offset.zero : const Offset(0, 1.4),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            opacity: fabVisible ? 1 : 0,
            child: IgnorePointer(
              ignoring: !fabVisible,
              child: FloatingActionButton.extended(
                onPressed: () => context.go('/tickets/new'),
                icon: const Icon(
                  Icons.add,
                  semanticLabel: 'Crear ticket',
                ),
                label: const Text('Nuevo ticket'),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: NavigationBar(
                height: 70,
                backgroundColor: Colors.transparent,
                indicatorColor: theme.colorScheme.primary.withOpacity(0.14),
                selectedIndex: navigationShell.currentIndex,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                onDestinationSelected: (int index) {
                  navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  );
                },
                destinations: const <NavigationDestination>[
                  NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard_rounded),
                    label: 'Tickets',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.add_circle_outline),
                    selectedIcon: Icon(Icons.add_circle),
                    label: 'Nuevo',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.stacked_bar_chart_outlined),
                    selectedIcon: Icon(Icons.stacked_bar_chart),
                    label: 'Reportes',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings_rounded),
                    label: 'Ajustes',
                  ),
                ],
              ),
            ),
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
                    _buildAnimatedPage<void>(
                      state.pageKey,
                      const TicketDashboardPage(),
                    ),
                routes: <RouteBase>[
                  GoRoute(
                    path: ':id',
                    name: 'ticket-detail',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (
                      BuildContext context,
                      GoRouterState state,
                    ) {
                      final int ticketId = int.parse(
                        state.pathParameters['id']!,
                      );
                      return _buildAnimatedPage<void>(
                        state.pageKey,
                        TicketDetailPage(ticketId: ticketId),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/tickets/new',
                name: 'ticket-new',
                pageBuilder: (BuildContext context, GoRouterState state) =>
                    _buildAnimatedPage<void>(
                  state.pageKey,
                  const TicketFormPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/reports',
                name: 'reports',
                pageBuilder: (BuildContext context, GoRouterState state) =>
                    _buildAnimatedPage<void>(
                  state.pageKey,
                  const ReportPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/settings',
                name: 'settings',
                pageBuilder: (BuildContext context, GoRouterState state) =>
                    _buildAnimatedPage<void>(
                  state.pageKey,
                  const SettingsPage(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

CustomTransitionPage<T> _buildAnimatedPage<T>(
  LocalKey key,
  Widget child,
) {
  return CustomTransitionPage<T>(
    key: key,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    child: child,
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      final CurvedAnimation curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.02),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}
