import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_store.dart';

class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<void> write(String key, String value) {
    return _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read(String key) {
    return _storage.read(key: key);
  }

  @override
  Future<void> delete(String key) {
    return _storage.delete(key: key);
  }

  @override
  Future<void> deleteAll(Iterable<String> keys) async {
    for (final String key in keys) {
      await _storage.delete(key: key);
    }
  }
}

TokenStore createTokenStoreImpl() => SecureTokenStore();
