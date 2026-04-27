import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/doctor_model.dart';
import '../repositories/doctor_repository.dart';

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  return DoctorRepository();
});

final doctorListProvider = FutureProvider<List<DoctorModel>>((ref) {
  final repository = ref.watch(doctorRepositoryProvider);
  return repository.getAll();
});

final latestDoctorProvider = FutureProvider<DoctorModel?>((ref) {
  final repository = ref.watch(doctorRepositoryProvider);
  return repository.getLatestDoctor();
});

final addDoctorProvider = FutureProvider.family<int, DoctorModel>((ref, doctor) {
  final repository = ref.watch(doctorRepositoryProvider);
  return repository.insert(doctor);
});

final updateDoctorProvider = 
    FutureProvider.family<void, DoctorModel>((ref, doctor) {
  final repository = ref.watch(doctorRepositoryProvider);
  return repository.update(doctor);
});

final deleteDoctorProvider = FutureProvider.family<void, int>((ref, id) {
  final repository = ref.watch(doctorRepositoryProvider);
  return repository.delete(id);
});
