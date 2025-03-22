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
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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

void _handleAlarmRing(int alarmId) async {
  // Initialize the alarm service
  final alarmService = AlarmService();
  await alarmService.init();
  
  // Get all alarms and find the one that's ringing
  final List<AlarmModel> alarms = alarmService.getAlarms();
  final AlarmModel? ringingAlarm = alarms.firstWhere(
    (alarm) => int.parse(alarm.id) == alarmId,
    orElse: () => alarms.firstWhere(
      (alarm) => int.parse('${alarm.id}9') == alarmId,
      orElse: () => alarms.first,
    ),
  );
  
  // Navigate to the alarm trigger screen if the app is running
  if (navigatorKey.currentContext != null && ringingAlarm != null) {
    Navigator.push(
      navigatorKey.currentContext!,
      MaterialPageRoute(
        builder: (context) => AlarmTriggerScreen(
          alarm: ringingAlarm,
        ),
      ),
    );
  }
}

// Global navigator key for accessing the context from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AlarmProvider(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Tiklarm',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const AlarmListScreen(),
      ),
    );
  }
}
