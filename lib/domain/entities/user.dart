import 'package:equatable/equatable.dart';

/// Basic representation of an end user that interacts with the ticketing system.
class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    this.email,
    this.isActive = true,
  });

  final int id;
  final String name;
  final String? email;
  final bool isActive;

  User copyWith({int? id, String? name, String? email, bool? isActive}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'email': email,
    'isActive': isActive,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as int,
    name: json['name'] as String,
    email: json['email'] as String?,
    isActive: json['isActive'] as bool? ?? true,
  );

  @override
  List<Object?> get props => <Object?>[id, name, email, isActive];
}
