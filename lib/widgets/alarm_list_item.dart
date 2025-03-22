import 'package:flutter/material.dart';
import 'package:tiklarm/models/alarm_model.dart';
import 'package:intl/intl.dart';

class AlarmListItem extends StatelessWidget {
  final AlarmModel alarm;
  final Function(bool) onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const AlarmListItem({
    Key? key,
    required this.alarm,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(alarm.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (_) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (_) {
        onDelete();
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Alarm Time
                Expanded(
                  flex: 2,
                  child: Text(
                    _formatTime(alarm.time),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: alarm.isActive
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                  ),
                ),
                
                // Alarm Details
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label
                      if (alarm.label.isNotEmpty)
                        Text(
                          alarm.label,
                          style: TextStyle(
                            fontSize: 16,
                            color: alarm.isActive
                                ? Theme.of(context).textTheme.bodyLarge?.color
                                : Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      
                      // Repeat Days
                      Text(
                        _getRepeatText(),
                        style: TextStyle(
                          fontSize: 14,
                          color: alarm.isActive
                              ? Colors.grey.shade600
                              : Colors.grey,
                        ),
                      ),
                      
                      // Additional Info
                      Row(
                        children: [
                          if (alarm.isVibrate)
                            Icon(
                              Icons.vibration,
                              size: 16,
                              color: alarm.isActive
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade400,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Toggle Switch
                Switch(
                  value: alarm.isActive,
                  onChanged: onToggle,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
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

  String _getRepeatText() {
    final List<String> daysShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    // Check if no days are selected
    if (!alarm.days.contains(true)) {
      return 'One time alarm';
    }
    
    // Check if all days are selected
    if (!alarm.days.contains(false)) {
      return 'Every day';
    }
    
    // Check if weekdays only
    if (alarm.days[0] && alarm.days[1] && alarm.days[2] && alarm.days[3] && alarm.days[4] && 
        !alarm.days[5] && !alarm.days[6]) {
      return 'Weekdays';
    }
    
    // Check if weekends only
    if (!alarm.days[0] && !alarm.days[1] && !alarm.days[2] && !alarm.days[3] && !alarm.days[4] && 
        alarm.days[5] && alarm.days[6]) {
      return 'Weekends';
    }
    
    // Otherwise, list the selected days
    final List<String> selectedDays = [];
    for (int i = 0; i < 7; i++) {
      if (alarm.days[i]) {
        selectedDays.add(daysShort[i]);
      }
    }
    
    return selectedDays.join(', ');
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alarm'),
        content: Text(
          'Are you sure you want to delete the alarm set for ${_formatTime(alarm.time)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }
} 