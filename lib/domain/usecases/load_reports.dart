import 'package:sistema_tickets_edis/domain/entities/report_summary.dart';
import 'package:sistema_tickets_edis/domain/repositories/ticket_repository.dart';
import 'package:sistema_tickets_edis/domain/value_objects/ticket_filters.dart';

/// Fetches aggregated metrics for dashboards.
class LoadReports {
  const LoadReports(this._repository);

  final TicketRepository _repository;

  Future<ReportSummary> call({TicketFilter? filter}) =>
      _repository.loadReportSummary(filter: filter);
}
