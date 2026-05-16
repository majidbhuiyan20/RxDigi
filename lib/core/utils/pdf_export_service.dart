import 'package:intl/intl.dart';
import 'package:prescripto/core/data/models/prescription_model.dart';
import 'package:prescripto/core/data/models/patient_model.dart';
import 'package:prescripto/core/data/models/doctor_model.dart';

class PdfExportService {
  // Generate PDF content as text (can be extended to real PDF with pdf package)
  static String generatePrescriptionText(
    PrescriptionModel prescription,
    PatientModel patient,
    DoctorModel doctor,
  ) {
    final medicines = prescription.medicines;
    final dateStr = DateFormat('dd/MM/yyyy').format(prescription.date);
    
    final buffer = StringBuffer();
    
    buffer.writeln('╔════════════════════════════════════════════════════════════════╗');
    buffer.writeln('║                          PRESCRIPTION                          ║');
    buffer.writeln('╚════════════════════════════════════════════════════════════════╝');
    buffer.writeln('');
    
    // Doctor Information
    buffer.writeln('┌─ DOCTOR INFORMATION ─────────────────────────────────────────┐');
    buffer.writeln('│ Name: ${doctor.fullName.padRight(54)} │');
    buffer.writeln('│ Title: ${(doctor.title ?? "").padRight(53)} │');
    buffer.writeln('│ Registration No: ${(doctor.bmdcRegNo ?? "").padRight(42)} │');
    buffer.writeln('│ Specialization: ${(doctor.specialization ?? "").padRight(43)} │');
    buffer.writeln('│ Chamber: ${doctor.clinicName.padRight(50)} │');
    buffer.writeln('│ Phone: ${(doctor.phoneNumber ?? "").padRight(52)} │');
    buffer.writeln('│ Hours: ${((doctor.startTime ?? "") + " - " + (doctor.endTime ?? "")).padRight(52)} │');
    buffer.writeln('└──────────────────────────────────────────────────────────────┘');
    buffer.writeln('');
    
    // Patient Information
    buffer.writeln('┌─ PATIENT INFORMATION ────────────────────────────────────────┐');
    buffer.writeln('│ Name: ${patient.name.padRight(54)} │');
    buffer.writeln('│ Age: ${(patient.age?.toString() ?? "").padRight(55)} │');
    buffer.writeln('│ Gender: ${(patient.gender ?? "").padRight(52)} │');
    buffer.writeln('│ Phone: ${(patient.phone ?? "").padRight(53)} │');
    buffer.writeln('│ Address: ${(patient.address ?? "").padRight(51)} │');
    buffer.writeln('└──────────────────────────────────────────────────────────────┘');
    buffer.writeln('');
    
    // Prescription Date
    buffer.writeln('Date: $dateStr');
    buffer.writeln('');
    
    // Diagnosis
    buffer.writeln('┌─ DIAGNOSIS ──────────────────────────────────────────────────┐');
    buffer.writeln('│ ${(prescription.diagnosis ?? "").padRight(60)} │');
    buffer.writeln('└──────────────────────────────────────────────────────────────┘');
    buffer.writeln('');
    
    // Medicines
    buffer.writeln('┌─ MEDICATIONS ────────────────────────────────────────────────┐');
    buffer.writeln('│');
    
    for (var i = 0; i < medicines.length; i++) {
      final medicine = medicines[i];
      buffer.writeln('│ ${i + 1}. ${(medicine.medicineName ?? "").padRight(57)} │');
      buffer.writeln('│    Strength: ${(medicine.strength ?? "").padRight(48)} │');
      buffer.writeln('│    Generic: ${(medicine.genericName ?? "").padRight(49)} │');
      buffer.writeln('│    Manufacturer: ${(medicine.manufacturer ?? "").padRight(44)} │');
      buffer.writeln('│    Dose: ${(medicine.dose ?? "").padRight(52)} │');
      buffer.writeln('│    Duration: ${(medicine.duration ?? "").padRight(48)} │');
      buffer.writeln('│    Instructions: ${(medicine.instruction ?? "").padRight(44)} │');
      buffer.writeln('│');
    }
    
    buffer.writeln('└──────────────────────────────────────────────────────────────┘');
    buffer.writeln('');
    
    // Advice
    if (prescription.advice != null && prescription.advice!.isNotEmpty) {
      buffer.writeln('┌─ ADVICE ─────────────────────────────────────────────────────┐');
      buffer.writeln('│ ${prescription.advice!.padRight(60)} │');
      buffer.writeln('└──────────────────────────────────────────────────────────────┘');
      buffer.writeln('');
    }
    
    buffer.writeln('╔════════════════════════════════════════════════════════════════╗');
    buffer.writeln('│  Doctor\'s Signature: _____________________                     │');
    buffer.writeln('╚════════════════════════════════════════════════════════════════╝');
    
    return buffer.toString();
  }

  // Format for printing
  static String formatForPrint(
    PrescriptionModel prescription,
    PatientModel patient,
    DoctorModel doctor,
  ) {
    return generatePrescriptionText(prescription, patient, doctor);
  }

  // Export as CSV (for data backup)
  static String exportAsCSV(
    PrescriptionModel prescription,
    PatientModel patient,
    DoctorModel doctor,
  ) {
    final medicines = prescription.medicines;
    final dateStr = DateFormat('yyyy-MM-dd').format(prescription.date);
    
    final buffer = StringBuffer();
    buffer.writeln('Doctor Name,Specialization,Patient Name,Patient Age,Prescription Date,Diagnosis,Medicine,Strength,Dose,Duration,Instructions');
    
    if (medicines.isEmpty) {
      buffer.writeln('${doctor.fullName},${doctor.specialization ?? ""},${patient.name},${patient.age ?? ""},$dateStr,${prescription.diagnosis ?? ""},N/A,N/A,N/A,N/A,N/A');
    } else {
      for (final medicine in medicines) {
        buffer.writeln('${doctor.fullName},${doctor.specialization ?? ""},${patient.name},${patient.age ?? ""},$dateStr,${prescription.diagnosis ?? ""},${medicine.medicineName ?? ""},${medicine.strength ?? ""},${medicine.dose ?? ""},${medicine.duration ?? ""},${medicine.instruction ?? ""}');
      }
    }
    
    return buffer.toString();
  }

  // Generate summary statistics
  static Map<String, String> generateSummary(
    PrescriptionModel prescription,
    PatientModel patient,
    DoctorModel doctor,
  ) {
    return {
      'doctorName': doctor.fullName,
      'patientName': patient.name,
      'date': DateFormat('dd MMM yyyy').format(prescription.date),
      'totalMedicines': prescription.medicines.length.toString(),
      'diagnosis': prescription.diagnosis ?? 'N/A',
      'advice': prescription.advice ?? 'N/A',
    };
  }
}
