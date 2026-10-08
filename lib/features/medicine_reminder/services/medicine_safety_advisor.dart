import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SafetyAdvice {
  final String badgeTextBn;
  final String badgeTextEn;
  final String fullAdviceBn;
  final String fullAdviceEn;
  final Color themeColor;
  final IconData icon;

  const SafetyAdvice({
    required this.badgeTextBn,
    required this.badgeTextEn,
    required this.fullAdviceBn,
    required this.fullAdviceEn,
    required this.themeColor,
    required this.icon,
  });
}

class MedicineSafetyAdvisor {
  MedicineSafetyAdvisor._();

  static SafetyAdvice? getAdvice(String medicineName, [String? genericOrForm]) {
    final text = '${medicineName.toLowerCase()} ${genericOrForm?.toLowerCase() ?? ""}';

    // 1. PPIs / Acid Reducers
    if (text.contains('omeprazole') ||
        text.contains('seclo') ||
        text.contains('sergel') ||
        text.contains('nexum') ||
        text.contains('pantonix') ||
        text.contains('finix') ||
        text.contains('pantoprazole') ||
        text.contains('esomeprazole') ||
        text.contains('rabeprazole') ||
        text.contains('losectil') ||
        text.contains('maxpro')) {
      return const SafetyAdvice(
        badgeTextBn: 'খাবার ৩০ মি. পূর্বে',
        badgeTextEn: '30m before meal',
        fullAdviceBn: 'সর্বোত্তম কার্যকারিতার জন্য সকালের নাস্তার ৩০-৪৫ মিনিট আগে এক গ্লাস স্বাভাবিক পানিসহ সেব্য।',
        fullAdviceEn: 'For optimal gastric absorption, take with water 30-45 minutes before meals.',
        themeColor: Color(0xFFD97706),
        icon: PhosphorIconsFill.clockCountdown,
      );
    }

    // 2. Antibiotics
    if (text.contains('azithromycin') ||
        text.contains('cefixime') ||
        text.contains('cipro') ||
        text.contains('zimax') ||
        text.contains('cef-3') ||
        text.contains('moxaclav') ||
        text.contains('amoxicillin') ||
        text.contains('ciprocin') ||
        text.contains('ceftriaxone')) {
      return const SafetyAdvice(
        badgeTextBn: 'কোর্স সম্পন্ন করুন',
        badgeTextEn: 'Complete course',
        fullAdviceBn: 'সুস্থ বোধ করলেও ডাক্তারের পুরো কোর্স শেষ করুন। দুধ বা দুগ্ধজাত খাবার গ্রহণের অন্তত ২ ঘণ্টা ব্যবধান রাখুন।',
        fullAdviceEn: 'Complete full prescribed course to prevent antibiotic resistance. Avoid dairy within 2 hours.',
        themeColor: Color(0xFF7C3AED),
        icon: PhosphorIconsFill.shieldCheck,
      );
    }

    // 3. NSAIDs / Painkillers
    if (text.contains('aceclofenac') ||
        text.contains('naproxen') ||
        text.contains('ibuprofen') ||
        text.contains('diclofenac') ||
        text.contains('flexi') ||
        text.contains('anaflex') ||
        text.contains('ketorolac') ||
        text.contains('paracetamol') ||
        text.contains('napa') ||
        text.contains('ace')) {
      return const SafetyAdvice(
        badgeTextBn: 'ভরা পেটে সেব্য',
        badgeTextEn: 'Take with food',
        fullAdviceBn: 'খালি পেটে ব্যথানাশক ওষুধ পরিহার করুন। পাকস্থলীর সুরক্ষায় পর্যাপ্ত খাবার খাওয়ার পর এক গ্লাস পানিসহ সেব্য।',
        fullAdviceEn: 'Always take with food and plenty of water to protect gastric lining.',
        themeColor: Color(0xFFDC2626),
        icon: PhosphorIconsFill.forkKnife,
      );
    }

    // 4. Antidiabetics
    if (text.contains('metformin') ||
        text.contains('glimepiride') ||
        text.contains('sitagliptin') ||
        text.contains('comet') ||
        text.contains('secrin') ||
        text.contains('vildagliptin')) {
      return const SafetyAdvice(
        badgeTextBn: 'খাবারের শুরুতে',
        badgeTextEn: 'With first bite',
        fullAdviceBn: 'রক্তে গ্লুকোজের হঠাৎ হ্রাস রোধে প্রধান খাবার গ্রহণের ঠিক শুরুতে বা খাবার চলাকালীন সময়ে সেব্য।',
        fullAdviceEn: 'Take with or right after your main meal to prevent sudden hypoglycemia.',
        themeColor: Color(0xFF0284C7),
        icon: PhosphorIconsFill.drop,
      );
    }

    // 5. Antihypertensives (BP)
    if (text.contains('amlodipine') ||
        text.contains('losartan') ||
        text.contains('bisoprolol') ||
        text.contains('camlosart') ||
        text.contains('angilock') ||
        text.contains('olmesartan') ||
        text.contains('atenolol')) {
      return const SafetyAdvice(
        badgeTextBn: 'নির্দিষ্ট সময়ে',
        badgeTextEn: 'Fixed daily time',
        fullAdviceBn: 'রক্তচাপ স্থিতিশীল রাখতে প্রতিদিন নির্দিষ্ট সময়ে (সকালে বা রাতে) গ্রহণ করুন। হঠাৎ ওষুধ বন্ধ করবেন না।',
        fullAdviceEn: 'Take at a consistent time every day. Never stop blood pressure medication abruptly.',
        themeColor: Color(0xFF0F766E),
        icon: PhosphorIconsFill.heartbeat,
      );
    }

    // 6. Minerals & Supplements
    if (text.contains('calcium') ||
        text.contains('iron') ||
        text.contains('calbo') ||
        text.contains('ipec') ||
        text.contains('osteocare') ||
        text.contains('zinc')) {
      return const SafetyAdvice(
        badgeTextBn: '২ ঘণ্টা ব্যবধান',
        badgeTextEn: 'Separate 2 hrs',
        fullAdviceBn: 'ক্যালসিয়াম ও আয়রন ট্যাবলেট একসাথে খেলে শোষণ বাধাগ্রস্ত হয়। এদের মধ্যে অন্তত ২ ঘণ্টা ব্যবধান বজায় রাখুন।',
        fullAdviceEn: 'Take calcium and iron at least 2 hours apart to allow full mineral absorption.',
        themeColor: Color(0xFF0D9488),
        icon: PhosphorIconsFill.sparkle,
      );
    }

    return null;
  }
}

