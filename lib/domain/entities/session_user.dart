import 'package:equatable/equatable.dart';

import 'package:sistema_tickets_edis/domain/entities/user.dart';

/// Roles soportados para los usuarios autenticados en la app.
enum UserRole { admin, user }

extension UserRoleX on UserRole {
  bool get isAdmin => this == UserRole.admin;

  bool get isUser => this == UserRole.user;
}

/// Usuario autenticado junto con sus permisos efectivos.
class SessionUser extends Equatable {
  const SessionUser({required this.user, required this.role});

  final User user;
  final UserRole role;

  @override
  List<Object?> get props => <Object?>[user, role];
}
