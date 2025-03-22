import 'dart:async';
import 'package:flutter/material.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  int _totalSeconds = 0;
  bool _isRunning = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _totalSeconds = _hours * 3600 + _minutes * 60 + _seconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalSeconds <= 0) {
        _cancelTimer();
        _showTimerCompleteDialog();
      } else {
        setState(() {
          _totalSeconds--;
          _hours = _totalSeconds ~/ 3600;
          _minutes = (_totalSeconds % 3600) ~/ 60;
          _seconds = _totalSeconds % 60;
        });
      }
    });
  }

  void _pauseTimer() {
    if (_timer != null) {
      _timer!.cancel();
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _cancelTimer() {
    if (_timer != null) {
      _timer!.cancel();
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _resetTimer() {
    _cancelTimer();
    setState(() {
      _hours = 0;
      _minutes = 0;
      _seconds = 0;
      _totalSeconds = 0;
    });
  }

  void _showTimerCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Timer Complete'),
        content: const Text('Your timer has finished!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Timer display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimerSegment(_hours, 'HRS'),
                const SizedBox(width: 8),
                const Text(':', style: TextStyle(fontSize: 40)),
                const SizedBox(width: 8),
                _buildTimerSegment(_minutes, 'MIN'),
                const SizedBox(width: 8),
                const Text(':', style: TextStyle(fontSize: 40)),
                const SizedBox(width: 8),
                _buildTimerSegment(_seconds, 'SEC'),
              ],
            ),
            const SizedBox(height: 32),
            
            // Time picker (only visible when not running)
            if (!_isRunning)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTimePicker(
                    value: _hours,
                    label: 'Hours',
                    maxValue: 23,
                    onChanged: (value) => setState(() => _hours = value),
                  ),
                  const SizedBox(width: 16),
                  _buildTimePicker(
                    value: _minutes,
                    label: 'Minutes',
                    maxValue: 59,
                    onChanged: (value) => setState(() => _minutes = value),
                  ),
                  const SizedBox(width: 16),
                  _buildTimePicker(
                    value: _seconds,
                    label: 'Seconds',
                    maxValue: 59,
                    onChanged: (value) => setState(() => _seconds = value),
                  ),
                ],
              ),
            const SizedBox(height: 32),
            
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isRunning
                    ? ElevatedButton(
                        onPressed: _pauseTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Icon(Icons.pause, size: 32),
                      )
                    : ElevatedButton(
                        onPressed: _hours == 0 && _minutes == 0 && _seconds == 0
                            ? null
                            : _startTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Icon(Icons.play_arrow, size: 32),
                      ),
                const SizedBox(width: 24),
                ElevatedButton(
                  onPressed: _resetTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(Icons.stop, size: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerSegment(int value, String label) {
    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildTimePicker({
    required int value,
    required String label,
    required int maxValue,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      children: [
        Text(label),
        const SizedBox(height: 8),
        SizedBox(
          width: 60,
          child: Card(
            elevation: 2,
            child: Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_drop_up),
                  onPressed: () {
                    if (value < maxValue) {
                      onChanged(value + 1);
                    }
                  },
                ),
                Text(
                  value.toString().padLeft(2, '0'),
                  style: const TextStyle(fontSize: 20),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_drop_down),
                  onPressed: () {
                    if (value > 0) {
                      onChanged(value - 1);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 