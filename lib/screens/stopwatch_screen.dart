import 'dart:async';
import 'package:flutter/material.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({Key? key}) : super(key: key);

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> with SingleTickerProviderStateMixin {
  bool _isRunning = false;
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  final List<Map<String, dynamic>> _laps = [];
  int _lapCounter = 1;
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

  void _startStopwatch() {
    setState(() {
      _isRunning = true;
      _stopwatch.start();
      _animationController.repeat(reverse: true);
    });

    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {});
    });
  }

  void _stopStopwatch() {
    setState(() {
      _isRunning = false;
      _stopwatch.stop();
      _animationController.stop();
    });
    _timer?.cancel();
  }

  void _resetStopwatch() {
    _stopStopwatch();
    setState(() {
      _laps.clear();
      _lapCounter = 1;
      _stopwatch.reset();
    });
  }

  void _recordLap() {
    if (_isRunning) {
      final lapTime = _stopwatch.elapsedMilliseconds;
      final previousLapTime = _laps.isNotEmpty ? _laps.first['totalTime'] as int : 0;
      final lapDuration = lapTime - previousLapTime;
      
      setState(() {
        _laps.insert(0, {
          'number': _lapCounter++,
          'lapTime': lapDuration,
          'totalTime': lapTime,
        });
      });
    }
  }

  String _formatTime(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate() % 100;
    int seconds = (milliseconds / 1000).truncate() % 60;
    int minutes = (milliseconds / 60000).truncate() % 60;
    int hours = (milliseconds / 3600000).truncate();

    String hoursStr = hours > 0 ? '${hours.toString().padLeft(2, '0')}:' : '';
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');
    String hundredsStr = hundreds.toString().padLeft(2, '0');

    return '$hoursStr$minutesStr:$secondsStr.$hundredsStr';
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = _formatTime(_stopwatch.elapsedMilliseconds);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          // Stopwatch display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Stopwatch time
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isRunning
                              ? [
                                  Theme.of(context).colorScheme.primary.withOpacity(0.2 + _animationController.value * 0.05),
                                  Theme.of(context).colorScheme.primary.withOpacity(0.05 + _animationController.value * 0.05),
                                ]
                              : [
                                  Theme.of(context).colorScheme.surface,
                                  Theme.of(context).colorScheme.surface,
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _isRunning
                                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                                : Colors.transparent,
                            blurRadius: 12,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: _isRunning
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                          letterSpacing: -1,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Control buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      icon: Icons.refresh,
                      label: 'Reset',
                      color: Colors.red.shade600,
                      onPressed: _stopwatch.elapsedMilliseconds > 0 ? _resetStopwatch : null,
                    ),
                    _buildControlButton(
                      icon: _isRunning ? Icons.pause : Icons.play_arrow,
                      label: _isRunning ? 'Pause' : 'Start',
                      color: _isRunning ? Colors.orange.shade600 : Colors.green.shade600,
                      onPressed: _isRunning ? _stopStopwatch : _startStopwatch,
                      large: true,
                    ),
                    _buildControlButton(
                      icon: Icons.flag,
                      label: 'Lap',
                      color: Colors.blue.shade600,
                      onPressed: _isRunning ? _recordLap : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Laps list
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Laps header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'LAPS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Lap list header
                  if (_laps.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const SizedBox(width: 40),
                          Expanded(
                            child: Text(
                              'LAP TIME',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'OVERALL TIME',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Laps list
                  Expanded(
                    child: _laps.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.flag_outlined,
                                    size: 36,
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No laps recorded',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap the lap button to record laps',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _laps.length,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemBuilder: (context, index) {
                              final lap = _laps[index];
                              final isFirst = index == 0 && _isRunning;
                              
                              // Find fastest and slowest laps
                              if (_laps.length > 1) {
                                int fastestLapIndex = 0;
                                int slowestLapIndex = 0;
                                int fastestLapTime = _laps[0]['lapTime'];
                                int slowestLapTime = _laps[0]['lapTime'];
                                
                                for (int i = 0; i < _laps.length; i++) {
                                  final lapTime = _laps[i]['lapTime'];
                                  if (lapTime < fastestLapTime) {
                                    fastestLapTime = lapTime;
                                    fastestLapIndex = i;
                                  }
                                  if (lapTime > slowestLapTime) {
                                    slowestLapTime = lapTime;
                                    slowestLapIndex = i;
                                  }
                                }
                                
                                final isFastest = index == fastestLapIndex;
                                final isSlowest = index == slowestLapIndex;
                                
                                return _buildLapItem(
                                  lap: lap,
                                  isFirst: isFirst,
                                  isFastest: isFastest,
                                  isSlowest: isSlowest,
                                );
                              } else {
                                return _buildLapItem(
                                  lap: lap,
                                  isFirst: isFirst,
                                  isFastest: false,
                                  isSlowest: false,
                                );
                              }
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLapItem({
    required Map<String, dynamic> lap,
    required bool isFirst,
    required bool isFastest,
    required bool isSlowest,
  }) {
    Color indicatorColor = Colors.grey;
    String indicator = '';
    
    if (isFirst) {
      indicatorColor = Theme.of(context).colorScheme.primary;
      indicator = 'CURRENT';
    } else if (isFastest) {
      indicatorColor = Colors.green.shade600;
      indicator = 'FASTEST';
    } else if (isSlowest) {
      indicatorColor = Colors.red.shade600;
      indicator = 'SLOWEST';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: isFirst
            ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
            : (isFastest
                ? Colors.green.withOpacity(0.05)
                : (isSlowest
                    ? Colors.red.withOpacity(0.05)
                    : Theme.of(context).colorScheme.surface)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFirst
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : (isFastest
                  ? Colors.green.withOpacity(0.3)
                  : (isSlowest
                      ? Colors.red.withOpacity(0.3)
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.1))),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Lap number
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: indicatorColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              lap['number'].toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: indicatorColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Lap time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (indicator.isNotEmpty)
                  Text(
                    indicator,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: indicatorColor,
                    ),
                  ),
                Text(
                  _formatTime(lap['lapTime']),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: isFirst || isFastest || isSlowest ? FontWeight.bold : FontWeight.normal,
                    color: isFirst
                        ? Theme.of(context).colorScheme.primary
                        : (isFastest
                            ? Colors.green.shade600
                            : (isSlowest
                                ? Colors.red.shade600
                                : Theme.of(context).colorScheme.onSurface)),
                  ),
                ),
              ],
            ),
          ),
          
          // Total time
          Expanded(
            child: Text(
              _formatTime(lap['totalTime']),
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    bool large = false,
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
            elevation: onPressed != null ? 4 : 0,
            padding: EdgeInsets.all(large ? 18 : 14),
            shape: const CircleBorder(),
          ),
          child: Icon(icon, size: large ? 32 : 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: onPressed != null
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
} 