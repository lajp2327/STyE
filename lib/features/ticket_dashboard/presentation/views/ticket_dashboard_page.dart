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

    final Widget ticketsSliver = ticketsAsync.when(
      data: (List<Ticket> tickets) {
        if (tickets.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: EmptyState(
                message:
                    'No hay tickets registrados. Crea el primero desde el botón “Nuevo ticket”.',
                icon: Icons.support_agent_outlined,
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((
              BuildContext context,
              int index,
            ) {
              final Ticket ticket = tickets[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == tickets.length - 1 ? 0 : 12,
                ),
                child: TicketCard(
                  ticket: ticket,
                  onTap: () => context.go('/tickets/${ticket.id}'),
                ),
              );
            }, childCount: tickets.length),
          ),
        );
      },
      error: (Object error, StackTrace stackTrace) => SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ErrorCard(message: 'Error al cargar tickets: $error'),
        ),
      ),
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: _TicketListShimmer(),
        ),
      ),
    );

    return CustomScrollView(
      slivers: <Widget>[
        const SliverAppBar.large(title: Text('Tickets TI')),
        SliverToBoxAdapter(
          child: ticketsAsync.maybeWhen(
            data: (List<Ticket> tickets) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _TicketMetrics(tickets: tickets),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ),
        SliverToBoxAdapter(
          child: _FilterSection(
            filter: filter,
            techniciansAsync: techniciansAsync,
          ),
        ),
        ticketsSliver,
      ],
    );
  }
}

class _FilterSection extends ConsumerWidget {
  const _FilterSection({required this.filter, required this.techniciansAsync});

  final TicketFilter filter;
  final AsyncValue<List<Technician>> techniciansAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Estado', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<TicketStatus>(
              segments: TicketStatus.values
                  .map(
                    (TicketStatus status) => ButtonSegment<TicketStatus>(
                      value: status,
                      label: Text(status.label),
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
          Text('Categoría', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TicketCategory.values
                  .map(
                    (TicketCategory category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category.label),
                        selected: filter.category == category,
                        onSelected: (bool value) {
                          ref.read(ticketFilterProvider.notifier).state = filter
                              .copyWith(category: value ? category : null);
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          Text('Técnico asignado', style: theme.textTheme.titleSmall),
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
      ),
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

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        _MetricCard(
          title: 'Nuevos',
          value: newCount,
          color: scheme.primary,
          icon: Icons.fiber_new,
        ),
        _MetricCard(
          title: 'En curso',
          value: inProgressCount,
          color: scheme.secondary,
          icon: Icons.autorenew,
        ),
        _MetricCard(
          title: 'Cerrados',
          value: closedCount,
          color: scheme.tertiary,
          icon: Icons.check_circle_outline,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final int value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      width: 220,
      child: Card.outlined(
        elevation: 1.5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, color: color),
              const SizedBox(height: 12),
              Text(
                '$value',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(title, style: theme.textTheme.titleMedium),
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
          child: const ShimmerPlaceholder(height: 136),
        ),
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
