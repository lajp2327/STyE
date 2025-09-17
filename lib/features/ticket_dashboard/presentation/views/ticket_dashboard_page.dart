import 'package:flutter/material.dart';
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

final techniciansProvider = StreamProvider<List<Technician>>((ref) {
  final repository = ref.watch(ticketRepositoryProvider);
  return repository.watchTechnicians();
});

class TicketDashboardPage extends ConsumerWidget {
  const TicketDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              SliverToBoxAdapter(
                child: ticketsAsync.maybeWhen(
                  data: (List<Ticket> tickets) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: _TicketMetrics(tickets: tickets),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ),
            )
            ..add(
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: _FilterSection(
                    filter: filter,
                    techniciansAsync: techniciansAsync,
                  ),
                ),
              ),
            )
            ..add(_TicketsSliver(ticketsAsync: ticketsAsync));
        }

        return CustomScrollView(
          slivers: slivers,
        );
      },
    );
  }
}

class _WideDashboardSection extends StatelessWidget {
  const _WideDashboardSection({
    required this.ticketsAsync,
    required this.filter,
    required this.techniciansAsync,
  });

  final AsyncValue<List<Ticket>> ticketsAsync;
  final TicketFilter filter;
  final AsyncValue<List<Technician>> techniciansAsync;

  @override
  Widget build(BuildContext context) {
    return ticketsAsync.when(
      data: (List<Ticket> tickets) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _TicketMetrics(tickets: tickets),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
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
                  padding: const EdgeInsets.all(16),
                  child: _TicketListPanel(tickets: tickets),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          _MetricsShimmer(),
          SizedBox(width: 24),
          Expanded(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: _TicketListShimmer(),
              ),
            ),
          ),
        ],
      ),
      error: (Object error, StackTrace stackTrace) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ErrorCard(message: 'Error al cargar tickets: $error'),
        ],
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: EmptyState(
                title: 'Sin tickets registrados',
                message:
                    'No hay tickets registrados. Crea el primero desde el botón “Nuevo ticket”.',
                icon: Icons.support_agent_outlined,
                actionLabel: 'Nuevo ticket',
                onAction: () => context.go('/tickets/new'),
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
                    bottom: index == tickets.length - 1 ? 0 : 12,
                  ),
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey<int>(ticket.id),
                    tween: Tween<double>(begin: 16, end: 0),
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    builder: (BuildContext context, double value, Widget? child) {
                      final double opacity = 1 - (value / 16);
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
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        sliver: SliverToBoxAdapter(child: _TicketListShimmer()),
      ),
      error: (Object error, StackTrace stackTrace) => SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ErrorCard(message: 'Error al cargar tickets: $error'),
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
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tickets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
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
    final TextTheme textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Estado', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<TicketStatus>(
            segments: TicketStatus.values
                .map(
                  (TicketStatus status) => ButtonSegment<TicketStatus>(
                    value: status,
                    label: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(status.label),
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
              ref.read(ticketFilterProvider.notifier).state = filter.copyWith(
                status: selected.isEmpty ? null : selected.first,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text('Categoría', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TicketCategory.values
                .map(
                  (TicketCategory category) => FilterChip(
                    label: Text(category.label),
                    selected: filter.category == category,
                    onSelected: (bool value) {
                      ref.read(ticketFilterProvider.notifier).state =
                          filter.copyWith(category: value ? category : null);
                    },
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        Text('Técnico asignado', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        techniciansAsync.when(
          data: (List<Technician> technicians) {
            return DropdownButtonFormField<int?>(
              value: filter.assignedTechnicianId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Selecciona un técnico',
              ),
              items: <DropdownMenuItem<int?>>[
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
              ],
              onChanged: (int? value) {
                ref.read(ticketFilterProvider.notifier).state =
                    filter.copyWith(assignedTechnicianId: value);
              },
            );
          },
          loading: () => const _DropdownShimmer(),
          error: (Object error, StackTrace stackTrace) =>
              ErrorCard(message: 'Error al cargar técnicos: $error'),
        ),
      ],
    );
  }
}

class _TicketMetrics extends StatelessWidget {
  const _TicketMetrics({required this.tickets});

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
        value: newCount,
        color: scheme.primary,
        icon: Icons.fiber_new,
      ),
      _MetricData(
        title: 'En curso',
        value: inProgressCount,
        color: scheme.secondary,
        icon: Icons.autorenew,
      ),
      _MetricData(
        title: 'Cerrados',
        value: closedCount,
        color: scheme.tertiary,
        icon: Icons.check_circle_outline,
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: metrics
          .map(( _MetricData data) => _MetricCard(data: data))
          .toList(),
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
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
    return SizedBox(
      width: 184,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(data.icon, color: data.color, size: 28),
              const SizedBox(height: 12),
              Text(
                '${data.value}',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: data.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
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
  const _TicketListShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(
        3,
        (int index) => Padding(
          padding: EdgeInsets.only(bottom: index == 2 ? 0 : 12),
          child: const ShimmerPlaceholder(
            height: 150,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
      ),
    );
  }
}

class _MetricsShimmer extends StatelessWidget {
  const _MetricsShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const <Widget>[
              ShimmerPlaceholder(width: 180, height: 112),
              ShimmerPlaceholder(width: 180, height: 112),
              ShimmerPlaceholder(width: 180, height: 112),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  ShimmerPlaceholder(height: 18, width: 160),
                  SizedBox(height: 16),
                  ShimmerPlaceholder(height: 40),
                  SizedBox(height: 12),
                  ShimmerPlaceholder(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownShimmer extends StatelessWidget {
  const _DropdownShimmer();

  @override
  Widget build(BuildContext context) {
    return const ShimmerPlaceholder(height: 56);
  }
}
