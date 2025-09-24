import 'web_auth_client_stub.dart'
    if (dart.library.html) 'web_auth_client_web.dart';

class WebAuthResult {
  const WebAuthResult({
    required this.accessToken,
    this.refreshToken,
    this.expiresOn,
    this.accountId,
  });

  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresOn;
  final String? accountId;
}

abstract class WebAuthClient {
  Future<WebAuthResult> login({required List<String> scopes});

  Future<WebAuthResult> acquireTokenSilent({
    required List<String> scopes,
    String? accountId,
  });

  Future<void> logout({String? accountId});
}

WebAuthClient createWebAuthClient() => createWebAuthClientImpl();
