import 'token_store_stub.dart'
    if (dart.library.html) 'token_store_web.dart'
    if (dart.library.io) 'token_store_secure.dart';

/// Persiste tokens de autenticación en el medio apropiado para la plataforma.
abstract class TokenStore {
  Future<void> write(String key, String value);

  Future<String?> read(String key);

  Future<void> delete(String key);

  Future<void> deleteAll(Iterable<String> keys) async {
    for (final String key in keys) {
      await delete(key);
    }
  }
}

TokenStore createTokenStore() => createTokenStoreImpl();
