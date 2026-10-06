import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';

class CardSectionTitle extends StatelessWidget {
  const CardSectionTitle({
    super.key, required this.title,
  });
  final String title;


  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: TextStyle(color: AppColors.textBlackColor, fontFamily: "PlusJakartaSans", fontWeight: FontWeight.w700, fontSize: 16),),
        Spacer(),
        Text("*", style: TextStyle(color: Colors.red, fontSize: 28),),

      ],
    );
  }
}