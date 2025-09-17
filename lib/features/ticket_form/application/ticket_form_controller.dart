import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sistema_tickets_edis/app/providers.dart';
import 'package:sistema_tickets_edis/domain/entities/catalog.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket.dart';
import 'package:sistema_tickets_edis/domain/entities/user.dart';
import 'package:sistema_tickets_edis/domain/usecases/create_ticket.dart';

final catalogEntriesProvider =
    FutureProvider.family<List<CatalogEntry>, CatalogType>((ref, type) {
  final repository = ref.watch(ticketRepositoryProvider);
  return repository.getCatalogEntries(type);
});

final ticketFormControllerProvider =
    StateNotifierProvider.autoDispose<TicketFormController, TicketFormState>((
  ref,
) {
  final CreateTicket createTicket = ref.watch(createTicketProvider);
  return TicketFormController(createTicket);
});

class TicketFormState {
  const TicketFormState({
    this.category = TicketCategory.altaNoParteRmFg,
    this.isSubmitting = false,
    this.createdTicket,
    this.errorMessage,
  });

  final TicketCategory category;
  final bool isSubmitting;
  final Ticket? createdTicket;
  final String? errorMessage;

  TicketFormState copyWith({
    TicketCategory? category,
    bool? isSubmitting,
    Ticket? createdTicket,
    String? errorMessage,
  }) {
    return TicketFormState(
      category: category ?? this.category,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      createdTicket: createdTicket ?? this.createdTicket,
      errorMessage: errorMessage,
    );
  }
}

class TicketFormController extends StateNotifier<TicketFormState> {
  TicketFormController(this._createTicket) : super(const TicketFormState());

  final CreateTicket _createTicket;

  void setCategory(TicketCategory category) {
    state = state.copyWith(category: category, errorMessage: null);
  }

  Future<void> submit({
    required String title,
    required String description,
    required String requester,
    String? requesterEmail,
    TicketAltaDetails? altaDetails,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final String normalizedName = requester.trim();
      final String? normalizedEmail =
          requesterEmail != null && requesterEmail.trim().isNotEmpty
              ? requesterEmail.trim()
              : null;
      final TicketDraft draft = TicketDraft(
        title: title,
        description: description,
        requester: User(id: 0, name: normalizedName, email: normalizedEmail),
        category: state.category,
        altaDetails: state.category == TicketCategory.altaNoParteRmFg
            ? altaDetails
            : null,
      );
      final Ticket ticket = await _createTicket(draft);
      state = state.copyWith(isSubmitting: false, createdTicket: ticket);
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
