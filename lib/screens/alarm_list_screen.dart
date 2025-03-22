import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiklarm/models/alarm_model.dart';
import 'package:tiklarm/providers/alarm_provider.dart';
import 'package:tiklarm/screens/alarm_edit_screen.dart';
import 'package:tiklarm/widgets/alarm_list_item.dart';
import 'package:intl/intl.dart';
import 'package:tiklarm/utils/platform_utils.dart';
import 'package:tiklarm/services/timer_service.dart';

class AlarmListScreen extends StatelessWidget {
  final bool showAppBar;
  
  const AlarmListScreen({Key? key, this.showAppBar = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: showAppBar ? AppBar(
        title: const Text('Tiklarm'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 2,
      ) : null,
      body: Column(
        children: [
          // Web platform notice
          if (PlatformUtils.isWeb)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.shade200.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade800),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Limited functionality on web platform. '
                      'For full alarm features, please use the mobile app.',
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Main content
          Expanded(
            child: Consumer<AlarmProvider>(
              builder: (context, alarmProvider, child) {
                if (alarmProvider.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Loading alarms...',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final alarms = alarmProvider.alarms;
                
                if (alarms.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.nightlight_round,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No alarms set',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to create your first alarm',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () => _navigateToAddAlarm(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Alarm'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: alarms.length,
                    itemBuilder: (context, index) {
                      final alarm = alarms[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: AlarmListItem(
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
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 64),
        child: FloatingActionButton.extended(
          onPressed: () => _navigateToAddAlarm(context),
          icon: const Icon(Icons.add),
          label: const Text('New Alarm'),
          elevation: 4,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
    // Use TimerService for consistent time formatting across the app
    return TimerService().formatTimeOfDay(time);
  }
} 