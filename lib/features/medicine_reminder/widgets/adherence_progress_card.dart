import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../app/app_colors.dart';

class AdherenceProgressCard extends StatelessWidget {
  final int activeCount;
  final int takenCount;
  final int totalCount;
  final double progress;
  final bool isBn;

  const AdherenceProgressCard({
    super.key,
    required this.activeCount,
    required this.takenCount,
    required this.totalCount,
    required this.progress,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final percentInt = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F766E), // Deep Clinical Teal
            Color(0xFF0D9488), // Vibrant Teal
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withValues(alpha: 0.22),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(PhosphorIconsFill.checkCircle, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn ? 'আজকের ঔষধ গ্রহণের অগ্রগতি' : "Today's Adherence",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      isBn
                          ? '$totalCount টি ডোজের মধ্যে $takenCount টি গ্রহণ সম্পন্ন ($percentInt%)'
                          : '$takenCount of $totalCount doses taken today ($percentInt%)',
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBn ? 'মোট সক্রিয় ঔষধ: $activeCount টি' : 'Active prescriptions: $activeCount',
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Text(
                percentInt == 100
                    ? (isBn ? '🎉 সকল ডোজ সম্পন্ন!' : '🎉 All Done!')
                    : (isBn ? 'সময়মত ঔষধ গ্রহণ করুন' : 'Keep it up!'),
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
