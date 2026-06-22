import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/body_measurement.dart';
import '../repositories/body_measurement_repository.dart';

// ─── Repository Provider ─────────────────────────────────────────────────────

final bodyMeasurementRepositoryProvider =
    Provider<BodyMeasurementRepository>((ref) {
  return BodyMeasurementRepository();
});

// ─── Notifier ────────────────────────────────────────────────────────────────

class BodyMeasurementNotifier
    extends AsyncNotifier<List<BodyMeasurement>> {
  @override
  Future<List<BodyMeasurement>> build() async {
    final repo = ref.read(bodyMeasurementRepositoryProvider);
    return repo.getMeasurements();
  }

  /// Tambah / update catatan berat badan
  Future<void> upsert({
    required DateTime date,
    required double weightKg,
    String? note,
  }) async {
    final repo = ref.read(bodyMeasurementRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.upsertMeasurement(date: date, weightKg: weightKg, note: note);
      return repo.getMeasurements();
    });
  }

  /// Hapus catatan berat badan
  Future<void> delete(String id) async {
    final repo = ref.read(bodyMeasurementRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.deleteMeasurement(id);
      return repo.getMeasurements();
    });
  }
}

// ─── Provider ────────────────────────────────────────────────────────────────

final bodyMeasurementProvider =
    AsyncNotifierProvider<BodyMeasurementNotifier, List<BodyMeasurement>>(
  BodyMeasurementNotifier.new,
);
