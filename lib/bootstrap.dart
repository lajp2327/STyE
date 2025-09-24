import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sistema_tickets_edis/app/app.dart';
import 'package:sistema_tickets_edis/app/providers.dart';
import 'package:sistema_tickets_edis/core/notifications/local_notification_service.dart';
import 'package:sistema_tickets_edis/core/notifications/notification_service.dart';
import 'package:sistema_tickets_edis/core/notifications/web_notification_service.dart';
import 'package:sistema_tickets_edis/core/pdf/alta_document_service.dart';
import 'package:sistema_tickets_edis/data/local/database/app_database.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AppDatabase database = AppDatabase();
  final NotificationService notifications =
      kIsWeb ? WebNotificationService() : LocalNotificationService();
  await notifications.initialize();
  final AltaDocumentService altaService = AltaDocumentService();
  final SharedPreferences preferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(database),
        localNotificationServiceProvider.overrideWithValue(notifications),
        altaDocumentServiceProvider.overrideWithValue(altaService),
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
      child: const TicketSystemApp(),
    ),
  );
}
