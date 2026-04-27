import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medicine_model.dart';
import '../repositories/medicine_repository.dart';

final medicineRepositoryProvider = Provider<MedicineRepository>((ref) {
  return MedicineRepository();
});

final medicineListProvider = FutureProvider<List<MedicineModel>>((ref) {
  final repository = ref.watch(medicineRepositoryProvider);
  return repository.getAll();
});

final medicineSearchProvider = 
    FutureProvider.family<List<MedicineModel>, String>((ref, query) {
  final repository = ref.watch(medicineRepositoryProvider);
  return repository.searchMedicines(query);
});

final medicineStrengthProvider = 
    FutureProvider.family<List<MedicineModel>, String>((ref, strength) {
  final repository = ref.watch(medicineRepositoryProvider);
  return repository.getMedicinesByStrength(strength);
});

final loadMedicinesFromCsvProvider = FutureProvider<void>((ref) {
  final repository = ref.watch(medicineRepositoryProvider);
  return repository.loadMedicinesFromCsv();
});

final addMedicineProvider = FutureProvider.family<int, MedicineModel>((ref, medicine) {
  final repository = ref.watch(medicineRepositoryProvider);
  return repository.insert(medicine);
});

final updateMedicineProvider = 
    FutureProvider.family<void, MedicineModel>((ref, medicine) {
  final repository = ref.watch(medicineRepositoryProvider);
  return repository.update(medicine);
});

final deleteMedicineProvider = FutureProvider.family<void, int>((ref, id) {
  final repository = ref.watch(medicineRepositoryProvider);
  return repository.delete(id);
});
