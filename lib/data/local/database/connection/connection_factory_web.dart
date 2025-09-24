import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor createExecutor() {
  return WebDatabase('tickets_db');
}
