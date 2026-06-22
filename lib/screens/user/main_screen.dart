import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'requests_screen.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});
  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  int _idx = 0;

  static const _screens = [
    HomeScreen(),
    RequestsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.darkGreen.withAlpha(20),
        surfaceTintColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded, color: AppColors.darkGreen),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: const Icon(Icons.inbox_outlined),
            selectedIcon: const Icon(Icons.inbox_rounded, color: AppColors.darkGreen),
            label: 'طلباتي',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded, color: AppColors.darkGreen),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}
