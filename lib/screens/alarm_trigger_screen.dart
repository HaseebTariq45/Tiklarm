import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiklarm/models/alarm_model.dart';
import 'package:tiklarm/providers/alarm_provider.dart';
import 'package:intl/intl.dart';

class AlarmTriggerScreen extends StatelessWidget {
  final AlarmModel alarm;
  
  const AlarmTriggerScreen({
    Key? key,
    required this.alarm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.jm();
    final now = DateTime.now();
    final formattedTime = timeFormat.format(
      DateTime(now.year, now.month, now.day, alarm.time.hour, alarm.time.minute)
    );
    
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
            if (alarm.label.isNotEmpty)
              Text(
                alarm.label,
                style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                ),
              ),
            
            const Spacer(flex: 1),
            
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Snooze Button
                  Expanded(
                    child: _buildActionButton(
                      context,
                      Icons.snooze,
                      'Snooze',
                      Colors.orange.shade600,
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
                      Colors.red.shade600,
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
    alarmProvider.snoozeAlarm(alarm.id);
    Navigator.pop(context);
  }

  void _dismissAlarm(BuildContext context) {
    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
    alarmProvider.dismissAlarm(alarm.id);
    Navigator.pop(context);
  }
} 