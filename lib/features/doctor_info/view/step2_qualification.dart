import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdigi/features/doctor_info/widgets/card_section_title.dart';
import 'package:rxdigi/features/doctor_info/widgets/card_title_section.dart';
import 'package:rxdigi/features/doctor_info/widgets/cutom_textfield_widgets.dart';
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
  final List<String> customPrimaryDegrees = [];
  final List<String> customHigherDegrees = [];
  final TextEditingController _degreeController = TextEditingController();
  late final AppLocalizations l10n;
  
  // Specialization dropdown
  String? selectedSpecialization;
  final List<String> specializations = [
    'Cardiology',
    'Dermatology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
    'Psychiatry',
    'Radiology',
    'Surgery',
    'General Practice',
    'Internal Medicine',
  ];

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

  void _showAddCustomDegreeDialog({required bool isPrimary}) {
    _degreeController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isPrimary ? "Add Custom Primary Degree" : "Add Custom Higher Degree"),
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
                  if (isPrimary) {
                    customPrimaryDegrees.add(_degreeController.text);
                  } else {
                    customHigherDegrees.add(_degreeController.text);
                  }
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
                           ...customPrimaryDegrees.map((degree) => SelectableTitleChip(title: degree, multiProvider: selectedTitlesProvider)),
                           // Add custom degree button
                           GestureDetector(
                             onTap: () => _showAddCustomDegreeDialog(isPrimary: true),
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
                                   "+ Others",
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
                       ),

                       SizedBox(height: 16,),
                     Row(
                       children: [
                         Text("Higher Degree", style: TextStyle(color: AppColors.textBlackColor, fontFamily: "PlayfairDisplay", fontWeight: FontWeight.w700, fontSize: 16),),
                         Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(0XFFEEF2F8),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text("Select Multiple", style: TextStyle(fontWeight: FontWeight.w500, fontFamily: AppTextStyles.playfair),),
                        )

                       ],
                     ),
                       SizedBox(height: 12),
                       Wrap(
                         spacing: 16,
                         runSpacing: 16,
                         children: [
                           SelectableTitleChip(title: "MD", multiProvider: selectedTitlesProvider),
                           SelectableTitleChip(title: "MS", multiProvider: selectedTitlesProvider),
                           SelectableTitleChip(title: "MRCP", multiProvider: selectedTitlesProvider),
                           SelectableTitleChip(title: "FRCP", multiProvider: selectedTitlesProvider),
                           SelectableTitleChip(title: "PhD", multiProvider: selectedTitlesProvider),
                           SelectableTitleChip(title: "MPH", multiProvider: selectedTitlesProvider),
                           SelectableTitleChip(title: "DLO", multiProvider: selectedTitlesProvider),
                           // Custom degrees chips
                           ...customHigherDegrees.map((degree) => SelectableTitleChip(title: degree, multiProvider: selectedTitlesProvider)),
                           // Add custom degree button
                           GestureDetector(
                             onTap: () => _showAddCustomDegreeDialog(isPrimary: false),
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
                       ),




                     ],
                   ),
                 ),
                 SizedBox(height: 20,),

                /// Specialization Section

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
                      CardTitleSection(icon: Icons.local_hospital, title: "Specialization"),
                      SizedBox(height: 4,),
                      CardSectionTitle(title: "Specialization"),
                      SizedBox(height: 12),
                      
                      // Specialization Dropdown
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedSpecialization != null 
                              ? AppColors.borderColor 
                              : AppColors.borderColor,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          child: DropdownButton<String>(
                            value: selectedSpecialization,
                            hint: Row(
                              children: [
                                Icon(Icons.local_hospital, color: Colors.grey[400], size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  'Select Specialization',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            isExpanded: true,
                            underline: const SizedBox(),
                            icon: Icon(Icons.expand_more, color: Colors.grey[600]),
                            items: specializations.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: AppColors.borderColor, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      value,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedSpecialization = newValue;
                              });
                            },
                            selectedItemBuilder: (BuildContext context) {
                              return specializations.map((String value) {
                                return Row(
                                  children: [
                                    Icon(Icons.local_hospital, 
                                      color: AppColors.borderColor, 
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      value,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList();
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 16,),
                      Row(
                        children: [
                          Text("Sub-Speciality", style: TextStyle(color: AppColors.textBlackColor, fontFamily: "PlayfairDisplay", fontWeight: FontWeight.w700, fontSize: 16)),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Color(0XFFEEF2F8),
                              borderRadius: BorderRadius.circular(30),
                            
                            ),
                            child: Text("Optional", style: TextStyle(fontWeight: FontWeight.w500, fontFamily: "PlusJakartaSans", fontSize: 16,),),

                          )
                        ],
                      ),
                      SizedBox(height: 16,),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: "EX: Interventional Cardiology",
                          hintStyle: TextStyle(
                            color: AppColors.textGreyColor.withOpacity(0.7),
                            fontSize: 16,
                          ),

                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.borderColor),
                          ),
                        ),
                      ),
                      SizedBox(height: 16,),
                      CardSectionTitle(title: "Experience"),
                      SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SelectableTitleChip(title: "1-3 Years", singleProvider: selectedExperienceProvider),
                          SelectableTitleChip(title: "3-5 Years", singleProvider: selectedExperienceProvider),
                          SelectableTitleChip(title: "5-10 Years", singleProvider: selectedExperienceProvider),
                          SelectableTitleChip(title: "10-20 Years", singleProvider: selectedExperienceProvider),
                          SelectableTitleChip(title: "20+ Years", singleProvider: selectedExperienceProvider),


                        ],
                      ),
                      SizedBox(height: 16,)



                    ],
                  ),

                ),
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
                  CardTitleSection(icon: Icons.speaker, title: "Educational Institution"),
                  SizedBox(height: 4,),
                  CardSectionTitle(title: "Enter College Name(MBBS)"),
                  SizedBox(height: 12),
                  CustomTextFieldWidgets(
                    hintText: "Ex: Dhaka Medical College",
                    prefixIcon: Icons.school,
                  ),
                  SizedBox(height: 16),
                  CardSectionTitle(title: "Passing Year"),
                  SizedBox(height: 12),
                  CustomTextFieldWidgets(
                    hintText: "Ex: 2015",
                    prefixIcon: Icons.calendar_today,
                  ),
                  SizedBox(height: 12),]))



              ],
            ),
          ),
        ),
      ),
    );
  }
}