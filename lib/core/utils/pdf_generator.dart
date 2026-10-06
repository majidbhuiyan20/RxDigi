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
  static pw.Font? _fontBangla;

  static Future<void> _loadFonts() async {
    if (_fontRegular == null) {
      try {
        final regularData = await rootBundle.load('assets/fonts/PlusJakartaSans-Regular.ttf');
        _fontRegular = pw.Font.ttf(regularData);
      } catch (e) {
        _fontRegular = await PdfGoogleFonts.poppinsRegular();
      }
    }
    if (_fontBold == null) {
      try {
        final boldData = await rootBundle.load('assets/fonts/PlusJakartaSans-Bold.ttf');
        _fontBold = pw.Font.ttf(boldData);
      } catch (e) {
        _fontBold = await PdfGoogleFonts.poppinsBold();
      }
    }
    if (_fontMedium == null) {
      try {
        final mediumData = await rootBundle.load('assets/fonts/PlusJakartaSans-Medium.ttf');
        _fontMedium = pw.Font.ttf(mediumData);
      } catch (e) {
        _fontMedium = _fontRegular;
      }
    }
    if (_fontItalic == null) {
      try {
        final italicData = await rootBundle.load('assets/fonts/PlusJakartaSans-Italic.ttf');
        _fontItalic = pw.Font.ttf(italicData);
      } catch (e) {
        _fontItalic = _fontRegular;
      }
    }
    if (_fontBangla == null) {
      try {
        final banglaData = await rootBundle.load('assets/fonts/TiroBangla-Regular.ttf');
        _fontBangla = pw.Font.ttf(banglaData);
      } catch (e) {
        _fontBangla = null;
      }
    }
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
          fontFallback: _fontBangla != null ? [_fontBangla!] : [],
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
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: 'Rx: ${prescription.id ?? 'N/A'} | Doctor: ${doctor.fullName} | Patient: ${patient.name}',
                        width: 38,
                        height: 38,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('Scan to verify digital prescription', style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey500)),
                    ],
                  ),
                  if (signature != null)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Container(
                          height: 36,
                          width: 75,
                          child: pw.Image(signature),
                        ),
                        pw.Container(width: 90, height: 0.5, color: PdfColors.grey400),
                        pw.SizedBox(height: 2),
                        pw.Text('Doctor Signature', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(color: dividerColor, thickness: 0.5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Generated by RxDigi - Smart Health & Rx', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
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
                  width: 155,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.only(right: 12),
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(right: pw.BorderSide(color: PdfColor.fromInt(0xFFE0E0E0), width: 0.5)),
                    ),
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
                ),
                pw.Partition(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 16),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Text('Rx', style: pw.TextStyle(font: _fontBold, fontSize: 32, color: primaryColor)),
                            pw.SizedBox(width: 8),
                            pw.Expanded(child: pw.Container(height: 1, color: dividerColor)),
                          ],
                        ),
                        pw.SizedBox(height: 12),
                        ...prescription.medicines.asMap().entries.map((entry) {
                          final i = entry.key;
                          final med = entry.value;
                          return pw.Container(
                            margin: const pw.EdgeInsets.only(bottom: 12),
                            child: pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Container(
                                  width: 16,
                                  child: pw.Text('${i + 1}.', style: pw.TextStyle(font: _fontBold, fontSize: 9, color: primaryColor)),
                                ),
                                pw.Expanded(
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text('${med.dosageForm ?? ''} ${med.medicineName} ${med.strength ?? ''}'.toUpperCase(),
                                        style: pw.TextStyle(font: _fontBold, fontSize: 10, color: textColor)),
                                      pw.SizedBox(height: 2),
                                      pw.Row(
                                        children: [
                                          pw.Container(
                                            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                            decoration: pw.BoxDecoration(
                                              color: lightGrey,
                                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                                              border: pw.Border.all(color: dividerColor, width: 0.5),
                                            ),
                                            child: pw.Text('${med.dose ?? ''}   •   ${med.duration ?? ''}',
                                              style: pw.TextStyle(fontSize: 8.5, color: textColor, font: _fontMedium)),
                                          ),
                                        ],
                                      ),
                                      if (med.instruction?.isNotEmpty == true) ...[
                                        pw.SizedBox(height: 2),
                                        pw.Text('▸ ${med.instruction}', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700, font: _fontItalic)),
                                      ],
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
//