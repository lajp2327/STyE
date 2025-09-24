import 'package:drift/drift.dart';

import 'connection_factory_stub.dart'
    if (dart.library.html) 'connection_factory_web.dart'
    if (dart.library.io) 'connection_factory_io.dart';

QueryExecutor createDriftExecutor() => createExecutor();
