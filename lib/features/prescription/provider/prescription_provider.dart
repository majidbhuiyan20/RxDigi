import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:rxdigi/core/data/models/medicine_in_prescription_model.dart';
import 'package:rxdigi/core/data/models/patient_model.dart';
import 'package:rxdigi/core/data/models/prescription_model.dart';

class PrescriptionState {
  final PatientModel? patient;
  final String? chiefComplaints;
  final String? diagnosis;
  final String? vitalSigns;
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
      medicines: medicines ?? this.medicines,
      advice: advice ?? this.advice,
      nextVisit: nextVisit ?? this.nextVisit,
      labTests: labTests ?? this.labTests,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PrescriptionNotifier extends StateNotifier<PrescriptionState> {
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

  void reset() {
    state = PrescriptionState();
  }
}

final prescriptionProvider = StateNotifierProvider<PrescriptionNotifier, PrescriptionState>((ref) {
  return PrescriptionNotifier();
});
