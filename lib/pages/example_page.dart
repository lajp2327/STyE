import 'package:flutter/material.dart';

import '../models/ticket.dart';
import '../services/auth_service.dart';
import '../services/dataverse_api.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage({
    super.key,
    required this.authService,
    required this.dataverseApi,
    required this.onLogout,
  });

  final AuthService authService;
  final DataverseApi dataverseApi;
  final VoidCallback onLogout;

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  bool _isLoadingTickets = false;
  bool _isCreating = false;
  List<Ticket> _tickets = <Ticket>[];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priorityController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    setState(() {
      _isLoadingTickets = true;
    });
    try {
      final List<Ticket> tickets = await widget.dataverseApi.getTickets();
      if (!mounted) {
        return;
      }
      setState(() {
        _tickets = tickets;
      });
    } catch (error) {
      _showErrorSnackBar('No fue posible cargar los tickets: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTickets = false;
        });
      }
    }
  }

  Future<void> _createTicket() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
    });

    final String title = _titleController.text.trim();
    final String priority = _priorityController.text.trim();
    final String status = _statusController.text.trim();

    try {
      final Ticket ticket = await widget.dataverseApi.createTicket(
        title: title,
        priority: priority,
        status: status,
      );
      if (!mounted) {
        return;
      }
      _titleController.clear();
      _priorityController.clear();
      _statusController.clear();
      setState(() {
        _tickets = <Ticket>[ticket, ..._tickets];
      });
      _showSnackBar('Ticket creado correctamente.');
    } catch (error) {
      _showErrorSnackBar('No fue posible crear el ticket: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Future<void> _showEditDialog(Ticket ticket) async {
    final TextEditingController titleController =
        TextEditingController(text: ticket.title);
    final TextEditingController priorityController =
        TextEditingController(text: ticket.priority);
    final TextEditingController statusController =
        TextEditingController(text: ticket.status);
    final GlobalKey<FormState> editFormKey = GlobalKey<FormState>();
    bool isSaving = false;

    final bool? updated = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setStateDialog) {
            return AlertDialog(
              title: const Text('Editar ticket'),
              content: Form(
                key: editFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Título'),
                      validator: _requiredValidator,
                    ),
                    TextFormField(
                      controller: priorityController,
                      decoration: const InputDecoration(labelText: 'Prioridad'),
                      validator: _requiredValidator,
                    ),
                    TextFormField(
                      controller: statusController,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      validator: _requiredValidator,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!editFormKey.currentState!.validate()) {
                            return;
                          }
                          setStateDialog(() {
                            isSaving = true;
                          });
                          try {
                            await widget.dataverseApi.updateTicket(
                              ticket.id,
                              title: titleController.text.trim(),
                              priority: priorityController.text.trim(),
                              status: statusController.text.trim(),
                            );
                            if (mounted) {
                              _showSnackBar('Ticket actualizado.');
                            }
                            if (context.mounted) {
                              Navigator.of(context).pop(true);
                            }
                          } catch (error) {
                            if (mounted) {
                              _showErrorSnackBar('Error al actualizar: $error');
                            }
                            setStateDialog(() {
                              isSaving = false;
                            });
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (updated == true) {
      await _loadTickets();
    }

    titleController.dispose();
    priorityController.dispose();
    statusController.dispose();
  }

  Future<void> _confirmDelete(Ticket ticket) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar ticket'),
          content: Text('¿Eliminar "${ticket.title}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_forever),
              label: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        await widget.dataverseApi.deleteTicket(ticket.id);
        if (!mounted) {
          return;
        }
        setState(() {
          _tickets = _tickets.where((Ticket t) => t.id != ticket.id).toList();
        });
        _showSnackBar('Ticket eliminado.');
      } catch (error) {
        _showErrorSnackBar('No fue posible eliminar el ticket: $error');
      }
    }
  }

  Future<void> _logout() async {
    try {
      await widget.authService.logout();
      if (!mounted) {
        return;
      }
      _showSnackBar('Sesión cerrada.');
    } finally {
      widget.onLogout();
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
    }
    return null;
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final bool isPreview = widget.dataverseApi.isPreview;

    final Widget listContent = _isLoadingTickets && _tickets.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadTickets,
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: <Widget>[
                if (isPreview)
                  Card(
                    color: theme.colorScheme.surfaceVariant,
                    child: ListTile(
                      leading: Icon(
                        Icons.visibility_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('Modo demo sin conexión'),
                      subtitle: const Text(
                        'Los tickets se almacenan solo en memoria y no se '
                        'envían a Dataverse. Compila sin WEB_PREVIEW para '
                        'usar la integración real.',
                      ),
                    ),
                  ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Test de humo',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '1. Pulsa "Crear ticket" tras iniciar sesión para ejecutar createTicket().\n'
                          '2. La lista inferior usa getTickets() tras el login.\n'
                          '3. Usa los botones de cada item para PATCH/DELETE.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Crear ticket',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Título',
                              hintText: 'Ej. Falla en impresora',
                            ),
                            validator: _requiredValidator,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _priorityController,
                            decoration: const InputDecoration(
                              labelText: 'Prioridad',
                              hintText: 'Ej. Alta',
                            ),
                            validator: _requiredValidator,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _statusController,
                            decoration: const InputDecoration(
                              labelText: 'Estado',
                              hintText: 'Ej. Abierto',
                            ),
                            validator: _requiredValidator,
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: _isCreating ? null : _createTicket,
                              icon: _isCreating
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.send),
                              label: Text(_isCreating ? 'Guardando...' : 'Crear ticket'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tickets (${_tickets.length})',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (_tickets.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No hay tickets todavía.'),
                    ),
                  )
                else
                  ..._tickets.map(_buildTicketTile),
              ],
            ),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Azure AD + Dataverse (new_ticket)'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(child: listContent),
    );
  }

  Widget _buildTicketTile(Ticket ticket) {
    return Card(
      child: ListTile(
        title: Text(ticket.title.isEmpty ? '(Sin título)' : ticket.title),
        subtitle: Text('Prioridad: ${ticket.priority} | Estado: ${ticket.status}'),
        trailing: Wrap(
          spacing: 8,
          children: <Widget>[
            IconButton(
              tooltip: 'Editar',
              onPressed: () => _showEditDialog(ticket),
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              tooltip: 'Eliminar',
              onPressed: () => _confirmDelete(ticket),
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}
