import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sistema_tickets_edis/app/providers.dart';
import 'package:sistema_tickets_edis/domain/entities/alta_document_result.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket_event.dart';
import 'package:sistema_tickets_edis/domain/entities/technician.dart';
import 'package:sistema_tickets_edis/domain/services/ticket_workflow_service.dart';
import 'package:sistema_tickets_edis/features/ticket_detail/application/ticket_detail_controller.dart';
import 'package:sistema_tickets_edis/features/shared/presentation/widgets/empty_state.dart';
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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: state.ticket.when(
          data: (Ticket ticket) => _TicketDetailBody(
            key: ValueKey<int>(ticket.id),
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
          loading: () => const _TicketDetailShimmer(),
        ),
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
    super.key,
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
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final Iterable<TicketStatus> nextStatuses = workflow.nextOptions(
      ticket.status,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: <Widget>[
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ErrorCard(message: errorMessage!, onDismiss: controller.clearError),
          ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  ticket.title,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    StatusChip(status: ticket.status),
                    AbsorbPointer(
                      child: AssistChip(
                        onPressed: () {},
                        icon: const Icon(Icons.category_outlined),
                        label: Text(ticket.category.label),
                      ),
                    ),
                    AbsorbPointer(
                      child: InputChip(
                        onPressed: () {},
                        avatar: const Icon(Icons.person_outline, size: 18),
                        label: Text(ticket.requesterName),
                      ),
                    ),
                    if (ticket.assignedTechnician != null)
                      AbsorbPointer(
                        child: InputChip(
                          onPressed: () {},
                          avatar: const Icon(Icons.engineering, size: 18),
                          label: Text(ticket.assignedTechnician!.name),
                        ),
                      ),
                    if (ticket.isAltaRmFg)
                      AbsorbPointer(
                        child: AssistChip(
                          onPressed: () {},
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text('Alta RM/FG'),
                        ),
                      ),
                  ],
                ),
                const Divider(height: 32),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _DetailTile(
                        icon: Icons.confirmation_number_outlined,
                        label: 'Folio',
                        value: '#${ticket.folio}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DetailTile(
                        icon: Icons.calendar_today_outlined,
                        label: 'Creado',
                        value:
                            '${localizations.formatMediumDate(ticket.createdAt)} · ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(ticket.createdAt))}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (ticket.resolvedAt != null)
                  _DetailTile(
                    icon: Icons.check_circle_outline,
                    label: 'Resuelto',
                    value:
                        '${localizations.formatMediumDate(ticket.resolvedAt!)} · ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(ticket.resolvedAt!))}',
                  ),
                if (ticket.resolvedAt != null) const SizedBox(height: 12),
                Text(
                  ticket.description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                      (TicketStatus status) => FilledButton.icon(
                        onPressed: () => onChangeStatus(status),
                        icon: Icon(_statusActionIcon(status)),
                        label: Text(status.label),
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
        const SizedBox(height: 24),
        Text('Histórico', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        _TicketHistory(history: history),
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
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: technicians.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (BuildContext context, int index) {
              final Technician tech = technicians[index];
              return ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(tech.name),
                subtitle: Text(tech.email),
                onTap: () => Navigator.of(context).pop(tech),
              );
            },
          ),
        );
      },
    );
    if (technician != null) {
      await onAssignTechnician(technician);
    }
  }
}

class _TicketHistory extends StatelessWidget {
  const _TicketHistory({required this.history});

  final AsyncValue<List<TicketEvent>> history;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    return history.when(
      data: (List<TicketEvent> events) {
        if (events.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: EmptyState(
                title: 'Sin eventos registrados',
                message: 'Los movimientos del ticket aparecerán aquí.',
                icon: Icons.timeline_outlined,
              ),
            ),
          );
        }
        return Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int index) {
              final TicketEvent event = events[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    _eventIcon(event.type),
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(event.message),
                subtitle: Text(
                  '${localizations.formatMediumDate(event.createdAt)} · ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(event.createdAt))}\nPor: ${event.author}',
                ),
              );
            },
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ShimmerPlaceholder(height: 160),
        ),
      ),
      error: (Object error, StackTrace stackTrace) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: ErrorCard(message: 'Error histórico: $error'),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TechnicianShimmer extends StatelessWidget {
  const _TechnicianShimmer();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 180, child: ShimmerPlaceholder(height: 48));
  }
}

class _TicketDetailShimmer extends StatelessWidget {
  const _TicketDetailShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: const <Widget>[
        ShimmerPlaceholder(height: 220),
        SizedBox(height: 16),
        ShimmerPlaceholder(height: 160),
        SizedBox(height: 24),
        ShimmerPlaceholder(height: 200),
      ],
    );
  }
}

IconData _eventIcon(TicketEventType type) {
  switch (type) {
    case TicketEventType.comment:
      return Icons.chat_bubble_outline;
    case TicketEventType.statusChange:
      return Icons.swap_horiz;
    case TicketEventType.assignment:
      return Icons.engineering;
    case TicketEventType.document:
      return Icons.picture_as_pdf_outlined;
  }
}

IconData _statusActionIcon(TicketStatus status) {
  switch (status) {
    case TicketStatus.nuevo:
      return Icons.fiber_new;
    case TicketStatus.enRevision:
      return Icons.search;
    case TicketStatus.enProceso:
      return Icons.autorenew;
    case TicketStatus.resuelto:
      return Icons.check_circle_outline;
    case TicketStatus.cerrado:
      return Icons.lock_outline;
  }
}
