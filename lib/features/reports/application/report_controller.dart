import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sistema_tickets_edis/app/providers.dart';
import 'package:sistema_tickets_edis/domain/entities/report_summary.dart';
import 'package:sistema_tickets_edis/domain/usecases/load_reports.dart';
import 'package:sistema_tickets_edis/domain/value_objects/ticket_filters.dart';

final reportControllerProvider =
    StateNotifierProvider.autoDispose<ReportController, AsyncValue<ReportSummary>>((ref) {
  final LoadReports loadReports = ref.watch(loadReportsProvider);
  return ReportController(loadReports)..load();
});

class ReportController extends StateNotifier<AsyncValue<ReportSummary>> {
  ReportController(this._loadReports) : super(const AsyncValue.loading());

  final LoadReports _loadReports;
  TicketFilter? _filter;

  Future<void> load({TicketFilter? filter}) async {
    _filter = filter ?? _filter;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadReports(filter: _filter));
  }
}
