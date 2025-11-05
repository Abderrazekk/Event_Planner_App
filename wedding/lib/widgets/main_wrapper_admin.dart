import 'package:flutter/material.dart';
import '../screens/admin/home.dart';
import '../screens/admin/category.dart';
import '../screens/admin/profile.dart';
import '../widgets/custom_bottom_navbar.dart';

class MainWrapperAdmin extends StatefulWidget {
  const MainWrapperAdmin({super.key});

  @override
  State<MainWrapperAdmin> createState() => _MainWrapperAdminState();
}

class _MainWrapperAdminState extends State<MainWrapperAdmin> {
  int _currentIndex = 0;
  
  // Navigator keys for each tab to manage their own navigation stack
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  // List of screens
  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoryScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == _currentIndex) {
      // If same tab is tapped, pop to first screen
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<bool> _onWillPop() async {
    final currentNavigator = _navigatorKeys[_currentIndex];
    
    // Check if the current tab can pop
    if (currentNavigator.currentState?.canPop() ?? false) {
      currentNavigator.currentState?.pop();
      return false;
    }
    
    // If it's not the home tab, switch to home tab instead of exiting
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return false;
    }
    
    // Allow exit only from home tab
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildOffstageNavigator(0),
            _buildOffstageNavigator(1),
            _buildOffstageNavigator(2),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _currentIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => _screens[index],
          );
        },
      ),
    );
  }
}