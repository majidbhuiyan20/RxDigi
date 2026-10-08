import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/vital_log_model.dart';

/// Clinical Report Generator for Doctor Consultations
/// Generates a structured 1-page clinical summary (PDF) of BP, Sugar, and Weight logs
class DoctorVitalsReportGenerator {
  DoctorVitalsReportGenerator._();

  static pw.Font? _fontRegular;
  static pw.Font? _fontBold;

  static Future<void> _loadFonts() async {
    if (_fontRegular == null) {
      try {
        final data = await rootBundle.load('assets/fonts/PlusJakartaSans-Regular.ttf');
        _fontRegular = pw.Font.ttf(data);
      } catch (_) {
        _fontRegular = await PdfGoogleFonts.poppinsRegular();
      }
    }
    if (_fontBold == null) {
      try {
        final data = await rootBundle.load('assets/fonts/PlusJakartaSans-Bold.ttf');
        _fontBold = pw.Font.ttf(data);
      } catch (_) {
        _fontBold = await PdfGoogleFonts.poppinsBold();
      }
    }
  }

  /// Builds the clinical PDF document bytes
  static Future<Uint8List> generateReportBytes({
    required List<VitalLogModel> logs,
    required int daysFilter, // e.g. 7, 14, 30, or 0 for All
    String patientName = 'Patient Record',
  }) async {
    await _loadFonts();
    final pdf = pw.Document();

    final now = DateTime.now();
    final cutoff = daysFilter > 0 ? now.subtract(Duration(days: daysFilter)) : null;

    final filteredLogs = (cutoff != null
        ? logs.where((l) => l.recordedAt.isAfter(cutoff)).toList()
        : List<VitalLogModel>.from(logs))
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt)); // Newest first

    // Separate by vital types
    final bpLogs = filteredLogs.where((l) => l.type == 'BP').toList();
    final sugarLogs = filteredLogs.where((l) => l.type == 'SUGAR').toList();
    final weightLogs = filteredLogs.where((l) => l.type == 'WEIGHT').toList();

    // Calculate BP Stats
    String bpLatest = 'N/A';
    String bpAverage = 'N/A';
    String bpZone = 'N/A';
    if (bpLogs.isNotEmpty) {
      final latest = bpLogs.first;
      bpLatest = '${latest.value1.toInt()}/${latest.value2?.toInt() ?? 0} mmHg';
      bpZone = latest.getBpStatus();

      double sumSys = 0;
      double sumDia = 0;
      int diaCount = 0;
      for (final l in bpLogs) {
        sumSys += l.value1;
        if (l.value2 != null) {
          sumDia += l.value2!;
          diaCount++;
        }
      }
      final avgSys = (sumSys / bpLogs.length).round();
      final avgDia = diaCount > 0 ? (sumDia / diaCount).round() : 0;
      bpAverage = '$avgSys/$avgDia mmHg';
    }

    // Calculate Sugar Stats
    String sugarLatest = 'N/A';
    String sugarAverage = 'N/A';
    if (sugarLogs.isNotEmpty) {
      final latest = sugarLogs.first;
      sugarLatest = '${latest.value1.toStringAsFixed(1)} ${latest.unit}';
      if (latest.category != null && latest.category!.isNotEmpty) {
        sugarLatest += ' (${latest.category})';
      }

      double sum = 0;
      for (final l in sugarLogs) {
        sum += l.value1;
      }
      final avg = (sum / sugarLogs.length).toStringAsFixed(1);
      sugarAverage = '$avg ${sugarLogs.first.unit}';
    }

    // Calculate Weight Stats
    String weightLatest = 'N/A';
    if (weightLogs.isNotEmpty) {
      final latest = weightLogs.first;
      weightLatest = '${latest.value1.toStringAsFixed(1)} kg';
      final bmi = latest.getBmi();
      if (bmi != null) {
        weightLatest += ' (BMI: ${bmi.toStringAsFixed(1)})';
      }
    }

    final periodLabel = daysFilter == 0
        ? 'All Recorded Time'
        : 'Last $daysFilter Days (${DateFormat('dd MMM').format(cutoff!)} - ${DateFormat('dd MMM yyyy').format(now)})';

    final theme = pw.ThemeData.withFont(
      base: _fontRegular,
      bold: _fontBold,
    );

    pdf.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Top Header: Clinical Branding & Document Title
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 12),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.teal700, width: 2),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'RxDigi CLINICAL HEALTH SUMMARY',
                        style: pw.TextStyle(
                          color: PdfColors.teal800,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Physician Consultation & Vitals Trend Report',
                        style: const pw.TextStyle(
                          color: PdfColors.grey700,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Date: ${DateFormat('dd MMM yyyy').format(now)}',
                        style: pw.TextStyle(
                          color: PdfColors.grey800,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Time: ${DateFormat('hh:mm a').format(now)}',
                        style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 9),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            // Patient Meta Box
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Report Subject: $patientName',
                        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Timeline Window: $periodLabel',
                        style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.teal50,
                      borderRadius: pw.BorderRadius.circular(4),
                      border: pw.Border.all(color: PdfColors.teal600),
                    ),
                    child: pw.Text(
                      'Total Logs: ${filteredLogs.length}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 14),

            // Key Clinical Metric Summary Cards (3 Columns)
            pw.Row(
              children: [
                // BP Card
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.teal300),
                      borderRadius: pw.BorderRadius.circular(6),
                      color: PdfColors.white,
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BLOOD PRESSURE',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.teal800,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          'Latest: $bpLatest',
                          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Average: $bpAverage',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: pw.BoxDecoration(
                            color: bpZone == 'Normal'
                                ? PdfColors.green50
                                : (bpZone.contains('Elevated') ? PdfColors.amber50 : PdfColors.red50),
                            borderRadius: pw.BorderRadius.circular(3),
                          ),
                          child: pw.Text(
                            'Status: $bpZone',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: bpZone == 'Normal'
                                  ? PdfColors.green800
                                  : (bpZone.contains('Elevated') ? PdfColors.amber900 : PdfColors.red800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 8),

                // Glucose Card
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.orange300),
                      borderRadius: pw.BorderRadius.circular(6),
                      color: PdfColors.white,
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BLOOD GLUCOSE',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.orange800,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          'Latest: $sugarLatest',
                          style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Average: $sugarAverage',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Target: 4.0 - 7.0 mmol/L',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 8),

                // Weight Card
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.purple300),
                      borderRadius: pw.BorderRadius.circular(6),
                      color: PdfColors.white,
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BODY WEIGHT',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.purple800,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          'Latest: $weightLatest',
                          style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Total Logs: ${weightLogs.length}',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'BMI Target: 18.5 - 24.9',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 16),

            // Section Heading: Clinical Log Table
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'CHRONOLOGICAL CLINICAL LOGS',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.Text(
                  'AHA/WHO Clinical Guidelines Applied',
                  style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
                ),
              ],
            ),
            pw.SizedBox(height: 6),

            // Table of Logs
            if (filteredLogs.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(24),
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  'No vitals recorded in this timeframe.',
                  style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
                ),
              )
            else
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2.0), // Date
                  1: const pw.FlexColumnWidth(1.4), // Type
                  2: const pw.FlexColumnWidth(2.2), // Value
                  3: const pw.FlexColumnWidth(2.0), // Status
                  4: const pw.FlexColumnWidth(3.0), // Notes
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.teal50),
                    children: [
                      _buildHeaderCell('Date & Time'),
                      _buildHeaderCell('Vital Type'),
                      _buildHeaderCell('Measurement'),
                      _buildHeaderCell('Status / Zone'),
                      _buildHeaderCell('Context / Notes'),
                    ],
                  ),
                  // Data Rows
                  ...filteredLogs.take(28).map((log) {
                    final dateStr = DateFormat('dd/MM/yy hh:mm a').format(log.recordedAt);
                    String readingStr = '';
                    String statusStr = '-';

                    if (log.type == 'BP') {
                      readingStr = '${log.value1.toInt()}/${log.value2?.toInt() ?? 0} ${log.unit}';
                      statusStr = log.getBpStatus();
                    } else if (log.type == 'SUGAR') {
                      readingStr = '${log.value1.toStringAsFixed(1)} ${log.unit}';
                      statusStr = log.category ?? 'Glucose';
                    } else if (log.type == 'WEIGHT') {
                      readingStr = '${log.value1.toStringAsFixed(1)} ${log.unit}';
                      final bmi = log.getBmi();
                      statusStr = bmi != null ? 'BMI ${bmi.toStringAsFixed(1)}' : 'Weight';
                    }

                    return pw.TableRow(
                      children: [
                        _buildDataCell(dateStr, isMono: true),
                        _buildDataCell(log.type, isBold: true),
                        _buildDataCell(readingStr, isBold: true),
                        _buildDataCell(statusStr),
                        _buildDataCell(log.notes?.isNotEmpty == true ? log.notes! : '-'),
                      ],
                    );
                  }),
                ],
              ),

            pw.SizedBox(height: 18),

            // Clinical Disclaimer & Footer
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'NOTICE TO CONSULTING PHYSICIAN:',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey800,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'This document was compiled digitally from patient self-measurements tracked in RxDigi. Blood pressure zones correspond to standard AHA/ACC 2017 thresholds. Please verify values using certified clinical diagnostic equipment.',
                    style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.teal900,
        ),
      ),
    );
  }

  static pw.Widget _buildDataCell(String text, {bool isBold = false, bool isMono = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: PdfColors.grey800,
        ),
      ),
    );
  }

  /// Trigger native Print / PDF Viewer Dialog
  static Future<void> printReport({
    required List<VitalLogModel> logs,
    required int daysFilter,
    String patientName = 'Patient Record',
  }) async {
    final pdfBytes = await generateReportBytes(
      logs: logs,
      daysFilter: daysFilter,
      patientName: patientName,
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'RxDigi_Doctor_Vitals_Report_${daysFilter == 0 ? "All" : "${daysFilter}d"}.pdf',
    );
  }

  /// Trigger Direct Share (WhatsApp, Email, etc.)
  static Future<void> shareReport({
    required List<VitalLogModel> logs,
    required int daysFilter,
    String patientName = 'Patient Record',
  }) async {
    final pdfBytes = await generateReportBytes(
      logs: logs,
      daysFilter: daysFilter,
      patientName: patientName,
    );
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'RxDigi_Doctor_Vitals_Report_${daysFilter == 0 ? "All" : "${daysFilter}d"}.pdf',
    );
  }
}
