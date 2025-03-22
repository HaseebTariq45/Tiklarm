import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiklarm/providers/alarm_provider.dart';
import 'package:tiklarm/screens/alarm_list_screen.dart';
import 'package:tiklarm/screens/alarm_trigger_screen.dart';
import 'package:tiklarm/services/alarm_service.dart';
import 'package:tiklarm/models/alarm_model.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:tiklarm/utils/platform_utils.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:tiklarm/screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiklarm/services/theme_service.dart';
import 'package:tiklarm/services/settings_service.dart';
import 'package:tiklarm/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final themeService = ThemeService();
  await themeService.initialize();
  
  final settingsService = SettingsService();
  await settingsService.initialize();
  
  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Configure logging
  if (kDebugMode) {
    if (kIsWeb) {
      // Web-specific configuration
    } else {
      // Native-specific configuration
    }
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider.value(value: settingsService),
      ],
      child: const MyApp(),
    ),
  );
}

// Global navigator key for accessing the context from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void _handleAlarmRing(int alarmId) {
  // Get the alarm from the AlarmService
  final alarmService = AlarmService();
  final alarms = alarmService.getAlarms();
  final alarmIndex = alarms.indexWhere((a) => a.id == alarmId.toString());
  
  if (alarmIndex != -1) {
    final alarm = alarms[alarmIndex];
    
    // Navigate to the trigger screen
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => AlarmTriggerScreen(alarm: alarm),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AlarmProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Tiklarm',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3F51B5),
            brightness: Brightness.light,
            primary: const Color(0xFF3F51B5),
            secondary: const Color(0xFF03DAC6),
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3F51B5),
            brightness: Brightness.dark,
            primary: const Color(0xFF3F51B5),
            secondary: const Color(0xFF03DAC6),
            surface: const Color(0xFF1E1E1E),
            background: const Color(0xFF121212),
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        themeMode: themeService.themeMode,
        home: const HomeScreen(),
      ),
    );
  }
}
