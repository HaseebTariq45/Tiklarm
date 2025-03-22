import 'package:flutter/material.dart';
import 'package:tiklarm/screens/alarm_list_screen.dart';
import 'package:tiklarm/screens/world_clock_screen.dart';
import 'package:tiklarm/screens/timer_screen.dart';
import 'package:tiklarm/screens/stopwatch_screen.dart';
import 'package:tiklarm/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiklarm/services/theme_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    AlarmListScreen(showAppBar: false),
    WorldClockScreen(),
    TimerScreen(),
    StopwatchScreen(),
  ];

  final List<String> _titles = [
    'Tiklarm',
    'World Clock',
    'Timer',
    'Stopwatch',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _screens.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ).then((_) {
                // Refresh theme settings after returning from settings screen
                ThemeService().refreshFromPrefs();
              });
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        margin: const EdgeInsets.only(top: 15),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
                _tabController.animateTo(index);
              });
            },
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.alarm),
                activeIcon: Icon(Icons.alarm, size: 28),
                label: 'Alarm',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.language),
                activeIcon: Icon(Icons.language, size: 28),
                label: 'World Clock',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.timer),
                activeIcon: Icon(Icons.timer, size: 28),
                label: 'Timer',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.timer_outlined),
                activeIcon: Icon(Icons.timer_outlined, size: 28),
                label: 'Stopwatch',
              ),
            ],
          ),
        ),
      ),
    );
  }
} 