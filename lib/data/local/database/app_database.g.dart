// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, UserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, name, email, isActive, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<UserRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserRow extends DataClass implements Insertable<UserRow> {
  final int id;
  final String name;
  final String? email;
  final bool isActive;
  final DateTime createdAt;
  const UserRow(
      {required this.id,
      required this.name,
      this.email,
      required this.isActive,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      name: Value(name),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory UserRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String?>(json['email']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String?>(email),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserRow copyWith(
          {int? id,
          String? name,
          Value<String?> email = const Value.absent(),
          bool? isActive,
          DateTime? createdAt}) =>
      UserRow(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email.present ? email.value : this.email,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
  UserRow copyWithCompanion(UsersCompanion data) {
    return UserRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, email, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<UserRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> email;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.email = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<UserRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UsersCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? email,
      Value<bool>? isActive,
      Value<DateTime>? createdAt}) {
    return UsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TechniciansTable extends Technicians
    with TableInfo<$TechniciansTable, TechnicianRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TechniciansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [id, name, email, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'technicians';
  @override
  VerificationContext validateIntegrity(Insertable<TechnicianRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TechnicianRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TechnicianRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $TechniciansTable createAlias(String alias) {
    return $TechniciansTable(attachedDatabase, alias);
  }
}

class TechnicianRow extends DataClass implements Insertable<TechnicianRow> {
  final int id;
  final String name;
  final String email;
  final bool isActive;
  const TechnicianRow(
      {required this.id,
      required this.name,
      required this.email,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  TechniciansCompanion toCompanion(bool nullToAbsent) {
    return TechniciansCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      isActive: Value(isActive),
    );
  }

  factory TechnicianRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TechnicianRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  TechnicianRow copyWith(
          {int? id, String? name, String? email, bool? isActive}) =>
      TechnicianRow(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        isActive: isActive ?? this.isActive,
      );
  TechnicianRow copyWithCompanion(TechniciansCompanion data) {
    return TechnicianRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TechnicianRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, email, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TechnicianRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.isActive == this.isActive);
}

class TechniciansCompanion extends UpdateCompanion<TechnicianRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> email;
  final Value<bool> isActive;
  const TechniciansCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  TechniciansCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String email,
    this.isActive = const Value.absent(),
  })  : name = Value(name),
        email = Value(email);
  static Insertable<TechnicianRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (isActive != null) 'is_active': isActive,
    });
  }

  TechniciansCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? email,
      Value<bool>? isActive}) {
    return TechniciansCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TechniciansCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $TicketsTable extends Tickets with TableInfo<$TicketsTable, TicketRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TicketsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _folioMeta = const VerificationMeta('folio');
  @override
  late final GeneratedColumn<String> folio = GeneratedColumn<String>(
      'folio', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _requesterIdMeta =
      const VerificationMeta('requesterId');
  @override
  late final GeneratedColumn<int> requesterId = GeneratedColumn<int>(
      'requester_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _assignedTechnicianIdMeta =
      const VerificationMeta('assignedTechnicianId');
  @override
  late final GeneratedColumn<int> assignedTechnicianId = GeneratedColumn<int>(
      'assigned_technician_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES technicians (id)'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _resolvedAtMeta =
      const VerificationMeta('resolvedAt');
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
      'resolved_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _closedAtMeta =
      const VerificationMeta('closedAt');
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
      'closed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _altaJsonMeta =
      const VerificationMeta('altaJson');
  @override
  late final GeneratedColumn<String> altaJson = GeneratedColumn<String>(
      'alta_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _metadataJsonMeta =
      const VerificationMeta('metadataJson');
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
      'metadata_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        folio,
        title,
        description,
        category,
        status,
        requesterId,
        assignedTechnicianId,
        createdAt,
        updatedAt,
        resolvedAt,
        closedAt,
        altaJson,
        metadataJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tickets';
  @override
  VerificationContext validateIntegrity(Insertable<TicketRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('folio')) {
      context.handle(
          _folioMeta, folio.isAcceptableOrUnknown(data['folio']!, _folioMeta));
    } else if (isInserting) {
      context.missing(_folioMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('requester_id')) {
      context.handle(
          _requesterIdMeta,
          requesterId.isAcceptableOrUnknown(
              data['requester_id']!, _requesterIdMeta));
    } else if (isInserting) {
      context.missing(_requesterIdMeta);
    }
    if (data.containsKey('assigned_technician_id')) {
      context.handle(
          _assignedTechnicianIdMeta,
          assignedTechnicianId.isAcceptableOrUnknown(
              data['assigned_technician_id']!, _assignedTechnicianIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
          _resolvedAtMeta,
          resolvedAt.isAcceptableOrUnknown(
              data['resolved_at']!, _resolvedAtMeta));
    }
    if (data.containsKey('closed_at')) {
      context.handle(_closedAtMeta,
          closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta));
    }
    if (data.containsKey('alta_json')) {
      context.handle(_altaJsonMeta,
          altaJson.isAcceptableOrUnknown(data['alta_json']!, _altaJsonMeta));
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
          _metadataJsonMeta,
          metadataJson.isAcceptableOrUnknown(
              data['metadata_json']!, _metadataJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TicketRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TicketRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      folio: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}folio'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      requesterId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}requester_id'])!,
      assignedTechnicianId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}assigned_technician_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      resolvedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}resolved_at']),
      closedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}closed_at']),
      altaJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}alta_json']),
      metadataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata_json'])!,
    );
  }

  @override
  $TicketsTable createAlias(String alias) {
    return $TicketsTable(attachedDatabase, alias);
  }
}

class TicketRow extends DataClass implements Insertable<TicketRow> {
  final int id;
  final String folio;
  final String title;
  final String description;
  final String category;
  final String status;
  final int requesterId;
  final int? assignedTechnicianId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final DateTime? closedAt;
  final String? altaJson;
  final String metadataJson;
  const TicketRow(
      {required this.id,
      required this.folio,
      required this.title,
      required this.description,
      required this.category,
      required this.status,
      required this.requesterId,
      this.assignedTechnicianId,
      required this.createdAt,
      required this.updatedAt,
      this.resolvedAt,
      this.closedAt,
      this.altaJson,
      required this.metadataJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['folio'] = Variable<String>(folio);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['category'] = Variable<String>(category);
    map['status'] = Variable<String>(status);
    map['requester_id'] = Variable<int>(requesterId);
    if (!nullToAbsent || assignedTechnicianId != null) {
      map['assigned_technician_id'] = Variable<int>(assignedTechnicianId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    if (!nullToAbsent || altaJson != null) {
      map['alta_json'] = Variable<String>(altaJson);
    }
    map['metadata_json'] = Variable<String>(metadataJson);
    return map;
  }

  TicketsCompanion toCompanion(bool nullToAbsent) {
    return TicketsCompanion(
      id: Value(id),
      folio: Value(folio),
      title: Value(title),
      description: Value(description),
      category: Value(category),
      status: Value(status),
      requesterId: Value(requesterId),
      assignedTechnicianId: assignedTechnicianId == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedTechnicianId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      altaJson: altaJson == null && nullToAbsent
          ? const Value.absent()
          : Value(altaJson),
      metadataJson: Value(metadataJson),
    );
  }

  factory TicketRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TicketRow(
      id: serializer.fromJson<int>(json['id']),
      folio: serializer.fromJson<String>(json['folio']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      category: serializer.fromJson<String>(json['category']),
      status: serializer.fromJson<String>(json['status']),
      requesterId: serializer.fromJson<int>(json['requesterId']),
      assignedTechnicianId:
          serializer.fromJson<int?>(json['assignedTechnicianId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
      altaJson: serializer.fromJson<String?>(json['altaJson']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'folio': serializer.toJson<String>(folio),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'category': serializer.toJson<String>(category),
      'status': serializer.toJson<String>(status),
      'requesterId': serializer.toJson<int>(requesterId),
      'assignedTechnicianId': serializer.toJson<int?>(assignedTechnicianId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
      'altaJson': serializer.toJson<String?>(altaJson),
      'metadataJson': serializer.toJson<String>(metadataJson),
    };
  }

  TicketRow copyWith(
          {int? id,
          String? folio,
          String? title,
          String? description,
          String? category,
          String? status,
          int? requesterId,
          Value<int?> assignedTechnicianId = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> resolvedAt = const Value.absent(),
          Value<DateTime?> closedAt = const Value.absent(),
          Value<String?> altaJson = const Value.absent(),
          String? metadataJson}) =>
      TicketRow(
        id: id ?? this.id,
        folio: folio ?? this.folio,
        title: title ?? this.title,
        description: description ?? this.description,
        category: category ?? this.category,
        status: status ?? this.status,
        requesterId: requesterId ?? this.requesterId,
        assignedTechnicianId: assignedTechnicianId.present
            ? assignedTechnicianId.value
            : this.assignedTechnicianId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
        closedAt: closedAt.present ? closedAt.value : this.closedAt,
        altaJson: altaJson.present ? altaJson.value : this.altaJson,
        metadataJson: metadataJson ?? this.metadataJson,
      );
  TicketRow copyWithCompanion(TicketsCompanion data) {
    return TicketRow(
      id: data.id.present ? data.id.value : this.id,
      folio: data.folio.present ? data.folio.value : this.folio,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      category: data.category.present ? data.category.value : this.category,
      status: data.status.present ? data.status.value : this.status,
      requesterId:
          data.requesterId.present ? data.requesterId.value : this.requesterId,
      assignedTechnicianId: data.assignedTechnicianId.present
          ? data.assignedTechnicianId.value
          : this.assignedTechnicianId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      resolvedAt:
          data.resolvedAt.present ? data.resolvedAt.value : this.resolvedAt,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      altaJson: data.altaJson.present ? data.altaJson.value : this.altaJson,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TicketRow(')
          ..write('id: $id, ')
          ..write('folio: $folio, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('status: $status, ')
          ..write('requesterId: $requesterId, ')
          ..write('assignedTechnicianId: $assignedTechnicianId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('altaJson: $altaJson, ')
          ..write('metadataJson: $metadataJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      folio,
      title,
      description,
      category,
      status,
      requesterId,
      assignedTechnicianId,
      createdAt,
      updatedAt,
      resolvedAt,
      closedAt,
      altaJson,
      metadataJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TicketRow &&
          other.id == this.id &&
          other.folio == this.folio &&
          other.title == this.title &&
          other.description == this.description &&
          other.category == this.category &&
          other.status == this.status &&
          other.requesterId == this.requesterId &&
          other.assignedTechnicianId == this.assignedTechnicianId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.resolvedAt == this.resolvedAt &&
          other.closedAt == this.closedAt &&
          other.altaJson == this.altaJson &&
          other.metadataJson == this.metadataJson);
}

class TicketsCompanion extends UpdateCompanion<TicketRow> {
  final Value<int> id;
  final Value<String> folio;
  final Value<String> title;
  final Value<String> description;
  final Value<String> category;
  final Value<String> status;
  final Value<int> requesterId;
  final Value<int?> assignedTechnicianId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> resolvedAt;
  final Value<DateTime?> closedAt;
  final Value<String?> altaJson;
  final Value<String> metadataJson;
  const TicketsCompanion({
    this.id = const Value.absent(),
    this.folio = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.status = const Value.absent(),
    this.requesterId = const Value.absent(),
    this.assignedTechnicianId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.altaJson = const Value.absent(),
    this.metadataJson = const Value.absent(),
  });
  TicketsCompanion.insert({
    this.id = const Value.absent(),
    required String folio,
    required String title,
    required String description,
    required String category,
    required String status,
    required int requesterId,
    this.assignedTechnicianId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.altaJson = const Value.absent(),
    this.metadataJson = const Value.absent(),
  })  : folio = Value(folio),
        title = Value(title),
        description = Value(description),
        category = Value(category),
        status = Value(status),
        requesterId = Value(requesterId);
  static Insertable<TicketRow> custom({
    Expression<int>? id,
    Expression<String>? folio,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? category,
    Expression<String>? status,
    Expression<int>? requesterId,
    Expression<int>? assignedTechnicianId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? resolvedAt,
    Expression<DateTime>? closedAt,
    Expression<String>? altaJson,
    Expression<String>? metadataJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (folio != null) 'folio': folio,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (status != null) 'status': status,
      if (requesterId != null) 'requester_id': requesterId,
      if (assignedTechnicianId != null)
        'assigned_technician_id': assignedTechnicianId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (closedAt != null) 'closed_at': closedAt,
      if (altaJson != null) 'alta_json': altaJson,
      if (metadataJson != null) 'metadata_json': metadataJson,
    });
  }

  TicketsCompanion copyWith(
      {Value<int>? id,
      Value<String>? folio,
      Value<String>? title,
      Value<String>? description,
      Value<String>? category,
      Value<String>? status,
      Value<int>? requesterId,
      Value<int?>? assignedTechnicianId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? resolvedAt,
      Value<DateTime?>? closedAt,
      Value<String?>? altaJson,
      Value<String>? metadataJson}) {
    return TicketsCompanion(
      id: id ?? this.id,
      folio: folio ?? this.folio,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      requesterId: requesterId ?? this.requesterId,
      assignedTechnicianId: assignedTechnicianId ?? this.assignedTechnicianId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      closedAt: closedAt ?? this.closedAt,
      altaJson: altaJson ?? this.altaJson,
      metadataJson: metadataJson ?? this.metadataJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (folio.present) {
      map['folio'] = Variable<String>(folio.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (requesterId.present) {
      map['requester_id'] = Variable<int>(requesterId.value);
    }
    if (assignedTechnicianId.present) {
      map['assigned_technician_id'] = Variable<int>(assignedTechnicianId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (altaJson.present) {
      map['alta_json'] = Variable<String>(altaJson.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TicketsCompanion(')
          ..write('id: $id, ')
          ..write('folio: $folio, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('status: $status, ')
          ..write('requesterId: $requesterId, ')
          ..write('assignedTechnicianId: $assignedTechnicianId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('altaJson: $altaJson, ')
          ..write('metadataJson: $metadataJson')
          ..write(')'))
        .toString();
  }
}

class $TicketEventsTable extends TicketEvents
    with TableInfo<$TicketEventsTable, TicketEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TicketEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _ticketIdMeta =
      const VerificationMeta('ticketId');
  @override
  late final GeneratedColumn<int> ticketId = GeneratedColumn<int>(
      'ticket_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tickets (id) ON DELETE CASCADE'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _metadataJsonMeta =
      const VerificationMeta('metadataJson');
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
      'metadata_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, ticketId, type, author, message, metadataJson, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ticket_events';
  @override
  VerificationContext validateIntegrity(Insertable<TicketEventRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ticket_id')) {
      context.handle(_ticketIdMeta,
          ticketId.isAcceptableOrUnknown(data['ticket_id']!, _ticketIdMeta));
    } else if (isInserting) {
      context.missing(_ticketIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    } else if (isInserting) {
      context.missing(_authorMeta);
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
          _metadataJsonMeta,
          metadataJson.isAcceptableOrUnknown(
              data['metadata_json']!, _metadataJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TicketEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TicketEventRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      ticketId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ticket_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      metadataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TicketEventsTable createAlias(String alias) {
    return $TicketEventsTable(attachedDatabase, alias);
  }
}

class TicketEventRow extends DataClass implements Insertable<TicketEventRow> {
  final int id;
  final int ticketId;
  final String type;
  final String author;
  final String message;
  final String metadataJson;
  final DateTime createdAt;
  const TicketEventRow(
      {required this.id,
      required this.ticketId,
      required this.type,
      required this.author,
      required this.message,
      required this.metadataJson,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ticket_id'] = Variable<int>(ticketId);
    map['type'] = Variable<String>(type);
    map['author'] = Variable<String>(author);
    map['message'] = Variable<String>(message);
    map['metadata_json'] = Variable<String>(metadataJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TicketEventsCompanion toCompanion(bool nullToAbsent) {
    return TicketEventsCompanion(
      id: Value(id),
      ticketId: Value(ticketId),
      type: Value(type),
      author: Value(author),
      message: Value(message),
      metadataJson: Value(metadataJson),
      createdAt: Value(createdAt),
    );
  }

  factory TicketEventRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TicketEventRow(
      id: serializer.fromJson<int>(json['id']),
      ticketId: serializer.fromJson<int>(json['ticketId']),
      type: serializer.fromJson<String>(json['type']),
      author: serializer.fromJson<String>(json['author']),
      message: serializer.fromJson<String>(json['message']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ticketId': serializer.toJson<int>(ticketId),
      'type': serializer.toJson<String>(type),
      'author': serializer.toJson<String>(author),
      'message': serializer.toJson<String>(message),
      'metadataJson': serializer.toJson<String>(metadataJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TicketEventRow copyWith(
          {int? id,
          int? ticketId,
          String? type,
          String? author,
          String? message,
          String? metadataJson,
          DateTime? createdAt}) =>
      TicketEventRow(
        id: id ?? this.id,
        ticketId: ticketId ?? this.ticketId,
        type: type ?? this.type,
        author: author ?? this.author,
        message: message ?? this.message,
        metadataJson: metadataJson ?? this.metadataJson,
        createdAt: createdAt ?? this.createdAt,
      );
  TicketEventRow copyWithCompanion(TicketEventsCompanion data) {
    return TicketEventRow(
      id: data.id.present ? data.id.value : this.id,
      ticketId: data.ticketId.present ? data.ticketId.value : this.ticketId,
      type: data.type.present ? data.type.value : this.type,
      author: data.author.present ? data.author.value : this.author,
      message: data.message.present ? data.message.value : this.message,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TicketEventRow(')
          ..write('id: $id, ')
          ..write('ticketId: $ticketId, ')
          ..write('type: $type, ')
          ..write('author: $author, ')
          ..write('message: $message, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, ticketId, type, author, message, metadataJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TicketEventRow &&
          other.id == this.id &&
          other.ticketId == this.ticketId &&
          other.type == this.type &&
          other.author == this.author &&
          other.message == this.message &&
          other.metadataJson == this.metadataJson &&
          other.createdAt == this.createdAt);
}

class TicketEventsCompanion extends UpdateCompanion<TicketEventRow> {
  final Value<int> id;
  final Value<int> ticketId;
  final Value<String> type;
  final Value<String> author;
  final Value<String> message;
  final Value<String> metadataJson;
  final Value<DateTime> createdAt;
  const TicketEventsCompanion({
    this.id = const Value.absent(),
    this.ticketId = const Value.absent(),
    this.type = const Value.absent(),
    this.author = const Value.absent(),
    this.message = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TicketEventsCompanion.insert({
    this.id = const Value.absent(),
    required int ticketId,
    required String type,
    required String author,
    required String message,
    this.metadataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : ticketId = Value(ticketId),
        type = Value(type),
        author = Value(author),
        message = Value(message);
  static Insertable<TicketEventRow> custom({
    Expression<int>? id,
    Expression<int>? ticketId,
    Expression<String>? type,
    Expression<String>? author,
    Expression<String>? message,
    Expression<String>? metadataJson,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ticketId != null) 'ticket_id': ticketId,
      if (type != null) 'type': type,
      if (author != null) 'author': author,
      if (message != null) 'message': message,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TicketEventsCompanion copyWith(
      {Value<int>? id,
      Value<int>? ticketId,
      Value<String>? type,
      Value<String>? author,
      Value<String>? message,
      Value<String>? metadataJson,
      Value<DateTime>? createdAt}) {
    return TicketEventsCompanion(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      type: type ?? this.type,
      author: author ?? this.author,
      message: message ?? this.message,
      metadataJson: metadataJson ?? this.metadataJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ticketId.present) {
      map['ticket_id'] = Variable<int>(ticketId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TicketEventsCompanion(')
          ..write('id: $id, ')
          ..write('ticketId: $ticketId, ')
          ..write('type: $type, ')
          ..write('author: $author, ')
          ..write('message: $message, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CatalogEntriesTable extends CatalogEntries
    with TableInfo<$CatalogEntriesTable, CatalogEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, type, code, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_entries';
  @override
  VerificationContext validateIntegrity(Insertable<CatalogEntryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {type, code},
      ];
  @override
  CatalogEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogEntryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
    );
  }

  @override
  $CatalogEntriesTable createAlias(String alias) {
    return $CatalogEntriesTable(attachedDatabase, alias);
  }
}

class CatalogEntryRow extends DataClass implements Insertable<CatalogEntryRow> {
  final int id;
  final String type;
  final String code;
  final String description;
  const CatalogEntryRow(
      {required this.id,
      required this.type,
      required this.code,
      required this.description});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['code'] = Variable<String>(code);
    map['description'] = Variable<String>(description);
    return map;
  }

  CatalogEntriesCompanion toCompanion(bool nullToAbsent) {
    return CatalogEntriesCompanion(
      id: Value(id),
      type: Value(type),
      code: Value(code),
      description: Value(description),
    );
  }

  factory CatalogEntryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogEntryRow(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      code: serializer.fromJson<String>(json['code']),
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'code': serializer.toJson<String>(code),
      'description': serializer.toJson<String>(description),
    };
  }

  CatalogEntryRow copyWith(
          {int? id, String? type, String? code, String? description}) =>
      CatalogEntryRow(
        id: id ?? this.id,
        type: type ?? this.type,
        code: code ?? this.code,
        description: description ?? this.description,
      );
  CatalogEntryRow copyWithCompanion(CatalogEntriesCompanion data) {
    return CatalogEntryRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      code: data.code.present ? data.code.value : this.code,
      description:
          data.description.present ? data.description.value : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogEntryRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('code: $code, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, code, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogEntryRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.code == this.code &&
          other.description == this.description);
}

class CatalogEntriesCompanion extends UpdateCompanion<CatalogEntryRow> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> code;
  final Value<String> description;
  const CatalogEntriesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.code = const Value.absent(),
    this.description = const Value.absent(),
  });
  CatalogEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required String code,
    required String description,
  })  : type = Value(type),
        code = Value(code),
        description = Value(description);
  static Insertable<CatalogEntryRow> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? code,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (code != null) 'code': code,
      if (description != null) 'description': description,
    });
  }

  CatalogEntriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? type,
      Value<String>? code,
      Value<String>? description}) {
    return CatalogEntriesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      code: code ?? this.code,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogEntriesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('code: $code, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

class $DmfExportsTable extends DmfExports
    with TableInfo<$DmfExportsTable, DmfExportRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DmfExportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _ticketIdMeta =
      const VerificationMeta('ticketId');
  @override
  late final GeneratedColumn<int> ticketId = GeneratedColumn<int>(
      'ticket_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tickets (id) ON DELETE CASCADE'));
  static const VerificationMeta _pdfPathMeta =
      const VerificationMeta('pdfPath');
  @override
  late final GeneratedColumn<String> pdfPath = GeneratedColumn<String>(
      'pdf_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _csvPathMeta =
      const VerificationMeta('csvPath');
  @override
  late final GeneratedColumn<String> csvPath = GeneratedColumn<String>(
      'csv_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, ticketId, pdfPath, csvPath, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dmf_exports';
  @override
  VerificationContext validateIntegrity(Insertable<DmfExportRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ticket_id')) {
      context.handle(_ticketIdMeta,
          ticketId.isAcceptableOrUnknown(data['ticket_id']!, _ticketIdMeta));
    } else if (isInserting) {
      context.missing(_ticketIdMeta);
    }
    if (data.containsKey('pdf_path')) {
      context.handle(_pdfPathMeta,
          pdfPath.isAcceptableOrUnknown(data['pdf_path']!, _pdfPathMeta));
    } else if (isInserting) {
      context.missing(_pdfPathMeta);
    }
    if (data.containsKey('csv_path')) {
      context.handle(_csvPathMeta,
          csvPath.isAcceptableOrUnknown(data['csv_path']!, _csvPathMeta));
    } else if (isInserting) {
      context.missing(_csvPathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DmfExportRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DmfExportRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      ticketId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ticket_id'])!,
      pdfPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pdf_path'])!,
      csvPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}csv_path'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $DmfExportsTable createAlias(String alias) {
    return $DmfExportsTable(attachedDatabase, alias);
  }
}

class DmfExportRow extends DataClass implements Insertable<DmfExportRow> {
  final int id;
  final int ticketId;
  final String pdfPath;
  final String csvPath;
  final DateTime createdAt;
  const DmfExportRow(
      {required this.id,
      required this.ticketId,
      required this.pdfPath,
      required this.csvPath,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ticket_id'] = Variable<int>(ticketId);
    map['pdf_path'] = Variable<String>(pdfPath);
    map['csv_path'] = Variable<String>(csvPath);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DmfExportsCompanion toCompanion(bool nullToAbsent) {
    return DmfExportsCompanion(
      id: Value(id),
      ticketId: Value(ticketId),
      pdfPath: Value(pdfPath),
      csvPath: Value(csvPath),
      createdAt: Value(createdAt),
    );
  }

  factory DmfExportRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DmfExportRow(
      id: serializer.fromJson<int>(json['id']),
      ticketId: serializer.fromJson<int>(json['ticketId']),
      pdfPath: serializer.fromJson<String>(json['pdfPath']),
      csvPath: serializer.fromJson<String>(json['csvPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ticketId': serializer.toJson<int>(ticketId),
      'pdfPath': serializer.toJson<String>(pdfPath),
      'csvPath': serializer.toJson<String>(csvPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DmfExportRow copyWith(
          {int? id,
          int? ticketId,
          String? pdfPath,
          String? csvPath,
          DateTime? createdAt}) =>
      DmfExportRow(
        id: id ?? this.id,
        ticketId: ticketId ?? this.ticketId,
        pdfPath: pdfPath ?? this.pdfPath,
        csvPath: csvPath ?? this.csvPath,
        createdAt: createdAt ?? this.createdAt,
      );
  DmfExportRow copyWithCompanion(DmfExportsCompanion data) {
    return DmfExportRow(
      id: data.id.present ? data.id.value : this.id,
      ticketId: data.ticketId.present ? data.ticketId.value : this.ticketId,
      pdfPath: data.pdfPath.present ? data.pdfPath.value : this.pdfPath,
      csvPath: data.csvPath.present ? data.csvPath.value : this.csvPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DmfExportRow(')
          ..write('id: $id, ')
          ..write('ticketId: $ticketId, ')
          ..write('pdfPath: $pdfPath, ')
          ..write('csvPath: $csvPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ticketId, pdfPath, csvPath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DmfExportRow &&
          other.id == this.id &&
          other.ticketId == this.ticketId &&
          other.pdfPath == this.pdfPath &&
          other.csvPath == this.csvPath &&
          other.createdAt == this.createdAt);
}

class DmfExportsCompanion extends UpdateCompanion<DmfExportRow> {
  final Value<int> id;
  final Value<int> ticketId;
  final Value<String> pdfPath;
  final Value<String> csvPath;
  final Value<DateTime> createdAt;
  const DmfExportsCompanion({
    this.id = const Value.absent(),
    this.ticketId = const Value.absent(),
    this.pdfPath = const Value.absent(),
    this.csvPath = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DmfExportsCompanion.insert({
    this.id = const Value.absent(),
    required int ticketId,
    required String pdfPath,
    required String csvPath,
    this.createdAt = const Value.absent(),
  })  : ticketId = Value(ticketId),
        pdfPath = Value(pdfPath),
        csvPath = Value(csvPath);
  static Insertable<DmfExportRow> custom({
    Expression<int>? id,
    Expression<int>? ticketId,
    Expression<String>? pdfPath,
    Expression<String>? csvPath,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ticketId != null) 'ticket_id': ticketId,
      if (pdfPath != null) 'pdf_path': pdfPath,
      if (csvPath != null) 'csv_path': csvPath,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DmfExportsCompanion copyWith(
      {Value<int>? id,
      Value<int>? ticketId,
      Value<String>? pdfPath,
      Value<String>? csvPath,
      Value<DateTime>? createdAt}) {
    return DmfExportsCompanion(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      pdfPath: pdfPath ?? this.pdfPath,
      csvPath: csvPath ?? this.csvPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ticketId.present) {
      map['ticket_id'] = Variable<int>(ticketId.value);
    }
    if (pdfPath.present) {
      map['pdf_path'] = Variable<String>(pdfPath.value);
    }
    if (csvPath.present) {
      map['csv_path'] = Variable<String>(csvPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DmfExportsCompanion(')
          ..write('id: $id, ')
          ..write('ticketId: $ticketId, ')
          ..write('pdfPath: $pdfPath, ')
          ..write('csvPath: $csvPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $TechniciansTable technicians = $TechniciansTable(this);
  late final $TicketsTable tickets = $TicketsTable(this);
  late final $TicketEventsTable ticketEvents = $TicketEventsTable(this);
  late final $CatalogEntriesTable catalogEntries = $CatalogEntriesTable(this);
  late final $DmfExportsTable dmfExports = $DmfExportsTable(this);
  late final TicketDao ticketDao = TicketDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [users, technicians, tickets, ticketEvents, catalogEntries, dmfExports];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('tickets',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('ticket_events', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('tickets',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('dmf_exports', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> email,
  Value<bool> isActive,
  Value<DateTime> createdAt,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> email,
  Value<bool> isActive,
  Value<DateTime> createdAt,
});

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, UserRow> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TicketsTable, List<TicketRow>> _ticketsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.tickets,
          aliasName: $_aliasNameGenerator(db.users.id, db.tickets.requesterId));

  $$TicketsTableProcessedTableManager get ticketsRefs {
    final manager = $$TicketsTableTableManager($_db, $_db.tickets)
        .filter((f) => f.requesterId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ticketsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> ticketsRefs(
      Expression<bool> Function($$TicketsTableFilterComposer f) f) {
    final $$TicketsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.requesterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableFilterComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> ticketsRefs<T extends Object>(
      Expression<T> Function($$TicketsTableAnnotationComposer a) f) {
    final $$TicketsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.requesterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableAnnotationComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    UserRow,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (UserRow, $$UsersTableReferences),
    UserRow,
    PrefetchHooks Function({bool ticketsRefs})> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            name: name,
            email: email,
            isActive: isActive,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> email = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            name: name,
            email: email,
            isActive: isActive,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$UsersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({ticketsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (ticketsRefs) db.tickets],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ticketsRefs)
                    await $_getPrefetchedData<UserRow, $UsersTable, TicketRow>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._ticketsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0).ticketsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.requesterId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    UserRow,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (UserRow, $$UsersTableReferences),
    UserRow,
    PrefetchHooks Function({bool ticketsRefs})>;
typedef $$TechniciansTableCreateCompanionBuilder = TechniciansCompanion
    Function({
  Value<int> id,
  required String name,
  required String email,
  Value<bool> isActive,
});
typedef $$TechniciansTableUpdateCompanionBuilder = TechniciansCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> email,
  Value<bool> isActive,
});

final class $$TechniciansTableReferences
    extends BaseReferences<_$AppDatabase, $TechniciansTable, TechnicianRow> {
  $$TechniciansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TicketsTable, List<TicketRow>> _ticketsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.tickets,
          aliasName: $_aliasNameGenerator(
              db.technicians.id, db.tickets.assignedTechnicianId));

  $$TicketsTableProcessedTableManager get ticketsRefs {
    final manager = $$TicketsTableTableManager($_db, $_db.tickets).filter(
        (f) => f.assignedTechnicianId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ticketsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TechniciansTableFilterComposer
    extends Composer<_$AppDatabase, $TechniciansTable> {
  $$TechniciansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  Expression<bool> ticketsRefs(
      Expression<bool> Function($$TicketsTableFilterComposer f) f) {
    final $$TicketsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.assignedTechnicianId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableFilterComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TechniciansTableOrderingComposer
    extends Composer<_$AppDatabase, $TechniciansTable> {
  $$TechniciansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$TechniciansTableAnnotationComposer
    extends Composer<_$AppDatabase, $TechniciansTable> {
  $$TechniciansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  Expression<T> ticketsRefs<T extends Object>(
      Expression<T> Function($$TicketsTableAnnotationComposer a) f) {
    final $$TicketsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.assignedTechnicianId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableAnnotationComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TechniciansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TechniciansTable,
    TechnicianRow,
    $$TechniciansTableFilterComposer,
    $$TechniciansTableOrderingComposer,
    $$TechniciansTableAnnotationComposer,
    $$TechniciansTableCreateCompanionBuilder,
    $$TechniciansTableUpdateCompanionBuilder,
    (TechnicianRow, $$TechniciansTableReferences),
    TechnicianRow,
    PrefetchHooks Function({bool ticketsRefs})> {
  $$TechniciansTableTableManager(_$AppDatabase db, $TechniciansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TechniciansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TechniciansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TechniciansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
          }) =>
              TechniciansCompanion(
            id: id,
            name: name,
            email: email,
            isActive: isActive,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String email,
            Value<bool> isActive = const Value.absent(),
          }) =>
              TechniciansCompanion.insert(
            id: id,
            name: name,
            email: email,
            isActive: isActive,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TechniciansTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({ticketsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (ticketsRefs) db.tickets],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ticketsRefs)
                    await $_getPrefetchedData<TechnicianRow, $TechniciansTable,
                            TicketRow>(
                        currentTable: table,
                        referencedTable:
                            $$TechniciansTableReferences._ticketsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TechniciansTableReferences(db, table, p0)
                                .ticketsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems.where(
                                (e) => e.assignedTechnicianId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TechniciansTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TechniciansTable,
    TechnicianRow,
    $$TechniciansTableFilterComposer,
    $$TechniciansTableOrderingComposer,
    $$TechniciansTableAnnotationComposer,
    $$TechniciansTableCreateCompanionBuilder,
    $$TechniciansTableUpdateCompanionBuilder,
    (TechnicianRow, $$TechniciansTableReferences),
    TechnicianRow,
    PrefetchHooks Function({bool ticketsRefs})>;
typedef $$TicketsTableCreateCompanionBuilder = TicketsCompanion Function({
  Value<int> id,
  required String folio,
  required String title,
  required String description,
  required String category,
  required String status,
  required int requesterId,
  Value<int?> assignedTechnicianId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> resolvedAt,
  Value<DateTime?> closedAt,
  Value<String?> altaJson,
  Value<String> metadataJson,
});
typedef $$TicketsTableUpdateCompanionBuilder = TicketsCompanion Function({
  Value<int> id,
  Value<String> folio,
  Value<String> title,
  Value<String> description,
  Value<String> category,
  Value<String> status,
  Value<int> requesterId,
  Value<int?> assignedTechnicianId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> resolvedAt,
  Value<DateTime?> closedAt,
  Value<String?> altaJson,
  Value<String> metadataJson,
});

final class $$TicketsTableReferences
    extends BaseReferences<_$AppDatabase, $TicketsTable, TicketRow> {
  $$TicketsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _requesterIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.tickets.requesterId, db.users.id));

  $$UsersTableProcessedTableManager get requesterId {
    final $_column = $_itemColumn<int>('requester_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_requesterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TechniciansTable _assignedTechnicianIdTable(_$AppDatabase db) =>
      db.technicians.createAlias($_aliasNameGenerator(
          db.tickets.assignedTechnicianId, db.technicians.id));

  $$TechniciansTableProcessedTableManager? get assignedTechnicianId {
    final $_column = $_itemColumn<int>('assigned_technician_id');
    if ($_column == null) return null;
    final manager = $$TechniciansTableTableManager($_db, $_db.technicians)
        .filter((f) => f.id.sqlEquals($_column));
    final item =
        $_typedResult.readTableOrNull(_assignedTechnicianIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TicketEventsTable, List<TicketEventRow>>
      _ticketEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.ticketEvents,
          aliasName:
              $_aliasNameGenerator(db.tickets.id, db.ticketEvents.ticketId));

  $$TicketEventsTableProcessedTableManager get ticketEventsRefs {
    final manager = $$TicketEventsTableTableManager($_db, $_db.ticketEvents)
        .filter((f) => f.ticketId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ticketEventsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DmfExportsTable, List<DmfExportRow>>
      _dmfExportsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.dmfExports,
              aliasName:
                  $_aliasNameGenerator(db.tickets.id, db.dmfExports.ticketId));

  $$DmfExportsTableProcessedTableManager get dmfExportsRefs {
    final manager = $$DmfExportsTableTableManager($_db, $_db.dmfExports)
        .filter((f) => f.ticketId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dmfExportsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TicketsTableFilterComposer
    extends Composer<_$AppDatabase, $TicketsTable> {
  $$TicketsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get folio => $composableBuilder(
      column: $table.folio, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
      column: $table.resolvedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
      column: $table.closedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get altaJson => $composableBuilder(
      column: $table.altaJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get requesterId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.requesterId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TechniciansTableFilterComposer get assignedTechnicianId {
    final $$TechniciansTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.assignedTechnicianId,
        referencedTable: $db.technicians,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TechniciansTableFilterComposer(
              $db: $db,
              $table: $db.technicians,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> ticketEventsRefs(
      Expression<bool> Function($$TicketEventsTableFilterComposer f) f) {
    final $$TicketEventsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ticketEvents,
        getReferencedColumn: (t) => t.ticketId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketEventsTableFilterComposer(
              $db: $db,
              $table: $db.ticketEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> dmfExportsRefs(
      Expression<bool> Function($$DmfExportsTableFilterComposer f) f) {
    final $$DmfExportsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dmfExports,
        getReferencedColumn: (t) => t.ticketId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DmfExportsTableFilterComposer(
              $db: $db,
              $table: $db.dmfExports,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TicketsTableOrderingComposer
    extends Composer<_$AppDatabase, $TicketsTable> {
  $$TicketsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get folio => $composableBuilder(
      column: $table.folio, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
      column: $table.resolvedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
      column: $table.closedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get altaJson => $composableBuilder(
      column: $table.altaJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson,
      builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get requesterId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.requesterId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TechniciansTableOrderingComposer get assignedTechnicianId {
    final $$TechniciansTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.assignedTechnicianId,
        referencedTable: $db.technicians,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TechniciansTableOrderingComposer(
              $db: $db,
              $table: $db.technicians,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TicketsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TicketsTable> {
  $$TicketsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get folio =>
      $composableBuilder(column: $table.folio, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
      column: $table.resolvedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<String> get altaJson =>
      $composableBuilder(column: $table.altaJson, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => column);

  $$UsersTableAnnotationComposer get requesterId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.requesterId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TechniciansTableAnnotationComposer get assignedTechnicianId {
    final $$TechniciansTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.assignedTechnicianId,
        referencedTable: $db.technicians,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TechniciansTableAnnotationComposer(
              $db: $db,
              $table: $db.technicians,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> ticketEventsRefs<T extends Object>(
      Expression<T> Function($$TicketEventsTableAnnotationComposer a) f) {
    final $$TicketEventsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ticketEvents,
        getReferencedColumn: (t) => t.ticketId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketEventsTableAnnotationComposer(
              $db: $db,
              $table: $db.ticketEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> dmfExportsRefs<T extends Object>(
      Expression<T> Function($$DmfExportsTableAnnotationComposer a) f) {
    final $$DmfExportsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dmfExports,
        getReferencedColumn: (t) => t.ticketId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DmfExportsTableAnnotationComposer(
              $db: $db,
              $table: $db.dmfExports,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TicketsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TicketsTable,
    TicketRow,
    $$TicketsTableFilterComposer,
    $$TicketsTableOrderingComposer,
    $$TicketsTableAnnotationComposer,
    $$TicketsTableCreateCompanionBuilder,
    $$TicketsTableUpdateCompanionBuilder,
    (TicketRow, $$TicketsTableReferences),
    TicketRow,
    PrefetchHooks Function(
        {bool requesterId,
        bool assignedTechnicianId,
        bool ticketEventsRefs,
        bool dmfExportsRefs})> {
  $$TicketsTableTableManager(_$AppDatabase db, $TicketsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TicketsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TicketsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TicketsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> folio = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> requesterId = const Value.absent(),
            Value<int?> assignedTechnicianId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> resolvedAt = const Value.absent(),
            Value<DateTime?> closedAt = const Value.absent(),
            Value<String?> altaJson = const Value.absent(),
            Value<String> metadataJson = const Value.absent(),
          }) =>
              TicketsCompanion(
            id: id,
            folio: folio,
            title: title,
            description: description,
            category: category,
            status: status,
            requesterId: requesterId,
            assignedTechnicianId: assignedTechnicianId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            resolvedAt: resolvedAt,
            closedAt: closedAt,
            altaJson: altaJson,
            metadataJson: metadataJson,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String folio,
            required String title,
            required String description,
            required String category,
            required String status,
            required int requesterId,
            Value<int?> assignedTechnicianId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> resolvedAt = const Value.absent(),
            Value<DateTime?> closedAt = const Value.absent(),
            Value<String?> altaJson = const Value.absent(),
            Value<String> metadataJson = const Value.absent(),
          }) =>
              TicketsCompanion.insert(
            id: id,
            folio: folio,
            title: title,
            description: description,
            category: category,
            status: status,
            requesterId: requesterId,
            assignedTechnicianId: assignedTechnicianId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            resolvedAt: resolvedAt,
            closedAt: closedAt,
            altaJson: altaJson,
            metadataJson: metadataJson,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TicketsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {requesterId = false,
              assignedTechnicianId = false,
              ticketEventsRefs = false,
              dmfExportsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (ticketEventsRefs) db.ticketEvents,
                if (dmfExportsRefs) db.dmfExports
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (requesterId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.requesterId,
                    referencedTable:
                        $$TicketsTableReferences._requesterIdTable(db),
                    referencedColumn:
                        $$TicketsTableReferences._requesterIdTable(db).id,
                  ) as T;
                }
                if (assignedTechnicianId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.assignedTechnicianId,
                    referencedTable:
                        $$TicketsTableReferences._assignedTechnicianIdTable(db),
                    referencedColumn: $$TicketsTableReferences
                        ._assignedTechnicianIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ticketEventsRefs)
                    await $_getPrefetchedData<TicketRow, $TicketsTable,
                            TicketEventRow>(
                        currentTable: table,
                        referencedTable:
                            $$TicketsTableReferences._ticketEventsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TicketsTableReferences(db, table, p0)
                                .ticketEventsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.ticketId == item.id),
                        typedResults: items),
                  if (dmfExportsRefs)
                    await $_getPrefetchedData<TicketRow, $TicketsTable,
                            DmfExportRow>(
                        currentTable: table,
                        referencedTable:
                            $$TicketsTableReferences._dmfExportsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TicketsTableReferences(db, table, p0)
                                .dmfExportsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.ticketId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TicketsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TicketsTable,
    TicketRow,
    $$TicketsTableFilterComposer,
    $$TicketsTableOrderingComposer,
    $$TicketsTableAnnotationComposer,
    $$TicketsTableCreateCompanionBuilder,
    $$TicketsTableUpdateCompanionBuilder,
    (TicketRow, $$TicketsTableReferences),
    TicketRow,
    PrefetchHooks Function(
        {bool requesterId,
        bool assignedTechnicianId,
        bool ticketEventsRefs,
        bool dmfExportsRefs})>;
typedef $$TicketEventsTableCreateCompanionBuilder = TicketEventsCompanion
    Function({
  Value<int> id,
  required int ticketId,
  required String type,
  required String author,
  required String message,
  Value<String> metadataJson,
  Value<DateTime> createdAt,
});
typedef $$TicketEventsTableUpdateCompanionBuilder = TicketEventsCompanion
    Function({
  Value<int> id,
  Value<int> ticketId,
  Value<String> type,
  Value<String> author,
  Value<String> message,
  Value<String> metadataJson,
  Value<DateTime> createdAt,
});

final class $$TicketEventsTableReferences
    extends BaseReferences<_$AppDatabase, $TicketEventsTable, TicketEventRow> {
  $$TicketEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TicketsTable _ticketIdTable(_$AppDatabase db) =>
      db.tickets.createAlias(
          $_aliasNameGenerator(db.ticketEvents.ticketId, db.tickets.id));

  $$TicketsTableProcessedTableManager get ticketId {
    final $_column = $_itemColumn<int>('ticket_id')!;

    final manager = $$TicketsTableTableManager($_db, $_db.tickets)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ticketIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TicketEventsTableFilterComposer
    extends Composer<_$AppDatabase, $TicketEventsTable> {
  $$TicketEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$TicketsTableFilterComposer get ticketId {
    final $$TicketsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableFilterComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TicketEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $TicketEventsTable> {
  $$TicketEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$TicketsTableOrderingComposer get ticketId {
    final $$TicketsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableOrderingComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TicketEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TicketEventsTable> {
  $$TicketEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TicketsTableAnnotationComposer get ticketId {
    final $$TicketsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableAnnotationComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TicketEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TicketEventsTable,
    TicketEventRow,
    $$TicketEventsTableFilterComposer,
    $$TicketEventsTableOrderingComposer,
    $$TicketEventsTableAnnotationComposer,
    $$TicketEventsTableCreateCompanionBuilder,
    $$TicketEventsTableUpdateCompanionBuilder,
    (TicketEventRow, $$TicketEventsTableReferences),
    TicketEventRow,
    PrefetchHooks Function({bool ticketId})> {
  $$TicketEventsTableTableManager(_$AppDatabase db, $TicketEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TicketEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TicketEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TicketEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> ticketId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> author = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<String> metadataJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              TicketEventsCompanion(
            id: id,
            ticketId: ticketId,
            type: type,
            author: author,
            message: message,
            metadataJson: metadataJson,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int ticketId,
            required String type,
            required String author,
            required String message,
            Value<String> metadataJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              TicketEventsCompanion.insert(
            id: id,
            ticketId: ticketId,
            type: type,
            author: author,
            message: message,
            metadataJson: metadataJson,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TicketEventsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({ticketId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (ticketId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ticketId,
                    referencedTable:
                        $$TicketEventsTableReferences._ticketIdTable(db),
                    referencedColumn:
                        $$TicketEventsTableReferences._ticketIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TicketEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TicketEventsTable,
    TicketEventRow,
    $$TicketEventsTableFilterComposer,
    $$TicketEventsTableOrderingComposer,
    $$TicketEventsTableAnnotationComposer,
    $$TicketEventsTableCreateCompanionBuilder,
    $$TicketEventsTableUpdateCompanionBuilder,
    (TicketEventRow, $$TicketEventsTableReferences),
    TicketEventRow,
    PrefetchHooks Function({bool ticketId})>;
typedef $$CatalogEntriesTableCreateCompanionBuilder = CatalogEntriesCompanion
    Function({
  Value<int> id,
  required String type,
  required String code,
  required String description,
});
typedef $$CatalogEntriesTableUpdateCompanionBuilder = CatalogEntriesCompanion
    Function({
  Value<int> id,
  Value<String> type,
  Value<String> code,
  Value<String> description,
});

class $$CatalogEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogEntriesTable> {
  $$CatalogEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));
}

class $$CatalogEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogEntriesTable> {
  $$CatalogEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));
}

class $$CatalogEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogEntriesTable> {
  $$CatalogEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);
}

class $$CatalogEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CatalogEntriesTable,
    CatalogEntryRow,
    $$CatalogEntriesTableFilterComposer,
    $$CatalogEntriesTableOrderingComposer,
    $$CatalogEntriesTableAnnotationComposer,
    $$CatalogEntriesTableCreateCompanionBuilder,
    $$CatalogEntriesTableUpdateCompanionBuilder,
    (
      CatalogEntryRow,
      BaseReferences<_$AppDatabase, $CatalogEntriesTable, CatalogEntryRow>
    ),
    CatalogEntryRow,
    PrefetchHooks Function()> {
  $$CatalogEntriesTableTableManager(
      _$AppDatabase db, $CatalogEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> description = const Value.absent(),
          }) =>
              CatalogEntriesCompanion(
            id: id,
            type: type,
            code: code,
            description: description,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String type,
            required String code,
            required String description,
          }) =>
              CatalogEntriesCompanion.insert(
            id: id,
            type: type,
            code: code,
            description: description,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CatalogEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CatalogEntriesTable,
    CatalogEntryRow,
    $$CatalogEntriesTableFilterComposer,
    $$CatalogEntriesTableOrderingComposer,
    $$CatalogEntriesTableAnnotationComposer,
    $$CatalogEntriesTableCreateCompanionBuilder,
    $$CatalogEntriesTableUpdateCompanionBuilder,
    (
      CatalogEntryRow,
      BaseReferences<_$AppDatabase, $CatalogEntriesTable, CatalogEntryRow>
    ),
    CatalogEntryRow,
    PrefetchHooks Function()>;
typedef $$DmfExportsTableCreateCompanionBuilder = DmfExportsCompanion Function({
  Value<int> id,
  required int ticketId,
  required String pdfPath,
  required String csvPath,
  Value<DateTime> createdAt,
});
typedef $$DmfExportsTableUpdateCompanionBuilder = DmfExportsCompanion Function({
  Value<int> id,
  Value<int> ticketId,
  Value<String> pdfPath,
  Value<String> csvPath,
  Value<DateTime> createdAt,
});

final class $$DmfExportsTableReferences
    extends BaseReferences<_$AppDatabase, $DmfExportsTable, DmfExportRow> {
  $$DmfExportsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TicketsTable _ticketIdTable(_$AppDatabase db) => db.tickets
      .createAlias($_aliasNameGenerator(db.dmfExports.ticketId, db.tickets.id));

  $$TicketsTableProcessedTableManager get ticketId {
    final $_column = $_itemColumn<int>('ticket_id')!;

    final manager = $$TicketsTableTableManager($_db, $_db.tickets)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ticketIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DmfExportsTableFilterComposer
    extends Composer<_$AppDatabase, $DmfExportsTable> {
  $$DmfExportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pdfPath => $composableBuilder(
      column: $table.pdfPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get csvPath => $composableBuilder(
      column: $table.csvPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$TicketsTableFilterComposer get ticketId {
    final $$TicketsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableFilterComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DmfExportsTableOrderingComposer
    extends Composer<_$AppDatabase, $DmfExportsTable> {
  $$DmfExportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pdfPath => $composableBuilder(
      column: $table.pdfPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get csvPath => $composableBuilder(
      column: $table.csvPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$TicketsTableOrderingComposer get ticketId {
    final $$TicketsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableOrderingComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DmfExportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DmfExportsTable> {
  $$DmfExportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pdfPath =>
      $composableBuilder(column: $table.pdfPath, builder: (column) => column);

  GeneratedColumn<String> get csvPath =>
      $composableBuilder(column: $table.csvPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TicketsTableAnnotationComposer get ticketId {
    final $$TicketsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ticketId,
        referencedTable: $db.tickets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TicketsTableAnnotationComposer(
              $db: $db,
              $table: $db.tickets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DmfExportsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DmfExportsTable,
    DmfExportRow,
    $$DmfExportsTableFilterComposer,
    $$DmfExportsTableOrderingComposer,
    $$DmfExportsTableAnnotationComposer,
    $$DmfExportsTableCreateCompanionBuilder,
    $$DmfExportsTableUpdateCompanionBuilder,
    (DmfExportRow, $$DmfExportsTableReferences),
    DmfExportRow,
    PrefetchHooks Function({bool ticketId})> {
  $$DmfExportsTableTableManager(_$AppDatabase db, $DmfExportsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DmfExportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DmfExportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DmfExportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> ticketId = const Value.absent(),
            Value<String> pdfPath = const Value.absent(),
            Value<String> csvPath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              DmfExportsCompanion(
            id: id,
            ticketId: ticketId,
            pdfPath: pdfPath,
            csvPath: csvPath,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int ticketId,
            required String pdfPath,
            required String csvPath,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              DmfExportsCompanion.insert(
            id: id,
            ticketId: ticketId,
            pdfPath: pdfPath,
            csvPath: csvPath,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DmfExportsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({ticketId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (ticketId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ticketId,
                    referencedTable:
                        $$DmfExportsTableReferences._ticketIdTable(db),
                    referencedColumn:
                        $$DmfExportsTableReferences._ticketIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$DmfExportsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DmfExportsTable,
    DmfExportRow,
    $$DmfExportsTableFilterComposer,
    $$DmfExportsTableOrderingComposer,
    $$DmfExportsTableAnnotationComposer,
    $$DmfExportsTableCreateCompanionBuilder,
    $$DmfExportsTableUpdateCompanionBuilder,
    (DmfExportRow, $$DmfExportsTableReferences),
    DmfExportRow,
    PrefetchHooks Function({bool ticketId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$TechniciansTableTableManager get technicians =>
      $$TechniciansTableTableManager(_db, _db.technicians);
  $$TicketsTableTableManager get tickets =>
      $$TicketsTableTableManager(_db, _db.tickets);
  $$TicketEventsTableTableManager get ticketEvents =>
      $$TicketEventsTableTableManager(_db, _db.ticketEvents);
  $$CatalogEntriesTableTableManager get catalogEntries =>
      $$CatalogEntriesTableTableManager(_db, _db.catalogEntries);
  $$DmfExportsTableTableManager get dmfExports =>
      $$DmfExportsTableTableManager(_db, _db.dmfExports);
}

mixin _$TicketDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $TechniciansTable get technicians => attachedDatabase.technicians;
  $TicketsTable get tickets => attachedDatabase.tickets;
  $TicketEventsTable get ticketEvents => attachedDatabase.ticketEvents;
  $CatalogEntriesTable get catalogEntries => attachedDatabase.catalogEntries;
  $DmfExportsTable get dmfExports => attachedDatabase.dmfExports;
}
