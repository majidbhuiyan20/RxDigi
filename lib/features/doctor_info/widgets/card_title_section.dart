import 'package:flutter/material.dart';
import '../../../app/app_text_style.dart';

class CardTitleSection extends StatelessWidget {
  final IconData icon;
  final String title;

  const CardTitleSection({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.primaryTextStyle(context),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Divider(
            thickness: 2,
            color: Color(0XFFDBE2ED),
          ),
        ),
      ],
    );
  }
}