import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:rxdigi/core/data/models/medicine_in_prescription_model.dart';
import 'package:rxdigi/core/data/models/patient_model.dart';
import 'package:rxdigi/core/data/models/prescription_model.dart';
import 'package:rxdigi/core/data/repositories/prescription_repository.dart';
import 'package:rxdigi/core/data/repositories/doctor_repository.dart';
import 'package:rxdigi/core/data/repositories/patient_repository.dart';

class PrescriptionState {
  final PatientModel? patient;
  final String? chiefComplaints;
  final String? diagnosis;
  final String? vitalSigns;
  final String? pastHistory;
  final List<MedicineInPrescription> medicines;
  final String? advice;
  final String? nextVisit;
  final List<String> labTests;
  final bool isLoading;

  PrescriptionState({
    this.patient,
    this.chiefComplaints,
    this.diagnosis,
    this.vitalSigns,
    this.pastHistory,
    this.medicines = const [],
    this.advice,
    this.nextVisit,
    this.labTests = const [],
    this.isLoading = false,
  });

  PrescriptionState copyWith({
    PatientModel? patient,
    String? chiefComplaints,
    String? diagnosis,
    String? vitalSigns,
    String? pastHistory,
    List<MedicineInPrescription>? medicines,
    String? advice,
    String? nextVisit,
    List<String>? labTests,
    bool? isLoading,
  }) {
    return PrescriptionState(
      patient: patient ?? this.patient,
      chiefComplaints: chiefComplaints ?? this.chiefComplaints,
      diagnosis: diagnosis ?? this.diagnosis,
      vitalSigns: vitalSigns ?? this.vitalSigns,
      pastHistory: pastHistory ?? this.pastHistory,
      medicines: medicines ?? this.medicines,
      advice: advice ?? this.advice,
      nextVisit: nextVisit ?? this.nextVisit,
      labTests: labTests ?? this.labTests,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PrescriptionNotifier extends StateNotifier<PrescriptionState> {
  final PrescriptionRepository _prescriptionRepo = PrescriptionRepository();
  final DoctorRepository _doctorRepo = DoctorRepository();
  final PatientRepository _patientRepo = PatientRepository();

  PrescriptionNotifier() : super(PrescriptionState());

  void setPatient(PatientModel patient) {
    state = state.copyWith(patient: patient);
  }

  void updateChiefComplaints(String complaints) {
    state = state.copyWith(chiefComplaints: complaints);
  }

  void updateDiagnosis(String diagnosis) {
    state = state.copyWith(diagnosis: diagnosis);
  }

  void updateVitals(String vitals) {
    state = state.copyWith(vitalSigns: vitals);
  }

  void updatePastHistory(String history) {
    state = state.copyWith(pastHistory: history);
  }

  void addMedicine(MedicineInPrescription medicine) {
    state = state.copyWith(medicines: [...state.medicines, medicine]);
  }

  void removeMedicine(int index) {
    final list = [...state.medicines];
    list.removeAt(index);
    state = state.copyWith(medicines: list);
  }

  void updateAdvice(String advice) {
    state = state.copyWith(advice: advice);
  }

  void updateNextVisit(String nextVisit) {
    state = state.copyWith(nextVisit: nextVisit);
  }

  void addLabTest(String test) {
    state = state.copyWith(labTests: [...state.labTests, test]);
  }

  Future<int> savePrescription() async {
    if (state.patient == null) return -1;

    state = state.copyWith(isLoading: true);

    try {
      // 1. Ensure patient is saved or updated
      int patientId;
      if (state.patient!.id == null) {
        patientId = await _patientRepo.insert(state.patient!);
      } else {
        await _patientRepo.update(state.patient!);
        patientId = state.patient!.id!;
      }

      // 2. Get current doctor
      final doctor = await _doctorRepo.getLatestDoctor();

      // 3. Create PrescriptionModel
      final prescription = PrescriptionModel(
        patientId: patientId,
        doctorId: doctor?.id,
        date: DateTime.now(),
        chiefComplaints: state.chiefComplaints,
        diagnosis: state.diagnosis,
        vitalSigns: state.vitalSigns,
        pastHistory: state.pastHistory,
        medicines: state.medicines,
        advice: state.advice,
        nextVisit: state.nextVisit,
        labTests: state.labTests,
      );

      // 4. Save to DB
      final id = await _prescriptionRepo.insert(prescription);
      
      state = state.copyWith(isLoading: false);
      return id;
    } catch (e) {
      print('Error saving prescription: $e');
      state = state.copyWith(isLoading: false);
      return -1;
    }
  }

  void reset() {
    state = PrescriptionState();
  }
}

final prescriptionProvider = StateNotifierProvider<PrescriptionNotifier, PrescriptionState>((ref) {
  return PrescriptionNotifier();
});
