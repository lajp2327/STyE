import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sistema_tickets_edis/app/providers.dart';
import 'package:sistema_tickets_edis/domain/entities/alta_document_result.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket_event.dart';
import 'package:sistema_tickets_edis/domain/entities/technician.dart';
import 'package:sistema_tickets_edis/domain/services/ticket_workflow_service.dart';
import 'package:sistema_tickets_edis/features/ticket_detail/application/ticket_detail_controller.dart';
import 'package:sistema_tickets_edis/features/shared/presentation/widgets/error_card.dart';
import 'package:sistema_tickets_edis/features/shared/presentation/widgets/shimmer_placeholder.dart';
import 'package:sistema_tickets_edis/features/shared/presentation/widgets/status_chip.dart';

final _techniciansProvider = StreamProvider<List<Technician>>((ref) {
  final repository = ref.watch(ticketRepositoryProvider);
  return repository.watchTechnicians();
});

class TicketDetailPage extends ConsumerStatefulWidget {
  const TicketDetailPage({required this.ticketId, super.key});

  final int ticketId;

  @override
  ConsumerState<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends ConsumerState<TicketDetailPage> {
  @override
  Widget build(BuildContext context) {
    final TicketDetailState state = ref.watch(
      ticketDetailControllerProvider(widget.ticketId),
    );
    final TicketDetailController controller = ref.read(
      ticketDetailControllerProvider(widget.ticketId).notifier,
    );
    final TicketWorkflowService workflow = ref.watch(
      ticketWorkflowServiceProvider,
    );
    final AsyncValue<List<Technician>> techniciansAsync = ref.watch(
      _techniciansProvider,
    );

    return Scaffold(
      appBar: AppBar(title: Text('Ticket #${widget.ticketId}')),
      body: state.ticket.when(
        data: (Ticket ticket) => _TicketDetailBody(
          ticket: ticket,
          history: state.history,
          controller: controller,
          workflow: workflow,
          techniciansAsync: techniciansAsync,
          onChangeStatus: (TicketStatus status) =>
              _onChangeStatus(ticket, status, controller),
          onAssignTechnician: (Technician technician) =>
              controller.assignTechnician(technician),
          onAddComment: (String message) => controller.addComment(message),
          onGenerateDocuments:
              ticket.isAltaRmFg ? () => _onGenerateDocuments(controller) : null,
          errorMessage: state.errorMessage,
        ),
        error: (Object error, StackTrace stackTrace) => Padding(
          padding: const EdgeInsets.all(16),
          child: ErrorCard(message: 'Error al cargar el ticket: $error'),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _onChangeStatus(
    Ticket ticket,
    TicketStatus status,
    TicketDetailController controller,
  ) async {
    final TextEditingController commentController = TextEditingController();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cambiar a ${status.label}?'),
          content: TextField(
            controller: commentController,
            decoration: const InputDecoration(
              labelText: 'Comentario',
              border: OutlineInputBorder(),
            ),
            minLines: 1,
            maxLines: 3,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await controller.changeStatus(
        status,
        comment: commentController.text.isEmpty ? null : commentController.text,
      );
    }
  }

  Future<void> _onGenerateDocuments(TicketDetailController controller) async {
    try {
      final AltaDocumentResult result = await controller.generateDocuments();
      if (!mounted) {
        return;
      }
      _showBanner(
        'Documentos generados: PDF ${result.pdfPath.split('/').last}',
        isError: false,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showBanner('Error al generar documentos: $error', isError: true);
    }
  }

  void _showBanner(String message, {required bool isError}) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.clearMaterialBanners();
    messenger.showMaterialBanner(
      MaterialBanner(
        backgroundColor:
            isError ? scheme.errorContainer : scheme.secondaryContainer,
        content: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color:
                isError ? scheme.onErrorContainer : scheme.onSecondaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: messenger.hideCurrentMaterialBanner,
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class _TicketDetailBody extends StatelessWidget {
  const _TicketDetailBody({
    required this.ticket,
    required this.history,
    required this.controller,
    required this.workflow,
    required this.techniciansAsync,
    required this.onChangeStatus,
    required this.onAssignTechnician,
    required this.onAddComment,
    this.errorMessage,
    this.onGenerateDocuments,
  });

  final Ticket ticket;
  final AsyncValue<List<TicketEvent>> history;
  final TicketDetailController controller;
  final TicketWorkflowService workflow;
  final AsyncValue<List<Technician>> techniciansAsync;
  final Future<void> Function(TicketStatus status) onChangeStatus;
  final Future<void> Function(Technician technician) onAssignTechnician;
  final Future<void> Function(String message) onAddComment;
  final Future<void> Function()? onGenerateDocuments;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme scheme = theme.colorScheme;
    final Iterable<TicketStatus> nextStatuses = workflow.nextOptions(
      ticket.status,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        if (errorMessage != null)
          ErrorCard(message: errorMessage!, onDismiss: controller.clearError),
        Card.outlined(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  ticket.title,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(ticket.description),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: <Widget>[
                    StatusChip(status: ticket.status),
                    Chip(label: Text(ticket.category.label)),
                    Chip(label: Text('Solicita: ${ticket.requesterName}')),
                    if (ticket.assignedTechnician != null)
                      Chip(
                        label: Text(
                          'Técnico: ${ticket.assignedTechnician!.name}',
                        ),
                      ),
                    if (ticket.isAltaRmFg) const Chip(label: Text('RM/FG')),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Creado: ${MaterialLocalizations.of(context).formatMediumDate(ticket.createdAt)}',
                ),
                if (ticket.resolvedAt != null)
                  Text(
                    'Resuelto: ${MaterialLocalizations.of(context).formatMediumDate(ticket.resolvedAt!)}',
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card.outlined(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Acciones', style: textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    ...nextStatuses.map(
                      (TicketStatus status) => FilledButton(
                        onPressed: () => onChangeStatus(status),
                        child: Text(status.label),
                      ),
                    ),
                    techniciansAsync.when(
                      data: (List<Technician> technicians) => FilledButton.icon(
                        onPressed: technicians.isEmpty
                            ? null
                            : () => _showTechnicianSheet(
                                  context,
                                  technicians,
                                  onAssignTechnician,
                                ),
                        icon: const Icon(Icons.engineering),
                        label: const Text('Asignar técnico'),
                      ),
                      loading: () => const _TechnicianShimmer(),
                      error: (Object error, StackTrace stackTrace) =>
                          ErrorCard(message: 'Error técnicos: $error'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showCommentDialog(context),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Agregar comentario'),
                    ),
                    if (onGenerateDocuments != null)
                      OutlinedButton.icon(
                        onPressed: onGenerateDocuments,
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('Generar RM/FG'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Histórico', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        history.when(
          data: (List<TicketEvent> events) => events.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text('Sin eventos registrados.')),
                )
              : Column(
                  children: events
                      .map(
                        (TicketEvent event) => Card.outlined(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: scheme.primaryContainer,
                              child: Icon(
                                _eventIcon(event.type),
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                            title: Text(event.message),
                            subtitle: Text(
                              '${MaterialLocalizations.of(context).formatMediumDate(event.createdAt)} · ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(event.createdAt))}\nPor: ${event.author}',
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ErrorCard(message: 'Error histórico: $error'),
          ),
        ),
      ],
    );
  }

  Future<void> _showCommentDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar comentario'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Comentario',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
    if (confirmed == true && controller.text.isNotEmpty) {
      await onAddComment(controller.text);
    }
  }

  Future<void> _showTechnicianSheet(
    BuildContext context,
    List<Technician> technicians,
    Future<void> Function(Technician technician) onAssignTechnician,
  ) async {
    final Technician? technician = await showModalBottomSheet<Technician>(
      context: context,
      builder: (BuildContext context) {
        return ListView(
          children: technicians
              .map(
                (Technician technician) => ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(technician.name),
                  subtitle: Text(technician.email),
                  onTap: () => Navigator.of(context).pop(technician),
                ),
              )
              .toList(),
        );
      },
    );
    if (technician != null) {
      await onAssignTechnician(technician);
    }
  }
}

class _TechnicianShimmer extends StatelessWidget {
  const _TechnicianShimmer();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 160, child: ShimmerPlaceholder(height: 48));
  }
}

IconData _eventIcon(TicketEventType type) {
  switch (type) {
    case TicketEventType.created:
      return Icons.note_add_outlined;
    case TicketEventType.statusChanged:
      return Icons.autorenew;
    case TicketEventType.assignment:
      return Icons.engineering;
    case TicketEventType.comment:
      return Icons.chat_bubble_outline;
    case TicketEventType.documentGenerated:
      return Icons.picture_as_pdf_outlined;
  }
}
