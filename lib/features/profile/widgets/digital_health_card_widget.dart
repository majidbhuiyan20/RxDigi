import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/utils/app_feedback.dart';
import '../models/user_health_profile_model.dart';

class DigitalHealthCardWidget extends StatelessWidget {
  final UserHealthProfileModel profile;
  final VoidCallback? onEdit;
  final VoidCallback? onShare;

  const DigitalHealthCardWidget({
    super.key,
    required this.profile,
    this.onEdit,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppFeedback.playLight();
        onEdit?.call();
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF022C22), // Deepest Emerald Obsidian
              Color(0xFF064E3B),
              Color(0xFF0F766E),
              Color(0xFF042F2E),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: const Color(0xFF2DD4BF).withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF022C22).withValues(alpha: 0.45),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: const Color(0xFF2DD4BF).withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: Stack(
            children: [
              // ─── Subtle Medical Wave Guilloche Watermark ───
              Positioned(
                right: -40,
                bottom: -30,
                child: Opacity(
                  opacity: 0.07,
                  child: Icon(
                    PhosphorIconsFill.heartbeat,
                    size: 240,
                    color: Colors.white,
                  ),
                ),
              ),

              // ─── Card Content ───
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Brand Hologram + Chip & Contactless
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // RxDigi Clinical Seal
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    PhosphorIconsFill.shieldCheck,
                                    size: 14,
                                    color: Color(0xFF5EEAD4),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'RxDigi HEALTH ID',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10.5,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Emergency Pass Chip
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
                              ),
                              child: const Text(
                                'EMERGENCY PASS',
                                style: TextStyle(
                                  color: Color(0xFFFCA5A5),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 8.5,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Contactless NFC Wave Icon
                        Transform.rotate(
                          angle: 1.57,
                          child: const Icon(
                            PhosphorIconsBold.wifiHigh,
                            color: Colors.white70,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Middle Row: Gold Smart Chip Graphic & Blood Group Ruby Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Smart EMV Chip Graphic
                        _buildGoldEmvChip(),

                        // Blood Group Badge (Highlighted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFDC2626).withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: Border.all(color: const Color(0xFFFCA5A5), width: 1.2),
                          ),
                          child: Row(
                            children: [
                              const Icon(PhosphorIconsFill.drop, size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                '${profile.bloodGroup} Positive',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Cardholder Name
                    Text(
                      profile.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Health Card Number & Demographics
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          profile.cardId,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          '${profile.age} বছর • ${profile.gender}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Divider
                    Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    const SizedBox(height: 12),

                    // Bottom Row: Emergency ICE & Edit Hint
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              PhosphorIconsFill.phoneCall,
                              size: 13,
                              color: Color(0xFFF87171),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ICE: ${profile.emergencyContact} (${profile.emergencyRelation})',
                              style: const TextStyle(
                                color: Color(0xFFFEE2E2),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        // Edit Action Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(PhosphorIconsBold.pencilSimple, size: 11, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'এডিট',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a metallic gold EMV smart chip graphic
  Widget _buildGoldEmvChip() {
    return Container(
      width: 44,
      height: 32,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFDE68A), // Metallic Light Gold
            Color(0xFFD97706), // Deep Amber Gold
            Color(0xFFF59E0B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFB45309), width: 0.8),
      ),
      child: Stack(
        children: [
          // Center microcircuit lines
          Center(
            child: Container(
              width: 24,
              height: 16,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF92400E).withValues(alpha: 0.7), width: 0.7),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Positioned(
            left: 21,
            top: 0,
            bottom: 0,
            child: Container(width: 1, color: const Color(0xFF92400E).withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}

