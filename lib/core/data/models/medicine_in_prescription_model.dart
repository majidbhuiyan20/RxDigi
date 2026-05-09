import 'dart:convert';
import 'medicine_model.dart';

class MedicineInPrescription {
  final int? id;
  final int? medicineId;
  final String? medicineName;
  final String? strength;
  final String? dose; // e.g., "1+0+1"
  final String? duration; // e.g., "5 days"
  final String? instruction; // e.g., "After meal"
  final String? genericName;
  final String? dosageForm;
  final String? manufacturer;

  MedicineInPrescription({
    this.id,
    this.medicineId,
    this.medicineName,
    this.strength,
    required this.dose,
    required this.duration,
    required this.instruction,
    this.genericName,
    this.dosageForm,
    this.manufacturer,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toMap() {
    return {
      'medicineId': medicineId,
      'medicineName': medicineName,
      'strength': strength,
      'dose': dose,
      'duration': duration,
      'instruction': instruction,
      'genericName': genericName,
      'dosageForm': dosageForm,
      'manufacturer': manufacturer,
    };
  }

  // Convert from JSON
  factory MedicineInPrescription.fromMap(Map<String, dynamic> map) {
    return MedicineInPrescription(
      id: map['id'],
      medicineId: map['medicineId'],
      medicineName: map['medicineName'],
      strength: map['strength'],
      dose: map['dose'],
      duration: map['duration'],
      instruction: map['instruction'],
      genericName: map['genericName'],
      dosageForm: map['dosageForm'],
      manufacturer: map['manufacturer'],
    );
  }

  String toJson() => jsonEncode(toMap());

  factory MedicineInPrescription.fromJson(String json) {
    return MedicineInPrescription.fromMap(jsonDecode(json));
  }

  factory MedicineInPrescription.fromMedicineModel(
    MedicineModel medicine, {
    required String dose,
    required String duration,
    required String instruction,
  }) {
    return MedicineInPrescription(
      medicineId: medicine.id,
      medicineName: medicine.name,
      strength: medicine.strength,
      dose: dose,
      duration: duration,
      instruction: instruction,
      genericName: medicine.genericName,
      dosageForm: medicine.dosageForm,
      manufacturer: medicine.manufacturer,
    );
  }

  MedicineInPrescription copyWith({
    int? id,
    int? medicineId,
    String? medicineName,
    String? strength,
    String? dose,
    String? duration,
    String? instruction,
    String? genericName,
    String? dosageForm,
    String? manufacturer,
  }) {
    return MedicineInPrescription(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      strength: strength ?? this.strength,
      dose: dose ?? this.dose,
      duration: duration ?? this.duration,
      instruction: instruction ?? this.instruction,
      genericName: genericName ?? this.genericName,
      dosageForm: dosageForm ?? this.dosageForm,
      manufacturer: manufacturer ?? this.manufacturer,
    );
  }

  @override
  String toString() {
    return '$medicineName - $strength ($dose)';
  }
}
