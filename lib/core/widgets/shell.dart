import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import 'package:wasteful/features/schedule/add_schedule.dart';
import 'package:wasteful/features/settings/settings.dart';
import '../theme/app_colors.dart';
import '../../features/home/home_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
   GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    AddScheduleScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          bottom: context.padding(PaddingSize.medium).bottom,
          top:  context.padding(PaddingSize.small).top
        ),
        child: _screens[_index],
      ),
       bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: 0,
          items: <Widget>[
            Icon(Icons.home_outlined, size: 30, color: colors.accent,),
            Icon(Icons.add_outlined, size: 30, color: colors.accent,),
            Icon(Icons.settings_outlined, size: 30, color: colors.accent,),
          ],
          color: colors.inverseBackground,
          buttonBackgroundColor: colors.background.withAlpha(100),
          backgroundColor: colors.background,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 600),
          onTap: (index) {
            setState(() {
              _index = index;
            });
          },
          letIndexChange: (index) => true,
        ),
      
    );
  }
}