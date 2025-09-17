import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sistema_tickets_edis/core/utils/duration_formatter.dart';
import 'package:sistema_tickets_edis/domain/entities/report_summary.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket.dart';
import 'package:sistema_tickets_edis/domain/entities/technician.dart';
import 'package:sistema_tickets_edis/features/reports/application/report_controller.dart';
import 'package:sistema_tickets_edis/features/shared/presentation/widgets/empty_state.dart';
import 'package:sistema_tickets_edis/features/shared/presentation/widgets/error_card.dart';
import 'package:sistema_tickets_edis/features/shared/presentation/widgets/shimmer_placeholder.dart';

class ReportPage extends ConsumerWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ReportSummary> state = ref.watch(reportControllerProvider);
    final ReportController controller = ref.read(reportControllerProvider.notifier);

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar.large(
          title: const Text('Reportes'),
          actions: <Widget>[
            IconButton(
              tooltip: 'Actualizar reportes',
              onPressed: () => controller.load(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          sliver: SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: state.when(
                loading: () => const _ReportsShimmer(),
                error: (Object error, StackTrace stackTrace) => ErrorCard(
                  message: 'Error al cargar reportes: $error',
                  onRetry: controller.load,
                ),
                data: (ReportSummary summary) => _ReportContent(summary: summary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportContent extends StatelessWidget {
  const _ReportContent({required this.summary});

  final ReportSummary summary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      children: <Widget>[
        _SectionCard(
          title: 'Tickets por categoría',
          child: _CategoryBarChart(data: summary.byCategory),
          legend: summary.byCategory.entries
              .map(
                (MapEntry<TicketCategory, int> entry) => _LegendChip(
                  label: entry.key.label,
                  color: theme.colorScheme.primary,
                ),
              )
              .toList(),
        ),
        _SectionCard(
          title: 'Tickets por estado',
          child: _StatusPieChart(data: summary.byStatus),
          legend: summary.byStatus.entries
              .map(
                (MapEntry<TicketStatus, int> entry) => _LegendChip(
                  label: entry.key.label,
                  color: _statusColor(entry.key, theme.colorScheme),
                ),
              )
              .toList(),
        ),
        _SectionCard(
          title: 'Promedio por estado',
          child: _DurationLineChart(data: summary.statusDurations),
          legend: summary.statusDurations.keys
              .map(
                (TicketStatus status) => _LegendChip(
                  label: status.label,
                  color: _statusColor(status, theme.colorScheme),
                ),
              )
              .toList(),
        ),
        _SectionCard(
          title: 'Tickets por técnico',
          child: _TechnicianList(data: summary.byTechnician),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: const Text('Tiempo promedio de resolución'),
            subtitle: Text(formatDuration(summary.averageResolution)),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.legend,
  });

  final String title;
  final Widget child;
  final List<Widget>? legend;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(height: 220, child: child),
              if (legend != null && legend!.isNotEmpty) ...<Widget>[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: legend!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Chip(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      avatar: Icon(Icons.brightness_1, size: 12, color: color),
      label: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
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
      return const EmptyState(
        title: 'Sin datos',
        message: 'No hay información de categorías disponible.',
        icon: Icons.bar_chart_outlined,
      );
    }
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final List<BarChartGroupData> groups = <BarChartGroupData>[];
    int index = 0;
    for (final MapEntry<TicketCategory, int> entry in data.entries) {
      groups.add(
        BarChartGroupData(
          x: index,
          barRods: <BarChartRodData>[
            BarChartRodData(
              toY: entry.value.toDouble(),
              color: scheme.primary,
              width: 18,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
          ],
          showingTooltipIndicators: const <int>[0],
        ),
      );
      index++;
    }
    final int maxValue = data.values.reduce((int a, int b) => a > b ? a : b);
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: scheme.inverseSurface,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            tooltipRoundedRadius: 14,
            getTooltipItem: (
              BarChartGroupData group,
              int groupIndex,
              BarChartRodData rod,
              int rodIndex,
            ) {
              final TicketCategory category = data.keys.elementAt(group.x.toInt());
              return BarTooltipItem(
                '${_oneLineLabel(category.label)}\n',
                theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onInverseSurface.withOpacity(0.72),
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: rod.toY.toStringAsFixed(0),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: scheme.onInverseSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                final TicketCategory category = data.keys.elementAt(value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _oneLineLabel(category.label, maxLength: 12),
                    style: theme.textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) => Text(
                value.toInt().toString(),
                style: theme.textTheme.labelSmall,
              ),
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: scheme.outlineVariant.withOpacity(0.3),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: groups,
        maxY: (maxValue == 0 ? 1 : maxValue.toDouble() * 1.2),
      ),
      swapAnimationDuration: const Duration(milliseconds: 300),
    );
  }
}

class _StatusPieChart extends StatelessWidget {
  const _StatusPieChart({required this.data});

  final Map<TicketStatus, int> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const EmptyState(
        title: 'Sin datos',
        message: 'No hay información de estados disponible.',
        icon: Icons.pie_chart_outline,
      );
    }
    final ColorScheme scheme = Theme.of(context).colorScheme;
    int index = 0;
    final List<PieChartSectionData> sections = data.entries.map((
      MapEntry<TicketStatus, int> entry,
    ) {
      final PieChartSectionData section = PieChartSectionData(
        color: _statusColor(entry.key, scheme),
        value: entry.value.toDouble(),
        title: entry.value.toString(),
        radius: 70,
        titleStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
      );
      index++;
      return section;
    }).toList();
    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        borderData: FlBorderData(show: false),
        pieTouchData: PieTouchData(enabled: true),
      ),
      swapAnimationDuration: const Duration(milliseconds: 300),
    );
  }
}

class _DurationLineChart extends StatelessWidget {
  const _DurationLineChart({required this.data});

  final Map<TicketStatus, Duration> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const EmptyState(
        title: 'Sin datos',
        message: 'Sin tiempos registrados para mostrar.',
        icon: Icons.show_chart_outlined,
      );
    }
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final List<FlSpot> spots = <FlSpot>[];
    int index = 0;
    for (final MapEntry<TicketStatus, Duration> entry in data.entries) {
      spots.add(FlSpot(index.toDouble(), entry.value.inHours.toDouble()));
      index++;
    }
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: scheme.inverseSurface,
            tooltipRoundedRadius: 14,
            getTooltipItems: (
              List<LineBarSpot> touchedSpots,
            ) => touchedSpots
                .map(
                  (LineBarSpot spot) => LineTooltipItem(
                    '${_oneLineLabel(data.keys.elementAt(spot.x.toInt()).label)}\n',
                    theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onInverseSurface.withOpacity(0.72),
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: '${spot.y.toStringAsFixed(1)} h',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: scheme.onInverseSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            isCurved: true,
            color: scheme.primary,
            barWidth: 4,
            spots: spots,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: scheme.primary.withOpacity(0.12),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final TicketStatus status = data.keys.elementAt(value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _oneLineLabel(status.label, maxLength: 10),
                    style: theme.textTheme.labelSmall,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (double value, TitleMeta meta) => Text(
                '${value.toStringAsFixed(0)} h',
                style: theme.textTheme.labelSmall,
              ),
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          getDrawingHorizontalLine: (_) => FlLine(
            color: scheme.outlineVariant.withOpacity(0.25),
            strokeWidth: 1,
          ),
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
      ),
      swapAnimationDuration: const Duration(milliseconds: 300),
    );
  }
}

class _TechnicianList extends StatelessWidget {
  const _TechnicianList({required this.data});

  final Map<Technician, int> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const EmptyState(
        title: 'Sin datos',
        message: 'No se registran tickets por técnico.',
        icon: Icons.engineering,
      );
    }
    final ThemeData theme = Theme.of(context);
    return Column(
      children: data.entries
          .map(
            (MapEntry<Technician, int> entry) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.engineering,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              title: Text(entry.key.name),
              subtitle: Text(entry.key.email),
              trailing: Text(
                '${entry.value}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ReportsShimmer extends StatelessWidget {
  const _ReportsShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const <Widget>[
        ShimmerPlaceholder(height: 260),
        SizedBox(height: 16),
        ShimmerPlaceholder(height: 260),
        SizedBox(height: 16),
        ShimmerPlaceholder(height: 260),
      ],
    );
  }
}

Color _statusColor(TicketStatus status, ColorScheme scheme) {
  switch (status) {
    case TicketStatus.nuevo:
      return scheme.primary;
    case TicketStatus.enRevision:
      return scheme.secondary;
    case TicketStatus.enProceso:
      return scheme.tertiary;
    case TicketStatus.resuelto:
      return scheme.inversePrimary;
    case TicketStatus.cerrado:
      return scheme.outline;
  }
}

String _oneLineLabel(String text, {int maxLength = 18}) {
  if (text.length <= maxLength) {
    return text;
  }
  return '${text.substring(0, maxLength - 1)}…';
}
