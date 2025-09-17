import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:sistema_tickets_edis/domain/entities/catalog.dart';
import 'package:sistema_tickets_edis/domain/entities/technician.dart';
import 'package:sistema_tickets_edis/domain/entities/user.dart';

/// Supported ticket categories.
///
/// They map to the allowed entry points defined by negocio TI.
enum TicketCategory {
  altaNoParteRmFg('ALTA_NO_PARTE_RM_FG'),
  soporteEdi('SOPORTE_EDI'),
  incidenciaUsuario('INCIDENCIA_USUARIO'),
  solicitudTi('SOLICITUD_TI');

  const TicketCategory(this.code);

  final String code;

  static TicketCategory fromCode(String value) => TicketCategory.values
      .firstWhere((TicketCategory element) => element.code == value);

  String get label {
    switch (this) {
      case TicketCategory.altaNoParteRmFg:
        return 'Alta de número de parte (RM/FG)';
      case TicketCategory.soporteEdi:
        return 'Soporte EDI';
      case TicketCategory.incidenciaUsuario:
        return 'Incidencia de usuario';
      case TicketCategory.solicitudTi:
        return 'Solicitud TI';
    }
  }
}

/// Workflow states available for a ticket.
enum TicketStatus {
  nuevo,
  enRevision,
  enProceso,
  resuelto,
  cerrado;

  String get label {
    switch (this) {
      case TicketStatus.nuevo:
        return 'Nuevo';
      case TicketStatus.enRevision:
        return 'En revisión';
      case TicketStatus.enProceso:
        return 'En proceso';
      case TicketStatus.resuelto:
        return 'Resuelto';
      case TicketStatus.cerrado:
        return 'Cerrado';
    }
  }

  static TicketStatus fromName(String value) => TicketStatus.values.firstWhere(
    (TicketStatus element) => element.name == value,
  );
}

/// Domain entity for RM/FG alta specific data.
class TicketAltaDetails extends Equatable {
  const TicketAltaDetails({
    required this.cliente,
    required this.destino,
    required this.material,
    required this.norma,
    required this.propiedadesQuimicas,
    required this.propiedadesMecanicas,
    required this.numeroParte,
  });

  final CatalogEntry cliente;
  final CatalogEntry destino;
  final CatalogEntry material;
  final CatalogEntry norma;
  final CatalogEntry propiedadesQuimicas;
  final CatalogEntry propiedadesMecanicas;
  final CatalogEntry numeroParte;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'cliente': cliente.toJson(),
    'destino': destino.toJson(),
    'material': material.toJson(),
    'norma': norma.toJson(),
    'propiedadesQuimicas': propiedadesQuimicas.toJson(),
    'propiedadesMecanicas': propiedadesMecanicas.toJson(),
    'numeroParte': numeroParte.toJson(),
  };

  factory TicketAltaDetails.fromJson(Map<String, dynamic> json) =>
      TicketAltaDetails(
        cliente: CatalogEntry.fromJson(json['cliente'] as Map<String, dynamic>),
        destino: CatalogEntry.fromJson(json['destino'] as Map<String, dynamic>),
        material: CatalogEntry.fromJson(
          json['material'] as Map<String, dynamic>,
        ),
        norma: CatalogEntry.fromJson(json['norma'] as Map<String, dynamic>),
        propiedadesQuimicas: CatalogEntry.fromJson(
          json['propiedadesQuimicas'] as Map<String, dynamic>,
        ),
        propiedadesMecanicas: CatalogEntry.fromJson(
          json['propiedadesMecanicas'] as Map<String, dynamic>,
        ),
        numeroParte: CatalogEntry.fromJson(
          json['numeroParte'] as Map<String, dynamic>,
        ),
      );

  @override
  List<Object?> get props => <Object?>[
    cliente,
    destino,
    material,
    norma,
    propiedadesQuimicas,
    propiedadesMecanicas,
    numeroParte,
  ];
}

/// Draft object to capture ticket input from UI before persistence.
class TicketDraft extends Equatable {
  const TicketDraft({
    required this.title,
    required this.description,
    required this.requester,
    required this.category,
    this.altaDetails,
    this.metadata = const <String, dynamic>{},
  });

  final String title;
  final String description;
  final User requester;
  final TicketCategory category;
  final TicketAltaDetails? altaDetails;
  final Map<String, dynamic> metadata;

  TicketDraft copyWith({
    String? title,
    String? description,
    User? requester,
    TicketCategory? category,
    TicketAltaDetails? altaDetails,
    Map<String, dynamic>? metadata,
  }) {
    return TicketDraft(
      title: title ?? this.title,
      description: description ?? this.description,
      requester: requester ?? this.requester,
      category: category ?? this.category,
      altaDetails: altaDetails ?? this.altaDetails,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    title,
    description,
    requester,
    category,
    altaDetails,
    metadata,
  ];
}

/// Domain representation of a ticket.
class Ticket extends Equatable {
  const Ticket({
    required this.id,
    required this.folio,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.requester,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
    this.assignedTechnician,
    this.resolvedAt,
    this.closedAt,
    this.altaDetails,
  });

  final int id;
  final String folio;
  final String title;
  final String description;
  final TicketCategory category;
  final TicketStatus status;
  final User requester;
  final Technician? assignedTechnician;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final DateTime? closedAt;
  final Map<String, dynamic> metadata;
  final TicketAltaDetails? altaDetails;

  bool get isAltaRmFg => category == TicketCategory.altaNoParteRmFg;

  String get requesterName => requester.name;

  Duration? get resolutionTime =>
      resolvedAt != null ? resolvedAt!.difference(createdAt) : null;

  Ticket copyWith({
    TicketStatus? status,
    Technician? assignedTechnician,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    DateTime? closedAt,
    Map<String, dynamic>? metadata,
    TicketAltaDetails? altaDetails,
    User? requester,
  }) {
    return Ticket(
      id: id,
      folio: folio,
      title: title,
      description: description,
      category: category,
      status: status ?? this.status,
      requester: requester ?? this.requester,
      assignedTechnician: assignedTechnician ?? this.assignedTechnician,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      closedAt: closedAt ?? this.closedAt,
      metadata: metadata ?? this.metadata,
      altaDetails: altaDetails ?? this.altaDetails,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'folio': folio,
    'title': title,
    'description': description,
    'category': category.code,
    'status': status.name,
    'requester': requester.toJson(),
    'assignedTechnician': assignedTechnician?.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'resolvedAt': resolvedAt?.toIso8601String(),
    'closedAt': closedAt?.toIso8601String(),
    'metadata': metadata,
    'altaDetails': altaDetails?.toJson(),
  };

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as int,
      folio: json['folio'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: TicketCategory.fromCode(json['category'] as String),
      status: TicketStatus.fromName(json['status'] as String),
      requester: User.fromJson(json['requester'] as Map<String, dynamic>),
      assignedTechnician: json['assignedTechnician'] == null
          ? null
          : Technician.fromJson(
              json['assignedTechnician'] as Map<String, dynamic>,
            ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      resolvedAt: (json['resolvedAt'] as String?)?.let(DateTime.parse),
      closedAt: (json['closedAt'] as String?)?.let(DateTime.parse),
      metadata:
          (json['metadata'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      altaDetails: json['altaDetails'] == null
          ? null
          : TicketAltaDetails.fromJson(
              json['altaDetails'] as Map<String, dynamic>,
            ),
    );
  }

  static Ticket fromDatabase({
    required int id,
    required String folio,
    required String title,
    required String description,
    required String category,
    required String status,
    required User requester,
    Technician? technician,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? resolvedAt,
    DateTime? closedAt,
    String? altaJson,
    String metadataJson = '{}',
  }) {
    final Map<String, dynamic> metadata = metadataJson.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(metadataJson) as Map<String, dynamic>;
    return Ticket(
      id: id,
      folio: folio,
      title: title,
      description: description,
      category: TicketCategory.fromCode(category),
      status: TicketStatus.fromName(status),
      requester: requester,
      assignedTechnician: technician,
      createdAt: createdAt,
      updatedAt: updatedAt,
      resolvedAt: resolvedAt,
      closedAt: closedAt,
      metadata: metadata,
      altaDetails: altaJson == null
          ? null
          : TicketAltaDetails.fromJson(
              jsonDecode(altaJson) as Map<String, dynamic>,
            ),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    folio,
    title,
    description,
    category,
    status,
    requester,
    assignedTechnician,
    createdAt,
    updatedAt,
    resolvedAt,
    closedAt,
    metadata,
    altaDetails,
  ];
}

extension _NullableStringParsing on String? {
  T? let<T>(T Function(String value) mapper) {
    final String? value = this;
    if (value == null) {
      return null;
    }
    return mapper(value);
  }
}
