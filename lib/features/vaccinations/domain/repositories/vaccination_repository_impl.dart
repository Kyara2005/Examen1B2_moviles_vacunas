// ============================================================
// lib/features/vaccinations/data/repositories/vaccination_repository_impl.dart
// ============================================================
 
/// Implementación del repositorio - corazón de la estrategia offline-first.
///
/// Explicación para sustentación:
/// El repositorio actúa como árbitro entre el datasource local (Isar)
/// y el remoto (Supabase). Al crear, siempre guarda localmente primero,
/// luego intenta sincronizar. Esto garantiza que el usuario nunca pierde datos.
class VaccinationRepositoryImpl implements VaccinationRepository {
  final VaccinationLocalDataSource _local;
  final VaccinationRemoteDataSource _remote;
  final ConnectivityService _connectivity;
 
  VaccinationRepositoryImpl(this._local, this._remote, this._connectivity);
 
  @override
  Future<Either<Failure, List<VaccinationEntity>>> getVaccinationsBySector(String sectorId) async {
    try {
      final isOnline = await _connectivity.isConnected();
 
      if (isOnline) {
        // Online: buscar en remoto y actualizar caché local
        final remoteModels = await _remote.getVaccinationsBySector(sectorId);
        for (final model in remoteModels) {
          await _local.saveVaccination(model);
        }
        return Right(remoteModels.map((m) => m.toEntity()).toList());
      } else {
        // Offline: retornar datos del caché local
        final localModels = await _local.getVaccinationsBySector(sectorId);
        return Right(localModels.map((m) => m.toEntity()).toList());
      }
    } catch (e) {
      // Si falla el remoto, intentar con local
      try {
        final localModels = await _local.getVaccinationsBySector(sectorId);
        return Right(localModels.map((m) => m.toEntity()).toList());
      } catch (localError) {
        return Left(CacheFailure(message: localError.toString()));
      }
    }
  }
 
  @override
  Future<Either<Failure, VaccinationEntity>> createVaccination(VaccinationEntity vaccination) async {
    try {
      // 1. Generar ID local único
      final localId = const Uuid().v4();
      final entityWithLocalId = vaccination.copyWith(localId: localId, isSynced: false);
 
      // 2. Guardar SIEMPRE en local primero (offline-first)
      final localModel = VaccinationModel.fromEntity(entityWithLocalId);
      await _local.saveVaccination(localModel);
 
      // 3. Intentar sincronizar si hay conexión
      final isOnline = await _connectivity.isConnected();
      if (isOnline) {
        final data = localModel.toSupabaseJson();
        final remoteModel = await _remote.createVaccination(data);
        await _local.markAsSynced(localModel.isarId, remoteModel.remoteId!);
        return Right(remoteModel.toEntity());
      }
 
      return Right(entityWithLocalId);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
 
  @override
  Future<Either<Failure, int>> syncPendingVaccinations() async {
    try {
      final isOnline = await _connectivity.isConnected();
      if (!isOnline) return const Right(0);
 
      final pending = await _local.getUnsyncedVaccinations();
      int syncedCount = 0;
 
      for (final model in pending) {
        try {
          final data = model.toSupabaseJson();
          if (model.remoteId != null) {
            // Actualización de registro ya sincronizado previamente
            await _remote.updateVaccination(model.remoteId!, data);
          } else {
            // Nuevo registro nunca sincronizado
            final remoteModel = await _remote.createVaccination(data);
            await _local.markAsSynced(model.isarId, remoteModel.remoteId!);
          }
          syncedCount++;
        } catch (e) {
          // Si falla un registro, continúa con los demás
          debugPrint('Error sincronizando ${model.localId}: $e');
        }
      }
 
      return Right(syncedCount);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
 
  @override
  Future<Either<Failure, int>> getUnsyncedCount() async {
    try {
      final count = await _local.getUnsyncedCount();
      return Right(count);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
 
  @override
  Future<Either<Failure, VaccinationEntity>> updateVaccination(VaccinationEntity vaccination) async {
    try {
      final model = VaccinationModel.fromEntity(vaccination.copyWith(isSynced: false));
      await _local.saveVaccination(model);
 
      final isOnline = await _connectivity.isConnected();
      if (isOnline && vaccination.id != null) {
        final data = model.toSupabaseJson();
        final remoteModel = await _remote.updateVaccination(vaccination.id!, data);
        await _local.markAsSynced(model.isarId, remoteModel.remoteId!);
        return Right(remoteModel.toEntity());
      }
 
      return Right(vaccination.copyWith(isSynced: false));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}