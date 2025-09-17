import 'package:equatable/equatable.dart';

/// Simple value object describing a closed date interval.
class DateRange extends Equatable {
  DateRange({required this.start, required this.end})
      : assert(!end.isBefore(start), 'end must be >= start');

  final DateTime start;
  final DateTime end;

  bool contains(DateTime value) =>
      (value.isAfter(start) || value.isAtSameMomentAs(start)) &&
      (value.isBefore(end) || value.isAtSameMomentAs(end));

  @override
  List<Object?> get props => <Object?>[start, end];
}