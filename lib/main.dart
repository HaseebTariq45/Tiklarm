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
import 'package:tiklarm/services/sound_service.dart';
import 'package:tiklarm/services/vibration_service.dart';

// Global navigator key for accessing the context from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void _handleAlarmRing(AlarmSettings alarmSettings) {
  debugPrint('Alarm ringing: ${alarmSettings.id}');
  
  // Get the alarm from the AlarmService
  final alarmService = AlarmService();
  final alarms = alarmService.getAlarms();
  final alarmIndex = alarms.indexWhere((a) => a.id == alarmSettings.id.toString());
  
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
  
  // Setup alarm callback
  if (PlatformUtils.isNativeAlarmsSupported) {
    try {
      await Alarm.init();
      // Register the alarm callback using the correct API method
      Alarm.ringStream.stream.listen(_handleAlarmRing);
    } catch (e) {
      debugPrint('Error setting up alarm callback: $e');
    }
  }
  
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
        ChangeNotifierProvider(create: (_) => AlarmProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final SoundService _soundService = SoundService();
  final VibrationService _vibrationService = VibrationService();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    // Clean up all resources when app is closed
    _soundService.dispose();
    _vibrationService.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      // Stop sounds and vibrations when app goes to background
      _soundService.stopSound();
      _vibrationService.stopVibration();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    
    return MaterialApp(
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
    );
  }
}
