// ============================================================
// lib/core/usecases/usecase.dart
// ============================================================
import 'package:dartz/dartz.dart';
 
/// Contrato base para todos los casos de uso.
/// [Type] = tipo de retorno exitoso
/// [Params] = parámetros de entrada
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
 
/// Para casos de uso sin parámetros
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}