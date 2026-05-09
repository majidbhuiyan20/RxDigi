import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/features/home/view/home_screen.dart';
import 'package:rxdigi/features/patients/view/patients_screen.dart';
import 'package:rxdigi/features/medicines/view/medicines_screen.dart';
import 'package:rxdigi/features/profile/view/profile_screen.dart';

import 'package:rxdigi/features/prescription/view/new_prescription_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PatientsScreen(),
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

  void _navigateToNewRx() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewPrescriptionScreen()),
    );
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
                    backgroundColor: AppColors.rxPrimaryColor,
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
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: Text('Patients'),
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
        height: 75,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, Icons.home),
            _buildNavItem(1, Icons.people_outlined, Icons.people),
            _buildMiddleNavItem(),
            _buildNavItem(3, Icons.medication_outlined, Icons.medication),
            _buildNavItem(4, Icons.person_outline, Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon) {
    bool isSelected = _selectedIndex == index;
    return InkResponse(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade400,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildMiddleNavItem() {
    return InkResponse(
      onTap: () => _onItemTapped(2),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.rxPrimaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.rxPrimaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
