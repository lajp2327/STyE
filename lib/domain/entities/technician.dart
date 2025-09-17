import 'package:equatable/equatable.dart';

/// Technician assigned to ticket resolution.
class Technician extends Equatable {
  const Technician({
    required this.id,
    required this.name,
    required this.email,
    this.isActive = true,
  });

  final int id;
  final String name;
  final String email;
  final bool isActive;

  Technician copyWith({String? name, String? email, bool? isActive}) {
    return Technician(
      id: id,
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

  factory Technician.fromJson(Map<String, dynamic> json) => Technician(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        isActive: json['isActive'] as bool? ?? true,
      );

  @override
  List<Object?> get props => <Object?>[id, name, email, isActive];
}
