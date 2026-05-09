import 'dart:convert';
import 'medicine_in_prescription_model.dart';

class PrescriptionModel {
  final int? id;
  final int patientId;
  final int? doctorId;
  final DateTime date;
  final String? chiefComplaints;
  final String? diagnosis;
  final String? vitalSigns;
  final String? pastHistory;
  final List<MedicineInPrescription> medicines;
  final String? advice;
  final String? nextVisit;
  final List<String> labTests;
  final DateTime? createdAt;

  PrescriptionModel({
    this.id,
    required this.patientId,
    this.doctorId,
    required this.date,
    this.chiefComplaints,
    this.diagnosis,
    this.vitalSigns,
    this.pastHistory,
    this.medicines = const [],
    this.advice,
    this.nextVisit,
    this.labTests = const [],
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'date': date.toIso8601String(),
      'chiefComplaints': chiefComplaints,
      'diagnosis': diagnosis,
      'vitalSigns': vitalSigns,
      'pastHistory': pastHistory,
      'medicines': jsonEncode(medicines.map((e) => e.toMap()).toList()),
      'advice': advice,
      'nextVisit': nextVisit,
      'labTests': jsonEncode(labTests),
    };
  }

  factory PrescriptionModel.fromMap(Map<String, dynamic> map) {
    return PrescriptionModel(
      id: map['id'],
      patientId: map['patientId'],
      doctorId: map['doctorId'],
      date: DateTime.parse(map['date']),
      chiefComplaints: map['chiefComplaints'],
      diagnosis: map['diagnosis'],
      vitalSigns: map['vitalSigns'],
      pastHistory: map['pastHistory'],
      medicines: map['medicines'] != null
          ? (jsonDecode(map['medicines']) as List)
              .map((e) => MedicineInPrescription.fromMap(e))
              .toList()
          : [],
      advice: map['advice'],
      nextVisit: map['nextVisit'],
      labTests: map['labTests'] != null
          ? List<String>.from(jsonDecode(map['labTests']))
          : [],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }
}
