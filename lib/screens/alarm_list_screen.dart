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
    // Add TimerService as a provider so the UI rebuilds when settings change
    return ChangeNotifierProvider.value(
      value: TimerService(),
      child: _AlarmListContent(showAppBar: showAppBar),
    );
  }
}

class _AlarmListContent extends StatelessWidget {
  final bool showAppBar;
  
  const _AlarmListContent({Key? key, required this.showAppBar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This will listen to both AlarmProvider and TimerService changes
    final alarmProvider = Provider.of<AlarmProvider>(context);
    // Listen to TimerService changes - this ensures we rebuild when time format changes
    final timerService = Provider.of<TimerService>(context);
    
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
          
          // Alarms
          alarmProvider.isLoading
              ? const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : alarmProvider.alarms.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.alarm_off,
                              size: 80,
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No alarms yet',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tap the + button to add one',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                        physics: const BouncingScrollPhysics(),
                        itemCount: alarmProvider.alarms.length,
                        itemBuilder: (context, index) {
                          final alarm = alarmProvider.alarms[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: AlarmListItem(
                              alarm: alarm,
                              onToggle: (isActive) =>
                                  alarmProvider.toggleAlarm(alarm.id, isActive),
                              onTap: () => _editAlarm(context, alarm),
                              onDelete: () => alarmProvider.deleteAlarm(alarm.id),
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 64),
        child: FloatingActionButton(
          onPressed: () => _addAlarm(context),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          child: const Icon(Icons.add),
          tooltip: 'Add Alarm',
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _addAlarm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmEditScreen(
          isNew: true,
          alarm: AlarmModel(
            id: '',
            time: TimeOfDay.now(),
            isActive: true,
            label: '',
            days: List.filled(7, false),
            isVibrate: true,
          ),
        ),
      ),
    );
  }

  void _editAlarm(BuildContext context, AlarmModel alarm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmEditScreen(alarm: alarm, isNew: false),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AlarmModel alarm) {
    final timerService = Provider.of<TimerService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Alarm'),
        content: Text(
          'Are you sure you want to delete the alarm set for ${timerService.formatTimeOfDay(alarm.time)}?',
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
} 