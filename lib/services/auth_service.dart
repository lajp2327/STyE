import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/auth_config.dart';

class AuthService {
  AuthService({
    FlutterAppAuth? appAuth,
    FlutterSecureStorage? secureStorage,
    DateTime Function()? now,
  })  : _appAuth = appAuth ?? const FlutterAppAuth(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _now = now ?? DateTime.now;

  final FlutterAppAuth _appAuth;
  final FlutterSecureStorage _secureStorage;
  final DateTime Function() _now;

  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _expiryKey = 'auth_access_token_expiry';

  Future<void> login() async {
    if (kIsWeb) {
      throw AuthException(
        'TODO: usa MSAL (msal-browser) o implementa un flujo PKCE manual para Web.',
      );
    }

    try {
      final AuthorizationTokenResponse? response =
          await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          AuthConfig.clientId,
          AuthConfig.redirectUriForPlatform(),
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: AuthConfig.authorizationEndpoint,
            tokenEndpoint: AuthConfig.tokenEndpoint,
          ),
          scopes: AuthConfig.scopes,
          promptValues: const <String>['select_account'],
        ),
      );

      if (response == null || response.accessToken == null) {
        throw const AuthException(
          'No se recibió un accessToken válido durante el inicio de sesión.',
        );
      }

      await _persistTokens(
        accessToken: response.accessToken!,
        refreshToken: response.refreshToken,
        expiry: response.accessTokenExpirationDateTime ??
            _now().toUtc().add(const Duration(hours: 1)),
      );
    } on AuthException {
      rethrow;
    } catch (error) {
      await logout();
      throw AuthException('Error durante el inicio de sesión: $error', error);
    }
  }

  Future<void> refreshIfNeeded() async {
    final DateTime? expiry = await _readExpiry();
    if (expiry == null) {
      return;
    }

    final Duration difference = expiry.difference(_now().toUtc());
    if (difference.inSeconds > 60) {
      return;
    }

    await _refreshToken();
  }

  Future<void> logout() async {
    await Future.wait(<Future<void>>[
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _secureStorage.delete(key: _expiryKey),
    ]);
  }

  Future<String> getAccessToken() async {
    await refreshIfNeeded();
    final String? accessToken =
        await _secureStorage.read(key: _accessTokenKey);

    if (accessToken == null || accessToken.isEmpty) {
      throw const AuthException('No hay una sesión válida. Ejecuta login().');
    }
    return accessToken;
  }

  Future<bool> hasValidSession() async {
    final String? accessToken =
        await _secureStorage.read(key: _accessTokenKey);
    final DateTime? expiry = await _readExpiry();

    if (accessToken == null || accessToken.isEmpty || expiry == null) {
      return false;
    }

    if (expiry.isBefore(_now().toUtc())) {
      try {
        await _refreshToken();
      } on AuthException {
        return false;
      }
    } else {
      try {
        await refreshIfNeeded();
      } on AuthException {
        return false;
      }
    }

    final String? refreshedToken =
        await _secureStorage.read(key: _accessTokenKey);
    return refreshedToken != null && refreshedToken.isNotEmpty;
  }

  Future<void> _refreshToken() async {
    if (kIsWeb) {
      throw AuthException(
        'TODO: usa MSAL (msal-browser) o implementa un flujo PKCE manual para Web.',
      );
    }

    final String? storedRefreshToken =
        await _secureStorage.read(key: _refreshTokenKey);
    if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
      throw const AuthException(
        'No hay refresh_token disponible. Inicia sesión nuevamente.',
      );
    }

    try {
      final TokenResponse? response = await _appAuth.token(
        TokenRequest(
          AuthConfig.clientId,
          AuthConfig.redirectUriForPlatform(),
          refreshToken: storedRefreshToken,
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: AuthConfig.authorizationEndpoint,
            tokenEndpoint: AuthConfig.tokenEndpoint,
          ),
          scopes: AuthConfig.scopes,
        ),
      );

      if (response == null || response.accessToken == null) {
        throw const AuthException(
          'No se recibió un accessToken válido al refrescar.',
        );
      }

      await _persistTokens(
        accessToken: response.accessToken!,
        refreshToken: response.refreshToken ?? storedRefreshToken,
        expiry: response.accessTokenExpirationDateTime ??
            _now().toUtc().add(const Duration(hours: 1)),
      );
    } on AuthException {
      rethrow;
    } catch (error) {
      await logout();
      throw AuthException('Error al refrescar el token: $error', error);
    }
  }

  Future<void> _persistTokens({
    required String accessToken,
    String? refreshToken,
    required DateTime expiry,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _secureStorage.write(
        key: _refreshTokenKey,
        value: refreshToken,
      );
    }
    await _secureStorage.write(
      key: _expiryKey,
      value: expiry.toUtc().toIso8601String(),
    );
  }

  Future<DateTime?> _readExpiry() async {
    final String? storedExpiry = await _secureStorage.read(key: _expiryKey);
    if (storedExpiry == null) {
      return null;
    }
    try {
      return DateTime.parse(storedExpiry).toUtc();
    } catch (_) {
      return null;
    }
  }
}

class AuthException implements Exception {
  const AuthException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() =>
      'AuthException: $message${cause != null ? ' (causa: $cause)' : ''}';
}
