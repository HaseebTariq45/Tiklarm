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

class _AlarmEditScreenState extends State<AlarmEditScreen> {
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
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'Add Alarm' : 'Edit Alarm'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAlarm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Picker
            Center(
              child: GestureDetector(
                onTap: _showTimePicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    _formatTime(_time),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // Day Selector
            const Text(
              'Repeat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DaySelector(
              days: _days,
              onChanged: (int index, bool value) {
                setState(() {
                  _days[index] = value;
                });
              },
            ),
            
            const SizedBox(height: 20),

            // Label Input
            const Text(
              'Label',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                hintText: 'Enter alarm name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _label = value;
              },
            ),
            
            const SizedBox(height: 20),

            // Sound Selector
            const Text(
              'Sound',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _soundPath,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _soundPath = newValue;
                  });
                }
              },
              items: _soundOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(_formatSoundName(value)),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),

            // Snooze Time Selector
            const Text(
              'Snooze Time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _snoozeTime,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _snoozeTime = newValue;
                  });
                }
              },
              items: _snoozeOptions.map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value minutes'),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),

            // Vibration Switch
            SwitchListTile(
              title: const Text(
                'Vibration',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              value: _isVibrate,
              onChanged: (bool value) {
                setState(() {
                  _isVibrate = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
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