import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prescription_model.dart';
import '../repositories/prescription_repository.dart';

final prescriptionRepositoryProvider = Provider<PrescriptionRepository>((ref) {
  return PrescriptionRepository();
});

final prescriptionListProvider = FutureProvider<List<PrescriptionModel>>((ref) {
  final repository = ref.watch(prescriptionRepositoryProvider);
  return repository.getAll();
});

final prescriptionsByPatientProvider = 
    FutureProvider.family<List<PrescriptionModel>, int>((ref, patientId) {
  final repository = ref.watch(prescriptionRepositoryProvider);
  return repository.getPrescriptionsByPatient(patientId);
});

final prescriptionsByDoctorProvider = 
    FutureProvider.family<List<PrescriptionModel>, int>((ref, doctorId) {
  final repository = ref.watch(prescriptionRepositoryProvider);
  return repository.getPrescriptionsByDoctor(doctorId);
});

final addPrescriptionProvider = FutureProvider.family<int, PrescriptionModel>((ref, prescription) {
  final repository = ref.watch(prescriptionRepositoryProvider);
  return repository.insert(prescription);
});

final updatePrescriptionProvider = 
    FutureProvider.family<void, PrescriptionModel>((ref, prescription) {
  final repository = ref.watch(prescriptionRepositoryProvider);
  return repository.update(prescription);
});

final deletePrescriptionProvider = FutureProvider.family<void, int>((ref, id) {
  final repository = ref.watch(prescriptionRepositoryProvider);
  return repository.delete(id);
});
