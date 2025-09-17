import 'package:sistema_tickets_edis/domain/entities/user.dart';

User buildUser({int id = 0, String name = 'Usuario Demo', String? email}) {
  final String normalizedEmail =
      email ??
      '${name.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]+"), '.')}.demo@tickets.test';
  return User(id: id, name: name, email: normalizedEmail);
}
