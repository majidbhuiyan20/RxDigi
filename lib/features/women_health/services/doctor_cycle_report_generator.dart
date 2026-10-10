import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/daily_symptom_log.dart';
import '../models/menstrual_cycle_model.dart';
import '../utils/women_health_formatters.dart';

/// Clinical Report Generator for Gynecologist & Doctor Consultations
/// Generates a standardized 1-page clinical summary (PDF & Text)
class DoctorCycleReportGenerator {
  DoctorCycleReportGenerator._();

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
    required MenstrualCycleModel cycle,
    required List<HistoricalCycleEntry> cycleHistory,
    required Map<String, DailySymptomLog> symptomsMap,
    required OCPTrackerState ocpState,
    required IronSupplementState ironState,
    String patientName = 'Patient Record',
  }) async {
    await _loadFonts();
    final pdf = pw.Document();

    final lmpFormatted = DateFormat('dd MMM yyyy').format(cycle.lastPeriodStartDate);
    final nextPeriodFormatted = DateFormat('dd MMM yyyy').format(cycle.nextPeriodDate);
    final ovulationFormatted = DateFormat('dd MMM yyyy').format(cycle.nextOvulationDate);
    final reportGeneratedAt = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    // Calculate regularity & averages
    final allLengths = [cycle.cycleLength, ...cycleHistory.map((c) => c.cycleLength)];
    final avgLength = (allLengths.reduce((a, b) => a + b) / allLengths.length).round();
    final isClinicallyIrregular = avgLength < 21 || avgLength > 35;

    // Tally cramps & symptoms
    int severeCrampsCount = 0;
    int moderateCrampsCount = 0;
    final symptomFrequency = <String, int>{};

    for (final log in symptomsMap.values) {
      if (log.cramp == CrampLevel.severe) severeCrampsCount++;
      if (log.cramp == CrampLevel.moderate) moderateCrampsCount++;
      for (final s in log.physicalSymptoms) {
        final englishLabel = SymptomCatalog.getLabel(s, false);
        symptomFrequency[englishLabel] = (symptomFrequency[englishLabel] ?? 0) + 1;
      }
    }

    final topSymptoms = symptomFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: _fontRegular,
          bold: _fontBold,
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ─── Header ───
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'RxDigi Clinical Health Summary',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#BE123C'),
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        "Gynecological & Menstrual Health Brief",
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColor.fromHex('#475569'),
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#FFF1F2'),
                          borderRadius: pw.BorderRadius.circular(6),
                          border: pw.Border.all(color: PdfColor.fromHex('#FECDD3')),
                        ),
                        child: pw.Text(
                          'CONFIDENTIAL MEDICAL BRIEF',
                          style: pw.TextStyle(
                            fontSize: 8.5,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#9F1239'),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Generated: $reportGeneratedAt',
                        style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 12),
              pw.Divider(thickness: 1, color: PdfColor.fromHex('#E2E8F0')),
              pw.SizedBox(height: 10),

              // ─── Key Clinical Metrics Cards ───
              pw.Row(
                children: [
                  _buildMetricTile(
                    label: 'LAST MENSTRUAL PERIOD (LMP)',
                    value: lmpFormatted,
                    highlightColor: PdfColor.fromHex('#BE123C'),
                  ),
                  pw.SizedBox(width: 10),
                  _buildMetricTile(
                    label: 'AVERAGE CYCLE LENGTH',
                    value: '$avgLength Days',
                    subText: 'Norm: 21-35 days',
                    highlightColor: PdfColor.fromHex('#0F172A'),
                  ),
                  pw.SizedBox(width: 10),
                  _buildMetricTile(
                    label: 'BLEEDING DURATION',
                    value: '${cycle.periodDuration} Days',
                    subText: 'Norm: 3-7 days',
                    highlightColor: PdfColor.fromHex('#0F172A'),
                  ),
                  pw.SizedBox(width: 10),
                  _buildMetricTile(
                    label: 'FIGO REGULARITY STATUS',
                    value: isClinicallyIrregular ? 'IRREGULAR' : 'REGULAR',
                    subText: isClinicallyIrregular ? 'Suspected Oligo/PCOS' : 'Normal variation',
                    highlightColor: isClinicallyIrregular
                        ? PdfColor.fromHex('#DC2626')
                        : PdfColor.fromHex('#16A34A'),
                  ),
                ],
              ),

              pw.SizedBox(height: 14),

              // ─── Forecast & Medication Section ───
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F8FAFC'),
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'PREDICTED NEXT PERIOD: $nextPeriodFormatted',
                          style: pw.TextStyle(
                            fontSize: 9.5,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#334155'),
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Estimated Ovulation Window: $ovulationFormatted',
                          style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Contraception (OCP): ${ocpState.isEnabled ? "${ocpState.pillBrand} (${ocpState.packDays}-day pack)" : "None recorded"}',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#475569'),
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Iron / Folic Acid: ${ironState.isEnabled ? ironState.supplementName : "Not currently active"}',
                          style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 14),

              // ─── Historical Cycles Table ───
              pw.Text(
                'Recent Menstrual Cycles Timeline (FIGO Log)',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#0F172A'),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColor.fromHex('#CBD5E1'), width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F1F5F9')),
                    children: [
                      _buildTableCell('Cycle Interval', isHeader: true),
                      _buildTableCell('Start Date', isHeader: true),
                      _buildTableCell('End Date', isHeader: true),
                      _buildTableCell('Cycle Length', isHeader: true),
                      _buildTableCell('Bleeding Days', isHeader: true),
                      _buildTableCell('Clinical Regularity', isHeader: true),
                    ],
                  ),
                  // Current active cycle
                  pw.TableRow(
                    children: [
                      _buildTableCell('Current Cycle'),
                      _buildTableCell(DateFormat('dd MMM yyyy').format(cycle.lastPeriodStartDate)),
                      _buildTableCell('In Progress'),
                      _buildTableCell('${cycle.cycleLength} Days'),
                      _buildTableCell('${cycle.periodDuration} Days'),
                      _buildTableCell(
                        cycle.isIrregularCycle ? 'Irregular / Flagged' : 'Normal',
                        textColor: cycle.isIrregularCycle
                            ? PdfColor.fromHex('#DC2626')
                            : PdfColor.fromHex('#16A34A'),
                      ),
                    ],
                  ),
                  // Past cycles
                  ...cycleHistory.take(5).map((entry) {
                    final startStr = DateFormat('dd MMM yyyy').format(entry.startDate);
                    final endStr = entry.endDate != null
                        ? DateFormat('dd MMM yyyy').format(entry.endDate!)
                        : 'N/A';
                    return pw.TableRow(
                      children: [
                        _buildTableCell(entry.id),
                        _buildTableCell(startStr),
                        _buildTableCell(endStr),
                        _buildTableCell('${entry.cycleLength} Days'),
                        _buildTableCell('${entry.periodDuration} Days'),
                        _buildTableCell(
                          entry.isIrregular ? 'Irregular (<21 or >35d)' : 'Normal Range',
                          textColor: entry.isIrregular
                              ? PdfColor.fromHex('#DC2626')
                              : PdfColor.fromHex('#16A34A'),
                        ),
                      ],
                    );
                  }),
                ],
              ),

              pw.SizedBox(height: 14),

              // ─── Dysmenorrhea & Logged Symptoms Profile ───
              pw.Text(
                'Symptom & Dysmenorrhea (Pain Severity) Profile',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#0F172A'),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Pain / Cramp Logs:',
                            style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            '• Severe Cramps: $severeCrampsCount episodes recorded',
                            style: pw.TextStyle(
                              fontSize: 8.5,
                              color: severeCrampsCount > 0 ? PdfColor.fromHex('#DC2626') : PdfColors.grey800,
                            ),
                          ),
                          pw.Text(
                            '• Moderate Cramps: $moderateCrampsCount episodes recorded',
                            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                          ),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Most Frequent Logged Symptoms:',
                            style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 3),
                          if (topSymptoms.isEmpty)
                            pw.Text('No specific physical symptoms recorded',
                                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600))
                          else
                            ...topSymptoms.take(4).map((e) => pw.Text(
                                  '• ${e.key}: ${e.value} time(s)',
                                  style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                                )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // ─── Doctor / Clinical Notes Box ───
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F8FAFC'),
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1')),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'CLINICIAN / GYNECOLOGIST CLINICAL NOTES & PRESCRIPTION:',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#475569'),
                      ),
                    ),
                    pw.SizedBox(height: 24),
                  ],
                ),
              ),

              pw.SizedBox(height: 8),
              pw.Text(
                'Note: This document provides tracked self-reported observations from RxDigi for assisting medical review. It does not replace clinical ultrasound or hormonal pathology tests.',
                style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildMetricTile({
    required String label,
    required String value,
    String? subText,
    required PdfColor highlightColor,
  }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#F8FAFC'),
          borderRadius: pw.BorderRadius.circular(6),
          border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: highlightColor,
              ),
            ),
            if (subText != null) ...[
              pw.SizedBox(height: 2),
              pw.Text(
                subText,
                style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    PdfColor textColor = PdfColors.black,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8.5,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColor.fromHex('#1E293B') : textColor,
        ),
      ),
    );
  }

  /// Print directly via system print dialog
  static Future<void> printReport({
    required MenstrualCycleModel cycle,
    required List<HistoricalCycleEntry> cycleHistory,
    required Map<String, DailySymptomLog> symptomsMap,
    required OCPTrackerState ocpState,
    required IronSupplementState ironState,
  }) async {
    final pdfBytes = await generateReportBytes(
      cycle: cycle,
      cycleHistory: cycleHistory,
      symptomsMap: symptomsMap,
      ocpState: ocpState,
      ironState: ironState,
    );
    await Printing.layoutPdf(
      onLayout: (_) async => pdfBytes,
      name: 'RxDigi_Women_Health_Report_${DateFormat("yyyyMMdd").format(DateTime.now())}',
    );
  }

  /// Share PDF to WhatsApp, Mail, or save to disk
  static Future<void> shareReport({
    required MenstrualCycleModel cycle,
    required List<HistoricalCycleEntry> cycleHistory,
    required Map<String, DailySymptomLog> symptomsMap,
    required OCPTrackerState ocpState,
    required IronSupplementState ironState,
  }) async {
    final pdfBytes = await generateReportBytes(
      cycle: cycle,
      cycleHistory: cycleHistory,
      symptomsMap: symptomsMap,
      ocpState: ocpState,
      ironState: ironState,
    );
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'RxDigi_Women_Health_Report_${DateFormat("yyyyMMdd").format(DateTime.now())}.pdf',
    );
  }

  /// Generate a clean plain text copy for WhatsApp or SMS
  static String generatePlainTextSummary({
    required MenstrualCycleModel cycle,
    required List<HistoricalCycleEntry> cycleHistory,
    required OCPTrackerState ocpState,
    required IronSupplementState ironState,
    required bool isBn,
  }) {
    final lmp = WomenHealthFormatters.formatDayMonth(cycle.lastPeriodStartDate, isBn: isBn);
    final next = WomenHealthFormatters.formatDayMonth(cycle.nextPeriodDate, isBn: isBn);

    if (isBn) {
      return '''
📋 RxDigi গাইনোকোলজিক্যাল ও সাইকেল রিপোর্ট:
• শেষ পিরিয়ডের তারিখ (LMP): $lmp
• সাইকেলের গড় স্থায়িত্ব: ${cycle.cycleLength} দিন
• ব্লিডিং সময়কাল: ${cycle.periodDuration} দিন
• সম্ভাব্য পরবর্তী পিরিয়ড: $next
• সাইকেল স্ট্যাটাস: ${cycle.cycleRegularityDescription(true)}
• জন্মনিয়ন্ত্রণ পিল (OCP): ${ocpState.isEnabled ? "${ocpState.pillBrand} (${ocpState.packDays} দিনের প্যাক)" : "না"}
• আয়রন সাপ্লিমেন্ট: ${ironState.isEnabled ? ironState.supplementName : "না"}
''';
    } else {
      return '''
📋 RxDigi Menstrual Health Clinical Summary:
• Last Menstrual Period (LMP): $lmp
• Cycle Length: ${cycle.cycleLength} days
• Bleeding Duration: ${cycle.periodDuration} days
• Next Predicted Period: $next
• Regularity Status: ${cycle.cycleRegularityDescription(false)}
• Contraception (OCP): ${ocpState.isEnabled ? "${ocpState.pillBrand} (${ocpState.packDays}-day pack)" : "None"}
• Iron Supplement: ${ironState.isEnabled ? ironState.supplementName : "None"}
''';
    }
  }
}

