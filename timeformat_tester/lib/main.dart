import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();
  
  // Get saved time format or use 24h as default
  final timeFormat = prefs.getString('timeFormat') ?? '24h';
  
  runApp(MyApp(timeFormat: timeFormat));
}

class MyApp extends StatelessWidget {
  final String timeFormat;
  
  const MyApp({Key? key, required this.timeFormat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Format Tester',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: TimeFormatTester(initialTimeFormat: timeFormat),
    );
  }
}

class TimeFormatTester extends StatefulWidget {
  final String initialTimeFormat;
  
  const TimeFormatTester({Key? key, required this.initialTimeFormat}) : super(key: key);

  @override
  State<TimeFormatTester> createState() => _TimeFormatTesterState();
}

class _TimeFormatTesterState extends State<TimeFormatTester> {
  late String _timeFormat;
  late TimeOfDay _currentTime;
  
  @override
  void initState() {
    super.initState();
    _timeFormat = widget.initialTimeFormat;
    _currentTime = TimeOfDay.now();
  }
  
  String formatTimeOfDay(TimeOfDay time) {
    final is24HourFormat = _timeFormat == '24h';
    
    if (is24HourFormat) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
    }
  }
  
  Future<void> setTimeFormat(String value) async {
    if (_timeFormat == value) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('timeFormat', value);
    
    setState(() {
      _timeFormat = value;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Format Tester'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Current time display
            Text(
              'Current Time:',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              formatTimeOfDay(_currentTime),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Example times
            Text(
              'Sample Times in $_timeFormat Format:',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            _buildTimeExample(const TimeOfDay(hour: 9, minute: 30)),
            _buildTimeExample(const TimeOfDay(hour: 13, minute: 45)),
            _buildTimeExample(const TimeOfDay(hour: 0, minute: 0)),
            _buildTimeExample(const TimeOfDay(hour: 23, minute: 59)),
            
            const SizedBox(height: 30),
            
            // Time format selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _timeFormat == '12h' 
                      ? null 
                      : () => setTimeFormat('12h'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _timeFormat == '12h' 
                        ? Theme.of(context).colorScheme.primaryContainer 
                        : null,
                    foregroundColor: _timeFormat == '12h' 
                        ? Theme.of(context).colorScheme.onPrimaryContainer 
                        : null,
                  ),
                  child: const Text('12-hour Format'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _timeFormat == '24h' 
                      ? null 
                      : () => setTimeFormat('24h'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _timeFormat == '24h' 
                        ? Theme.of(context).colorScheme.primaryContainer 
                        : null,
                    foregroundColor: _timeFormat == '24h' 
                        ? Theme.of(context).colorScheme.onPrimaryContainer 
                        : null,
                  ),
                  child: const Text('24-hour Format'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Setting will be saved across app restarts',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            
            const SizedBox(height: 30),
            
            // Update time button
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _currentTime = TimeOfDay.now();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Update Current Time'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTimeExample(TimeOfDay time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 16),
          const Text('→'),
          const SizedBox(width: 16),
          Text(
            formatTimeOfDay(time),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
