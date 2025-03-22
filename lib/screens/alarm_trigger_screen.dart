import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiklarm/models/alarm_model.dart';
import 'package:tiklarm/providers/alarm_provider.dart';
import 'package:intl/intl.dart';
import 'package:tiklarm/services/timer_service.dart';
import 'package:tiklarm/services/sound_service.dart';
import 'package:tiklarm/services/vibration_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class AlarmTriggerScreen extends StatefulWidget {
  final AlarmModel alarm;
  
  const AlarmTriggerScreen({
    Key? key,
    required this.alarm,
  }) : super(key: key);

  @override
  State<AlarmTriggerScreen> createState() => _AlarmTriggerScreenState();
}

class _AlarmTriggerScreenState extends State<AlarmTriggerScreen> {
  final SoundService _soundService = SoundService();
  final VibrationService _vibrationService = VibrationService();
  
  @override
  void initState() {
    super.initState();
    _startAlarm();
  }
  
  void _startAlarm() async {
    try {
      // Keep screen on while alarm is active
      await WakelockPlus.enable();
      
      // Play alarm sound
      await _soundService.playAlarmSound();
      
      // Start vibration if enabled
      if (widget.alarm.isVibrate) {
        await _vibrationService.startAlarmVibration();
      }
    } catch (e) {
      debugPrint('Error starting alarm features: $e');
      // Still try to play sound and vibrate even if wakelock fails
      try {
        await _soundService.playAlarmSound();
        
        if (widget.alarm.isVibrate) {
          await _vibrationService.startAlarmVibration();
        }
      } catch (soundError) {
        debugPrint('Error playing alarm sound/vibration: $soundError');
      }
    }
  }
  
  @override
  void dispose() {
    try {
      // Stop sound and vibration when screen is closed
      _soundService.stopSound();
      _vibrationService.stopVibration();
      
      // Allow screen to turn off again
      WakelockPlus.disable();
    } catch (e) {
      debugPrint('Error cleaning up alarm resources: $e');
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerService = TimerService();
    final formattedTime = timerService.formatTimeOfDay(widget.alarm.time);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 1),
            
            // Alarm Icon
            Icon(
              Icons.alarm,
              size: 100,
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.85),
            ),
            
            const SizedBox(height: 40),
            
            // Alarm Time
            Text(
              formattedTime,
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Alarm Label
            if (widget.alarm.label.isNotEmpty)
              Text(
                widget.alarm.label,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                ),
              ),
            
            const Spacer(flex: 1),
            
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // Snooze Button
                  Expanded(
                    child: _buildActionButton(
                      context,
                      Icons.snooze,
                      'Snooze',
                      Colors.amber.shade700,
                      () => _snoozeAlarm(context),
                    ),
                  ),
                  
                  const SizedBox(width: 20),
                  
                  // Dismiss Button
                  Expanded(
                    child: _buildActionButton(
                      context,
                      Icons.alarm_off,
                      'Dismiss',
                      Colors.red.shade700,
                      () => _dismissAlarm(context),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _snoozeAlarm(BuildContext context) {
    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
    alarmProvider.snoozeAlarm(widget.alarm.id);
    Navigator.pop(context);
  }

  void _dismissAlarm(BuildContext context) {
    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
    alarmProvider.dismissAlarm(widget.alarm.id);
    Navigator.pop(context);
  }
} 