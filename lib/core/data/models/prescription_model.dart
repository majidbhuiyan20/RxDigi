import 'dart:convert';
import 'medicine_in_prescription_model.dart';

class PrescriptionModel {
  final int? id;
  final int patientId;
  final int? doctorId;
  final String? date;
  final String? diagnosis;
  final String? notes;
  final List<MedicineInPrescription>? medicinesDetails; // New: detailed medicines
  final String? medicines; // Legacy: keep for compatibility
  final DateTime? createdAt;

  PrescriptionModel({
    this.id,
    required this.patientId,
    this.doctorId,
    this.date,
    this.diagnosis,
    this.notes,
    this.medicinesDetails,
    this.medicines,
    this.createdAt,
  });

  // Get medicines list as JSON string
  String getMedicinesJson() {
    if (medicinesDetails == null || medicinesDetails!.isEmpty) {
      return '[]';
    }
    return jsonEncode(
      medicinesDetails!.map((m) => m.toMap()).toList(),
    );
  }

  // Parse medicines from JSON string
  static List<MedicineInPrescription> parseMedicinesFromJson(String? json) {
    if (json == null || json.isEmpty || json == '[]') {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded
          .map((m) => MedicineInPrescription.fromMap(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error parsing medicines: $e');
      return [];
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'date': date,
      'diagnosis': diagnosis,
      'notes': notes,
      'medicines': getMedicinesJson(), // Store as JSON
    };
  }

  factory PrescriptionModel.fromMap(Map<String, dynamic> map) {
    final medicinesDetails = 
        PrescriptionModel.parseMedicinesFromJson(map['medicines']);

    return PrescriptionModel(
      id: map['id'],
      patientId: map['patientId'] ?? 0,
      doctorId: map['doctorId'],
      date: map['date'],
      diagnosis: map['diagnosis'],
      notes: map['notes'],
      medicinesDetails: medicinesDetails,
      medicines: map['medicines'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }

  PrescriptionModel copyWith({
    int? id,
    int? patientId,
    int? doctorId,
    String? date,
    String? diagnosis,
    String? notes,
    List<MedicineInPrescription>? medicinesDetails,
    String? medicines,
    DateTime? createdAt,
  }) {
    return PrescriptionModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      date: date ?? this.date,
      diagnosis: diagnosis ?? this.diagnosis,
      notes: notes ?? this.notes,
      medicinesDetails: medicinesDetails ?? this.medicinesDetails,
      medicines: medicines ?? this.medicines,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
