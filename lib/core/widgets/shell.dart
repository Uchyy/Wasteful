import 'package:flutter/material.dart';
import 'package:wasteful/core/extensions/responsive_font.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import 'package:wasteful/features/add_schedule/add_schedule.dart';
import 'package:wasteful/features/settings/settings.dart';
import '../theme/app_colors.dart';
import '../../features/home/home_screen.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    SettingsScreen(),
    AddScheduleScreen(),
  ];

  void _onAddPressed() {
    setState(() {
      _index = 2; // Navigate to the AddScheduleScreen
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          bottom: context.padding(PaddingSize.large).bottom
        ),
        child:  IndexedStack(index: _index, children: _screens),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.accent,
        onPressed: _onAddPressed,
        shape: const CircleBorder(),
        child: Icon(Icons.add, color: colors.textPrimary, size: context.fontSize(FontSize.extraLarge) * 1.2),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        iconSize: context.fontSize(FontSize.extraLarge) ,
        icons: const [Icons.home_outlined, Icons.settings_outlined],
        activeIndex: _index,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.smoothEdge,
        leftCornerRadius: 20,
        rightCornerRadius: 20,
        backgroundColor: colors.surface,
        activeColor: colors.accent,
        inactiveColor: colors.textMuted,
        onTap: (index) => setState(() => _index = index),
      ),
    );
  }
}