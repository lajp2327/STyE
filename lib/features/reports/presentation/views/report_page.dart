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
          pinned: true,
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
              duration: const Duration(milliseconds: 260),
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
    final ColorScheme scheme = theme.colorScheme;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        const double spacing = 16;
        final bool isTwoColumns = width >= 900;
        final double cardWidth = isTwoColumns ? (width - spacing) / 2 : width;
        final List<MapEntry<TicketCategory, int>> categories =
            summary.byCategory.entries.toList();
        final List<MapEntry<TicketStatus, int>> statuses =
            summary.byStatus.entries.toList();

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: <Widget>[
            _ReportCard(
              width: cardWidth,
              title: 'Tickets por categoría',
              contentHeight: 240,
              child: _CategoryBarChart(data: summary.byCategory),
              legend: List<Widget>.generate(
                categories.length,
                (int index) => _LegendChip(
                  label: categories[index].key.label,
                  color: _categoryColor(index, scheme),
                ),
              ),
            ),
            _ReportCard(
              width: cardWidth,
              title: 'Tickets por estado',
              contentHeight: 240,
              child: _StatusPieChart(data: summary.byStatus),
              legend: statuses
                  .map(
                    (MapEntry<TicketStatus, int> entry) => _LegendChip(
                      label: entry.key.label,
                      color: _statusColor(entry.key, scheme),
                    ),
                  )
                  .toList(),
            ),
            _ReportCard(
              width: cardWidth,
              title: 'Tiempo promedio por estado',
              contentHeight: 240,
              child: _DurationLineChart(data: summary.statusDurations),
              legend: statuses
                  .map(
                    (MapEntry<TicketStatus, int> entry) => _LegendChip(
                      label: entry.key.label,
                      color: _statusColor(entry.key, scheme),
                    ),
                  )
                  .toList(),
            ),
            _ReportCard(
              width: cardWidth,
              title: 'Tickets por técnico',
              child: _TechnicianList(data: summary.byTechnician),
            ),
            _ReportCard(
              width: isTwoColumns ? cardWidth : width,
              title: 'Tiempo promedio de resolución',
              contentHeight: 160,
              child: _ResolutionSummary(duration: summary.averageResolution),
            ),
          ],
        );
      },
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.title,
    required this.child,
    this.legend,
    this.width,
    this.contentHeight,
  });

  final String title;
  final Widget child;
  final List<Widget>? legend;
  final double? width;
  final double? contentHeight;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Widget body = contentHeight != null
        ? SizedBox(height: contentHeight, child: child)
        : child;
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              body,
              if (legend != null && legend!.isNotEmpty) ...<Widget>[
                const SizedBox(height: 20),
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
    final ColorScheme scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.circle, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
    final List<MapEntry<TicketCategory, int>> entries = data.entries.toList();
    final List<BarChartGroupData> groups = <BarChartGroupData>[];
    for (int index = 0; index < entries.length; index++) {
      final MapEntry<TicketCategory, int> entry = entries[index];
      final Color barColor = _categoryColor(index, scheme);
      groups.add(
        BarChartGroupData(
          x: index,
          barRods: <BarChartRodData>[
            BarChartRodData(
              toY: entry.value.toDouble(),
              width: 20,
              borderRadius: const BorderRadius.all(Radius.circular(14)),
              gradient: LinearGradient(
                colors: <Color>[
                  barColor,
                  barColor.withOpacity(0.65),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ],
          showingTooltipIndicators: const <int>[0],
        ),
      );
    }
    final int maxValue = entries.fold<int>(
      0,
      (int previousValue, MapEntry<TicketCategory, int> element) =>
          element.value > previousValue ? element.value : previousValue,
    );
    final TextStyle tooltipLabelStyle =
        (theme.textTheme.labelSmall ?? const TextStyle(fontSize: 12)).copyWith(
      color: scheme.onInverseSurface.withOpacity(0.72),
    );
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: groups,
        maxY: (maxValue == 0 ? 1 : maxValue.toDouble() * 1.2),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: scheme.inverseSurface,
            tooltipRoundedRadius: 16,
            tooltipPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            getTooltipItem: (
              BarChartGroupData group,
              int groupIndex,
              BarChartRodData rod,
              int rodIndex,
            ) {
              final TicketCategory category = entries[group.x.toInt()].key;
              return BarTooltipItem(
                '${_oneLineLabel(category.label)}\n',
                tooltipLabelStyle,
                children: <TextSpan>[
                  TextSpan(
                    text: '${rod.toY.toStringAsFixed(0)} tickets',
                    style: theme.textTheme.titleMedium?.copyWith(
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
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() < 0 || value.toInt() >= entries.length) {
                  return const SizedBox.shrink();
                }
                final TicketCategory category = entries[value.toInt()].key;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _oneLineLabel(category.label, maxLength: 14),
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
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: scheme.outlineVariant.withOpacity(0.28),
            strokeWidth: 1,
            dashArray: <int>[4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
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
      return const EmptyState(
        title: 'Sin datos',
        message: 'No hay información de estados disponible.',
        icon: Icons.pie_chart_outline,
      );
    }
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final List<MapEntry<TicketStatus, int>> entries = data.entries.toList();
    final int total = entries.fold<int>(0, (int value, MapEntry<TicketStatus, int> element) => value + element.value);
    final List<PieChartSectionData> sections = <PieChartSectionData>[];
    for (final MapEntry<TicketStatus, int> entry in entries) {
      final double percentage = total == 0 ? 0 : entry.value / total * 100;
      sections.add(
        PieChartSectionData(
          color: _statusColor(entry.key, scheme),
          value: entry.value.toDouble(),
          title: '${percentage.toStringAsFixed(0)}%',
          titleStyle: theme.textTheme.labelLarge?.copyWith(
            color: scheme.onPrimary,
            fontWeight: FontWeight.w700,
          ),
          radius: 68,
        ),
      );
    }
    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 2,
        centerSpaceRadius: 42,
        pieTouchData: PieTouchData(enabled: true),
        borderData: FlBorderData(show: false),
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
      return const EmptyState(
        title: 'Sin datos',
        message: 'Sin tiempos registrados para mostrar.',
        icon: Icons.show_chart_outlined,
      );
    }
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final List<MapEntry<TicketStatus, Duration>> entries = data.entries.toList();
    final List<FlSpot> spots = <FlSpot>[];
    for (int index = 0; index < entries.length; index++) {
      spots.add(FlSpot(index.toDouble(), entries[index].value.inHours.toDouble()));
    }
    final TextStyle tooltipLabelStyle =
        (theme.textTheme.labelSmall ?? const TextStyle(fontSize: 12)).copyWith(
      color: scheme.onInverseSurface.withOpacity(0.72),
    );
    return LineChart(
      LineChartData(
        minY: 0,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: scheme.inverseSurface,
            tooltipRoundedRadius: 16,
            getTooltipItems: (List<LineBarSpot> touchedSpots) => touchedSpots
                .map(
                  (LineBarSpot spot) => LineTooltipItem(
                    '${_oneLineLabel(entries[spot.x.toInt()].key.label)}\n',
                    tooltipLabelStyle,
                    children: <TextSpan>[
                      TextSpan(
                        text: '${spot.y.toStringAsFixed(1)} h',
                        style: theme.textTheme.titleMedium?.copyWith(
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
            barWidth: 4,
            color: scheme.primary,
            spots: spots,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: <Color>[
                  scheme.primary.withOpacity(0.24),
                  scheme.primary.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() < 0 || value.toInt() >= entries.length) {
                  return const SizedBox.shrink();
                }
                final TicketStatus status = entries[value.toInt()].key;
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
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: scheme.outlineVariant.withOpacity(0.25),
            strokeWidth: 1,
            dashArray: const <int>[4, 4],
          ),
        ),
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
      return const EmptyState(
        title: 'Sin datos',
        message: 'No se registran tickets por técnico.',
        icon: Icons.engineering,
      );
    }
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final List<MapEntry<Technician, int>> entries = data.entries.toList();
    return Column(
      children: List<Widget>.generate(entries.length, (int index) {
        final MapEntry<Technician, int> entry = entries[index];
        final bool isLast = index == entries.length - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
          child: Container(
            decoration: BoxDecoration(
              color: scheme.surfaceVariant.withOpacity(0.24),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                child: Icon(
                  Icons.engineering,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              title: Text(entry.key.name),
              subtitle: Text(entry.key.email),
              trailing: _LegendChip(
                label: '${entry.value} tickets',
                color: scheme.primary,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ResolutionSummary extends StatelessWidget {
  const _ResolutionSummary({required this.duration});

  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircleAvatar(
            radius: 28,
            backgroundColor: scheme.primaryContainer,
            child: Icon(Icons.timer_outlined, color: scheme.primary, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            formatDuration(duration),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Promedio de resolución por ticket',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportsShimmer extends StatelessWidget {
  const _ReportsShimmer();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        const double spacing = 16;
        final bool isTwoColumns = width >= 900;
        final double cardWidth = isTwoColumns ? (width - spacing) / 2 : width;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: <Widget>[
            ShimmerPlaceholder(
              width: cardWidth,
              height: 280,
              borderRadius: const BorderRadius.all(Radius.circular(24)),
            ),
            ShimmerPlaceholder(
              width: cardWidth,
              height: 280,
              borderRadius: const BorderRadius.all(Radius.circular(24)),
            ),
            ShimmerPlaceholder(
              width: cardWidth,
              height: 280,
              borderRadius: const BorderRadius.all(Radius.circular(24)),
            ),
            ShimmerPlaceholder(
              width: cardWidth,
              height: 220,
              borderRadius: const BorderRadius.all(Radius.circular(24)),
            ),
            ShimmerPlaceholder(
              width: isTwoColumns ? cardWidth : width,
              height: 200,
              borderRadius: const BorderRadius.all(Radius.circular(24)),
            ),
          ],
        );
      },
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

Color _categoryColor(int index, ColorScheme scheme) {
  final List<Color> palette = <Color>[
    scheme.primary,
    scheme.secondary,
    scheme.tertiary,
    scheme.primaryContainer,
    scheme.secondaryContainer,
  ];
  return palette[index % palette.length];
}

String _oneLineLabel(String text, {int maxLength = 18}) {
  if (text.length <= maxLength) {
    return text;
  }
  return '${text.substring(0, maxLength - 1)}…';
}
