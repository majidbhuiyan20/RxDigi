import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/menstrual_cycle_model.dart';

class DailyBodyForecastSection extends StatelessWidget {
  final CyclePhase phase;

  const DailyBodyForecastSection({
    super.key,
    required this.phase,
  });

  Map<String, dynamic> _getEnergyDetails() {
    switch (phase) {
      case CyclePhase.menstrual:
        return {
          'title': 'বিশ্রাম ও হালকা চলাচল',
          'desc': 'শক্তি কিছুটা কম থাকতে পারে। জিম বা ভারী দৌড়াদৌড়ি এড়িয়ে হালকা হাঁটাচলা ও স্ট্রেচিং করুন।',
          'icon': PhosphorIconsFill.batteryCharging,
          'color': const Color(0xFFE11D48),
        };
      case CyclePhase.follicular:
        return {
          'title': 'উচ্চ কর্মশক্তি ও প্রাণচাঞ্চল্য',
          'desc': 'শরীরে শক্তি দ্রুত বাড়ছে। নতুন কাজ শুরু করা, কার্ডিও বা স্ট্রেংথ ট্রেনিংয়ের সেরা সময়।',
          'icon': PhosphorIconsFill.lightning,
          'color': const Color(0xFFD97706),
        };
      case CyclePhase.fertileOvulation:
        return {
          'title': 'সর্বোচ্চ স্ট্যামিনা ও পিক পারফরম্যান্স',
          'desc': 'শরীরের শক্তি ও আত্মবিশ্বাস এই সময় শীর্ষে থাকে। যেকোনো চ্যালেঞ্জিং কাজের জন্য আদর্শ।',
          'icon': PhosphorIconsFill.fire,
          'color': const Color(0xFF8B5CF6),
        };
      case CyclePhase.luteal:
        return {
          'title': 'ধীরস্থির ও রিলাক্সিং মোড',
          'desc': 'প্রজেস্টেরন বাড়ায় দ্রুত ক্লান্তি আসতে পারে। যোগব্যায়াম, মেডিটেশন ও গভীর ঘুম নিশ্চিত করুন।',
          'icon': PhosphorIconsFill.moonStars,
          'color': const Color(0xFF0284C7),
        };
    }
  }

  Map<String, dynamic> _getSkinDetails() {
    switch (phase) {
      case CyclePhase.menstrual:
        return {
          'title': 'সংবেদনশীল ও শুষ্ক ত্বক',
          'desc': 'হরমোন কমে যাওয়ায় ত্বক শুষ্ক লাগতে পারে। পর্যাপ্ত পানি পান ও হাইড্রেটিং ময়েশ্চারাইজার লাগান।',
          'icon': PhosphorIconsFill.drop,
          'color': const Color(0xFF0D9488),
        };
      case CyclePhase.follicular:
        return {
          'title': 'সতেজ ও ফ্রেশ স্কিন',
          'desc': 'এস্ট্রোজেন বৃদ্ধিতে ত্বক স্বাভাবিকভাবে আর্দ্র ও স্বাস্থ্যোজ্জ্বল থাকে। ভারী মেকআপ ছাড়াই সুন্দর।',
          'icon': PhosphorIconsFill.sparkle,
          'color': const Color(0xFFEC4899),
        };
      case CyclePhase.fertileOvulation:
        return {
          'title': 'ন্যাচারাল পিক গ্লো (Peak Radiance)',
          'desc': 'রক্তসঞ্চালন সর্বোচ্চ থাকায় ত্বকে স্বাভাবিক আভা ফুটে ওঠে। এটি আপনার সবচেয়ে গ্লোয়িং সময়।',
          'icon': PhosphorIconsFill.sun,
          'color': const Color(0xFFF59E0B),
        };
      case CyclePhase.luteal:
        return {
          'title': 'ব্রণ বা তৈলাক্ততার ঝুঁকি',
          'desc': 'সেবাম উৎপাদন বেড়ে ব্রণ বা পিম্পল হতে পারে। নিয়মিত ফেসওয়াশ ও পরিচ্ছন্নতা বজায় রাখুন।',
          'icon': PhosphorIconsFill.shieldCheck,
          'color': const Color(0xFFBE185D),
        };
    }
  }

  Map<String, dynamic> _getFoodDetails() {
    switch (phase) {
      case CyclePhase.menstrual:
        return {
          'title': 'আয়রন ও ভিটামিন সি সমৃদ্ধ খাবার',
          'desc': 'রক্তের ঘাটতি পূরণে কচু শাক, কলিজা, ডাল, বেদানা ও কুসুম গরম পানি বিশেষ উপকারী।',
          'icon': PhosphorIconsFill.forkKnife,
          'color': const Color(0xFFB91C1C),
        };
      case CyclePhase.follicular:
        return {
          'title': 'প্রোটিন ও সবুজ শাকসবজি',
          'desc': 'ডিম, বাদাম, সবুজ সালাদ ও টক দই হরমোন ব্যালেন্স রক্ষা করতে চমৎকার সাহায্য করে।',
          'icon': PhosphorIconsFill.bowlFood,
          'color': const Color(0xFF059669),
        };
      case CyclePhase.fertileOvulation:
        return {
          'title': 'অ্যান্টিঅক্সিডেন্ট ও ওমেগা-৩',
          'desc': 'আখরোট, মাছ, বেরি ও রঙিন ফল খান। শরীরকে ডিটক্স রাখতে প্রতিদিন ৮-১০ গ্লাস পানি আবশ্যক।',
          'icon': PhosphorIconsFill.dropHalfBottom,
          'color': const Color(0xFF6D28D9),
        };
      case CyclePhase.luteal:
        return {
          'title': 'ম্যাগনেসিয়াম ও মিষ্টি নিয়ন্ত্রণ',
          'desc': 'চিনির লোভ সামলাতে ডার্ক চকলেট, কলা বা ড্রাই ফ্রুটস বেছে নিন। অতিরিক্ত চা-কফি পরিহার করুন।',
          'icon': PhosphorIconsFill.cookie,
          'color': const Color(0xFFD97706),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final energy = _getEnergyDetails();
    final skin = _getSkinDetails();
    final food = _getFoodDetails();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'আজকের শারীরিক ও লাইফস্টাইল ইনসাইট',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        _buildForecastCard(
          badgeLabel: 'শারীরিক শক্তি ও ব্যায়াম',
          title: energy['title'],
          desc: energy['desc'],
          icon: energy['icon'],
          color: energy['color'],
        ),
        const SizedBox(height: 10),
        _buildForecastCard(
          badgeLabel: 'ত্বক ও রূপচর্চা',
          title: skin['title'],
          desc: skin['desc'],
          icon: skin['icon'],
          color: skin['color'],
        ),
        const SizedBox(height: 10),
        _buildForecastCard(
          badgeLabel: 'পুষ্টি ও খাদ্যাভ্যাস',
          title: food['title'],
          desc: food['desc'],
          icon: food['icon'],
          color: food['color'],
        ),
      ],
    );
  }

  Widget _buildForecastCard({
    required String badgeLabel,
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      badgeLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

