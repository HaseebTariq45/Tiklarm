import 'dart:async';
import 'package:flutter/material.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with SingleTickerProviderStateMixin {
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  int _totalSeconds = 0;
  bool _isRunning = false;
  Timer? _timer;
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    final totalSeconds = _hours * 3600 + _minutes * 60 + _seconds;
    if (totalSeconds <= 0) return;
    
    setState(() {
      _isRunning = true;
      _totalSeconds = totalSeconds;
      _animationController.repeat(reverse: true);
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
        _animationController.stop();
      });
    }
  }

  void _cancelTimer() {
    if (_timer != null) {
      _timer!.cancel();
      setState(() {
        _isRunning = false;
        _animationController.stop();
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
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            const Text('Timer Complete'),
          ],
        ),
        content: const Text('Your timer has finished!'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Timer display
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    color: _isRunning
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1 + _animationController.value * 0.05)
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(_isRunning ? 0.2 : 0.1),
                        blurRadius: 12,
                        spreadRadius: _isRunning ? 2 : 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: _isRunning
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTimerSegment(_hours, 'HRS'),
                      _buildTimerDivider(),
                      _buildTimerSegment(_minutes, 'MIN'),
                      _buildTimerDivider(),
                      _buildTimerSegment(_seconds, 'SEC'),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 40),
            
            // Time picker (only visible when not running)
            if (!_isRunning)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTimePicker(
                      value: _hours,
                      label: 'Hours',
                      maxValue: 23,
                      onChanged: (value) => setState(() => _hours = value),
                    ),
                    _buildTimePicker(
                      value: _minutes,
                      label: 'Minutes',
                      maxValue: 59,
                      onChanged: (value) => setState(() => _minutes = value),
                    ),
                    _buildTimePicker(
                      value: _seconds,
                      label: 'Seconds',
                      maxValue: 59,
                      onChanged: (value) => setState(() => _seconds = value),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 40),
            
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: Icons.refresh,
                  label: 'Reset',
                  color: Colors.red,
                  onPressed: _totalSeconds > 0 ? _resetTimer : null,
                ),
                const SizedBox(width: 20),
                _isRunning
                    ? _buildControlButton(
                        icon: Icons.pause,
                        label: 'Pause',
                        color: Colors.orange,
                        size: 1.3,
                        onPressed: _pauseTimer,
                      )
                    : _buildControlButton(
                        icon: Icons.play_arrow,
                        label: 'Start',
                        color: Colors.green,
                        size: 1.3,
                        onPressed: _hours == 0 && _minutes == 0 && _seconds == 0
                            ? null
                            : _startTimer,
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTimerDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: _isRunning
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildTimerSegment(int value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: _isRunning
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildTimePickerButton(
                icon: Icons.keyboard_arrow_up,
                onPressed: value < maxValue
                    ? () => onChanged(value + 1)
                    : null,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Text(
                  value.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              _buildTimePickerButton(
                icon: Icons.keyboard_arrow_down,
                onPressed: value > 0
                    ? () => onChanged(value - 1)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimePickerButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        width: double.infinity,
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: onPressed != null
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
        ),
      ),
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    double size = 1.0,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            disabledBackgroundColor: color.withOpacity(0.3),
            disabledForegroundColor: Colors.white.withOpacity(0.5),
            elevation: onPressed != null ? 6 : 0,
            padding: EdgeInsets.all(16 * size),
            shape: const CircleBorder(),
          ),
          child: Icon(icon, size: 32 * size),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: onPressed != null
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
} 