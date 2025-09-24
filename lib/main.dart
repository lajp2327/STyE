import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'config/auth_config.dart';
import 'pages/example_page.dart';
import 'services/auth_service.dart';
import 'services/dataverse_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AuthService authService = AuthService();
  final DataverseApi dataverseApi = DataverseApi(authService: authService);

  runApp(
    TicketDemoApp(
      authService: authService,
      dataverseApi: dataverseApi,
    ),
  );
}

class TicketDemoApp extends StatelessWidget {
  const TicketDemoApp({
    super.key,
    required this.authService,
    required this.dataverseApi,
  });

  final AuthService authService;
  final DataverseApi dataverseApi;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Azure AD + Dataverse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: AuthGuard(
        authService: authService,
        dataverseApi: dataverseApi,
      ),
    );
  }
}

class AuthGuard extends StatefulWidget {
  const AuthGuard({
    super.key,
    required this.authService,
    required this.dataverseApi,
  });

  final AuthService authService;
  final DataverseApi dataverseApi;

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _checkingSession = true;
  bool _isAuthenticated = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _bootstrapSession();
  }

  Future<void> _bootstrapSession() async {
    setState(() {
      _checkingSession = true;
    });
    try {
      final bool hasSession = await widget.authService.hasValidSession();
      if (!mounted) {
        return;
      }
      setState(() {
        _isAuthenticated = hasSession;
      });
      if (!hasSession) {
        _showInfo(
          'Configura AuthConfig con tu TENANT_ID, CLIENT_ID y Redirect URIs antes de iniciar sesión.',
        );
      }
    } catch (error) {
      _showError('No fue posible validar la sesión: $error');
    } finally {
      if (mounted) {
        setState(() {
          _checkingSession = false;
        });
      }
    }
  }

  Future<void> _login() async {
    setState(() {
      _isProcessing = true;
    });
    try {
      await widget.authService.login();
      if (!mounted) {
        return;
      }
      setState(() {
        _isAuthenticated = true;
      });
      _showInfo('Autenticación completada. Tokens almacenados en secure storage.');
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (error) {
      _showError('Error inesperado al iniciar sesión: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _handleLogout() {
    setState(() {
      _isAuthenticated = false;
    });
  }

  void _showInfo(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSession) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isAuthenticated) {
      return ExamplePage(
        authService: widget.authService,
        dataverseApi: widget.dataverseApi,
        onLogout: _handleLogout,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Azure AD (PKCE)'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Icon(Icons.lock_outline, size: 72),
              const SizedBox(height: 16),
              Text(
                'Inicia sesión con Authorization Code + PKCE.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'TENANT: ${AuthConfig.tenantId}\nCLIENT_ID: ${AuthConfig.clientId}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (kIsWeb)
                const Card(
                  color: Colors.amber,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'TODO Web: integra MSAL (msal-browser) o implementa un flujo PKCE manual. '
                      'flutter_appauth no soporta Web. También puedes compilar con '
                      '--dart-define=WEB_PREVIEW=true para navegar en modo demo sin conexión.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _isProcessing ? null : _login,
                icon: _isProcessing
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: Text(_isProcessing ? 'Conectando...' : 'Login con Azure AD'),
              ),
              const SizedBox(height: 12),
              Text(
                'Scopes configurados:\n${AuthConfig.scopes.join('\n')}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "Recuerda conceder permisos “Admin consent” al scope https://<ORG>.crm.dynamics.com/.default.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
