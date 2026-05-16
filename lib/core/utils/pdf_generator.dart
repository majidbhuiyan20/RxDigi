import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models/prescription_model.dart';
import '../data/models/patient_model.dart';
import '../data/models/doctor_model.dart';

class PdfGenerator {
  // Cache fonts to improve performance and prevent re-downloading/re-loading
  static pw.Font? _fontBold;
  static pw.Font? _fontMedium;
  static pw.Font? _fontRegular;
  static pw.Font? _fontItalic;

  static Future<void> _loadFonts() async {
    _fontBold ??= await PdfGoogleFonts.poppinsBold();
    _fontMedium ??= await PdfGoogleFonts.poppinsMedium();
    _fontRegular ??= await PdfGoogleFonts.poppinsRegular();
    _fontItalic ??= await PdfGoogleFonts.poppinsItalic();
  }

  static Future<Uint8List> generatePrescriptionPdf(
    PrescriptionModel prescription,
    PatientModel patient,
    DoctorModel doctor,
  ) async {
    final pdf = pw.Document();
    await _loadFonts();

    final primaryColor = PdfColor.fromHex('#004D40');
    final accentColor = PdfColor.fromHex('#00BFA5');
    final textColor = PdfColor.fromHex('#263238');
    final lightGrey = PdfColor.fromHex('#F5F7F8');
    final dividerColor = PdfColor.fromHex('#CFD8DC');

    pw.MemoryImage? clinicLogo;
    if (doctor.clinicLogoPath != null && File(doctor.clinicLogoPath!).existsSync()) {
      clinicLogo = pw.MemoryImage(File(doctor.clinicLogoPath!).readAsBytesSync());
    }

    pw.MemoryImage? signature;
    if (doctor.signaturePath != null && File(doctor.signaturePath!).existsSync()) {
      signature = pw.MemoryImage(File(doctor.signaturePath!).readAsBytesSync());
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(35),
        theme: pw.ThemeData.withFont(
          base: _fontRegular,
          bold: _fontBold,
          italic: _fontItalic,
        ),
        header: (pw.Context context) {
          if (context.pageNumber > 1) {
             return pw.Container(
               alignment: pw.Alignment.centerRight,
               margin: const pw.EdgeInsets.only(bottom: 10),
               child: pw.Text('Prescription Continued - Page ${context.pageNumber}', 
                 style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
             );
          }
          return pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (clinicLogo != null)
                    pw.Container(
                      width: 60,
                      height: 60,
                      margin: const pw.EdgeInsets.only(right: 15),
                      child: pw.Image(clinicLogo),
                    ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('${doctor.title ?? 'Dr.'} ${doctor.fullName}'.toUpperCase(),
                          style: pw.TextStyle(font: _fontBold, fontSize: 24, color: primaryColor)),
                        pw.SizedBox(height: 4),
                        pw.Text(doctor.degrees ?? '',
                          style: pw.TextStyle(font: _fontMedium, fontSize: 11, color: textColor)),
                        if (doctor.collegeName?.isNotEmpty == true)
                          pw.Text(doctor.collegeName!,
                            style: pw.TextStyle(fontSize: 9, color: textColor)),
                        pw.SizedBox(height: 4),
                        pw.Container(
                          margin: const pw.EdgeInsets.symmetric(vertical: 4),
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: pw.BoxDecoration(
                            color: accentColor,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Text('${doctor.specialization ?? ''}${doctor.subSpecialization?.isNotEmpty == true ? " (${doctor.subSpecialization})" : ""}',
                            style: pw.TextStyle(font: _fontBold, fontSize: 10, color: PdfColors.white)),
                        ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(doctor.clinicName, textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(font: _fontBold, fontSize: 14, color: primaryColor)),
                        pw.SizedBox(height: 4),
                        pw.Text(doctor.address, textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(fontSize: 9, color: textColor)),
                        pw.SizedBox(height: 4),
                        pw.Text('Phone: ${doctor.mobile}',
                          style: pw.TextStyle(font: _fontBold, fontSize: 10, color: primaryColor)),
                        if (doctor.email.isNotEmpty)
                          pw.Text('Email: ${doctor.email}',
                            style: pw.TextStyle(fontSize: 9, color: textColor)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 15),
              pw.Container(height: 3, color: accentColor, width: 80, alignment: pw.Alignment.centerLeft),
              pw.SizedBox(height: 15),
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
                    _buildPatientDetail('PATIENT NAME', patient.name, _fontBold!, primaryColor),
                    _buildPatientDetail('AGE / GENDER', '${patient.age ?? 'N/A'}Y / ${patient.gender ?? 'N/A'}', _fontBold!, primaryColor),
                    _buildPatientDetail('DATE', '${prescription.date.day.toString().padLeft(2, '0')}-${prescription.date.month.toString().padLeft(2, '0')}-${prescription.date.year}', _fontBold!, primaryColor),
                  ],
                ),
              ),
              pw.SizedBox(height: 25),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Column(
            children: [
              if (signature != null)
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  margin: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        height: 40,
                        width: 80,
                        child: pw.Image(signature),
                      ),
                      pw.Container(width: 100, height: 0.5, color: PdfColors.grey400),
                      pw.Text('Authorized Signature', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                    ],
                  ),
                ),
              pw.Divider(color: dividerColor, thickness: 0.5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Generated by Prescripto', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
                  pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
                ],
              ),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            pw.Partitions(
              children: [
                pw.Partition(
                  width: 160,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (prescription.chiefComplaints?.isNotEmpty == true)
                        _buildSidebarGroup('CHIEF COMPLAINTS', prescription.chiefComplaints!, _fontBold!, primaryColor),
                      if (prescription.vitalSigns?.isNotEmpty == true)
                        _buildSidebarGroup('VITALS & SIGNS', prescription.vitalSigns!, _fontBold!, primaryColor),
                      if (prescription.diagnosis?.isNotEmpty == true)
                        _buildSidebarGroup('DIAGNOSIS', prescription.diagnosis!, _fontBold!, primaryColor),
                      if (prescription.labTests.isNotEmpty)
                        _buildSidebarGroup('INVESTIGATIONS', prescription.labTests.join('\n• '), _fontBold!, primaryColor, isList: true),
                    ],
                  ),
                ),
                pw.Partition(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 20),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Text('Rx', style: pw.TextStyle(font: _fontBold, fontSize: 35, color: primaryColor)),
                            pw.SizedBox(width: 10),
                            pw.Expanded(child: pw.Container(height: 1, color: lightGrey)),
                          ],
                        ),
                        pw.SizedBox(height: 15),
                        ...prescription.medicines.asMap().entries.map((entry) {
                          final i = entry.key;
                          final med = entry.value;
                          return pw.Container(
                            margin: const pw.EdgeInsets.only(bottom: 15),
                            child: pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('${i + 1}. ', style: pw.TextStyle(font: _fontBold, fontSize: 10)),
                                pw.Expanded(
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text('${med.dosageForm ?? ''} ${med.medicineName} ${med.strength ?? ''}'.toUpperCase(),
                                        style: pw.TextStyle(font: _fontBold, fontSize: 10, color: textColor)),
                                      pw.SizedBox(height: 2),
                                      pw.Text('${med.dose ?? ''} --- ${med.duration ?? ''}', style: const pw.TextStyle(fontSize: 9)),
                                      if (med.instruction?.isNotEmpty == true)
                                        pw.Text('Note: ${med.instruction}', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600, font: _fontItalic)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        if (prescription.advice?.isNotEmpty == true) ...[
                          pw.SizedBox(height: 15),
                          pw.Text('ADVICE', style: pw.TextStyle(font: _fontBold, fontSize: 9, color: primaryColor)),
                          ...prescription.advice!.split('\n').where((s) => s.trim().isNotEmpty).map((line) =>
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(top: 2),
                              child: pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('• ', style: const pw.TextStyle(fontSize: 9)),
                                  pw.Expanded(child: pw.Text(line.trim(), style: const pw.TextStyle(fontSize: 9))),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (prescription.nextVisit?.isNotEmpty == true) ...[
                          pw.SizedBox(height: 15),
                          pw.Text('Next Visit: ${prescription.nextVisit}', style: pw.TextStyle(font: _fontBold, fontSize: 9, color: primaryColor)),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPatientDetail(String label, String value, pw.Font font, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
        pw.Text(value, style: pw.TextStyle(font: font, fontSize: 10, color: color)),
      ],
    );
  }

  static pw.Widget _buildSidebarGroup(String title, String content, pw.Font font, PdfColor color, {bool isList = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(font: font, fontSize: 8, color: color)),
          pw.SizedBox(height: 2),
          pw.Text(isList ? '• $content' : content, style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  static Future<void> printPrescription(PrescriptionModel prescription, PatientModel patient, DoctorModel doctor) async {
    final bytes = await generatePrescriptionPdf(prescription, patient, doctor);
    await Printing.layoutPdf(
      onLayout: (format) => bytes,
      name: 'Prescription_${patient.name}',
    );
  }

  static Future<void> sharePrescription(PrescriptionModel prescription, PatientModel patient, DoctorModel doctor) async {
    final bytes = await generatePrescriptionPdf(prescription, patient, doctor);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Prescription_${patient.name.replaceAll(' ', '_')}.pdf',
    );
  }

  static Future<void> downloadPrescription(PrescriptionModel prescription, PatientModel patient, DoctorModel doctor) async {
    await sharePrescription(prescription, patient, doctor);
  }
}
