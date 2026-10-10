import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../app/app_colors.dart';

/// Central theme & color design system for Health Tips feature.
/// Modifying colors or styles here will instantly cascade across the entire Tips UI.
class TipsTheme {
  // Brand & Shell Colors
  static const Color primary = AppColors.primaryColor;
  static const Color background = Color(0xFFF8FAFC);
  static const Color cardBackground = Colors.white;
  static const Color border = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Feature Section Badges & Tints
  static const Color quickHackColor = Color(0xFFD97706); // Warm Amber
  static const Color quickHackBg = Color(0xFFFFFBEB);
  static const Color quickHackBorder = Color(0xFFFDE68A);

  static const Color mythColor = Color(0xFF7C3AED); // Modern Violet
  static const Color mythBg = Color(0xFFF5F3FF);
  static const Color mythBorder = Color(0xFFDDD6FE);

  static const Color doColor = Color(0xFF059669); // Emerald Green
  static const Color doBg = Color(0xFFECFDF5);
  static const Color doBorder = Color(0xFFA7F3D0);

  static const Color dontColor = Color(0xFFDC2626); // Rose Red
  static const Color dontBg = Color(0xFFFEF2F2);
  static const Color dontBorder = Color(0xFFFECACA);

  static const Color remedyColor = Color(0xFF0D9488); // Teal
  static const Color remedyBg = Color(0xFFF0FDFA);
  static const Color remedyBorder = Color(0xFF99F6E4);

  static const Color doctorWarningColor = Color(0xFFB91C1C); // Deep Red
  static const Color doctorWarningBg = Color(0xFFFFF1F2);
  static const Color doctorWarningBorder = Color(0xFFFECDD3);

  // Category Color Palette
  static const Map<String, Color> _categoryColors = {
    'stomach': Color(0xFFEA580C),       // Orange
    'brain': Color(0xFF4F46E5),         // Indigo
    'eyes': Color(0xFF0284C7),          // Sky Blue
    'hair': Color(0xFF9333EA),          // Purple
    'skin': Color(0xFFE11D48),          // Rose Pink
    'heart': Color(0xFFDC2626),         // Crimson Red
    'bone': Color(0xFF475569),          // Slate
    'bones': Color(0xFF475569),         // Slate
    'ent': Color(0xFF0D9488),           // Teal
    'mouth': Color(0xFF0D9488),         // Teal
    'kidney': Color(0xFF0891B2),        // Cyan
    'kidneys': Color(0xFF0891B2),       // Cyan
    'feet': Color(0xFF6D28D9),          // Violet
    'hands_feet': Color(0xFF6D28D9),    // Violet
    'emergency': Color(0xFFB91C1C),     // Deep Red
    'lifestyle': Color(0xFF059669),     // Emerald
    'pancreas': Color(0xFF059669),      // Emerald
    'women': Color(0xFFBE185D),         // Deep Pink
    'fitness': Color(0xFF16A34A),       // Vibrant Green
  };

  /// Returns themed category color
  static Color getColor(String key) {
    final lower = key.toLowerCase();
    for (final entry in _categoryColors.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return primary;
  }

  /// Returns light background tint for category chip/badge
  static Color getLightBg(String key) {
    return getColor(key).withValues(alpha: 0.10);
  }

  /// Returns Phosphor IconData for a body part or category
  static IconData getIcon(String key) {
    final lower = key.toLowerCase();
    if (lower.contains('stomach') || lower.contains('gas') || lower.contains('হজম')) {
      return PhosphorIconsRegular.fire;
    } else if (lower.contains('brain') || lower.contains('sleep') || lower.contains('মাথা') || lower.contains('ঘুম')) {
      return PhosphorIconsRegular.brain;
    } else if (lower.contains('eye') || lower.contains('চোখ')) {
      return PhosphorIconsRegular.eye;
    } else if (lower.contains('hair') || lower.contains('চুল')) {
      return PhosphorIconsRegular.sparkle;
    } else if (lower.contains('skin') || lower.contains('ত্বক')) {
      return PhosphorIconsRegular.drop;
    } else if (lower.contains('heart') || lower.contains('হার্ট') || lower.contains('রক্তচাপ')) {
      return PhosphorIconsRegular.heartbeat;
    } else if (lower.contains('bone') || lower.contains('joint') || lower.contains('হাড়') || lower.contains('কোমর')) {
      return PhosphorIconsRegular.personSimpleWalk;
    } else if (lower.contains('ent') || lower.contains('mouth') || lower.contains('ear') || lower.contains('oral') || lower.contains('দাঁত')) {
      return PhosphorIconsRegular.smiley;
    } else if (lower.contains('kidney') || lower.contains('water') || lower.contains('পানি')) {
      return PhosphorIconsRegular.dropHalfBottom;
    } else if (lower.contains('feet') || lower.contains('hand') || lower.contains('nail') || lower.contains('পা') || lower.contains('নখ')) {
      return PhosphorIconsRegular.footprints;
    } else if (lower.contains('emergency') || lower.contains('aid') || lower.contains('জরুরি')) {
      return PhosphorIconsRegular.firstAid;
    } else if (lower.contains('lifestyle') || lower.contains('pancreas') || lower.contains('diabetes') || lower.contains('জীবনধারা')) {
      return PhosphorIconsRegular.scales;
    } else if (lower.contains('women') || lower.contains('নারী') || lower.contains('মাতৃত্ব')) {
      return PhosphorIconsRegular.flowerLotus;
    } else if (lower.contains('fitness') || lower.contains('ব্যায়াম') || lower.contains('posture')) {
      return PhosphorIconsRegular.personSimpleWalk;
    }
    return PhosphorIconsRegular.heartStraight;
  }
}

