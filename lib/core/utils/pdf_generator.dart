import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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

    // Load professional modern fonts
    final mainBold = await PdfGoogleFonts.poppinsBold();
    final mainMedium = await PdfGoogleFonts.poppinsMedium();
    final mainRegular = await PdfGoogleFonts.poppinsRegular();
    final mainItalic = await PdfGoogleFonts.poppinsItalic();

    // Modern Eye-catching Color Palette
    final primaryColor = PdfColor.fromHex('#004D40'); // Deep Teal
    final accentColor = PdfColor.fromHex('#00BFA5'); // Bright Teal
    final textColor = PdfColor.fromHex('#263238'); // Charcoal Grey
    final lightGrey = PdfColor.fromHex('#F5F7F8');
    final dividerColor = PdfColor.fromHex('#CFD8DC');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(35),
        theme: pw.ThemeData.withFont(
          base: mainRegular,
          bold: mainBold,
          italic: mainItalic,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- Stylish Header ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '${doctor.title ?? 'Dr.'} ${doctor.fullName}'.toUpperCase(),
                          style: pw.TextStyle(
                            font: mainBold,
                            fontSize: 24,
                            color: primaryColor,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          doctor.degrees ?? '',
                          style: pw.TextStyle(font: mainMedium, fontSize: 11, color: textColor),
                        ),
                        pw.Container(
                          margin: const pw.EdgeInsets.symmetric(vertical: 4),
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: pw.BoxDecoration(
                            color: accentColor,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Text(
                            doctor.specialization ?? '',
                            style: pw.TextStyle(font: mainBold, fontSize: 10, color: PdfColors.white),
                          ),
                        ),
                        if (doctor.bmdcRegNo != null)
                          pw.Text(
                            'Registration: ${doctor.bmdcRegNo}',
                            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                          ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          doctor.clinicName,
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(font: mainBold, fontSize: 14, color: primaryColor),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          doctor.address,
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(fontSize: 9, color: textColor),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Phone: ${doctor.mobile}',
                          style: pw.TextStyle(font: mainBold, fontSize: 10, color: primaryColor),
                        ),
                        if (doctor.email != null)
                          pw.Text(
                            doctor.email,
                            style: pw.TextStyle(fontSize: 9, color: textColor),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              
              pw.SizedBox(height: 15),
              pw.Container(height: 3, color: accentColor, width: 80),
              pw.SizedBox(height: 15),

              // --- Patient Info Bar (Eye-catching Design) ---
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: lightGrey,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: dividerColor, width: 0.5),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPatientDetail('PATIENT NAME', patient.name, mainBold, primaryColor),
                    _buildPatientDetail('AGE / GENDER', '${patient.age ?? 'N/A'}Y / ${patient.gender ?? 'N/A'}', mainBold, primaryColor),
                    _buildPatientDetail('DATE', '${prescription.date.day.toString().padLeft(2, '0')}-${prescription.date.month.toString().padLeft(2, '0')}-${prescription.date.year}', mainBold, primaryColor),
                  ],
                ),
              ),

              pw.SizedBox(height: 25),

              // --- Main Layout ---
              pw.Expanded(
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // --- Sidebar: Observations & Vitals ---
                    pw.Container(
                      width: 160,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (prescription.chiefComplaints?.isNotEmpty == true)
                            _buildSidebarGroup('CHIEF COMPLAINTS', prescription.chiefComplaints!, mainBold, primaryColor),
                          
                          if (prescription.vitalSigns?.isNotEmpty == true)
                            _buildSidebarGroup('VITALS & SIGNS', prescription.vitalSigns!, mainBold, primaryColor),

                          if (prescription.diagnosis?.isNotEmpty == true)
                            _buildSidebarGroup('DIAGNOSIS', prescription.diagnosis!, mainBold, primaryColor),

                          if (prescription.labTests.isNotEmpty)
                            _buildSidebarGroup('INVESTIGATIONS', prescription.labTests.join('\n• '), mainBold, primaryColor, isList: true),
                        ],
                      ),
                    ),

                    // --- Stylized Divider ---
                    pw.Container(
                      width: 1,
                      color: dividerColor,
                      margin: const pw.EdgeInsets.symmetric(horizontal: 20),
                    ),

                    // --- Right Side: Rx (Medications) ---
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            children: [
                              pw.Text('Rx', style: pw.TextStyle(font: mainBold, fontSize: 40, color: primaryColor)),
                              pw.SizedBox(width: 10),
                              pw.Expanded(child: pw.Container(height: 1, color: lightGrey)),
                            ],
                          ),
                          pw.SizedBox(height: 15),
                          
                          // No Table - Clean List Design
                          ...prescription.medicines.asMap().entries.map((entry) {
                            final i = entry.key;
                            final med = entry.value;
                            return pw.Container(
                              margin: const pw.EdgeInsets.only(bottom: 18),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Row(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Container(
                                        width: 18,
                                        height: 18,
                                        margin: const pw.EdgeInsets.only(top: 2, right: 8),
                                        decoration: pw.BoxDecoration(
                                          color: primaryColor,
                                          shape: pw.BoxShape.circle,
                                        ),
                                        alignment: pw.Alignment.center,
                                        child: pw.Text('${i + 1}', style: const pw.TextStyle(color: PdfColors.white, fontSize: 9)),
                                      ),
                                      pw.Expanded(
                                        child: pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text(
                                              '${med.dosageForm ?? ''} ${med.medicineName} ${med.strength ?? ''}'.toUpperCase(),
                                              style: pw.TextStyle(font: mainBold, fontSize: 11, color: textColor),
                                            ),
                                            pw.SizedBox(height: 4),
                                            pw.Row(
                                              children: [
                                                pw.Text('Schedule: ', style: pw.TextStyle(font: mainBold, fontSize: 9, color: accentColor)),
                                                pw.Text(med.dose ?? '', style: const pw.TextStyle(fontSize: 9)),
                                                pw.SizedBox(width: 15),
                                                pw.Text('Duration: ', style: pw.TextStyle(font: mainBold, fontSize: 9, color: accentColor)),
                                                pw.Text(med.duration ?? '', style: const pw.TextStyle(fontSize: 9)),
                                              ],
                                            ),
                                            if (med.instruction?.isNotEmpty == true)
                                              pw.Padding(
                                                padding: const pw.EdgeInsets.only(top: 4),
                                                child: pw.Text(
                                                  'Instruction: ${med.instruction}',
                                                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600, font: mainItalic),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),

                          if (prescription.advice?.isNotEmpty == true) ...[
                            pw.SizedBox(height: 20),
                            pw.Container(height: 1, color: lightGrey),
                            pw.SizedBox(height: 10),
                            pw.Text('ADVICE', style: pw.TextStyle(font: mainBold, fontSize: 10, color: primaryColor)),
                            pw.SizedBox(height: 4),
                            pw.Text(prescription.advice!, style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey800)),
                          ],

                          if (prescription.nextVisit?.isNotEmpty == true) ...[
                            pw.Spacer(),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: pw.BoxDecoration(
                                color: lightGrey,
                                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                                border: pw.Border.all(color: accentColor, width: 1),
                              ),
                              child: pw.Row(
                                mainAxisSize: pw.MainAxisSize.min,
                                children: [
                                  pw.Text('Follow-up Date: ', style: pw.TextStyle(font: mainBold, fontSize: 10, color: primaryColor)),
                                  pw.Text(prescription.nextVisit!, style: pw.TextStyle(font: mainBold, fontSize: 10, color: accentColor)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- Professional Footer ---
              pw.SizedBox(height: 20),
              pw.Divider(color: dividerColor, thickness: 0.5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Generated by RxDigi', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
                      pw.Text('Schedule: ${doctor.offDays ?? 'N/A'} | ${doctor.startTime ?? ''} - ${doctor.endTime ?? ''}', 
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(width: 120, height: 1, color: textColor),
                      pw.SizedBox(height: 2),
                      pw.Text('Authorized Signature', style: pw.TextStyle(font: mainBold, fontSize: 9, color: primaryColor)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPatientDetail(String label, String value, pw.Font font, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
        pw.SizedBox(height: 2),
        pw.Text(value, style: pw.TextStyle(font: font, fontSize: 11, color: color)),
      ],
    );
  }

  static pw.Widget _buildSidebarGroup(String title, String content, pw.Font font, PdfColor color, {bool isList = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(font: font, fontSize: 9, color: color, letterSpacing: 1)),
          pw.SizedBox(height: 5),
          pw.Text(
            isList ? '• $content' : content,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey900),
          ),
        ],
      ),
    );
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

  static Future<void> downloadPrescription(
    PrescriptionModel prescription,
    PatientModel patient,
    DoctorModel doctor,
  ) async {
    final pdfBytes = await generatePrescriptionPdf(prescription, patient, doctor);
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Prescription_${patient.name.replaceAll(' ', '_')}.pdf',
    );
  }

  static Future<void> sharePrescription(
    PrescriptionModel prescription,
    PatientModel patient,
    DoctorModel doctor,
  ) async {
    final pdfBytes = await generatePrescriptionPdf(prescription, patient, doctor);
    
    // Using Printing.sharePdf is the most reliable way to share PDFs on both iOS and Android
    // as it handles the temporary file creation and platform-specific sharing protocols correctly.
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Prescription_${patient.name.replaceAll(' ', '_')}.pdf',
      subject: 'Prescription - ${patient.name}',
    );
  }
}
