import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sistema_tickets_edis/core/errors/failure.dart';
import 'package:sistema_tickets_edis/data/local/database/app_database.dart';
import 'package:sistema_tickets_edis/domain/entities/session_user.dart';
import 'package:sistema_tickets_edis/domain/entities/user.dart';
import 'package:sistema_tickets_edis/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required SharedPreferences preferences,
    required AppDatabase database,
  })  : _preferences = preferences,
        _database = database {
    _controller = StreamController<SessionUser?>.broadcast(
      onListen: () {
        _controller.add(_currentUser);
      },
    );
    _accounts = _readAccounts();
    final String? persistedEmail = _preferences.getString(_currentKey);
    if (persistedEmail != null) {
      unawaited(_restoreSession(persistedEmail));
    } else {
      _emit(null);
    }
  }

  static const String _accountsKey = 'auth.accounts';
  static const String _currentKey = 'auth.current';
  static final List<_AdminIdentity> _adminIdentities = <_AdminIdentity>[
    _AdminIdentity(
      fullName: 'Juan Pablo Pérez',
      email: 'jperez@mmpg.com.mx',
    ),
    _AdminIdentity(
      fullName: 'Luis Ángel Mendoza',
      email: 'lmendoza@mmpg.com.mx',
    ),
    _AdminIdentity(
      fullName: 'Vicente Estrada',
      email: 'vestrada@mmpg.com.mx',
    ),
  ];

  final SharedPreferences _preferences;
  final AppDatabase _database;
  late final StreamController<SessionUser?> _controller;
  Map<String, _StoredAccount> _accounts = <String, _StoredAccount>{};
  SessionUser? _currentUser;

  @override
  Stream<SessionUser?> watchSession() => _controller.stream;

  @override
  Future<SessionUser?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }
    final String? email = _preferences.getString(_currentKey);
    if (email == null) {
      return null;
    }
    await _restoreSession(email);
    return _currentUser;
  }

  @override
  Future<SessionUser> login({
    required String email,
    required String password,
  }) async {
    final String normalizedEmail = _normalizeEmail(email);
    final _StoredAccount? stored = _accounts[normalizedEmail];
    if (stored == null) {
      throw const AuthenticationFailure('El correo no está registrado.');
    }
    final String passwordHash = _hashPassword(password);
    if (stored.passwordHash != passwordHash) {
      throw const AuthenticationFailure('Credenciales inválidas.');
    }
    final UserRow? userRow = await _database.ticketDao.findUserById(stored.userId);
    final UserRow user = userRow ??
        await _database.ticketDao.ensureUser(
          name: stored.name,
          email: stored.email,
        );
    if (userRow == null && stored.userId != user.id) {
      _accounts[normalizedEmail] = stored.copyWith(
        userId: user.id,
        name: user.name,
        email: user.email ?? stored.email,
      );
      await _persistAccounts();
    }
    final SessionUser sessionUser = _buildSessionUser(user.toDomain());
    await _preferences.setString(_currentKey, normalizedEmail);
    _emit(sessionUser);
    return sessionUser;
  }

  @override
  Future<SessionUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final String normalizedEmail = _normalizeEmail(email);
    if (_accounts.containsKey(normalizedEmail)) {
      throw const AuthenticationFailure('El correo ya está registrado.');
    }
    final String normalizedName = name.trim();
    final UserRow userRow = await _database.ticketDao.ensureUser(
      name: normalizedName,
      email: normalizedEmail,
    );
    final _StoredAccount account = _StoredAccount(
      userId: userRow.id,
      name: userRow.name,
      email: normalizedEmail,
      passwordHash: _hashPassword(password),
    );
    _accounts[normalizedEmail] = account;
    await _persistAccounts();
    await _preferences.setString(_currentKey, normalizedEmail);
    final SessionUser sessionUser = _buildSessionUser(userRow.toDomain());
    _emit(sessionUser);
    return sessionUser;
  }

  @override
  Future<void> logout() async {
    _accounts = _readAccounts();
    await _preferences.remove(_currentKey);
    _emit(null);
  }

  void dispose() {
    _controller.close();
  }

  void _emit(SessionUser? user) {
    _currentUser = user;
    if (!_controller.isClosed) {
      _controller.add(user);
    }
  }

  Future<void> _restoreSession(String email) async {
    final String normalizedEmail = _normalizeEmail(email);
    final _StoredAccount? stored = _accounts[normalizedEmail];
    if (stored == null) {
      await _preferences.remove(_currentKey);
      _emit(null);
      return;
    }
    final UserRow? userRow = await _database.ticketDao.findUserById(stored.userId);
    if (userRow == null) {
      final UserRow ensured = await _database.ticketDao.ensureUser(
        name: stored.name,
        email: stored.email,
      );
      _accounts[normalizedEmail] = stored.copyWith(
        userId: ensured.id,
        name: ensured.name,
        email: ensured.email ?? stored.email,
      );
      await _persistAccounts();
      final SessionUser sessionUser = _buildSessionUser(ensured.toDomain());
      _emit(sessionUser);
      return;
    }
    final SessionUser sessionUser = _buildSessionUser(userRow.toDomain());
    _emit(sessionUser);
  }

  Map<String, _StoredAccount> _readAccounts() {
    final String? raw = _preferences.getString(_accountsKey);
    if (raw == null || raw.isEmpty) {
      return <String, _StoredAccount>{};
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return <String, _StoredAccount>{
        for (final dynamic entry in decoded)
          if (entry is Map<String, dynamic>)
            entry['email'] as String: _StoredAccount.fromJson(entry),
      };
    } catch (_) {
      return <String, _StoredAccount>{};
    }
  }

  Future<void> _persistAccounts() async {
    final List<Map<String, dynamic>> serialized = _accounts.values
        .map((_StoredAccount account) => account.toJson())
        .toList();
    await _preferences.setString(_accountsKey, jsonEncode(serialized));
  }

  SessionUser _buildSessionUser(User user) {
    final UserRole role = _isAdmin(user.name, user.email) ? UserRole.admin : UserRole.user;
    return SessionUser(user: user, role: role);
  }

  bool _isAdmin(String name, String? email) {
    final String normalizedName = _normalizeName(name);
    final String? normalizedEmail =
        email != null && email.isNotEmpty ? _normalizeEmail(email) : null;
    for (final _AdminIdentity identity in _adminIdentities) {
      if (identity.matches(normalizedName: normalizedName, normalizedEmail: normalizedEmail)) {
        return true;
      }
    }
    return false;
  }

  static String _normalizeEmail(String email) => email.trim().toLowerCase();

  static String _normalizeName(String value) {
    final String lowered = value.trim().toLowerCase();
    final Map<String, String> replacements = <String, String>{
      'á': 'a',
      'à': 'a',
      'ä': 'a',
      'â': 'a',
      'é': 'e',
      'è': 'e',
      'ë': 'e',
      'ê': 'e',
      'í': 'i',
      'ì': 'i',
      'ï': 'i',
      'î': 'i',
      'ó': 'o',
      'ò': 'o',
      'ö': 'o',
      'ô': 'o',
      'ú': 'u',
      'ù': 'u',
      'ü': 'u',
      'û': 'u',
      'ñ': 'n',
    };
    String normalized = lowered;
    replacements.forEach((String original, String replacement) {
      normalized = normalized.replaceAll(original, replacement);
    });
    normalized = normalized.replaceAll(RegExp(r'[\-_,.]'), ' ');
    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9\s]'), '');
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    return normalized;
  }

  String _hashPassword(String password) {
    final List<int> bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }
}

class _StoredAccount {
  const _StoredAccount({
    required this.userId,
    required this.name,
    required this.email,
    required this.passwordHash,
  });

  final int userId;
  final String name;
  final String email;
  final String passwordHash;

  _StoredAccount copyWith({
    int? userId,
    String? name,
    String? email,
    String? passwordHash,
  }) {
    return _StoredAccount(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userId': userId,
        'name': name,
        'email': email,
        'passwordHash': passwordHash,
      };

  factory _StoredAccount.fromJson(Map<String, dynamic> json) => _StoredAccount(
        userId: json['userId'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        passwordHash: json['passwordHash'] as String,
      );
}

class _AdminIdentity {
  const _AdminIdentity({
    required this.fullName,
    required this.email,
  });

  final String fullName;
  final String email;

  bool matches({String? normalizedName, String? normalizedEmail}) {
    final String normalizedFullName = AuthRepositoryImpl._normalizeName(fullName);
    final String normalizedEmailValue = AuthRepositoryImpl._normalizeEmail(email);

    if (normalizedEmail != null && normalizedEmail == normalizedEmailValue) {
      return true;
    }

    final Set<String> nameCandidates = <String>{normalizedFullName};
    final List<String> parts = normalizedFullName.split(' ');
    if (parts.isNotEmpty) {
      nameCandidates.add(parts.first);
      nameCandidates.add(parts.last);
      for (int i = 1; i <= parts.length; i++) {
        nameCandidates.add(parts.take(i).join(' '));
      }
      if (parts.length >= 2) {
        nameCandidates.add('${parts.first} ${parts.last}');
      }
    }

    if (normalizedName != null && nameCandidates.contains(normalizedName)) {
      return true;
    }

    if (normalizedEmail != null) {
      final String localPart = normalizedEmail.split('@').first;
      final String normalizedLocal =
          AuthRepositoryImpl._normalizeName(localPart.replaceAll(RegExp(r'[._]'), ' '));
      if (nameCandidates.contains(normalizedLocal)) {
        return true;
      }
    }

    return false;
  }
}
