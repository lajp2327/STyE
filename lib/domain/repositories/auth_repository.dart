import 'package:sistema_tickets_edis/domain/entities/session_user.dart';

/// Contrato para autenticación y manejo de sesión local.
abstract class AuthRepository {
  Stream<SessionUser?> watchSession();

  Future<SessionUser?> getCurrentUser();

  Future<SessionUser> login({
    required String email,
    required String password,
  });

  Future<SessionUser> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();
}
