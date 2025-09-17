import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sistema_tickets_edis/domain/entities/catalog.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket.dart';
import 'package:sistema_tickets_edis/features/ticket_form/application/ticket_form_controller.dart';
import 'package:sistema_tickets_edis/features/shared/presentation/widgets/error_card.dart';
import 'package:sistema_tickets_edis/features/shared/presentation/widgets/shimmer_placeholder.dart';

class TicketFormPage extends ConsumerStatefulWidget {
  const TicketFormPage({super.key});

  @override
  ConsumerState<TicketFormPage> createState() => _TicketFormPageState();
}

class _TicketFormPageState extends ConsumerState<TicketFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _requesterController = TextEditingController();

  CatalogEntry? _cliente;
  CatalogEntry? _destino;
  CatalogEntry? _material;
  CatalogEntry? _norma;
  CatalogEntry? _propQui;
  CatalogEntry? _propMec;
  CatalogEntry? _numeroParte;
  late final ProviderSubscription<TicketFormState> _subscription;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _subscription = ref.listenManual<TicketFormState>(
      ticketFormControllerProvider,
      (TicketFormState? prev, TicketFormState next) {
        if (!mounted) return;
        if (next.createdTicket != null &&
            next.createdTicket != prev?.createdTicket) {
          final Ticket ticket = next.createdTicket!;
          _showBanner('Ticket ${ticket.folio} creado correctamente');
          context.go('/tickets/${ticket.id}');
        }
      },
    );
  }

  @override
  void dispose() {
    _subscription.close();
    _titleController.dispose();
    _descriptionController.dispose();
    _requesterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TicketFormState state = ref.watch(ticketFormControllerProvider);
    final TicketFormController controller = ref.read(
      ticketFormControllerProvider.notifier,
    );
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar ticket')),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                children: <Widget>[
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Column(
                      children: <Widget>[
                        if (state.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ErrorCard(
                              message: state.errorMessage!,
                              onDismiss: controller.clearError,
                            ),
                          ),
                        if (_formError != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ErrorCard(
                              message: _formError!,
                              onDismiss: () => setState(() => _formError = null),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Información general', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<TicketCategory>(
                            value: state.category,
                            decoration: const InputDecoration(
                              labelText: 'Categoría',
                            ),
                            items: TicketCategory.values
                                .map(
                                  (TicketCategory category) =>
                                      DropdownMenuItem<TicketCategory>(
                                    value: category,
                                    child: Text(category.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (TicketCategory? value) {
                              if (value != null) {
                                controller.setCategory(value);
                                if (_formError != null) {
                                  setState(() => _formError = null);
                                }
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Título',
                            ),
                            validator: (String? value) =>
                                (value == null || value.isEmpty) ? 'Ingresa un título' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Descripción',
                            ),
                            validator: (String? value) => (value == null || value.isEmpty)
                                ? 'Describe el requerimiento'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _requesterController,
                            decoration: const InputDecoration(
                              labelText: 'Solicitante',
                            ),
                            validator: (String? value) => (value == null || value.isEmpty)
                                ? 'Indica el solicitante'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (state.category == TicketCategory.altaNoParteRmFg) ...<Widget>[
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: _buildAltaSection(ref),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton.icon(
                onPressed: state.isSubmitting
                    ? null
                    : () => _handleSubmit(controller, state),
                icon: state.isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: const Text('Enviar ticket'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBanner(String message, {bool isError = false}) {
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

  Widget _buildAltaSection(WidgetRef ref) {
    final AsyncValue<List<CatalogEntry>> clientes = ref.watch(
      catalogEntriesProvider(CatalogType.cliente),
    );
    final AsyncValue<List<CatalogEntry>> destinos = ref.watch(
      catalogEntriesProvider(CatalogType.destino),
    );
    final AsyncValue<List<CatalogEntry>> materiales = ref.watch(
      catalogEntriesProvider(CatalogType.material),
    );
    final AsyncValue<List<CatalogEntry>> normas = ref.watch(
      catalogEntriesProvider(CatalogType.norma),
    );
    final AsyncValue<List<CatalogEntry>> propQui = ref.watch(
      catalogEntriesProvider(CatalogType.propiedadesQuimicas),
    );
    final AsyncValue<List<CatalogEntry>> propMec = ref.watch(
      catalogEntriesProvider(CatalogType.propiedadesMecanicas),
    );
    final AsyncValue<List<CatalogEntry>> numerosParte = ref.watch(
      catalogEntriesProvider(CatalogType.numeroParte),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Datos RM/FG', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        _CatalogDropdown(
          label: 'Cliente',
          asyncValue: clientes,
          value: _cliente,
          onChanged: (CatalogEntry? value) => setState(() => _cliente = value),
        ),
        const SizedBox(height: 12),
        _CatalogDropdown(
          label: 'Destino',
          asyncValue: destinos,
          value: _destino,
          onChanged: (CatalogEntry? value) => setState(() => _destino = value),
        ),
        const SizedBox(height: 12),
        _CatalogDropdown(
          label: 'Material',
          asyncValue: materiales,
          value: _material,
          onChanged: (CatalogEntry? value) => setState(() => _material = value),
        ),
        const SizedBox(height: 12),
        _CatalogDropdown(
          label: 'Norma',
          asyncValue: normas,
          value: _norma,
          onChanged: (CatalogEntry? value) => setState(() => _norma = value),
        ),
        const SizedBox(height: 12),
        _CatalogDropdown(
          label: 'Propiedades químicas',
          asyncValue: propQui,
          value: _propQui,
          onChanged: (CatalogEntry? value) => setState(() => _propQui = value),
        ),
        const SizedBox(height: 12),
        _CatalogDropdown(
          label: 'Propiedades mecánicas',
          asyncValue: propMec,
          value: _propMec,
          onChanged: (CatalogEntry? value) => setState(() => _propMec = value),
        ),
        const SizedBox(height: 12),
        _CatalogDropdown(
          label: 'Número de parte',
          asyncValue: numerosParte,
          value: _numeroParte,
          onChanged: (CatalogEntry? value) =>
              setState(() => _numeroParte = value),
        ),
      ],
    );
  }

  Future<void> _handleSubmit(
    TicketFormController controller,
    TicketFormState state,
  ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _formError = null);
    TicketAltaDetails? altaDetails;
    if (state.category == TicketCategory.altaNoParteRmFg) {
      if (_cliente == null ||
          _destino == null ||
          _material == null ||
          _norma == null ||
          _propQui == null ||
          _propMec == null ||
          _numeroParte == null) {
        setState(() {
          _formError = 'Completa los datos RM/FG';
        });
        return;
      }
      altaDetails = TicketAltaDetails(
        cliente: _cliente!,
        destino: _destino!,
        material: _material!,
        norma: _norma!,
        propiedadesQuimicas: _propQui!,
        propiedadesMecanicas: _propMec!,
        numeroParte: _numeroParte!,
      );
    }
    await controller.submit(
      title: _titleController.text,
      description: _descriptionController.text,
      requester: _requesterController.text,
      altaDetails: altaDetails,
    );
  }
}

class _CatalogDropdown extends StatelessWidget {
  const _CatalogDropdown({
    required this.label,
    required this.asyncValue,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final AsyncValue<List<CatalogEntry>> asyncValue;
  final CatalogEntry? value;
  final ValueChanged<CatalogEntry?> onChanged;

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      data: (List<CatalogEntry> entries) => DropdownButtonFormField<CatalogEntry>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
        ),
        items: entries
            .map(
              (CatalogEntry entry) => DropdownMenuItem<CatalogEntry>(
                value: entry,
                child: Text('${entry.code} · ${entry.description}'),
              ),
            )
            .toList(),
        onChanged: onChanged,
        validator: (CatalogEntry? selected) =>
            selected == null ? 'Selecciona $label' : null,
      ),
      loading: () => const ShimmerPlaceholder(height: 56),
      error: (Object error, StackTrace stackTrace) =>
          ErrorCard(message: 'Error al cargar $label: $error'),
    );
  }
}
