import 'package:flutter/material.dart';
import 'package:tiklarm/models/alarm_model.dart';
import 'package:tiklarm/services/timer_service.dart';

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
    final isActive = alarm.isActive;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final timerService = TimerService();
    
    return Dismissible(
      key: Key(alarm.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24.0),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (_) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (_) {
        onDelete();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isActive 
                ? (isDark 
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.3) 
                    : Theme.of(context).colorScheme.primary.withOpacity(0.1))
                : Colors.transparent,
              blurRadius: isActive ? 8 : 0,
              spreadRadius: isActive ? 1 : 0,
              offset: isActive ? const Offset(0, 2) : Offset.zero,
            ),
          ],
        ),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isActive 
                ? BorderSide(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                    width: 1.5,
                  )
                : BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                    width: 1,
                  ),
          ),
          color: isActive 
              ? (isDark 
                  ? Theme.of(context).colorScheme.surface 
                  : Theme.of(context).colorScheme.surface)
              : (isDark 
                  ? Theme.of(context).colorScheme.surface.withOpacity(0.5) 
                  : Theme.of(context).colorScheme.surface.withOpacity(0.7)),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 16, bottom: 16, right: 16),
              child: Row(
                children: [
                  // Alarm Time
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              timerService.formatTimeOfDay(alarm.time),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? (isDark 
                                        ? Theme.of(context).colorScheme.primary 
                                        : Theme.of(context).colorScheme.primary)
                                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                letterSpacing: -1,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Label
                        if (alarm.label.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2, bottom: 4),
                            child: Text(
                              alarm.label,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isActive
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        
                        // Repeat Days and Icons
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _getRepeatText(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isActive
                                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        
                        // Features row
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              _buildFeatureChip(
                                isActive: isActive && alarm.isVibrate,
                                icon: Icons.vibration,
                                label: 'Vibrate',
                                context: context,
                              ),
                              const SizedBox(width: 8),
                              _buildFeatureChip(
                                isActive: isActive,
                                icon: Icons.music_note,
                                label: 'Sound',
                                context: context,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Toggle Switch
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Transform.scale(
                      scale: 1.1,
                      child: Switch(
                        value: isActive,
                        onChanged: onToggle,
                        activeColor: Theme.of(context).colorScheme.primary,
                        activeTrackColor: isDark
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                            : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        inactiveThumbColor: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade400,
                        inactiveTrackColor: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip({
    required bool isActive,
    required IconData icon,
    required String label,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
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
    final timerService = TimerService();
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alarm'),
        content: Text(
          'Are you sure you want to delete the alarm set for ${timerService.formatTimeOfDay(alarm.time)}?',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }
} 