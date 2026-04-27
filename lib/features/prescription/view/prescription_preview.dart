import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/app/app_routes.dart';
import 'package:rxdigi/app/app_text_style.dart';
import 'package:rxdigi/l10n/app_localizations.dart';

class PrescriptionPreview extends StatelessWidget {
  const PrescriptionPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = MediaQuery.of(context).size.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Prescription Preview'),
        backgroundColor: const Color(0xFF0D3592),
      ),
      body: Container(
        color: AppColors.appBackgroundColor,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Prescription Layout',
                  style: AppTextStyles.largeBlackTextStyle(context)
                      .copyWith(color: AppColors.primaryColor),
                ),
                SizedBox(height: 8),
                Text(
                  'This information will be displayed on every prescription',
                  style: AppTextStyles.smallGreyTextStyle(context),
                ),
                SizedBox(height: 24),
                
                // Prescription Preview Card
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.borderColor,
                      width: isDesktop ? 2 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header
                      Text(
                        '℞ PRESCRIPTION',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      Divider(
                        color: AppColors.borderColor,
                        thickness: 1.5,
                        height: 20,
                      ),
                      
                      // Doctor Info Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Doctor Name
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Dr. [Full Name]\n',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          
                          // Qualifications
                          Text(
                            'MD (Internal Medicine), MRCP(UK)',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          
                          // Specialization
                          Text(
                            'Specialization: Cardiology',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          
                          // BMDC Number
                          Text(
                            'BMDC Reg No: A-XXXXX',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 12),
                          
                          Divider(
                            color: AppColors.borderColor,
                            thickness: 1,
                          ),
                          SizedBox(height: 12),
                          
                          // Chamber Info
                          Text(
                            'Chamber: Dhaka Medical College Hospital',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          
                          Text(
                            'Phone: +880XXXXXXXXXX',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          
                          Text(
                            'Email: doctor@email.com',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          
                          Text(
                            'Consulting Hours: 09:00 AM - 05:00 PM',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 20),
                      Divider(
                        color: AppColors.borderColor,
                        thickness: 1.5,
                        height: 20,
                      ),
                      
                      // Space for medicines
                      SizedBox(height: 16),
                      Text(
                        'Medicines will be listed here',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 40),
                      
                      // Signature
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          children: [
                            Text(
                              '_____________',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Dr. Signature',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Info Text
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0XFFD7EBFE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your doctor information has been saved successfully. You can now start creating prescriptions.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: AppColors.primaryColor,
                            width: 1.5,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Edit Information',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to home screen
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.homeScreenRoute,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Create Prescription',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
