import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Medicine schedule slots (morning / noon / night) with consistent
/// icon + colour, used everywhere instead of emojis.
class SlotStyle {
  final String key;
  final IconData icon;
  final Color color;

  const SlotStyle(this.key, this.icon, this.color);

  static final morning = SlotStyle('morning', PhosphorIconsRegular.sunHorizon, const Color(0xFFF59E0B));
  static final noon = SlotStyle('noon', PhosphorIconsRegular.sun, const Color(0xFFEA580C));
  static final night = SlotStyle('night', PhosphorIconsRegular.moonStars, const Color(0xFF4F46E5));

  static SlotStyle of(String key) {
    switch (key) {
      case 'morning':
        return morning;
      case 'noon':
        return noon;
      default:
        return night;
    }
  }
}

/// Small rounded icon used in section headers and slot labels.
class SlotIcon extends StatelessWidget {
  final SlotStyle style;
  final double size;
  const SlotIcon(this.style, {super.key, this.size = 16});

  @override
  Widget build(BuildContext context) => Icon(style.icon, size: size, color: style.color);
}
