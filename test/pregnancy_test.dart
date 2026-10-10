import 'package:flutter_test/flutter_test.dart';
import 'package:prescripto/features/women_health/models/pregnancy_model.dart';

void main() {
  group('PregnancyModel Calculations', () {
    test('Calculates correct gestational weeks, days and trimester from LMP', () {
      final now = DateTime.now();
      // Suppose LMP was 70 days ago (10 weeks)
      final lmp = now.subtract(const Duration(days: 70));
      final pregnancy = PregnancyModel.fromLmp(lmp);

      expect(pregnancy.currentWeek, 11); // (70/7).floor() + 1 = 11th week
      expect(pregnancy.currentDayOfWeek, 1);
      expect(pregnancy.currentTrimester, PregnancyTrimester.first);
      expect(pregnancy.progressFraction, greaterThan(0.2));
    });

    test('Calculates EDD as LMP + 280 days', () {
      final lmp = DateTime(2026, 1, 1);
      final pregnancy = PregnancyModel.fromLmp(lmp);

      final expectedEdd = lmp.add(const Duration(days: 280));
      expect(pregnancy.estimatedDueDate.year, expectedEdd.year);
      expect(pregnancy.estimatedDueDate.month, expectedEdd.month);
      expect(pregnancy.estimatedDueDate.day, expectedEdd.day);
    });

    test('PregnancyWeekInfo json serialization works accurately', () {
      final json = {
        'week': 14,
        'fruitEmoji': '🍋',
        'fruitNameBn': 'একটি পাকা লেবুর সমান',
        'fruitNameEn': 'a ripe Lemon',
        'lengthCm': 8.7,
        'weightGrams': 43.0,
        'babyDevelopmentBn': 'শিশুর অঙ্গপ্রত্যঙ্গ দ্রুত বাড়ছে',
        'babyDevelopmentEn': 'Rapid fetal development',
        'motherChangesBn': 'পেট বড় হচ্ছে',
        'motherChangesEn': 'Bump is growing',
        'careTipBn': 'আরামদায়ক জুতো পরুন',
        'careTipEn': 'Wear comfy shoes',
        'notificationTextBn': '১৪তম সপ্তাহ শুরু',
        'notificationTextEn': 'Week 14 has begun',
      };
      final item = PregnancyWeekInfo.fromJson(json);
      expect(item.week, 14);
      expect(item.fruitEmoji, '🍋');
      expect(item.fruitNameBn, 'একটি পাকা লেবুর সমান');
      expect(item.lengthCm, 8.7);
      expect(item.weightGrams, 43.0);
      expect(item.toJson()['week'], 14);
    });

    test('PregnancyWeekCatalog handles boundary weeks', () {
      final week4 = PregnancyWeekCatalog.getWeekInfo(4);
      expect(week4.week, 4);
      final week40 = PregnancyWeekCatalog.getWeekInfo(40);
      expect(week40.week, 40);
      final clampedLow = PregnancyWeekCatalog.getWeekInfo(1);
      expect(clampedLow.week, 4);
      final clampedHigh = PregnancyWeekCatalog.getWeekInfo(45);
      expect(clampedHigh.week, 40);
    });
  });
}
