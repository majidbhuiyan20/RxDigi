import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../data/models/prescription_model.dart';
import '../data/models/patient_model.dart';
import '../data/models/doctor_model.dart';

class PdfGenerator {
  static Future<Uint8List> generatePrescriptionPdf(
    PrescriptionModel prescription,
    PatientModel patient,
    DoctorModel doctor,
  ) async {
    final pdf = pw.Document();

    final oswaldBold = await PdfGoogleFonts.oswaldBold();
    final oswaldRegular = await PdfGoogleFonts.oswaldRegular();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header - Doctor Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(doctor.fullName ?? '',
                          style: pw.TextStyle(font: oswaldBold, fontSize: 18)),
                      pw.Text(doctor.degrees ?? '',
                          style: pw.TextStyle(font: oswaldRegular, fontSize: 12)),
                      pw.Text(doctor.specialization ?? '',
                          style: pw.TextStyle(font: oswaldRegular, fontSize: 12)),
                      pw.Text(doctor.bmdcRegNo != null ? 'BMDC Reg: ${doctor.bmdcRegNo}' : '',
                          style: pw.TextStyle(font: oswaldRegular, fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(doctor.clinicName ?? '',
                          style: pw.TextStyle(font: oswaldBold, fontSize: 14)),
                      pw.Text(doctor.address ?? '',
                          style: pw.TextStyle(font: oswaldRegular, fontSize: 10)),
                      pw.Text(doctor.phoneNumber ?? '',
                          style: pw.TextStyle(font: oswaldRegular, fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 10),

              // Patient Info
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Name: ${patient.name}',
                        style: pw.TextStyle(font: oswaldBold, fontSize: 12)),
                    pw.Text('Age: ${patient.age ?? ''}',
                        style: pw.TextStyle(font: oswaldRegular, fontSize: 12)),
                    pw.Text('Gender: ${patient.gender ?? ''}',
                        style: pw.TextStyle(font: oswaldRegular, fontSize: 12)),
                    pw.Text('Date: ${prescription.date.day}/${prescription.date.month}/${prescription.date.year}',
                        style: pw.TextStyle(font: oswaldRegular, fontSize: 12)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Body
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left Column: Vitals, Complaints, History
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (prescription.chiefComplaints != null && prescription.chiefComplaints!.isNotEmpty) ...[
                          pw.Text('Chief Complaints', style: pw.TextStyle(font: oswaldBold, fontSize: 14)),
                          pw.Text(prescription.chiefComplaints!, style: pw.TextStyle(fontSize: 12)),
                          pw.SizedBox(height: 10),
                        ],
                        if (prescription.vitalSigns != null && prescription.vitalSigns!.isNotEmpty) ...[
                          pw.Text('Vital Signs', style: pw.TextStyle(font: oswaldBold, fontSize: 14)),
                          pw.Text(prescription.vitalSigns!, style: pw.TextStyle(fontSize: 12)),
                          pw.SizedBox(height: 10),
                        ],
                        if (prescription.pastHistory != null && prescription.pastHistory!.isNotEmpty) ...[
                          pw.Text('Past History', style: pw.TextStyle(font: oswaldBold, fontSize: 14)),
                          pw.Text(prescription.pastHistory!, style: pw.TextStyle(fontSize: 12)),
                          pw.SizedBox(height: 10),
                        ],
                        if (prescription.diagnosis != null && prescription.diagnosis!.isNotEmpty) ...[
                          pw.Text('Diagnosis', style: pw.TextStyle(font: oswaldBold, fontSize: 14)),
                          pw.Text(prescription.diagnosis!, style: pw.TextStyle(fontSize: 12)),
                          pw.SizedBox(height: 10),
                        ],
                        if (prescription.labTests.isNotEmpty) ...[
                          pw.Text('Investigations', style: pw.TextStyle(font: oswaldBold, fontSize: 14)),
                          ...prescription.labTests.map((test) => pw.Bullet(text: test, style: const pw.TextStyle(fontSize: 12))),
                          pw.SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                  pw.VerticalDivider(width: 20),
                  // Right Column: Medicines
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Rx', style: pw.TextStyle(font: oswaldBold, fontSize: 24)),
                        pw.SizedBox(height: 10),
                        ...prescription.medicines.asMap().entries.map((entry) {
                          final i = entry.key;
                          final med = entry.value;
                          return pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 10),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('${i + 1}. ${med.dosageForm ?? ''} ${med.medicineName} ${med.strength ?? ''}',
                                    style: pw.TextStyle(font: oswaldBold, fontSize: 12)),
                                pw.Text('    ${med.dose} ----- ${med.duration}',
                                    style: const pw.TextStyle(fontSize: 11)),
                                pw.Text('    ${med.instruction}',
                                    style: pw.TextStyle(font: oswaldRegular, fontSize: 10, color: PdfColors.grey700)),
                              ],
                            ),
                          );
                        }),
                        pw.SizedBox(height: 20),
                        if (prescription.advice != null && prescription.advice!.isNotEmpty) ...[
                          pw.Text('Advice', style: pw.TextStyle(font: oswaldBold, fontSize: 14)),
                          pw.Text(prescription.advice!, style: const pw.TextStyle(fontSize: 12)),
                        ],
                        if (prescription.nextVisit != null && prescription.nextVisit!.isNotEmpty) ...[
                          pw.SizedBox(height: 10),
                          pw.Text('Next Visit: ${prescription.nextVisit}',
                              style: pw.TextStyle(font: oswaldBold, fontSize: 12)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              pw.Spacer(),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Generated by RxDigi', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                  pw.Text('Signature: ___________________', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> printPrescription(
    PrescriptionModel prescription,
    PatientModel patient,
    DoctorModel doctor,
  ) async {
    final pdfBytes = await generatePrescriptionPdf(prescription, patient, doctor);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Prescription_${patient.name}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  static Future<void> sharePrescription(
    PrescriptionModel prescription,
    PatientModel patient,
    DoctorModel doctor,
  ) async {
    final pdfBytes = await generatePrescriptionPdf(prescription, patient, doctor);
    
    // Create a temporary file to share
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/Prescription_${patient.name.replaceAll(' ', '_')}.pdf');
    await file.writeAsBytes(pdfBytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Prescription for ${patient.name}',
      subject: 'Prescription - RxDigi',
    );
  }

  static Future<void> shareToWhatsApp(
    PrescriptionModel prescription,
    PatientModel patient,
    DoctorModel doctor,
  ) async {
    // WhatsApp sharing typically uses the same mechanism as general sharing
    // but we can customize the text message.
    await sharePrescription(prescription, patient, doctor);
  }
}
