import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sistema_tickets_edis/app/providers.dart';
import 'package:sistema_tickets_edis/domain/entities/catalog.dart';
import 'package:sistema_tickets_edis/domain/entities/session_user.dart';
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
    final SessionUser? session = ref.watch(currentSessionProvider);
    final bool isAdmin = session?.role.isAdmin ?? false;
    final bool useImplicitRequester = session?.role.isUser ?? false;
    final bool showRequesterField = session == null || isAdmin;
    if (isAdmin && session != null && _requesterController.text.isEmpty) {
      _requesterController.text = session.user.name;
    } else if (!showRequesterField && _requesterController.text.isNotEmpty) {
      _requesterController.clear();
    }

    return Scaffold(
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: <Widget>[
            SliverAppBar.large(title: const Text('Nuevo ticket')),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: Column(
                        key: ValueKey<String>(
                          '${state.errorMessage ?? ''}${_formError ?? ''}',
                        ),
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
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Información general',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 20),
                            DropdownButtonFormField<TicketCategory>(
                              value: state.category,
                              decoration: _inputDecoration(
                                context,
                                label: 'Categoría del ticket',
                                hint: 'Selecciona el motivo principal',
                                icon: Icons.category_outlined,
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
                              validator: (TicketCategory? value) =>
                                  value == null ? 'Selecciona una categoría' : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _titleController,
                              decoration: _inputDecoration(
                                context,
                                label: 'Título del ticket',
                                hint: 'Ej. Falla en el servidor de correo',
                                icon: Icons.subject_outlined,
                              ),
                              validator: (String? value) =>
                                  (value == null || value.isEmpty) ? 'Ingresa un título' : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 5,
                              decoration: _inputDecoration(
                                context,
                                label: 'Descripción detallada',
                                hint: 'Cuéntanos qué ocurre o qué necesitas resolver',
                                icon: Icons.chat_outlined,
                              ),
                              validator: (String? value) => (value == null || value.isEmpty)
                                  ? 'Describe el requerimiento'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            if (showRequesterField)
                              TextFormField(
                                controller: _requesterController,
                                decoration: _inputDecoration(
                                  context,
                                  label: 'Nombre del solicitante',
                                  hint: 'Ej. Laura Martínez',
                                  icon: Icons.person_outline,
                                ),
                                validator: (String? value) =>
                                    (value == null || value.isEmpty)
                                        ? 'Indica el solicitante'
                                        : null,
                              )
                            else if (session != null)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer
                                      .withOpacity(0.38),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(
                                      Icons.verified_user_outlined,
                                      color: theme.colorScheme.onSecondaryContainer,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            session.user.name,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  theme.colorScheme.onSecondaryContainer,
                                            ),
                                          ),
                                          if (session.user.email != null &&
                                              session.user.email!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Text(
                                                session.user.email!,
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: theme
                                                      .colorScheme.onSecondaryContainer
                                                      .withOpacity(0.85),
                                                ),
                                              ),
                                            ),
                                          const SizedBox(height: 8),
                                          Text(
                                            useImplicitRequester
                                                ? 'Tus tickets quedarán asociados automáticamente a tu cuenta.'
                                                : 'Creando ticket como parte del equipo de TI.',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme
                                                  .colorScheme.onSecondaryContainer
                                                  .withOpacity(0.9),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (state.category == TicketCategory.altaNoParteRmFg) ...<Widget>[
                      const SizedBox(height: 20),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: _buildAltaSection(ref),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: FilledButton.icon(
          onPressed: state.isSubmitting
              ? null
              : () => _handleSubmit(controller, state, session, showRequesterField),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            textStyle: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          icon: state.isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send_rounded),
          label: const Text('Enviar ticket'),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    String? hint,
    IconData? icon,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon) : null,
      filled: true,
      fillColor: scheme.surfaceVariant.withOpacity(0.24),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: scheme.outlineVariant.withOpacity(0.6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
          icon: Icons.apartment_outlined,
          asyncValue: clientes,
          value: _cliente,
          onChanged: (CatalogEntry? value) => setState(() => _cliente = value),
        ),
        const SizedBox(height: 12),
        _CatalogDropdown(
          label: 'Destino',
          icon: Icons.place_outlined,
          asyncValue: destinos,
          value: _destino,
          onChanged: (CatalogEntry? value) => setState(() => _destino = value),
        ),
        const SizedBox(height: 12),
        _CatalogDropdown(
          label: 'Material',
          icon: Icons.layers_outlined,
          asyncValue: materiales,
          value: _material,
          onChanged: (CatalogEntry? value) => setState(() => _material = value),
        ),
        const SizedBox(height: 12),
        _CatalogDropdown(
          label: 'Norma',
          icon: Icons.rule_folder_outlined,
          asyncValue: normas,
          value: _norma,
          onChanged: (CatalogEntry? value) => setState(() => _norma = value),
        ),
        const SizedBox(height: 12),
        _CatalogDropdown(
          label: 'Propiedades químicas',
          icon: Icons.science_outlined,
          asyncValue: propQui,
          value: _propQui,
          onChanged: (CatalogEntry? value) => setState(() => _propQui = value),
        ),
        const SizedBox(height: 12),
        _CatalogDropdown(
          label: 'Propiedades mecánicas',
          icon: Icons.handyman_outlined,
          asyncValue: propMec,
          value: _propMec,
          onChanged: (CatalogEntry? value) => setState(() => _propMec = value),
        ),
        const SizedBox(height: 12),
        _CatalogDropdown(
          label: 'Número de parte',
          icon: Icons.confirmation_number_outlined,
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
    SessionUser? session,
    bool showRequesterField,
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
      requester: showRequesterField ? _requesterController.text : null,
      requesterEmail: session?.user.email,
      altaDetails: altaDetails,
      sessionUser: !showRequesterField ? session : null,
    );
  }
}

class _CatalogDropdown extends StatelessWidget {
  const _CatalogDropdown({
    required this.label,
    required this.asyncValue,
    required this.value,
    required this.onChanged,
    this.icon,
  });

  final String label;
  final AsyncValue<List<CatalogEntry>> asyncValue;
  final CatalogEntry? value;
  final ValueChanged<CatalogEntry?> onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return asyncValue.when(
      data: (List<CatalogEntry> entries) => DropdownButtonFormField<CatalogEntry>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Selecciona $label',
          prefixIcon: icon != null ? Icon(icon) : null,
          filled: true,
          fillColor: scheme.surfaceVariant.withOpacity(0.24),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: scheme.outlineVariant.withOpacity(0.6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: scheme.primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
      loading: () => const ShimmerPlaceholder(
        height: 56,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      error: (Object error, StackTrace stackTrace) =>
          ErrorCard(message: 'Error al cargar $label: $error'),
    );
  }
}
