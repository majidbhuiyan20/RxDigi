import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prescripto/app/app_colors.dart';
import 'package:prescripto/app/app_routes.dart';
import 'package:prescripto/core/data/providers/doctor_provider.dart';
import 'package:prescripto/features/home/view/home_screen.dart';
import 'package:prescripto/features/health_tips/view/health_tips_screen.dart';
import 'package:prescripto/features/medicines/view/medicines_screen.dart';
import 'package:prescripto/features/profile/view/profile_screen.dart';
import 'package:prescripto/features/prescription/view/new_prescription_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HealthTipsScreen(),
    const SizedBox(), // Placeholder for New Rx
    const MedicinesScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      _navigateToNewRx();
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _navigateToNewRx() async {
    final doctor = await ref.read(latestDoctorProvider.future);
    if (!mounted) return;

    if (doctor == null) {
      // First-time prescriber prompt: Friendly modal to setup profile
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Setup Prescriber Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: const Text(
            'To generate professional prescriptions with your degrees, clinic name, and header, please set up your doctor profile once.',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRoutes.introOnboarding);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Setup Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NewPrescriptionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex > 2 ? _selectedIndex - 1 : (_selectedIndex == 2 ? 0 : _selectedIndex),
              onDestinationSelected: (int index) {
                int actualIndex = index;
                if (index >= 2) actualIndex = index + 1;
                setState(() {
                  _selectedIndex = actualIndex;
                });
              },
              labelType: NavigationRailLabelType.all,
              backgroundColor: AppColors.topHeaderColor,
              selectedIconTheme: const IconThemeData(color: Colors.white),
              unselectedIconTheme: IconThemeData(color: Colors.white.withOpacity(0.5)),
              selectedLabelTextStyle: const TextStyle(color: Colors.white),
              unselectedLabelTextStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              leading: Column(
                children: [
                  const SizedBox(height: 20),
                  FloatingActionButton(
                    onPressed: _navigateToNewRx,
                    backgroundColor: AppColors.primaryColor,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.health_and_safety_outlined),
                  selectedIcon: Icon(Icons.health_and_safety),
                  label: Text('Health Tips'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.medication_outlined),
                  selectedIcon: Icon(Icons.medication),
                  label: Text('Medicines'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: _screens[_selectedIndex == 2 ? 0 : _selectedIndex],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 70,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.grid_view_outlined, Icons.grid_view_rounded),
            _buildNavItem(1, Icons.health_and_safety_outlined, Icons.health_and_safety_rounded),
            _buildMiddleNavItem(),
            _buildNavItem(3, Icons.medication_outlined, Icons.medication_rounded),
            _buildNavItem(4, Icons.person_outline_rounded, Icons.person_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: isSelected ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? AppColors.primaryColor : Colors.grey.shade400,
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            width: isSelected ? 4 : 0,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiddleNavItem() {
    return GestureDetector(
      onTap: () => _onItemTapped(2),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryColor, AppColors.topHeaderColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
