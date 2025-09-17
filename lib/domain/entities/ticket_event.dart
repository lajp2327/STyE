import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Type of event stored in the ticket history.
enum TicketEventType {
  created,
  statusChanged,
  assignment,
  comment,
  documentGenerated,
}

/// Immutable ticket event for traceability.
class TicketEvent extends Equatable {
  const TicketEvent({
    required this.id,
    required this.ticketId,
    required this.type,
    required this.message,
    required this.author,
    required this.createdAt,
    this.metadata = const <String, dynamic>{},
  });

  final int id;
  final int ticketId;
  final TicketEventType type;
  final String message;
  final String author;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  TicketEvent copyWith({
    TicketEventType? type,
    String? message,
    String? author,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return TicketEvent(
      id: id,
      ticketId: ticketId,
      type: type ?? this.type,
      message: message ?? this.message,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'ticketId': ticketId,
        'type': type.name,
        'message': message,
        'author': author,
        'createdAt': createdAt.toIso8601String(),
        'metadata': metadata,
      };

  factory TicketEvent.fromJson(Map<String, dynamic> json) => TicketEvent(
        id: json['id'] as int,
        ticketId: json['ticketId'] as int,
        type: TicketEventType.values.byName(json['type'] as String),
        message: json['message'] as String,
        author: json['author'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        metadata: (json['metadata'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      );

  static TicketEvent fromDatabase({
    required int id,
    required int ticketId,
    required String type,
    required String message,
    required String author,
    required DateTime createdAt,
    required String metadataJson,
  }) {
    return TicketEvent(
      id: id,
      ticketId: ticketId,
      type: TicketEventType.values.byName(type),
      message: message,
      author: author,
      createdAt: createdAt,
      metadata:
          metadataJson.isEmpty ? <String, dynamic>{} : jsonDecode(metadataJson) as Map<String, dynamic>,
    );
  }

  @override
  List<Object?> get props => <Object?>[id, ticketId, type, message, author, createdAt, metadata];
}
