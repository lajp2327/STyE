import 'dart:html' as html;

import 'token_store.dart';

class WebTokenStore implements TokenStore {
  WebTokenStore([html.Storage? storage]) : _storage = storage ?? _resolveStorage();

  final html.Storage? _storage;

  static html.Storage? _resolveStorage() {
    try {
      return html.window.localStorage;
    } catch (_) {
      return null;
    }
  }

  html.Storage _ensureStorage() {
    final html.Storage? storage = _storage;
    if (storage == null) {
      throw UnsupportedError('localStorage no está disponible en este navegador.');
    }
    return storage;
  }

  @override
  Future<void> write(String key, String value) async {
    _ensureStorage()[key] = value;
  }

  @override
  Future<String?> read(String key) async {
    return _ensureStorage()[key];
  }

  @override
  Future<void> delete(String key) async {
    _ensureStorage().remove(key);
  }
}

TokenStore createTokenStoreImpl() => WebTokenStore();
