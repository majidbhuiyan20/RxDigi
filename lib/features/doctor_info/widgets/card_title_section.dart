import 'package:flutter/material.dart';

import '../../../app/app_text_style.dart';
import '../../../l10n/app_localizations.dart';

class CardTitleSection extends StatelessWidget {
  const CardTitleSection({
    super.key,
    required this.l10n,
  });

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.camera_alt, size: 24),
        SizedBox(width: 12),
        Text(
          l10n.profileImage,
          style: AppTextStyles.primaryTextStyle,
        ),
        SizedBox(width: 12),

        Expanded(
          child: Divider(
            thickness: 2,
            color: Color(0XFFDBE2ED),
          ),
        ),
      ],
    );
  }
}