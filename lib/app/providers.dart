import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sistema_tickets_edis/core/notifications/local_notification_service.dart';
import 'package:sistema_tickets_edis/core/pdf/alta_document_service.dart';
import 'package:sistema_tickets_edis/data/local/database/app_database.dart';
import 'package:sistema_tickets_edis/data/repositories/auth_repository_impl.dart';
import 'package:sistema_tickets_edis/data/repositories/ticket_repository_impl.dart';
import 'package:sistema_tickets_edis/domain/entities/session_user.dart';
import 'package:sistema_tickets_edis/domain/repositories/auth_repository.dart';
import 'package:sistema_tickets_edis/domain/repositories/ticket_repository.dart';
import 'package:sistema_tickets_edis/domain/services/ticket_workflow_service.dart';
import 'package:sistema_tickets_edis/domain/usecases/add_ticket_comment.dart';
import 'package:sistema_tickets_edis/domain/usecases/assign_technician.dart';
import 'package:sistema_tickets_edis/domain/usecases/create_ticket.dart';
import 'package:sistema_tickets_edis/domain/usecases/generate_rm_fg_documents.dart';
import 'package:sistema_tickets_edis/domain/usecases/load_reports.dart';
import 'package:sistema_tickets_edis/domain/usecases/update_ticket_status.dart';

final appDatabaseProvider = Provider<AppDatabase>((ProviderRef<AppDatabase> ref) {
  throw UnimplementedError('AppDatabase debe inyectarse desde bootstrap.');
});

final localNotificationServiceProvider = Provider<LocalNotificationService>((ref) {
  throw UnimplementedError('LocalNotificationService debe inyectarse desde bootstrap.');
});

final altaDocumentServiceProvider = Provider<AltaDocumentService>((ref) {
  throw UnimplementedError('AltaDocumentService debe inyectarse desde bootstrap.');
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences debe inyectarse desde bootstrap.');
});

final themeModeProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
  final SharedPreferences preferences = ref.watch(sharedPreferencesProvider);
  return ThemeModeController(preferences);
});

final ticketWorkflowServiceProvider = Provider<TicketWorkflowService>((ref) {
  return TicketWorkflowService();
});

final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  final AppDatabase database = ref.watch(appDatabaseProvider);
  final TicketWorkflowService workflow = ref.watch(ticketWorkflowServiceProvider);
  final LocalNotificationService notifications = ref.watch(localNotificationServiceProvider);
  final AltaDocumentService altaService = ref.watch(altaDocumentServiceProvider);
  return TicketRepositoryImpl(
    database: database,
    workflowService: workflow,
    notificationService: notifications,
    altaDocumentService: altaService,
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final SharedPreferences preferences = ref.watch(sharedPreferencesProvider);
  final AppDatabase database = ref.watch(appDatabaseProvider);
  final AuthRepositoryImpl repository = AuthRepositoryImpl(
    preferences: preferences,
    database: database,
  );
  ref.onDispose(repository.dispose);
  return repository;
});

final authStateProvider = StreamProvider<SessionUser?>((ref) {
  final AuthRepository repository = ref.watch(authRepositoryProvider);
  return repository.watchSession();
});

final currentSessionProvider = Provider<SessionUser?>((ref) {
  final AsyncValue<SessionUser?> authState = ref.watch(authStateProvider);
  return authState.maybeWhen(data: (SessionUser? value) => value, orElse: () => null);
});

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController(SharedPreferences preferences)
      : _preferences = preferences,
        super(_resolveInitialMode(preferences));

  static const String _themeModeKey = 'settings.theme.mode';

  final SharedPreferences _preferences;

  static ThemeMode _resolveInitialMode(SharedPreferences preferences) {
    final String? value = preferences.getString(_themeModeKey);
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) {
      return;
    }
    state = mode;
    await _preferences.setString(_themeModeKey, mode.name);
  }

  Future<void> toggleDarkMode(bool enabled) =>
      setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
}

final createTicketProvider = Provider<CreateTicket>((ref) => CreateTicket(ref.watch(ticketRepositoryProvider)));
final updateTicketStatusProvider =
    Provider<UpdateTicketStatus>((ref) => UpdateTicketStatus(ref.watch(ticketRepositoryProvider)));
final assignTechnicianProvider =
    Provider<AssignTechnician>((ref) => AssignTechnician(ref.watch(ticketRepositoryProvider)));
final addTicketCommentProvider =
    Provider<AddTicketComment>((ref) => AddTicketComment(ref.watch(ticketRepositoryProvider)));
final generateRmFgDocumentsProvider =
    Provider<GenerateRmFgDocuments>((ref) => GenerateRmFgDocuments(ref.watch(ticketRepositoryProvider)));
final loadReportsProvider = Provider<LoadReports>((ref) => LoadReports(ref.watch(ticketRepositoryProvider)));
