// --- lib/features/auth/domain/entities/user_entity.dart ---
 
import 'package:equatable/equatable.dart';
 
class UserEntity extends Equatable {
  final String id;
  final String authUserId;
  final String cedula;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String role;
  final bool mustChangePassword;
  final bool isActive;
 
  const UserEntity({
    required this.id,
    required this.authUserId,
    required this.cedula,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.role,
    required this.mustChangePassword,
    required this.isActive,
  });
 
  String get fullName => '$firstName $lastName';
 
  @override
  List<Object?> get props => [id, authUserId, role];
}