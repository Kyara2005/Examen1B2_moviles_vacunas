// ============================================================
// lib/features/auth/domain/repositories/auth_repository.dart
// ============================================================
 
import 'package:dartz/dartz.dart';
 
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });
 
  Future<Either<Failure, void>> logout();
 
  Future<Either<Failure, void>> changePassword({
    required String newPassword,
  });
 
  Future<Either<Failure, void>> resetPassword({
    required String email,
  });
 
  Future<Either<Failure, UserEntity?>> getCurrentUser();
}