import 'package:equatable/equatable.dart';

/// Catalog types supported by the RM/FG workflow.
enum CatalogType {
  cliente('CLIENTE'),
  destino('DESTINO'),
  material('MATERIAL'),
  norma('NORMA'),
  propiedadesQuimicas('PROP_QUIM'),
  propiedadesMecanicas('PROP_MEC'),
  numeroParte('NO_PARTE');

  const CatalogType(this.code);

  final String code;

  static CatalogType fromCode(String value) =>
      CatalogType.values.firstWhere((CatalogType element) => element.code == value);

  String get label {
    switch (this) {
      case CatalogType.cliente:
        return 'Cliente';
      case CatalogType.destino:
        return 'Destino';
      case CatalogType.material:
        return 'Material';
      case CatalogType.norma:
        return 'Norma';
      case CatalogType.propiedadesQuimicas:
        return 'Prop. químicas';
      case CatalogType.propiedadesMecanicas:
        return 'Prop. mecánicas';
      case CatalogType.numeroParte:
        return 'Número de parte';
    }
  }
}

/// Simple catalog value.
class CatalogEntry extends Equatable {
  const CatalogEntry({
    required this.id,
    required this.type,
    required this.code,
    required this.description,
  });

  final int id;
  final CatalogType type;
  final String code;
  final String description;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'type': type.code,
        'code': code,
        'description': description,
      };

  factory CatalogEntry.fromJson(Map<String, dynamic> json) => CatalogEntry(
        id: json['id'] as int,
        type: CatalogType.fromCode(json['type'] as String),
        code: json['code'] as String,
        description: json['description'] as String,
      );

  @override
  List<Object?> get props => <Object?>[id, type, code, description];
}
