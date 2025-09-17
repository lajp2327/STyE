import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sistema_tickets_edis/app/providers.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket.dart';
import 'package:sistema_tickets_edis/domain/repositories/ticket_repository.dart';
import 'package:sistema_tickets_edis/domain/value_objects/ticket_filters.dart';

final ticketFilterProvider = StateProvider<TicketFilter>((ref) => const TicketFilter());

final ticketListControllerProvider =
    StateNotifierProvider<TicketListController, AsyncValue<List<Ticket>>>((ref) {
  final TicketRepository repository = ref.watch(ticketRepositoryProvider);
  return TicketListController(repository, ref);
});

class TicketListController extends StateNotifier<AsyncValue<List<Ticket>>> {
  TicketListController(this._repository, this._ref) : super(const AsyncValue.loading()) {
    _filter = _ref.read(ticketFilterProvider);
    _listen();
    _filterSubscription = _ref.listen<TicketFilter>(ticketFilterProvider, (TicketFilter? previous, TicketFilter next) {
      if (previous == next) {
        return;
      }
      _filter = next;
      _listen();
    });
  }

  final TicketRepository _repository;
  final Ref _ref;
  late TicketFilter _filter;
  StreamSubscription<List<Ticket>>? _ticketsSubscription;
  late final ProviderSubscription<TicketFilter> _filterSubscription;

  void _listen() {
    _ticketsSubscription?.cancel();
    state = const AsyncValue.loading();
    _ticketsSubscription = _repository.watchTickets(filter: _filter).listen(
      (List<Ticket> tickets) => state = AsyncValue.data(tickets),
      onError: (Object error, StackTrace stackTrace) => state = AsyncValue.error(error, stackTrace),
    );
  }

  @override
  void dispose() {
    _ticketsSubscription?.cancel();
    _filterSubscription.close();
    super.dispose();
  }
}
