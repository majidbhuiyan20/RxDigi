import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vital_log_model.dart';
import '../repository/vitals_repository.dart';

final vitalsRepositoryProvider = Provider<VitalsRepository>((ref) {
  return VitalsRepository();
});

final vitalsListProvider = FutureProvider<List<VitalLogModel>>((ref) async {
  final repo = ref.watch(vitalsRepositoryProvider);
  return repo.getAllVitals();
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
