import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sistema_tickets_edis/core/notifications/local_notification_service.dart';
import 'package:sistema_tickets_edis/core/pdf/alta_document_service.dart';
import 'package:sistema_tickets_edis/data/local/database/app_database.dart';
import 'package:sistema_tickets_edis/data/repositories/ticket_repository_impl.dart';
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
