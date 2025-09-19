// lib/data/local/database/app_database.dart
import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:sistema_tickets_edis/domain/entities/catalog.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket_event.dart';
import 'package:sistema_tickets_edis/domain/entities/technician.dart';
import 'package:sistema_tickets_edis/domain/entities/user.dart';

part 'app_database.g.dart';

/// Conexión perezosa a SQLite
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    try {
      final Directory dir = await getApplicationDocumentsDirectory();
      final File file = File(p.join(dir.path, 'tickets.db'));
      return NativeDatabase(file);
    } catch (_) {
      final Directory temp =
          await Directory.systemTemp.createTemp('tickets_db');
      final File file = File(p.join(temp.path, 'tickets.db'));
      return NativeDatabase(file);
    }
  });
}

/// ========================
/// Tablas Drift (fuente)
/// ========================

@DataClassName('UserRow')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get email => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('TechnicianRow')
class Technicians extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

@DataClassName('TicketRow')
class Tickets extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get folio => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get category => text()();
  TextColumn get status => text()();

  /// Solicitante
  IntColumn get requesterId => integer().references(Users, #id)();

  /// Técnico asignado (nullable)
  IntColumn get assignedTechnicianId =>
      integer().nullable().references(Technicians, #id)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  DateTimeColumn get closedAt => dateTime().nullable()();

  /// JSON del caso de alta RM/FG (opcional)
  TextColumn get altaJson => text().nullable()();

  /// Metadatos varios
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
}

@DataClassName('TicketEventRow')
class TicketEvents extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get ticketId =>
      integer().references(Tickets, #id, onDelete: KeyAction.cascade)();

  TextColumn get type => text()();
  TextColumn get author => text()();
  TextColumn get message => text()();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('CatalogEntryRow')
class CatalogEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();
  TextColumn get code => text()();
  TextColumn get description => text()();

  @override
  List<Set<Column>> get uniqueKeys => <Set<Column>>[
        <Column>{type, code},
      ];
}

@DataClassName('DmfExportRow')
class DmfExports extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get ticketId =>
      integer().references(Tickets, #id, onDelete: KeyAction.cascade)();

  TextColumn get pdfPath => text()();
  TextColumn get csvPath => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// ========================
/// Base de datos + DAOs
/// ========================

@DriftDatabase(
  tables: <Type>[
    Users,
    Technicians,
    Tickets,
    TicketEvents,
    CatalogEntries,
    DmfExports,
  ],
  daos: <Type>[
    TicketDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor}) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await m.createAll();
          await _seedTechnicians();
          await _seedCatalogs();
        },
        beforeOpen: (OpeningDetails details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Seeds: Técnicos
  Future<void> _seedTechnicians() async {
    const List<Map<String, String>> seeds = <Map<String, String>>[
      {'name': 'María Sánchez', 'email': 'maria.sanchez@empresa.com'},
      {'name': 'Luis Ortega', 'email': 'luis.ortega@empresa.com'},
      {'name': 'Ana Herrera', 'email': 'ana.herrera@empresa.com'},
    ];

    await batch((Batch b) {
      b.insertAll(
        technicians,
        seeds
            .map((e) => TechniciansCompanion.insert(
                  name: e['name']!,
                  email: e['email']!,
                ))
            .toList(),
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  /// Seeds: Catálogos
  Future<void> _seedCatalogs() async {
    const Map<CatalogType, List<Map<String, String>>> catalogs =
        <CatalogType, List<Map<String, String>>>{
      CatalogType.cliente: [
        {'code': 'C001', 'description': 'Cliente 1'},
        {'code': 'C002', 'description': 'Cliente 2'},
      ],
      CatalogType.destino: [
        {'code': 'D-MX', 'description': 'Monterrey'},
        {'code': 'D-GDL', 'description': 'Guadalajara'},
      ],
      CatalogType.material: [
        {'code': 'MAT-AL', 'description': 'Aluminio'},
        {'code': 'MAT-AC', 'description': 'Acero'},
      ],
      CatalogType.norma: [
        {'code': 'N-ISO', 'description': 'ISO 9001'},
        {'code': 'N-ASTM', 'description': 'ASTM A36'},
      ],
      CatalogType.propiedadesQuimicas: [
        {'code': 'Q-BASE', 'description': 'Base estándar'},
        {'code': 'Q-ALT', 'description': 'Alta resistencia'},
      ],
      CatalogType.propiedadesMecanicas: [
        {'code': 'M-STD', 'description': 'Módulo estándar'},
        {'code': 'M-ALT', 'description': 'Módulo alterno'},
      ],
      CatalogType.numeroParte: [
        {'code': 'NP-001', 'description': 'Parte 001'},
        {'code': 'NP-002', 'description': 'Parte 002'},
      ],
    };

    await batch((Batch b) {
      for (final entry in catalogs.entries) {
        b.insertAll(
          catalogEntries,
          entry.value
              .map((item) => CatalogEntriesCompanion.insert(
                    type: entry.key.code,
                    code: item['code']!,
                    description: item['description']!,
                  ))
              .toList(),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }
}

/// DTO compuesto útil para UI/servicios
class TicketWithRelations {
  const TicketWithRelations({
    required this.ticket,
    required this.requester,
    this.technician,
  });

  final TicketRow ticket;
  final UserRow requester;
  final TechnicianRow? technician;
}

@DriftAccessor(
  tables: <Type>[
    Tickets,
    TicketEvents,
    Technicians,
    CatalogEntries,
    Users,
    DmfExports,
  ],
)
class TicketDao extends DatabaseAccessor<AppDatabase> with _$TicketDaoMixin {
  TicketDao(AppDatabase db) : super(db);

  /// Listado reactivo de tickets con solicitante y técnico (si existe)
  Stream<List<TicketWithRelations>> watchTickets() {
    final query = select(tickets).join(<Join>[
      innerJoin(users, users.id.equalsExp(tickets.requesterId)),
      leftOuterJoin(
        technicians,
        technicians.id.equalsExp(tickets.assignedTechnicianId),
      ),
    ])
      ..orderBy(<OrderingTerm>[
        OrderingTerm(expression: tickets.createdAt, mode: OrderingMode.desc),
      ]);

    return query.watch().map(
          (rows) => rows.map(_mapTicketResult).toList(),
        );
  }

  Future<List<TicketWithRelations>> getAllTickets() async {
    final query = select(tickets).join(<Join>[
      innerJoin(users, users.id.equalsExp(tickets.requesterId)),
      leftOuterJoin(
        technicians,
        technicians.id.equalsExp(tickets.assignedTechnicianId),
      ),
    ])
      ..orderBy(<OrderingTerm>[
        OrderingTerm(expression: tickets.createdAt, mode: OrderingMode.desc),
      ]);

    final rows = await query.get();
    return rows.map(_mapTicketResult).toList();
  }

  Future<TicketWithRelations?> findTicket(int id) async {
    final query = select(tickets).join(<Join>[
      innerJoin(users, users.id.equalsExp(tickets.requesterId)),
      leftOuterJoin(
        technicians,
        technicians.id.equalsExp(tickets.assignedTechnicianId),
      ),
    ])
      ..where(tickets.id.equals(id));

    final rows = await query.get();
    if (rows.isEmpty) return null;
    return _mapTicketResult(rows.first);
  }

  Stream<List<TechnicianRow>> watchTechnicians() {
    final q = (select(technicians)
      ..where((t) => t.isActive.equals(true))
      ..orderBy([
        (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
      ]));
    return q.watch();
  }

  Future<List<TechnicianRow>> getAllTechnicians() {
    final q = (select(technicians)
      ..where((t) => t.isActive.equals(true))
      ..orderBy([
        (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
      ]));
    return q.get();
  }

  Stream<List<TicketEventRow>> watchEvents(int ticketId) {
    final q = (select(ticketEvents)
      ..where((e) => e.ticketId.equals(ticketId))
      ..orderBy([
        (e) => OrderingTerm(expression: e.createdAt, mode: OrderingMode.asc),
      ]));
    return q.watch();
  }

  /// Inserta ticket usando Companions (recomendado)
  Future<int> insertTicket(TicketsCompanion entry) {
    return into(tickets).insert(entry);
  }

  Future<void> updateTicketStatus({
    required int ticketId,
    required String status,
    DateTime? resolvedAt,
    DateTime? closedAt,
  }) async {
    await (update(tickets)..where((t) => t.id.equals(ticketId))).write(
      TicketsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
        resolvedAt: Value(resolvedAt),
        closedAt: Value(closedAt),
      ),
    );
  }

  Future<void> assignTechnician({
    required int ticketId,
    required int technicianId,
  }) async {
    await (update(tickets)..where((t) => t.id.equals(ticketId))).write(
      TicketsCompanion(
        assignedTechnicianId: Value(technicianId),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> insertEvent(TicketEventsCompanion entry) {
    return into(ticketEvents).insert(entry);
  }

  Future<void> insertDmfExport({
    required int ticketId,
    required String pdfPath,
    required String csvPath,
  }) async {
    await into(dmfExports).insert(
      DmfExportsCompanion.insert(
        ticketId: ticketId,
        pdfPath: pdfPath,
        csvPath: csvPath,
        // createdAt tiene default currentDateAndTime
      ),
    );
  }

  Future<Map<int, List<TicketEventRow>>> eventsByTicketIds(
      List<int> ids) async {
    if (ids.isEmpty) return <int, List<TicketEventRow>>{};
    final q = (select(ticketEvents)
      ..where((e) => e.ticketId.isIn(ids))
      ..orderBy([
        (e) => OrderingTerm(expression: e.createdAt, mode: OrderingMode.asc),
      ]));
    final rows = await q.get();
    return rows.groupListsBy((e) => e.ticketId);
  }

  Future<UserRow?> findUserById(int id) {
    return (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();
  }

  Future<UserRow?> findUserByEmail(String email) {
    return (select(users)..where((u) => u.email.equals(email))).getSingleOrNull();
  }

  Future<List<CatalogEntryRow>> getCatalogEntries(String type) {
    final q = (select(catalogEntries)
      ..where((c) => c.type.equals(type))
      ..orderBy([
        (c) => OrderingTerm(expression: c.description, mode: OrderingMode.asc),
      ]));
    return q.get();
  }

  /// Crea/actualiza un usuario por nombre/email (normalizado)
  Future<UserRow> ensureUser({required String name, String? email}) async {
    final String normalizedName = name.trim();
    final String? normalizedEmail =
        (email != null && email.trim().isNotEmpty) ? email.trim() : null;

    final existing = await (select(users)
          ..where((u) => u.name.equals(normalizedName)))
        .getSingleOrNull();

    if (existing != null) {
      if (normalizedEmail != null && existing.email != normalizedEmail) {
        await (update(users)..where((u) => u.id.equals(existing.id))).write(
          UsersCompanion(email: Value(normalizedEmail)),
        );
        return existing.copyWith(email: Value(normalizedEmail));
      }
      return existing;
    }

    final companion = UsersCompanion.insert(
      name: normalizedName,
      email: Value(normalizedEmail),
    );
    return into(users).insertReturning(companion);
  }

  /// Mapea un join row a DTO de UI
  TicketWithRelations _mapTicketResult(TypedResult row) {
    return TicketWithRelations(
      ticket: row.readTable(tickets),
      requester: row.readTable(users),
      technician: row.readTableOrNull(technicians),
    );
  }
}

/// ========================
/// Extensiones a dominio
/// ========================

extension TechnicianRowX on TechnicianRow {
  Technician toDomain() =>
      Technician(id: id, name: name, email: email, isActive: isActive);
}

extension UserRowX on UserRow {
  User toDomain() => User(id: id, name: name, email: email, isActive: isActive);
}

extension CatalogEntryRowX on CatalogEntryRow {
  CatalogEntry toDomain() => CatalogEntry(
        id: id,
        type: CatalogType.fromCode(type),
        code: code,
        description: description,
      );
}

extension TicketEventRowX on TicketEventRow {
  TicketEvent toDomain() => TicketEvent.fromDatabase(
        id: id,
        ticketId: ticketId,
        type: type,
        message: message,
        author: author,
        createdAt: createdAt,
        metadataJson: metadataJson,
      );
}
