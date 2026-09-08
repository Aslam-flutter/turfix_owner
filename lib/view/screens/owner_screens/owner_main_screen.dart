import 'package:flutter/material.dart';
import 'package:turfix_owner/view/screens/owner_screens/my_turfs_screen.dart';
import 'package:turfix_owner/view/screens/owner_screens/owner_booking_screen.dart';
import 'package:turfix_owner/view/screens/owner_screens/owner_dash_board.dart';
import 'package:turfix_owner/view/screens/owner_screens/owner_profile_screen.dart';

class OwnerMainScreen extends StatefulWidget {
  const OwnerMainScreen({super.key});

  @override
  State<OwnerMainScreen> createState() => _OwnerMainScreenState();
}

class _OwnerMainScreenState extends State<OwnerMainScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    Center(child: OwnerDashboardScreen()),
    Center(child: MyTurfsScreen()),
    Center(child: OwnerBookingScreen()),
    Center(child: OwnerProfileScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    // const primary = Color(0xff16A34A);

    return Scaffold(
      body: pages[selectedIndex],

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xff111827),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                buildNavItem(
                  index: 0,
                  icon: Icons.dashboard_customize_outlined,
                  selectedIcon: Icons.dashboard_customize,
                  title: "Dashboard",
                ),

                buildNavItem(
                  index: 1,
                  icon: Icons.stadium_outlined,
                  selectedIcon: Icons.stadium,
                  title: "Turfs",
                ),

                buildNavItem(
                  index: 2,
                  icon: Icons.calendar_month_outlined,
                  selectedIcon: Icons.calendar_month,
                  title: "Bookings",
                ),

                buildNavItem(
                  index: 3,
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  title: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String title,
  }) {
    const primary = Color(0xff16A34A);

    final selected = selectedIndex == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? selectedIcon : icon,
                size: 25,
                color: selected ? primary : Colors.white70,
              ),

              const SizedBox(height: 4),

              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? primary : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
