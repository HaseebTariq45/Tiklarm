import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiklarm/models/alarm_model.dart';
import 'package:tiklarm/providers/alarm_provider.dart';
import 'package:tiklarm/screens/alarm_edit_screen.dart';
import 'package:tiklarm/widgets/alarm_list_item.dart';
import 'package:intl/intl.dart';

class AlarmListScreen extends StatelessWidget {
  const AlarmListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiklarm'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 2,
      ),
      body: Consumer<AlarmProvider>(
        builder: (context, alarmProvider, child) {
          if (alarmProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final alarms = alarmProvider.alarms;
          
          if (alarms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.alarm_off,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No alarms set',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _navigateToAddAlarm(context),
                    child: const Text('Add Alarm'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: alarms.length,
            itemBuilder: (context, index) {
              final alarm = alarms[index];
              return AlarmListItem(
                alarm: alarm,
                onToggle: (value) {
                  alarmProvider.toggleAlarm(alarm.id, value);
                },
                onTap: () {
                  _navigateToEditAlarm(context, alarm);
                },
                onDelete: () {
                  _showDeleteConfirmation(context, alarm);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddAlarm(context),
        tooltip: 'Add Alarm',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddAlarm(BuildContext context) async {
    // Generate a unique ID for the new alarm
    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Default alarm with current time
    final TimeOfDay now = TimeOfDay.now();
    final AlarmModel newAlarm = AlarmModel(
      id: id,
      time: now,
      days: List.filled(7, false),
    );
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmEditScreen(alarm: newAlarm, isNew: true),
      ),
    );
  }

  void _navigateToEditAlarm(BuildContext context, AlarmModel alarm) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmEditScreen(alarm: alarm, isNew: false),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AlarmModel alarm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Alarm'),
        content: Text(
          'Are you sure you want to delete the alarm set for ${_formatTime(alarm.time)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AlarmProvider>(context, listen: false)
                  .deleteAlarm(alarm.id);
              Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    final format = DateFormat.jm(); // e.g. 9:30 AM
    return format.format(dt);
  }
} 