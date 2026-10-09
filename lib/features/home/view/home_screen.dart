import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/today_medicine_card.dart';
import '../../weekly_wellness/widgets/weekly_scorecard_home_banner.dart';
import '../widgets/lifestyle_wellness_home_card.dart';
import '../../habit_tracker/widgets/health_habit_home_card.dart';
import '../widgets/home_vitals_card.dart';
import '../widgets/featured_tip_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F9FD),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── 1. Modern Welcoming Header (Greeting, Search Bar, Settings) ───
            HomeHeader(),

            // ─── 2. Scrollable Dashboard Body ───
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── 4 Quick Actions Row (Medicines, Reminder, Vitals, Rx) ───
                  QuickActionsRow(),
                  SizedBox(height: 18),

                  // ─── Weekly Wellness Celebration Scorecard ───
                  WeeklyScorecardHomeBanner(),
                  SizedBox(height: 18),

                  // ─── Daily Medicine Routine & Adherence Checklist ───
                  TodayMedicineCard(),
                  SizedBox(height: 18),

                  // ─── Lifestyle, Diet & Women Health Hub ───
                  LifestyleWellnessHomeCard(),
                  SizedBox(height: 18),

                  // ─── Daily Health Habits & Interactive Streak Tracker ───
                  HealthHabitHomeCard(),
                  SizedBox(height: 18),

                  // ─── Personal Health Vitals (BP, Sugar, Weight) ───
                  HomeVitalsCard(),
                  SizedBox(height: 18),

                  // ─── Daily Featured Bilingual Health Tip ───
                  FeaturedTipCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

