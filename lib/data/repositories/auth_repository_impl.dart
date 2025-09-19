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
  static const List<String> _adminKeywords = <String>['juan pablo', 'luis', 'vicente'];

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
    final String normalizedName = name.trim().toLowerCase();
    if (_adminKeywords.contains(normalizedName)) {
      return true;
    }
    if (email != null && email.isNotEmpty) {
      final String localPart = email.split('@').first;
      final String normalizedLocal = localPart.replaceAll(RegExp(r'[._]'), ' ').trim().toLowerCase();
      final String compactLocal = normalizedLocal.replaceAll(' ', '');
      return _adminKeywords.contains(normalizedLocal) || _adminKeywords.contains(compactLocal);
    }
    return false;
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

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
