import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
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

    // Load fonts
    final oswaldBold = await PdfGoogleFonts.oswaldBold();
    final oswaldRegular = await PdfGoogleFonts.oswaldRegular();
    final bengaliFont = await PdfGoogleFonts.notoSansBengaliRegular();
    final bengaliBold = await PdfGoogleFonts.notoSansBengaliBold();

    // Colors based on the design
    final primaryPurple = PdfColor.fromHex('#6A1B9A'); // Deep Purple
    final accentRed = PdfColor.fromHex('#C62828'); // Red
    final accentBlue = PdfColor.fromHex('#1565C0'); // Blue
    final greyColor = PdfColors.grey800;
    final borderColor = PdfColors.grey400;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        theme: pw.ThemeData.withFont(
          base: oswaldRegular,
          bold: oswaldBold,
          fontFallback: [bengaliFont],
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- Header ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left: Bengali Doctor Info
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          doctor.fullName,
                          style: pw.TextStyle(
                            font: bengaliBold,
                            fontSize: 20,
                            color: primaryPurple,
                          ),
                        ),
                        pw.Text(
                          doctor.degrees ?? '',
                          style: pw.TextStyle(font: bengaliFont, fontSize: 10, color: greyColor),
                        ),
                        pw.Text(
                          doctor.specialization ?? '',
                          style: pw.TextStyle(font: bengaliFont, fontSize: 10, color: accentRed),
                        ),
                        pw.Text(
                          doctor.clinicName,
                          style: pw.TextStyle(font: bengaliFont, fontSize: 9, color: accentBlue),
                        ),
                      ],
                    ),
                  ),
                  // Right: English Doctor Info
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          '${doctor.title ?? 'Dr.'} ${doctor.fullName}'.toUpperCase(),
                          style: pw.TextStyle(
                            font: oswaldBold,
                            fontSize: 18,
                            color: primaryPurple,
                          ),
                        ),
                        pw.Text(
                          doctor.degrees ?? '',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(fontSize: 9, color: greyColor),
                        ),
                        pw.Text(
                          doctor.specialization ?? '',
                          style: pw.TextStyle(fontSize: 10, color: accentRed, font: oswaldBold),
                        ),
                        pw.Text(
                          doctor.clinicName,
                          style: pw.TextStyle(fontSize: 9, color: accentBlue),
                        ),
                        if (doctor.bmdcRegNo != null)
                          pw.Text(
                            'BMDC Reg. No: ${doctor.bmdcRegNo}',
                            style: pw.TextStyle(fontSize: 9, color: greyColor),
                          ),
                        pw.Text(
                          'Contact: ${doctor.mobile}',
                          style: pw.TextStyle(fontSize: 9, color: greyColor, font: oswaldBold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 0.5, color: borderColor),
              pw.SizedBox(height: 5),

              // --- Patient Info Bar ---
              pw.Row(
                children: [
                  _buildPatientField('Name:', patient.name, 2, oswaldBold),
                  _buildPatientField('Age:', patient.age?.toString() ?? '', 0.5, oswaldBold),
                  _buildPatientField('Gender:', patient.gender ?? '', 0.5, oswaldBold),
                  _buildPatientField('Date:', '${prescription.date.day.toString().padLeft(2, '0')}/${prescription.date.month.toString().padLeft(2, '0')}/${prescription.date.year}', 0.8, oswaldBold),
                ],
              ),
              pw.SizedBox(height: 15),

              // --- Main Content ---
              pw.Expanded(
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Left Column (Sidebar)
                    pw.Container(
                      width: 140,
                      padding: const pw.EdgeInsets.only(right: 10),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (prescription.diagnosis?.isNotEmpty == true) ...[
                            _buildSectionTitle('Dx:', oswaldBold),
                            pw.Text(prescription.diagnosis!, style: const pw.TextStyle(fontSize: 10)),
                            pw.SizedBox(height: 10),
                          ],
                          
                          if (prescription.chiefComplaints?.isNotEmpty == true) ...[
                            _buildSectionTitle('Clinical Complaints:', oswaldBold),
                            pw.Text(prescription.chiefComplaints!, style: const pw.TextStyle(fontSize: 10)),
                            pw.SizedBox(height: 10),
                          ],

                          _buildSectionTitle('Risk Factors / Vitals:', oswaldBold),
                          pw.Text(prescription.vitalSigns ?? 'BP: \nPulse: \nTemp: ', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                          pw.SizedBox(height: 10),

                          if (prescription.labTests.isNotEmpty) ...[
                            _buildSectionTitle('Investigations:', oswaldBold),
                            ...prescription.labTests.map((t) => pw.Text('• $t', style: const pw.TextStyle(fontSize: 9))),
                          ] else ...[
                            _buildSectionTitle('Investigations:', oswaldBold),
                            pw.Text('ECG, CXR, RBS...', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                          ],
                        ],
                      ),
                    ),

                    // Vertical Divider
                    pw.Container(width: 0.5, color: borderColor, height: double.infinity),

                    // Right Column (Rx Grid)
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.only(left: 10),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Rx', style: pw.TextStyle(font: oswaldBold, fontSize: 24, color: primaryPurple)),
                            pw.SizedBox(height: 5),
                            
                            // Medicine Table
                            pw.Table(
                              border: pw.TableBorder.all(color: borderColor, width: 0.5),
                              columnWidths: {
                                0: const pw.FixedColumnWidth(25), // Sl
                                1: const pw.FlexColumnWidth(3),  // Medicine Name
                                2: const pw.FixedColumnWidth(30), // Morning
                                3: const pw.FixedColumnWidth(30), // Noon
                                4: const pw.FixedColumnWidth(30), // Night
                                5: const pw.FlexColumnWidth(1.2), // Before/After
                              },
                              children: [
                                // Table Header
                                pw.TableRow(
                                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                                  children: [
                                    _tableHeader('', oswaldBold),
                                    _tableHeader('Medicine Name', oswaldBold),
                                    _tableHeader('সকাল', bengaliBold),
                                    _tableHeader('দুপুর', bengaliBold),
                                    _tableHeader('রাত', bengaliBold),
                                    pw.Column(
                                      children: [
                                        _tableHeader('খাবার', bengaliBold),
                                        pw.Row(
                                          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                                          children: [
                                            pw.Text('আগে', style: pw.TextStyle(font: bengaliFont, fontSize: 7)),
                                            pw.Text('পরে', style: pw.TextStyle(font: bengaliFont, fontSize: 7)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // Medicine Rows
                                ...prescription.medicines.asMap().entries.map((entry) {
                                  final i = entry.key;
                                  final med = entry.value;
                                  final doses = med.dose?.split('+') ?? [];
                                  return pw.TableRow(
                                    children: [
                                      _tableCell('${i + 1}'),
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.all(4),
                                        child: pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text(med.medicineName ?? '', style: pw.TextStyle(font: oswaldBold, fontSize: 10)),
                                            if (med.strength != null)
                                              pw.Text(med.strength!, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                                            if (med.instruction != null)
                                              pw.Text(med.instruction!, style: pw.TextStyle(fontSize: 7, font: bengaliFont, color: accentBlue)),
                                          ],
                                        ),
                                      ),
                                      _tableCell(doses.length > 0 ? doses[0] : ''),
                                      _tableCell(doses.length > 1 ? doses[1] : ''),
                                      _tableCell(doses.length > 2 ? doses[2] : ''),
                                      _tableCell(med.duration ?? ''),
                                    ],
                                  );
                                }),
                                // Empty rows to fill the grid like in the image
                                for (var i = 0; i < (12 - prescription.medicines.length).clamp(0, 12); i++)
                                  pw.TableRow(
                                    children: [
                                      _tableCell(''),
                                      _tableCell(''),
                                      _tableCell(''),
                                      _tableCell(''),
                                      _tableCell(''),
                                      _tableCell(''),
                                    ],
                                  ),
                              ],
                            ),
                            
                            if (prescription.advice?.isNotEmpty == true) ...[
                              pw.SizedBox(height: 15),
                              _buildSectionTitle('Advice:', oswaldBold),
                              pw.Text(prescription.advice!, style: const pw.TextStyle(fontSize: 10)),
                            ],

                            if (prescription.nextVisit?.isNotEmpty == true) ...[
                              pw.SizedBox(height: 10),
                              pw.Container(
                                padding: const pw.EdgeInsets.all(4),
                                decoration: pw.BoxDecoration(border: pw.Border.all(color: accentBlue, width: 0.5)),
                                child: pw.Text('Next Visit: ${prescription.nextVisit}', style: pw.TextStyle(font: oswaldBold, fontSize: 10, color: accentBlue)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- Footer ---
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 0.5, color: borderColor),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${doctor.offDays ?? ''} ${doctor.startTime ?? ''} - ${doctor.endTime ?? ''}', 
                        style: pw.TextStyle(font: bengaliFont, fontSize: 8, color: accentRed)
                      ),
                      pw.Text(doctor.address, style: pw.TextStyle(font: bengaliFont, fontSize: 8)),
                      pw.Text(
                        'সিরিয়ালের জন্য: ${doctor.serialNumber1 ?? ''}${doctor.serialNumber2 != null ? ', ${doctor.serialNumber2}' : ''}', 
                        style: pw.TextStyle(font: bengaliBold, fontSize: 8, color: primaryPurple)
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Row(
                        children: [
                          pw.Text(doctor.clinicName, style: pw.TextStyle(font: bengaliBold, fontSize: 8, color: accentBlue)),
                          pw.SizedBox(width: 5),
                          pw.Container(width: 20, height: 20, decoration: const pw.BoxDecoration(color: PdfColors.grey300, shape: pw.BoxShape.circle)),
                        ],
                      ),
                      pw.Text(doctor.address, style: pw.TextStyle(font: bengaliFont, fontSize: 7)),
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

  static pw.Widget _buildPatientField(String label, String value, double flex, pw.Font font) {
    return pw.Expanded(
      flex: (flex * 100).toInt(),
      child: pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 5),
        child: pw.Row(
          children: [
            pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey400))),
                child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Text(title, style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.black)),
    );
  }

  static pw.Widget _tableHeader(String text, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      alignment: pw.Alignment.center,
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 9)),
    );
  }

  static pw.Widget _tableCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      height: 25,
      alignment: pw.Alignment.center,
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
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
    
    // Use Printing.sharePdf which provides a "Save to Files" or similar option
    // or use share_plus as a fallback.
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
    
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/Prescription_${patient.name.replaceAll(' ', '_')}.pdf');
    await file.writeAsBytes(pdfBytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Prescription for ${patient.name}',
      subject: 'Prescription - RxDigi',
    );
  }
}
