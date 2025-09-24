import 'package:msal_js/msal_js.dart' as msal;

import '../../config/auth_config.dart';
import 'web_auth_client.dart';

class MsalWebAuthClient implements WebAuthClient {
  MsalWebAuthClient([msal.PublicClientApplication? application])
      : _application = application ?? _buildApplication();

  final msal.PublicClientApplication _application;

  static msal.PublicClientApplication _buildApplication() {
    final msal.Configuration configuration = msal.Configuration(
      auth: msal.BrowserAuthOptions(
        clientId: AuthConfig.clientId,
        authority: AuthConfig.authority,
        redirectUri: AuthConfig.redirectUriWeb,
      ),
      cache: msal.CacheOptions(
        cacheLocation: msal.BrowserCacheLocation.localStorage,
        storeAuthStateInCookie: false,
      ),
    );
    return msal.PublicClientApplication(configuration);
  }

  @override
  Future<WebAuthResult> login({required List<String> scopes}) async {
    final msal.AuthenticationResult result = await _application.loginPopup(
      msal.PopupRequest(scopes: scopes),
    );
    return _mapResult(result);
  }

  @override
  Future<WebAuthResult> acquireTokenSilent({
    required List<String> scopes,
    String? accountId,
  }) async {
    final msal.AccountInfo? account = _resolveAccount(accountId);
    final msal.SilentRequest request = msal.SilentRequest(
      scopes: scopes,
      account: account,
    );
    final msal.AuthenticationResult result =
        await _application.acquireTokenSilent(request);
    return _mapResult(result);
  }

  @override
  Future<void> logout({String? accountId}) async {
    final msal.AccountInfo? account = _resolveAccount(accountId);
    await _application.logoutPopup(msal.EndSessionRequest(account: account));
  }

  WebAuthResult _mapResult(msal.AuthenticationResult result) {
    final String? accessToken = result.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw StateError('MSAL no devolvió un accessToken válido.');
    }
    final DateTime? expiresOn = result.expiresOn;
    final String? accountId = result.account?.homeAccountId;
    return WebAuthResult(
      accessToken: accessToken,
      refreshToken: null,
      expiresOn: expiresOn?.toUtc(),
      accountId: accountId,
    );
  }

  msal.AccountInfo? _resolveAccount(String? accountId) {
    final List<msal.AccountInfo> accounts = _application.getAllAccounts();
    if (accounts.isEmpty) {
      return null;
    }
    if (accountId == null || accountId.isEmpty) {
      return accounts.first;
    }
    for (final msal.AccountInfo account in accounts) {
      if (account.homeAccountId == accountId) {
        return account;
      }
    }
    return accounts.first;
  }
}

WebAuthClient createWebAuthClientImpl() => MsalWebAuthClient();
