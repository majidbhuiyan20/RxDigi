import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';


class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.onTap, required this.title,
  });

  final VoidCallback onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0XFF1D6DD9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(title, style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),),
      ),
    );
  }
}