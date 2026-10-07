import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/today_medicine_card.dart';
import '../widgets/medicine_price_shortcut_card.dart';
import '../widgets/home_vitals_card.dart';
import '../widgets/featured_tip_card.dart';
import '../../habit_tracker/widgets/health_habit_home_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F9FD),
      body: Column(
        children: [
          // ─── 1. Welcoming Header (Greeting & Settings) ───
          HomeHeader(),

          // ─── 2. Scrollable Body ───
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Daily Medicine Routine & Adherence Checklist
                  TodayMedicineCard(),
                  SizedBox(height: 16),

                  // Medicine Price & Generic Alternative Finder Shortcut
                  MedicinePriceShortcutCard(),
                  SizedBox(height: 20),

                  // Daily habits and medicine adherence summary
                  HealthHabitHomeCard(),
                  SizedBox(height: 20),

                  // Personal Health Vitals (BP, Sugar, Weight)
                  HomeVitalsCard(),
                  SizedBox(height: 20),

                  // Daily Featured Bilingual Health Tip
                  FeaturedTipCard(),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
