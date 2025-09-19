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
  const TicketFormPage({super.key, TicketCategory? initialCategory})
      : initialCategory = initialCategory ?? TicketCategory.altaNoParteRmFg;

  final TicketCategory initialCategory;

  @override
  ConsumerState<TicketFormPage> createState() => _TicketFormPageState();
}

class _TicketFormPageState extends ConsumerState<TicketFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _requesterController = TextEditingController();

  static const Map<TicketCategory, _CategoryInfo> _categoryInfo =
      <TicketCategory, _CategoryInfo>{
    TicketCategory.altaNoParteRmFg: _CategoryInfo(
      title: 'Alta de número de parte (RM/FG)',
      tagline: 'Prepara la ficha técnica para nuevos materiales.',
      description:
          'Captura cliente, destino, norma y propiedades para iniciar la autorización.',
      icon: Icons.inventory_2_outlined,
    ),
    TicketCategory.soporteEdi: _CategoryInfo(
      title: 'Soporte EDI',
      tagline: 'Dale seguimiento a integraciones electrónicas.',
      description:
          'Reporta incidencias con archivos, transacciones o conectores de intercambio.',
      icon: Icons.cloud_sync_outlined,
    ),
    TicketCategory.incidenciaUsuario: _CategoryInfo(
      title: 'Incidencia de usuario',
      tagline: 'Atiende una falla o comportamiento inusual.',
      description:
          'Describe qué dejó de funcionar para que TI priorice y dé seguimiento.',
      icon: Icons.report_problem_outlined,
    ),
    TicketCategory.solicitudTi: _CategoryInfo(
      title: 'Solicitud TI',
      tagline: 'Pide configuraciones, accesos o acompañamiento.',
      description:
          'Solicita apoyo para nuevas cuentas, instalaciones o mejoras de servicios TI.',
      icon: Icons.handyman_outlined,
    ),
  };

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(ticketFormControllerProvider.notifier)
          .setCategory(widget.initialCategory);
    });
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
    final TicketCategory selectedCategory = state.category;
    final _CategoryInfo categoryInfo = _categoryInfo[selectedCategory]!;
    final Color accent = _categoryAccent(theme.colorScheme, selectedCategory);

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
            SliverAppBar.large(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('Nuevo ticket'),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        categoryInfo.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    categoryInfo.tagline,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
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
                              'Tipo de solicitud',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildCategorySelector(
                              state,
                              controller,
                              theme,
                              theme.colorScheme,
                            ),
                            const SizedBox(height: 16),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 240),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              child: _buildCategorySummary(
                                categoryInfo,
                                accent,
                                theme,
                                selectedCategory,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Divider(
                              height: 32,
                              thickness: 1,
                              color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Información general',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
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

  Widget _buildCategorySelector(
    TicketFormState state,
    TicketFormController controller,
    ThemeData theme,
    ColorScheme scheme,
  ) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final bool multiColumn = availableWidth >= 640;
        const double spacing = 12;
        final double targetWidth = multiColumn
            ? (availableWidth - spacing) / 2
            : availableWidth;
        final double itemWidth = targetWidth.clamp(260, availableWidth).toDouble();
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: TicketCategory.values.map((TicketCategory category) {
            final bool selected = state.category == category;
            final _CategoryInfo info = _categoryInfo[category]!;
            final Color accent = _categoryAccent(scheme, category);
            return SizedBox(
              width: multiColumn ? itemWidth : availableWidth,
              child: _CategoryOption(
                info: info,
                accent: accent,
                selected: selected,
                onTap: () => _onSelectCategory(controller, category),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCategorySummary(
    _CategoryInfo info,
    Color accent,
    ThemeData theme,
    TicketCategory category,
  ) {
    final ColorScheme scheme = theme.colorScheme;
    return AnimatedContainer(
      key: ValueKey<TicketCategory>(category),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(info.icon, color: accent, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  info.tagline,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  info.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withOpacity(0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onSelectCategory(
    TicketFormController controller,
    TicketCategory category,
  ) {
    controller.setCategory(category);
    setState(() {
      if (_formError != null) {
        _formError = null;
      }
      if (category != TicketCategory.altaNoParteRmFg) {
        _cliente = null;
        _destino = null;
        _material = null;
        _norma = null;
        _propQui = null;
        _propMec = null;
        _numeroParte = null;
      }
    });
  }

  Color _categoryAccent(ColorScheme scheme, TicketCategory category) {
    switch (category) {
      case TicketCategory.altaNoParteRmFg:
        return scheme.primary;
      case TicketCategory.soporteEdi:
        return scheme.tertiary;
      case TicketCategory.incidenciaUsuario:
        return scheme.error;
      case TicketCategory.solicitudTi:
        return scheme.secondary;
    }
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

class _CategoryOption extends StatelessWidget {
  const _CategoryOption({
    required this.info,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final _CategoryInfo info;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected
            ? accent.withOpacity(0.16)
            : scheme.surfaceVariant.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? accent
              : scheme.outlineVariant.withOpacity(0.5),
          width: selected ? 1.6 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(info.icon, color: accent),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        info.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        info.tagline,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 24,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: selected ? 1 : 0,
                    child: Icon(Icons.check_circle, color: accent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryInfo {
  const _CategoryInfo({
    required this.title,
    required this.tagline,
    required this.description,
    required this.icon,
  });

  final String title;
  final String tagline;
  final String description;
  final IconData icon;
}
