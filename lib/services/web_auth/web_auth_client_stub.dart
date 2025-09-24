import 'web_auth_client.dart';

WebAuthClient createWebAuthClientImpl() => _UnsupportedWebAuthClient();

class _UnsupportedWebAuthClient implements WebAuthClient {
  @override
  Future<WebAuthResult> acquireTokenSilent({
    required List<String> scopes,
    String? accountId,
  }) {
    throw UnsupportedError('WebAuthClient no está disponible en esta plataforma.');
  }

  @override
  Future<WebAuthResult> login({required List<String> scopes}) {
    throw UnsupportedError('WebAuthClient no está disponible en esta plataforma.');
  }

  @override
  Future<void> logout({String? accountId}) async {}
}
