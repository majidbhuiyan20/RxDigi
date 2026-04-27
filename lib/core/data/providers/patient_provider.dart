import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/patient_model.dart';
import '../repositories/patient_repository.dart';

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  return PatientRepository();
});

final patientListProvider = FutureProvider<List<PatientModel>>((ref) {
  final repository = ref.watch(patientRepositoryProvider);
  return repository.getAll();
});

final getPatientProvider = FutureProvider.family<PatientModel?, int>((ref, patientId) {
  final repository = ref.watch(patientRepositoryProvider);
  return repository.getById(patientId);
});

final patientSearchProvider = 
    FutureProvider.family<List<PatientModel>, String>((ref, query) {
  final repository = ref.watch(patientRepositoryProvider);
  return repository.searchPatients(query);
});

final addPatientProvider = FutureProvider.family<int, PatientModel>((ref, patient) {
  final repository = ref.watch(patientRepositoryProvider);
  return repository.insert(patient);
});

final updatePatientProvider = 
    FutureProvider.family<void, PatientModel>((ref, patient) {
  final repository = ref.watch(patientRepositoryProvider);
  return repository.update(patient);
});

final deletePatientProvider = FutureProvider.family<void, int>((ref, id) {
  final repository = ref.watch(patientRepositoryProvider);
  return repository.delete(id);
});
