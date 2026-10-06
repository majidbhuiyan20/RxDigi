import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vital_log_model.dart';
import '../repository/vitals_repository.dart';

final vitalsRepositoryProvider = Provider<VitalsRepository>((ref) {
  return VitalsRepository();
});

class VitalsNotifier extends StateNotifier<AsyncValue<List<VitalLogModel>>> {
  final VitalsRepository _repository;

  VitalsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadVitals();
  }

  Future<void> loadVitals() async {
    try {
      final vitals = await _repository.getAllVitals();
      state = AsyncValue.data(vitals);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addVital(VitalLogModel vital) async {
    await _repository.insertVital(vital);
    await loadVitals();
  }

  Future<void> deleteVital(int id) async {
    await _repository.deleteVital(id);
    await loadVitals();
  }
}

final vitalsListProvider = StateNotifierProvider<VitalsNotifier, AsyncValue<List<VitalLogModel>>>((ref) {
  final repo = ref.watch(vitalsRepositoryProvider);
  return VitalsNotifier(repo);
});

final latestBpProvider = Provider<VitalLogModel?>((ref) {
  final listAsync = ref.watch(vitalsListProvider);
  return listAsync.maybeWhen(
    data: (list) {
      final bps = list.where((v) => v.type == 'BP').toList();
      return bps.isNotEmpty ? bps.first : null;
    },
    orElse: () => null,
  );
});

final latestSugarProvider = Provider<VitalLogModel?>((ref) {
  final listAsync = ref.watch(vitalsListProvider);
  return listAsync.maybeWhen(
    data: (list) {
      final sugars = list.where((v) => v.type == 'SUGAR').toList();
      return sugars.isNotEmpty ? sugars.first : null;
    },
    orElse: () => null,
  );
});

final latestWeightProvider = Provider<VitalLogModel?>((ref) {
  final listAsync = ref.watch(vitalsListProvider);
  return listAsync.maybeWhen(
    data: (list) {
      final weights = list.where((v) => v.type == 'WEIGHT').toList();
      return weights.isNotEmpty ? weights.first : null;
    },
    orElse: () => null,
  );
});
