import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

QueryExecutor createExecutor() {
  return LazyDatabase(() async {
    try {
      final Directory dir = await getApplicationDocumentsDirectory();
      final File file = File(p.join(dir.path, 'tickets.db'));
      return NativeDatabase(file);
    } catch (_) {
      final Directory temp = await Directory.systemTemp.createTemp('tickets_db');
      final File file = File(p.join(temp.path, 'tickets.db'));
      return NativeDatabase(file);
    }
  });
}
