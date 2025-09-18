import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sistema_tickets_edis/app/providers.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket.dart';
import 'package:sistema_tickets_edis/domain/entities/technician.dart';
import 'package:sistema_tickets_edis/domain/value_objects/ticket_filters.dart';
import 'package:sistema_tickets_edis/features/shared/presentation/widgets/empty_state.dart';
import 'package:sistema_tickets_edis/features/shared/presentation/widgets/error_card.dart';
import 'package:sistema_tickets_edis/features/shared/presentation/widgets/shimmer_placeholder.dart';
import 'package:sistema_tickets_edis/features/shared/presentation/widgets/ticket_card.dart';
import 'package:sistema_tickets_edis/features/ticket_dashboard/presentation/controllers/ticket_list_controller.dart';

final dashboardFabVisibilityProvider =
    StateProvider<bool>((StateProviderRef<bool> ref) => true);

final techniciansProvider = StreamProvider<List<Technician>>((ref) {
  final repository = ref.watch(ticketRepositoryProvider);
  return repository.watchTechnicians();
});

class TicketDashboardPage extends ConsumerStatefulWidget {
  const TicketDashboardPage({super.key});

  @override
  ConsumerState<TicketDashboardPage> createState() =>
      _TicketDashboardPageState();
}

class _TicketDashboardPageState extends ConsumerState<TicketDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(dashboardFabVisibilityProvider.notifier).state = true;
    });
  }

  bool _handleScrollNotification(UserScrollNotification notification) {
    final ScrollDirection direction = notification.direction;
    final StateController<bool> controller =
        ref.read(dashboardFabVisibilityProvider.notifier);

    if (direction == ScrollDirection.reverse && controller.state) {
      controller.state = false;
    } else if (direction == ScrollDirection.forward && !controller.state) {
      controller.state = true;
    } else if (direction == ScrollDirection.idle &&
        notification.metrics.extentBefore <= 0 &&
        !controller.state) {
      controller.state = true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Ticket>> ticketsAsync = ref.watch(
      ticketListControllerProvider,
    );
    final TicketFilter filter = ref.watch(ticketFilterProvider);
    final AsyncValue<List<Technician>> techniciansAsync = ref.watch(
      techniciansProvider,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isTablet = constraints.maxWidth >= 600;
        final List<Widget> slivers = <Widget>[
          SliverAppBar.large(
            title: const Text('Tickets TI'),
            actions: <Widget>[
              IconButton(
                tooltip: 'Recargar tickets',
                onPressed: () => ref.invalidate(ticketListControllerProvider),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ];

        if (isTablet) {
          slivers.add(
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              sliver: SliverToBoxAdapter(
                child: _WideDashboardSection(
                  ticketsAsync: ticketsAsync,
                  filter: filter,
                  techniciansAsync: techniciansAsync,
                ),
              ),
            ),
          );
        } else {
          slivers
            ..add(
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: ticketsAsync.when(
                      data: (List<Ticket> tickets) => _TicketMetrics(
                        key: ValueKey<int>(tickets.length),
                        tickets: tickets,
                      ),
                      loading: () => const _MetricsShimmer(
                        key: ValueKey<String>('metrics-loading'),
                      ),
                      error: (Object error, StackTrace stackTrace) => ErrorCard(
                        key: const ValueKey<String>('metrics-error'),
                        message: 'Error al cargar tickets: $error',
                        onRetry: () => ref.invalidate(ticketListControllerProvider),
                      ),
                    ),
                  ),
                ),
              ),
            )
            ..add(
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                sliver: SliverToBoxAdapter(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _FilterSection(
                        filter: filter,
                        techniciansAsync: techniciansAsync,
                      ),
                    ),
                  ),
                ),
              ),
            )
            ..add(_TicketsSliver(ticketsAsync: ticketsAsync));
        }

        return NotificationListener<UserScrollNotification>(
          onNotification: _handleScrollNotification,
          child: CustomScrollView(
            slivers: slivers,
          ),
        );
      },
    );
  }
}

class _WideDashboardSection extends ConsumerWidget {
  const _WideDashboardSection({
    required this.ticketsAsync,
    required this.filter,
    required this.techniciansAsync,
  });

  final AsyncValue<List<Ticket>> ticketsAsync;
  final TicketFilter filter;
  final AsyncValue<List<Technician>> techniciansAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: ticketsAsync.when(
        data: (List<Ticket> tickets) {
          return Row(
            key: ValueKey<int>(tickets.length),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _TicketMetrics(tickets: tickets),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: _FilterSection(
                          filter: filter,
                          techniciansAsync: techniciansAsync,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _TicketListPanel(tickets: tickets),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => Row(
          key: const ValueKey<String>('dashboard-loading'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
            SizedBox(width: 360, child: _MetricsShimmer()),
            SizedBox(width: 24),
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: _TicketListShimmer(),
                ),
              ),
            ),
          ],
        ),
        error: (Object error, StackTrace stackTrace) => ErrorCard(
          key: const ValueKey<String>('dashboard-error'),
          message: 'Error al cargar tickets: $error',
          onRetry: () => ref.invalidate(ticketListControllerProvider),
        ),
      ),
    );
  }
}

class _TicketsSliver extends StatelessWidget {
  const _TicketsSliver({required this.ticketsAsync});

  final AsyncValue<List<Ticket>> ticketsAsync;

  @override
  Widget build(BuildContext context) {
    return ticketsAsync.when(
      data: (List<Ticket> tickets) {
        if (tickets.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                  child: EmptyState(
                    title: 'Sin tickets registrados',
                    message:
                        'No hay tickets registrados. Crea el primero desde el botón “Nuevo ticket”.',
                    icon: Icons.support_agent_outlined,
                    actionLabel: 'Nuevo ticket',
                    onAction: () => context.go('/tickets/new'),
                  ),
                ),
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final Ticket ticket = tickets[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == tickets.length - 1 ? 0 : 16,
                  ),
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey<int>(ticket.id),
                    tween: Tween<double>(begin: 28, end: 0),
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    builder: (BuildContext context, double value, Widget? child) {
                      final double opacity = 1 - (value / 28);
                      return Opacity(
                        opacity: opacity.clamp(0, 1),
                        child: Transform.translate(
                          offset: Offset(0, value),
                          child: child,
                        ),
                      );
                    },
                    child: TicketCard(
                      ticket: ticket,
                      onTap: () => context.go('/tickets/${ticket.id}'),
                    ),
                  ),
                );
              },
              childCount: tickets.length,
            ),
          ),
        );
      },
      loading: () => const SliverPadding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
        sliver: SliverToBoxAdapter(child: _TicketListShimmer()),
      ),
      error: (Object error, StackTrace stackTrace) => SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: ErrorCard(
            message: 'Error al cargar tickets: $error',
          ),
        ),
      ),
    );
  }
}

class _TicketListPanel extends StatelessWidget {
  const _TicketListPanel({required this.tickets});

  final List<Ticket> tickets;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: tickets.isEmpty
          ? EmptyState(
              key: const ValueKey<String>('empty-wide'),
              title: 'Sin tickets registrados',
              message:
                  'Crea un ticket con el botón “Nuevo ticket” para comenzar a dar seguimiento.',
              icon: Icons.support_agent_outlined,
              actionLabel: 'Nuevo ticket',
              onAction: () => context.go('/tickets/new'),
            )
          : ListView.separated(
              key: ValueKey<int>(tickets.length),
              padding: const EdgeInsets.symmetric(vertical: 4),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tickets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (BuildContext context, int index) {
                final Ticket ticket = tickets[index];
                return TicketCard(
                  ticket: ticket,
                  onTap: () => context.go('/tickets/${ticket.id}'),
                );
              },
            ),
    );
  }
}

class _FilterSection extends ConsumerWidget {
  const _FilterSection({
    required this.filter,
    required this.techniciansAsync,
  });

  final TicketFilter filter;
  final AsyncValue<List<Technician>> techniciansAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool hasActiveFilters = filter.status != null ||
        filter.category != null ||
        filter.assignedTechnicianId != null;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final int columns;
        if (availableWidth >= 960) {
          columns = 3;
        } else if (availableWidth >= 640) {
          columns = 2;
        } else {
          columns = 1;
        }
        final double spacing = 16;
        final double safeWidth = availableWidth.isFinite
            ? availableWidth
            : MediaQuery.of(context).size.width;
        final double columnWidth = columns == 1
            ? safeWidth
            : (safeWidth - (columns - 1) * spacing) / columns;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Filtros',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (hasActiveFilters)
                  TextButton.icon(
                    onPressed: () =>
                        ref.read(ticketFilterProvider.notifier).state =
                            const TicketFilter(),
                    icon: const Icon(Icons.filter_alt_off_outlined),
                    label: const Text('Limpiar'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: <Widget>[
                _FilterGroup(
                  width: columnWidth,
                  label: 'Estado',
                  child: SizedBox(
                    width: columnWidth,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: SegmentedButton<TicketStatus>(
                        segments: TicketStatus.values
                            .map(
                              (TicketStatus status) => ButtonSegment<TicketStatus>(
                                value: status,
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(_statusIcon(status), size: 18),
                                    const SizedBox(width: 6),
                                    Text(status.label),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        emptySelectionAllowed: true,
                        showSelectedIcon: false,
                        selected: filter.status != null
                            ? <TicketStatus>{filter.status!}
                            : <TicketStatus>{},
                        onSelectionChanged: (Set<TicketStatus> selected) {
                          ref.read(ticketFilterProvider.notifier).state =
                              filter.copyWith(
                            status: selected.isEmpty ? null : selected.first,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                _FilterGroup(
                  width: columnWidth,
                  label: 'Categoría',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TicketCategory.values
                        .map(
                          (TicketCategory category) => FilterChip(
                            avatar: Icon(_categoryIcon(category), size: 18),
                            label: Text(category.label),
                            selected: filter.category == category,
                            onSelected: (bool value) {
                              ref.read(ticketFilterProvider.notifier).state =
                                  filter.copyWith(
                                category: value ? category : null,
                              );
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
                _FilterGroup(
                  width: columnWidth,
                  label: 'Técnico asignado',
                  child: techniciansAsync.when(
                    data: (List<Technician> technicians) {
                      final List<DropdownMenuItem<int?>> items =
                          <DropdownMenuItem<int?>>[
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Todos los técnicos'),
                        ),
                        ...technicians.map(
                          (Technician tech) => DropdownMenuItem<int?>(
                            value: tech.id,
                            child: Text(tech.name),
                          ),
                        ),
                      ];
                      return DropdownButtonFormField<int?>(
                        value: filter.assignedTechnicianId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Selecciona un técnico',
                          prefixIcon: Icon(Icons.engineering),
                        ),
                        items: items,
                        onChanged: (int? value) {
                          ref.read(ticketFilterProvider.notifier).state =
                              filter.copyWith(assignedTechnicianId: value);
                        },
                      );
                    },
                    loading: () => const _DropdownShimmer(),
                    error: (Object error, StackTrace stackTrace) => ErrorCard(
                      message: 'Error al cargar técnicos: $error',
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _FilterGroup extends StatelessWidget {
  const _FilterGroup({
    required this.label,
    required this.child,
    required this.width,
  });

  final String label;
  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _TicketMetrics extends StatelessWidget {
  const _TicketMetrics({required this.tickets, super.key});

  final List<Ticket> tickets;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final int newCount = tickets
        .where((Ticket ticket) => ticket.status == TicketStatus.nuevo)
        .length;
    final int inProgressCount = tickets
        .where(
          (Ticket ticket) =>
              ticket.status == TicketStatus.enProceso ||
              ticket.status == TicketStatus.enRevision,
        )
        .length;
    final int closedCount = tickets
        .where(
          (Ticket ticket) =>
              ticket.status == TicketStatus.cerrado ||
              ticket.status == TicketStatus.resuelto,
        )
        .length;

    final List<_MetricData> metrics = <_MetricData>[
      _MetricData(
        title: 'Nuevos',
        subtitle: 'En espera de asignación',
        value: newCount,
        color: scheme.primary,
        icon: Icons.mark_email_unread_rounded,
      ),
      _MetricData(
        title: 'En curso',
        subtitle: 'Recibiendo atención',
        value: inProgressCount,
        color: scheme.secondary,
        icon: Icons.play_circle_outline,
      ),
      _MetricData(
        title: 'Cerrados',
        subtitle: 'Finalizados recientemente',
        value: closedCount,
        color: scheme.tertiary,
        icon: Icons.verified_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double safeWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final int columns;
        if (safeWidth >= 920) {
          columns = 3;
        } else if (safeWidth >= 620) {
          columns = 2;
        } else {
          columns = 1;
        }
        const double spacing = 16;
        final double computedWidth = columns == 1
            ? safeWidth
            : (safeWidth - (columns - 1) * spacing) / columns;
        final double minWidth = safeWidth < 220 ? safeWidth : 220;
        final double itemWidth = columns == 1
            ? safeWidth
            : computedWidth.clamp(minWidth, safeWidth).toDouble();

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: metrics
              .map(
                (_MetricData data) => SizedBox(
                  width: columns == 1 ? safeWidth : itemWidth,
                  child: _MetricCard(data: data),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final int value;
  final Color color;
  final IconData icon;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              data.color.withOpacity(0.18),
              data.color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 22,
                backgroundColor: data.color.withOpacity(0.18),
                child: Icon(data.icon, color: data.color, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                '${data.value}',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: data.color,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                data.subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketListShimmer extends StatelessWidget {
  const _TicketListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(
        3,
        (int index) => Padding(
          padding: EdgeInsets.only(bottom: index == 2 ? 0 : 16),
          child: const ShimmerPlaceholder(
            height: 170,
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),
      ),
    );
  }
}

class _MetricsShimmer extends StatelessWidget {
  const _MetricsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double safeWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final int columns;
        if (safeWidth >= 920) {
          columns = 3;
        } else if (safeWidth >= 620) {
          columns = 2;
        } else {
          columns = 1;
        }
        const double spacing = 16;
        final double computedWidth = columns == 1
            ? safeWidth
            : (safeWidth - (columns - 1) * spacing) / columns;
        final double minWidth = safeWidth < 220 ? safeWidth : 220;
        final double itemWidth = columns == 1
            ? safeWidth
            : computedWidth.clamp(minWidth, safeWidth).toDouble();

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List<Widget>.generate(
            3,
            (int index) => ShimmerPlaceholder(
              width: columns == 1 ? safeWidth : itemWidth,
              height: 160,
              borderRadius: const BorderRadius.all(Radius.circular(24)),
            ),
          ),
        );
      },
    );
  }
}

class _DropdownShimmer extends StatelessWidget {
  const _DropdownShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerPlaceholder(
      height: 56,
      borderRadius: BorderRadius.all(Radius.circular(20)),
    );
  }
}

IconData _statusIcon(TicketStatus status) {
  switch (status) {
    case TicketStatus.nuevo:
      return Icons.mark_email_unread_outlined;
    case TicketStatus.enRevision:
      return Icons.manage_search_rounded;
    case TicketStatus.enProceso:
      return Icons.autorenew_rounded;
    case TicketStatus.resuelto:
      return Icons.verified_outlined;
    case TicketStatus.cerrado:
      return Icons.lock_outline;
  }
}

IconData _categoryIcon(TicketCategory category) {
  switch (category) {
    case TicketCategory.altaNoParteRmFg:
      return Icons.description_outlined;
    case TicketCategory.soporteEdi:
      return Icons.hub_outlined;
    case TicketCategory.incidenciaUsuario:
      return Icons.report_problem_outlined;
    case TicketCategory.solicitudTi:
      return Icons.support_agent;
  }
}
