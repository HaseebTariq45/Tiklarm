import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiklarm/models/alarm_model.dart';
import 'package:tiklarm/providers/alarm_provider.dart';
import 'package:tiklarm/widgets/day_selector.dart';
import 'package:intl/intl.dart';

class AlarmEditScreen extends StatefulWidget {
  final AlarmModel alarm;
  final bool isNew;

  const AlarmEditScreen({
    Key? key,
    required this.alarm,
    required this.isNew,
  }) : super(key: key);

  @override
  State<AlarmEditScreen> createState() => _AlarmEditScreenState();
}

class _AlarmEditScreenState extends State<AlarmEditScreen> with SingleTickerProviderStateMixin {
  late TimeOfDay _time;
  late String _label;
  late List<bool> _days;
  late String _soundPath;
  late bool _isVibrate;
  late int _snoozeTime;
  final List<int> _snoozeOptions = [1, 5, 10, 15, 20, 30];
  final List<String> _soundOptions = [
    'default_alarm',
    'gentle_alarm',
    'upbeat_alarm',
    'nature_alarm',
    'classic_alarm'
  ];

  final _labelController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _time = widget.alarm.time;
    _label = widget.alarm.label;
    _labelController.text = _label;
    _days = List.from(widget.alarm.days);
    _soundPath = widget.alarm.soundPath;
    _isVibrate = widget.alarm.isVibrate;
    _snoozeTime = widget.alarm.snoozeTime;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _labelController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          widget.isNew ? 'Add Alarm' : 'Edit Alarm',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: _saveAlarm,
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _animation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time Picker
              Center(
                child: Hero(
                  tag: widget.isNew ? 'new_alarm_time' : 'alarm_time_${widget.alarm.id}',
                  child: GestureDetector(
                    onTap: _showTimePicker,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 24),
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 36),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  Theme.of(context).colorScheme.primary.withOpacity(0.6),
                                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                ]
                              : [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        _formatTime(_time),
                        style: const TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 28),

              // Section Title
              _buildSectionTitle('Repeat on'),
              
              // Day Selector
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: DaySelector(
                    days: _days,
                    onChanged: (int index, bool value) {
                      setState(() {
                        _days[index] = value;
                      });
                    },
                  ),
                ),
              ),

              // Label Input
              _buildSectionTitle('Alarm Name'),
              _buildTextField(
                controller: _labelController,
                hintText: 'Enter alarm name',
                icon: Icons.label_outline,
                onChanged: (value) {
                  _label = value;
                },
              ),
              
              const SizedBox(height: 24),

              // Sound Selector
              _buildSectionTitle('Sound'),
              _buildDropdown<String>(
                value: _soundPath,
                items: _soundOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(_formatSoundName(value)),
                  );
                }).toList(),
                icon: Icons.music_note,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _soundPath = newValue;
                    });
                  }
                },
              ),
              
              const SizedBox(height: 24),

              // Snooze Time Selector
              _buildSectionTitle('Snooze Duration'),
              _buildDropdown<int>(
                value: _snoozeTime,
                items: _snoozeOptions.map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value minutes'),
                  );
                }).toList(),
                icon: Icons.snooze,
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _snoozeTime = newValue;
                    });
                  }
                },
              ),
              
              const SizedBox(height: 24),

              // Vibration Switch
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SwitchListTile(
                  title: Row(
                    children: [
                      Icon(
                        Icons.vibration,
                        color: _isVibrate 
                            ? Theme.of(context).colorScheme.primary 
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        size: 26,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Vibration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  value: _isVibrate,
                  activeColor: Theme.of(context).colorScheme.primary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onChanged: (bool value) {
                    setState(() {
                      _isVibrate = value;
                    });
                  },
                ),
              ),
              
              // Save Button
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 24, bottom: 16),
                  child: ElevatedButton(
                    onPressed: _saveAlarm,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 3,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check),
                        SizedBox(width: 8),
                        Text(
                          'Save Alarm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          prefixIcon: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required IconData icon,
    required Function(T?) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        ),
        icon: Icon(
          Icons.arrow_drop_down,
          color: Theme.of(context).colorScheme.primary,
        ),
        dropdownColor: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        items: items,
      ),
    );
  }

  void _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).colorScheme.surface,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodColor: Theme.of(context).colorScheme.primaryContainer,
              dayPeriodTextColor: Theme.of(context).colorScheme.onPrimaryContainer,
              hourMinuteColor: Theme.of(context).colorScheme.primaryContainer,
              hourMinuteTextColor: Theme.of(context).colorScheme.onPrimaryContainer,
              dialBackgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              dialHandColor: Theme.of(context).colorScheme.primary,
              dialTextColor: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
      });
    }
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
    final format = DateFormat.Hm(); // e.g. 09:30
    return format.format(dt);
  }

  String _formatSoundName(String soundPath) {
    // Convert 'default_alarm' to 'Default Alarm'
    return soundPath
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  void _saveAlarm() {
    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
    
    final updatedAlarm = widget.alarm.copyWith(
      time: _time,
      label: _label,
      days: _days,
      soundPath: _soundPath,
      isVibrate: _isVibrate,
      snoozeTime: _snoozeTime,
    );
    
    if (widget.isNew) {
      alarmProvider.addAlarm(updatedAlarm);
    } else {
      alarmProvider.updateAlarm(updatedAlarm);
    }
    
    Navigator.pop(context);
  }
} 