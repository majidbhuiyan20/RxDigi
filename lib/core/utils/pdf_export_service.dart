import 'package:rxdigi/core/data/models/prescription_model.dart';
import 'package:rxdigi/core/data/models/patient_model.dart';
import 'package:rxdigi/core/data/models/doctor_model.dart';

class PdfExportService {
  // Generate PDF content as text (can be extended to real PDF with pdf package)
  static String generatePrescriptionText(
    PrescriptionModel prescription,
    PatientModel patient,
    DoctorModel doctor,
  ) {
    final medicines = prescription.medicinesDetails ?? [];
    
    final buffer = StringBuffer();
    
    buffer.writeln('╔════════════════════════════════════════════════════════════════╗');
    buffer.writeln('║                          PRESCRIPTION                          ║');
    buffer.writeln('╚════════════════════════════════════════════════════════════════╝');
    buffer.writeln('');
    
    // Doctor Information
    buffer.writeln('┌─ DOCTOR INFORMATION ─────────────────────────────────────────┐');
    buffer.writeln('│ Name: ${doctor.fullName}');
    buffer.writeln('│ Title: ${doctor.title}');
    buffer.writeln('│ Registration No: ${doctor.bmdcRegNo}');
    buffer.writeln('│ Specialization: ${doctor.specialization}');
    buffer.writeln('│ Chamber: ${doctor.clinicName}');
    buffer.writeln('│ Phone: ${doctor.phoneNumber}');
    buffer.writeln('│ Hours: ${doctor.startTime} - ${doctor.endTime}');
    buffer.writeln('└──────────────────────────────────────────────────────────────┘');
    buffer.writeln('');
    
    // Patient Information
    buffer.writeln('┌─ PATIENT INFORMATION ────────────────────────────────────────┐');
    buffer.writeln('│ Name: ${patient.name}');
    buffer.writeln('│ Age: ${patient.age}');
    buffer.writeln('│ Gender: ${patient.gender}');
    buffer.writeln('│ Phone: ${patient.phone}');
    buffer.writeln('│ Address: ${patient.address}');
    buffer.writeln('└──────────────────────────────────────────────────────────────┘');
    buffer.writeln('');
    
    // Prescription Date
    buffer.writeln('Date: ${prescription.date}');
    buffer.writeln('');
    
    // Diagnosis
    buffer.writeln('┌─ DIAGNOSIS ──────────────────────────────────────────────────┐');
    buffer.writeln('│ ${prescription.diagnosis}');
    buffer.writeln('└──────────────────────────────────────────────────────────────┘');
    buffer.writeln('');
    
    // Medicines
    buffer.writeln('┌─ MEDICATIONS ────────────────────────────────────────────────┐');
    buffer.writeln('│');
    
    for (var i = 0; i < medicines.length; i++) {
      final medicine = medicines[i];
      buffer.writeln('│ ${i + 1}. ${medicine.medicineName}');
      buffer.writeln('│    Strength: ${medicine.strength}');
      buffer.writeln('│    Generic: ${medicine.genericName}');
      buffer.writeln('│    Manufacturer: ${medicine.manufacturer}');
      buffer.writeln('│    Dose: ${medicine.dose}');
      buffer.writeln('│    Duration: ${medicine.duration}');
      buffer.writeln('│    Instructions: ${medicine.instruction}');
      buffer.writeln('│');
    }
    
    buffer.writeln('└──────────────────────────────────────────────────────────────┘');
    buffer.writeln('');
    
    // Notes
    if (prescription.notes != null && prescription.notes!.isNotEmpty) {
      buffer.writeln('┌─ ADDITIONAL NOTES ───────────────────────────────────────────┐');
      buffer.writeln('│ ${prescription.notes}');
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
    final medicines = prescription.medicinesDetails ?? [];
    
    final buffer = StringBuffer();
    buffer.writeln('Doctor Name,Specialization,Patient Name,Patient Age,Prescription Date,Diagnosis,Medicine,Strength,Dose,Duration,Instructions');
    
    if (medicines.isEmpty) {
      buffer.writeln('${doctor.fullName},${doctor.specialization},${patient.name},${patient.age},${prescription.date},${prescription.diagnosis},N/A,N/A,N/A,N/A,N/A');
    } else {
      for (final medicine in medicines) {
        buffer.writeln('${doctor.fullName},${doctor.specialization},${patient.name},${patient.age},${prescription.date},${prescription.diagnosis},${medicine.medicineName},${medicine.strength},${medicine.dose},${medicine.duration},${medicine.instruction}');
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
    final medicines = prescription.medicinesDetails ?? [];
    
    return {
      'doctorName': doctor.fullName,
      'patientName': patient.name,
      'date': prescription.date ?? 'N/A',
      'totalMedicines': medicines.length.toString(),
      'diagnosis': prescription.diagnosis ?? 'N/A',
      'notes': prescription.notes ?? 'N/A',
    };
  }
}
