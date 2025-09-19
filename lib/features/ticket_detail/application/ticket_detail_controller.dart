import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sistema_tickets_edis/app/providers.dart';
import 'package:sistema_tickets_edis/core/errors/failure.dart';
import 'package:sistema_tickets_edis/domain/entities/alta_document_result.dart';
import 'package:sistema_tickets_edis/domain/entities/session_user.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket_event.dart';
import 'package:sistema_tickets_edis/domain/entities/technician.dart';
import 'package:sistema_tickets_edis/domain/repositories/ticket_repository.dart';
import 'package:sistema_tickets_edis/domain/usecases/add_ticket_comment.dart';
import 'package:sistema_tickets_edis/domain/usecases/assign_technician.dart';
import 'package:sistema_tickets_edis/domain/usecases/generate_rm_fg_documents.dart';
import 'package:sistema_tickets_edis/domain/usecases/update_ticket_status.dart';
import 'package:sistema_tickets_edis/domain/value_objects/ticket_filters.dart';

final ticketDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<TicketDetailController, TicketDetailState, int>((ref, ticketId) {
  final TicketRepository repository = ref.watch(ticketRepositoryProvider);
  final UpdateTicketStatus updateStatus = ref.watch(
    updateTicketStatusProvider,
  );
  final AssignTechnician assignTechnician = ref.watch(
    assignTechnicianProvider,
  );
  final AddTicketComment addComment = ref.watch(addTicketCommentProvider);
  final GenerateRmFgDocuments generateRmFg = ref.watch(
    generateRmFgDocumentsProvider,
  );
  final SessionUser? session = ref.watch(currentSessionProvider);
  return TicketDetailController(
    repository,
    updateStatus,
    assignTechnician,
    addComment,
    generateRmFg,
    ticketId,
    session,
  );
});

class TicketDetailState {
  const TicketDetailState({
    this.ticket = const AsyncValue.loading(),
    this.history = const AsyncValue.loading(),
    this.errorMessage,
  });

  final AsyncValue<Ticket> ticket;
  final AsyncValue<List<TicketEvent>> history;
  final String? errorMessage;

  TicketDetailState copyWith({
    AsyncValue<Ticket>? ticket,
    AsyncValue<List<TicketEvent>>? history,
    String? errorMessage,
  }) {
    return TicketDetailState(
      ticket: ticket ?? this.ticket,
      history: history ?? this.history,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class TicketDetailController extends StateNotifier<TicketDetailState> {
  TicketDetailController(
    this._repository,
    this._updateStatus,
    this._assignTechnician,
    this._addComment,
    this._generateRmFgDocuments,
    this._ticketId,
    this._sessionUser,
  ) : super(const TicketDetailState()) {
    _init();
  }

  final TicketRepository _repository;
  final UpdateTicketStatus _updateStatus;
  final AssignTechnician _assignTechnician;
  final AddTicketComment _addComment;
  final GenerateRmFgDocuments _generateRmFgDocuments;
  final int _ticketId;
  final SessionUser? _sessionUser;
  StreamSubscription<List<Ticket>>? _ticketSubscription;
  StreamSubscription<List<TicketEvent>>? _historySubscription;

  Future<void> _init() async {
    state = state.copyWith(
      ticket: const AsyncValue.loading(),
      history: const AsyncValue.loading(),
    );
    try {
      final Ticket? ticket = await _repository.findTicket(_ticketId);
      if (ticket == null || !_hasAccess(ticket)) {
        state = state.copyWith(
          ticket: AsyncValue.error(
            NotFoundFailure('Ticket $_ticketId no disponible'),
            StackTrace.current,
          ),
        );
        return;
      }
      state = state.copyWith(ticket: AsyncValue.data(ticket));
    } catch (error, stackTrace) {
      state = state.copyWith(ticket: AsyncValue.error(error, stackTrace));
    }
    _ticketSubscription = _repository.watchTickets(filter: _filterForSession()).listen((
      List<Ticket> tickets,
    ) {
      final Ticket? ticket = tickets.firstWhereOrNull(
        (Ticket element) => element.id == _ticketId,
      );
      if (ticket != null && _hasAccess(ticket)) {
        state = state.copyWith(ticket: AsyncValue.data(ticket));
      }
    });
    _historySubscription = _repository.watchTicketHistory(_ticketId).listen(
          (List<TicketEvent> events) =>
              state = state.copyWith(history: AsyncValue.data(events)),
          onError: (Object error, StackTrace stackTrace) => state =
              state.copyWith(history: AsyncValue.error(error, stackTrace)),
        );
  }

  Future<void> changeStatus(
    TicketStatus status, {
    String author = 'Coordinador',
    String? comment,
  }) async {
    if (!(_sessionUser?.role.isAdmin ?? false)) {
      return;
    }
    try {
      await _updateStatus(
        ticketId: _ticketId,
        nextStatus: status,
        author: author,
        comment: comment,
      );
      state = state.copyWith(errorMessage: null);
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  Future<void> assignTechnician(
    Technician technician, {
    String? comment,
  }) async {
    if (!(_sessionUser?.role.isAdmin ?? false)) {
      return;
    }
    try {
      await _assignTechnician(
        ticketId: _ticketId,
        technician: technician,
        comment: comment,
      );
      state = state.copyWith(errorMessage: null);
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  Future<void> addComment(
    String message, {
    String author = 'Usuario',
    Map<String, dynamic>? metadata,
  }) async {
    if (!(_sessionUser?.role.isAdmin ?? false)) {
      return;
    }
    try {
      await _addComment(
        ticketId: _ticketId,
        message: message,
        author: author,
        metadata: metadata,
      );
      state = state.copyWith(errorMessage: null);
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  Future<AltaDocumentResult> generateDocuments() =>
      _generateRmFgDocuments(_ticketId);

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  TicketFilter _filterForSession() {
    if (_sessionUser == null || _sessionUser!.role.isAdmin) {
      return const TicketFilter();
    }
    return TicketFilter(requesterId: _sessionUser!.user.id);
  }

  bool _hasAccess(Ticket ticket) {
    if (_sessionUser == null || _sessionUser!.role.isAdmin) {
      return true;
    }
    return ticket.requester.id == _sessionUser!.user.id;
  }

  @override
  void dispose() {
    _ticketSubscription?.cancel();
    _historySubscription?.cancel();
    super.dispose();
  }
}
