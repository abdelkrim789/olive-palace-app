import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../user/profile_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_requests_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});
  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _idx = 0;

  static const _screens = [
    AdminDashboardScreen(),
    AdminRequestsScreen(),
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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.darkGreen),
            label: 'الإحصائيات',
          ),
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox_rounded, color: AppColors.darkGreen),
            label: 'الطلبات',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.darkGreen),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}
