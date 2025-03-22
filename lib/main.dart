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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure logging
  if (kDebugMode) {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Flutter error: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');
    };
  }
  
  // Initialize the alarm plugin
  if (PlatformUtils.isNativeAlarmsSupported) {
    try {
      await Alarm.init();
      
      // Handle alarm callback when app is launched from an alarm
      Alarm.ringing.listen((alarmSet) {
        // Find the alarm with the given ID and show the trigger screen
        if (alarmSet.alarms.isNotEmpty) {
          _handleAlarmRing(alarmSet.alarms.first.id);
        }
      });
    } catch (e) {
      debugPrint('Error initializing alarm: $e');
    }
  }
  
  runApp(const MyApp());
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AlarmProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Tiklarm',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
