import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdigi/features/doctor_info/widgets/card_section_title.dart';
import 'package:rxdigi/features/doctor_info/widgets/card_title_section.dart';
import 'package:rxdigi/features/doctor_info/widgets/personal_info_section.dart';
import 'package:rxdigi/features/doctor_info/widgets/selectable_title_chip.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_style.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/profile_image_section.dart';

class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  _DottedBorderPainter({
    required this.color,
    this.strokeWidth = 2,
    this.dashWidth = 5,
    this.dashSpace = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(30));

    _drawDottedBorder(canvas, paint, rRect);
  }

  void _drawDottedBorder(Canvas canvas, Paint paint, RRect rRect) {
    const radius = 30.0;
    final pathMetrics = _createDottedPath(rRect).computeMetrics();

    for (var metric in pathMetrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final segment = metric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  Path _createDottedPath(RRect rRect) {
    final path = Path();
    path.addRRect(rRect);
    return path;
  }

  @override
  bool shouldRepaint(_DottedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}

class Step2Qualification extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step2Qualification({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<Step2Qualification> createState() => _Step2QualificationState();
}

class _Step2QualificationState extends State<Step2Qualification> {
  final List<String> customDegrees = [];
  final TextEditingController _degreeController = TextEditingController();
  late final AppLocalizations l10n;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    l10n = AppLocalizations.of(context)!;
  }

  @override
  void dispose() {
    _degreeController.dispose();
    super.dispose();
  }

  void _showAddCustomDegreeDialog() {
    _degreeController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Custom Degree"),
        content: TextField(
          controller: _degreeController,
          decoration: InputDecoration(
            hintText: "Enter degree name (e.g., MD, PhD)",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              if (_degreeController.text.isNotEmpty) {
                setState(() {
                  customDegrees.add(_degreeController.text);
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final isDesktop   = MediaQuery.of(context).size.width > 600;
    return SizedBox.expand(
      child: Container(
        color:  AppColors.appBackgroundColor,
        child: Padding(
          padding:  EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.educationAndSpecialization, style: AppTextStyles.largeBlackTextStyle(context),),
                Text(l10n.provideYourDegreeInfo, style: AppTextStyles.smallGreyTextStyle(context),),
                SizedBox(height: 16,),
                 Container(
                   padding: EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(12),
                     border: Border.all(
                       color: AppColors.borderColor,
                       width: isDesktop ? 3 : 1.5,
                     )
                   ),
                   child: Column(
                     children: [
                       CardTitleSection(icon: Icons.school_rounded, title: l10n.degrees),
                       SizedBox(height: 4,),
                       CardSectionTitle(title: l10n.selectPrimaryDegree),
                       SizedBox(height: 12),

                       Wrap(
                         spacing: 16,
                         runSpacing: 16,
                         children: [
                           SelectableTitleChip(title: "MBBS", multiProvider: selectedTitlesProvider),
                           SelectableTitleChip(title: "BCS", multiProvider: selectedTitlesProvider),
                           SelectableTitleChip(title: "FCPS", multiProvider: selectedTitlesProvider),
                           SelectableTitleChip(title: "BDS", multiProvider: selectedTitlesProvider),
                           SelectableTitleChip(title: "BMMS", multiProvider: selectedTitlesProvider),
                           SelectableTitleChip(title: "BHMS", multiProvider: selectedTitlesProvider),
                           SelectableTitleChip(title: "MBChB", multiProvider: selectedTitlesProvider),
                           // Custom degrees chips
                           ...customDegrees.map((degree) => SelectableTitleChip(title: degree, multiProvider: selectedTitlesProvider)),
                           // Add custom degree button
                           GestureDetector(
                             onTap: _showAddCustomDegreeDialog,
                             child: CustomPaint(
                               painter: _DottedBorderPainter(
                                 color: Colors.black87,
                                 strokeWidth: 1.5,
                               ),
                               child: Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                 decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(30),
                                   color: Colors.white,
                                 ),
                                 child: Text(
                                   "+ Custom",
                                   style: TextStyle(
                                     color: Colors.black87,
                                     fontSize: 14,
                                     fontWeight: FontWeight.w500,
                                   ),
                                 ),
                               ),
                             ),
                           ),
                         ],
                       )


                     ],
                   ),
                 ),
                 SizedBox(height: 60,),

              ],
            ),
          ),
        ),
      ),
    );
  }
}