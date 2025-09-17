import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sistema_tickets_edis/core/utils/duration_formatter.dart';
import 'package:sistema_tickets_edis/domain/entities/report_summary.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket.dart';
import 'package:sistema_tickets_edis/domain/entities/technician.dart';
import 'package:sistema_tickets_edis/features/reports/application/report_controller.dart';
import 'package:sistema_tickets_edis/features/shared/presentation/widgets/error_card.dart';

class ReportPage extends ConsumerWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ReportSummary> state = ref.watch(reportControllerProvider);
    final Widget contentSliver = state.when(
      loading: () => const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (Object error, StackTrace stackTrace) => SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ErrorCard(message: 'Error al cargar reportes: $error'),
        ),
      ),
      data: (ReportSummary summary) => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        sliver: SliverList(
          delegate: SliverChildListDelegate(<Widget>[
            _SectionCard(
              title: 'Tickets por categoría',
              child: _CategoryBarChart(data: summary.byCategory),
            ),
            _SectionCard(
              title: 'Tickets por estado',
              child: _StatusPieChart(data: summary.byStatus),
            ),
            _SectionCard(
              title: 'Promedio por estado',
              child: _DurationLineChart(data: summary.statusDurations),
            ),
            _SectionCard(
              title: 'Tickets por técnico',
              child: _TechnicianList(data: summary.byTechnician),
            ),
            Card.outlined(
              child: ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: const Text('Tiempo promedio de resolución'),
                subtitle: Text(formatDuration(summary.averageResolution)),
              ),
            ),
            const SizedBox(height: 12),
          ]),
        ),
      ),
    );

    return CustomScrollView(
      slivers: <Widget>[
        const SliverAppBar.large(title: Text('Reportes')),
        contentSliver,
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(height: 200, child: child),
          ],
        ),
      ),
    );
  }
}

class _CategoryBarChart extends StatelessWidget {
  const _CategoryBarChart({required this.data});

  final Map<TicketCategory, int> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Sin datos'));
    }
    final List<BarChartGroupData> groups = <BarChartGroupData>[];
    int index = 0;
    for (final MapEntry<TicketCategory, int> entry in data.entries) {
      groups.add(
        BarChartGroupData(
          x: index,
          barRods: <BarChartRodData>[
            BarChartRodData(
              toY: entry.value.toDouble(),
              color: Theme.of(context).colorScheme.primary,
              width: 22,
            ),
          ],
          showingTooltipIndicators: const <int>[0],
        ),
      );
      index++;
    }
    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (
              BarChartGroupData group,
              int groupIndex,
              BarChartRodData rod,
              int rodIndex,
            ) {
              final TicketCategory category = data.keys.elementAt(
                group.x.toInt(),
              );
              return BarTooltipItem(
                '${category.label}: ${rod.toY.toStringAsFixed(0)}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final TicketCategory category = data.keys.elementAt(
                  value.toInt(),
                );
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    category.name,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: groups,
      ),
    );
  }
}

class _StatusPieChart extends StatelessWidget {
  const _StatusPieChart({required this.data});

  final Map<TicketStatus, int> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Sin datos'));
    }
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final List<Color> colors = <Color>[
      scheme.primary,
      scheme.secondary,
      scheme.tertiary,
      scheme.error,
      scheme.inversePrimary,
    ];
    int index = 0;
    final List<PieChartSectionData> sections = data.entries.map((
      MapEntry<TicketStatus, int> entry,
    ) {
      final PieChartSectionData section = PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
      index++;
      return section;
    }).toList();
    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 2,
        centerSpaceRadius: 32,
        borderData: FlBorderData(show: false),
        pieTouchData: PieTouchData(enabled: true),
      ),
    );
  }
}

class _DurationLineChart extends StatelessWidget {
  const _DurationLineChart({required this.data});

  final Map<TicketStatus, Duration> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Sin datos'));
    }
    final List<FlSpot> spots = <FlSpot>[];
    int index = 0;
    for (final MapEntry<TicketStatus, Duration> entry in data.entries) {
      spots.add(FlSpot(index.toDouble(), entry.value.inHours.toDouble()));
      index++;
    }
    return LineChart(
      LineChartData(
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 4,
            spots: spots,
            dotData: FlDotData(show: true),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final TicketStatus status = data.keys.elementAt(value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    status.name,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) =>
                  Text('${value.toStringAsFixed(0)}h'),
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _TechnicianList extends StatelessWidget {
  const _TechnicianList({required this.data});

  final Map<Technician, int> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Sin datos'));
    }
    return Column(
      children: data.entries
          .map(
            (MapEntry<Technician, int> entry) => ListTile(
              leading: const Icon(Icons.engineering),
              title: Text(entry.key.name),
              subtitle: Text(entry.key.email),
              trailing: Text('${entry.value}'),
            ),
          )
          .toList(),
    );
  }
}
