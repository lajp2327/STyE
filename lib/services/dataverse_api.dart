import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/auth_config.dart';
import '../config/preview_config.dart';
import '../models/ticket.dart';
import 'auth_service.dart';

class DataverseApi {
  DataverseApi({
    AuthService? authService,
    http.Client? httpClient,
    List<Ticket>? previewSeed,
    bool? previewMode,
  })  : _authService = authService ?? AuthService(),
        _httpClient = httpClient ?? http.Client(),
        _previewMode =
            previewMode ?? (authService?.isPreview ?? false) || kUsePreviewBackend,
        _previewTickets = <Ticket>[],
        _previewSequence = 0 {
    if (_previewMode) {
      final Iterable<Ticket> seed = previewSeed ?? _defaultPreviewTickets;
      _previewTickets.addAll(List<Ticket>.of(seed));
      _previewSequence = _previewTickets.length;
    }
  }

  final AuthService _authService;
  final http.Client _httpClient;
  final bool _previewMode;
  final List<Ticket> _previewTickets;
  int _previewSequence;

  bool get isPreview => _previewMode;

  static Uri get _collectionUri =>
      Uri.parse('${AuthConfig.organizationHost}/api/data/v9.2/new_tickets');

  Future<List<Ticket>> getTickets({
    int top = 20,
    String? filter,
    String? orderBy,
  }) async {
    if (_previewMode) {
      return _previewTickets.take(top).toList();
    }

    final List<Ticket> tickets = <Ticket>[];
    Uri? requestUri = _buildListUri(top: top, filter: filter, orderBy: orderBy);

    while (requestUri != null) {
      final http.Response response = await _authorizedGet(requestUri);
      final Map<String, dynamic> decoded = _decodeJson(response);
      final Iterable<dynamic> rawValues = decoded['value'] as Iterable<dynamic>? ??
          const <dynamic>[];
      tickets.addAll(
        rawValues
            .whereType<Map<String, dynamic>>()
            .map(Ticket.fromJson),
      );

      final String? nextLink = decoded['@odata.nextLink'] as String?;
      if (nextLink == null || nextLink.isEmpty) {
        requestUri = null;
      } else {
        requestUri = Uri.parse(nextLink);
      }
    }

    return tickets;
  }

  Future<Ticket> createTicket({
    required String title,
    required String priority,
    required String status,
  }) async {
    if (_previewMode) {
      final Ticket ticket = Ticket(
        id: _generatePreviewId(),
        title: title,
        priority: priority,
        status: status,
      );
      _previewTickets.insert(0, ticket);
      return ticket;
    }

    final String token = await _authService.getAccessToken();
    final http.Response response = await _httpClient.post(
      _collectionUri,
      headers: _headers(token),
      body: jsonEncode(<String, dynamic>{
        'new_title': title,
        'new_priority': priority,
        'new_status': status,
      }),
    );

    _ensureSuccess(response);

    if (response.body.isNotEmpty) {
      final Map<String, dynamic> decoded = _decodeJson(response);
      return Ticket.fromJson(decoded);
    }

    final String? entityId = response.headers['odata-entityid'];
    final String? ticketId = _extractGuid(entityId);

    return Ticket(
      id: ticketId ?? '',
      title: title,
      priority: priority,
      status: status,
    );
  }

  Future<void> updateTicket(
    String id, {
    String? title,
    String? priority,
    String? status,
  }) async {
    if (_previewMode) {
      final int index =
          _previewTickets.indexWhere((Ticket ticket) => ticket.id == id);
      if (index == -1) {
        throw DataverseApiException(
          'No se encontró el ticket $id en el modo preview.',
        );
      }

      final Ticket current = _previewTickets[index];
      final Ticket updated = current.copyWith(
        title: title?.isNotEmpty == true ? title : null,
        priority: priority?.isNotEmpty == true ? priority : null,
        status: status?.isNotEmpty == true ? status : null,
      );
      _previewTickets[index] = updated;
      return;
    }

    final Map<String, dynamic> updates = <String, dynamic>{};
    if (title != null) {
      updates['new_title'] = title;
    }
    if (priority != null) {
      updates['new_priority'] = priority;
    }
    if (status != null) {
      updates['new_status'] = status;
    }

    if (updates.isEmpty) {
      return;
    }

    final String token = await _authService.getAccessToken();
    final Uri resourceUri = _ticketUri(id);
    final http.Response response = await _httpClient.patch(
      resourceUri,
      headers: _headers(token),
      body: jsonEncode(updates),
    );

    _ensureSuccess(response);
  }

  Future<void> deleteTicket(String id) async {
    if (_previewMode) {
      final int previousLength = _previewTickets.length;
      _previewTickets.removeWhere((Ticket ticket) => ticket.id == id);
      final bool wasRemoved = _previewTickets.length != previousLength;
      if (!wasRemoved) {
        throw DataverseApiException(
          'No se pudo eliminar el ticket $id en modo preview.',
        );
      }
      return;
    }

    final String token = await _authService.getAccessToken();
    final Uri resourceUri = _ticketUri(id);
    final http.Response response = await _httpClient.delete(
      resourceUri,
      headers: _headers(token),
    );

    _ensureSuccess(response);
  }

  void dispose() {
    _httpClient.close();
  }

  static const List<Ticket> _defaultPreviewTickets = <Ticket>[
    Ticket(
      id: 'preview-1',
      title: 'Demo: seguimiento de incidente',
      priority: 'Alta',
      status: 'Abierto',
    ),
    Ticket(
      id: 'preview-2',
      title: 'Demo: revisión de equipo',
      priority: 'Media',
      status: 'En progreso',
    ),
    Ticket(
      id: 'preview-3',
      title: 'Demo: seguimiento preventivo',
      priority: 'Baja',
      status: 'Cerrado',
    ),
  ];

  Uri _buildListUri({
    required int top,
    String? filter,
    String? orderBy,
  }) {
    final String dollar = String.fromCharCode(36);
    final Map<String, String> queryParameters = <String, String>{
      '${dollar}select': 'new_title,new_priority,new_status,new_ticketid',
      '${dollar}top': top.toString(),
    };

    if (filter != null && filter.isNotEmpty) {
      queryParameters['${dollar}filter'] = filter;
    }

    if (orderBy != null && orderBy.isNotEmpty) {
      queryParameters['${dollar}orderby'] = orderBy;
    }

    return _collectionUri.replace(queryParameters: queryParameters);
  }

  Future<http.Response> _authorizedGet(Uri uri) async {
    final String token = await _authService.getAccessToken();
    final http.Response response = await _httpClient.get(
      uri,
      headers: _headers(token),
    );
    _ensureSuccess(response);
    return response;
  }

  Uri _ticketUri(String id) {
    final String trimmedId = id.replaceAll('{', '').replaceAll('}', '');
    return Uri.parse('${AuthConfig.organizationHost}/api/data/v9.2/new_tickets($trimmedId)');
  }

  Map<String, String> _headers(String token) => <String, String>{
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'OData-Version': '4.0',
      };

  Map<String, dynamic> _decodeJson(http.Response response) {
    if (response.bodyBytes.isEmpty) {
      return const <String, dynamic>{};
    }
    final String content = utf8.decode(response.bodyBytes);
    if (content.isEmpty) {
      return const <String, dynamic>{};
    }
    return jsonDecode(content) as Map<String, dynamic>;
  }

  void _ensureSuccess(http.Response response) {
    final bool isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    if (isSuccess) {
      return;
    }

    final String details = _extractError(response);
    throw DataverseApiException(
      'Error ${response.statusCode} al llamar a Dataverse: $details',
    );
  }

  String _extractError(http.Response response) {
    if (response.bodyBytes.isEmpty) {
      return response.reasonPhrase ?? 'Respuesta vacía';
    }

    try {
      final Map<String, dynamic> decoded =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final dynamic error = decoded['error'];
      if (error is Map<String, dynamic>) {
        final String? message = error['message'] as String?;
        return message ?? decoded.toString();
      }
      return decoded.toString();
    } catch (_) {
      return utf8.decode(response.bodyBytes);
    }
  }

  String? _extractGuid(String? entityId) {
    if (entityId == null) {
      return null;
    }
    final RegExpMatch? match =
        RegExp(r'([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})')
            .firstMatch(entityId);
    return match?.group(1);
  }

  String _generatePreviewId() {
    _previewSequence++;
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String sequence = _previewSequence.toString().padLeft(3, '0');
    return 'preview-$timestamp-$sequence';
  }
}

class DataverseApiException implements Exception {
  DataverseApiException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() =>
      'DataverseApiException: $message${cause != null ? ' (causa: $cause)' : ''}';
}
