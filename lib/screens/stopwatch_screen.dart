import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({Key? key}) : super(key: key);

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> with TickerProviderStateMixin {
  bool _isRunning = false;
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  final List<Map<String, dynamic>> _laps = [];
  int _lapCounter = 1;
  
  // Controllers for animations
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  
  // For tracking fastest and slowest laps
  int? _fastestLapIndex;
  int? _slowestLapIndex;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for the stopwatch when running
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Rotation animation for the decorative elements
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    
    // Wave animation for the background elements
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    
    // Start background animations
    _rotationController.repeat();
    _waveController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _rotationController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _startStopwatch() {
    setState(() {
      _isRunning = true;
      _stopwatch.start();
      _pulseController.repeat(reverse: true);
    });

    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {});
    });
  }

  void _stopStopwatch() {
    setState(() {
      _isRunning = false;
      _stopwatch.stop();
      _pulseController.stop();
    });
    _timer?.cancel();
  }

  void _resetStopwatch() {
    _stopStopwatch();
    setState(() {
      _laps.clear();
      _lapCounter = 1;
      _stopwatch.reset();
      _fastestLapIndex = null;
      _slowestLapIndex = null;
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
        
        // Update fastest and slowest laps
        _updateFastestAndSlowestLaps();
      });
    }
  }
  
  void _updateFastestAndSlowestLaps() {
    if (_laps.length <= 1) {
      _fastestLapIndex = _slowestLapIndex = null;
      return;
    }
    
    int? fastestIndex;
    int? slowestIndex;
    int? fastestTime;
    int? slowestTime;
    
    for (int i = 0; i < _laps.length; i++) {
      final lapTime = _laps[i]['lapTime'] as int;
      
      if (fastestTime == null || lapTime < fastestTime) {
        fastestTime = lapTime;
        fastestIndex = i;
      }
      
      if (slowestTime == null || lapTime > slowestTime) {
        slowestTime = lapTime;
        slowestIndex = i;
      }
    }
    
    _fastestLapIndex = fastestIndex;
    _slowestLapIndex = slowestIndex;
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
  
  String _formatLapTime(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate() % 100;
    int seconds = (milliseconds / 1000).truncate() % 60;
    int minutes = (milliseconds / 60000).truncate() % 60;
    
    String minutesStr = minutes > 0 ? '${minutes.toString()}:' : '';
    String secondsStr = seconds.toString().padLeft(2, '0');
    String hundredsStr = hundreds.toString().padLeft(2, '0');
    
    return '$minutesStr$secondsStr.$hundredsStr';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        colorScheme.background,
                        colorScheme.background,
                        colorScheme.primary.withOpacity(0.05 + 0.03 * math.sin(_waveController.value * math.pi)),
                      ]
                    : [
                        colorScheme.background,
                        colorScheme.primary.withOpacity(0.03 + 0.02 * math.sin(_waveController.value * math.pi)),
                        colorScheme.background,
                      ],
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top section with title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 15, 24, 10),
                    child: Text(
                      'Stopwatch',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onBackground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  // Stopwatch display with animations
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _isRunning ? _pulseAnimation.value : 1.0,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer circle with rotating gradient
                                AnimatedBuilder(
                                  animation: _rotationController,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: _rotationController.value * 2 * math.pi,
                                      child: Container(
                                        width: 230,
                                        height: 230,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: SweepGradient(
                                            colors: [
                                              colorScheme.primary.withOpacity(0.1),
                                              colorScheme.secondary.withOpacity(0.3),
                                              colorScheme.primary.withOpacity(0.1),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                
                                // Inner circle with time display
                                Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colorScheme.surface,
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorScheme.primary.withOpacity(0.2),
                                        blurRadius: 20,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _formatTime(_stopwatch.elapsedMilliseconds),
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                            color: _isRunning
                                                ? colorScheme.primary
                                                : colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Status text
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _isRunning
                                                ? colorScheme.primary.withOpacity(0.1)
                                                : colorScheme.surfaceVariant.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            _isRunning ? 'Running' : 'Ready',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: _isRunning
                                                  ? colorScheme.primary
                                                  : colorScheme.onSurface.withOpacity(0.7),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  // Lap counter
                  if (_laps.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_laps.length} ${_laps.length == 1 ? 'Lap' : 'Laps'}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          Text(
                            'Total: ${_formatTime(_stopwatch.elapsedMilliseconds)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Laps list
                  Expanded(
                    flex: 6,
                    child: _laps.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  size: 48,
                                  color: colorScheme.onSurface.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No laps recorded',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Press the lap button when running to record laps',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurface.withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: _laps.length,
                              itemBuilder: (context, index) {
                                // Reverse the index to show newest laps at the top
                                int reversedIndex = _laps.length - 1 - index;
                                return _buildLapItem(context, reversedIndex);
                              },
                            ),
                          ),
                  ),
                  
                  // Control buttons
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildControlButton(
                            icon: Icons.refresh,
                            label: 'Reset',
                            onPressed: _resetStopwatch,
                            color: colorScheme.error,
                            isOutlined: true,
                          ),
                          if (_isRunning)
                            _buildControlButton(
                              icon: Icons.flag_outlined,
                              label: 'Lap',
                              onPressed: _recordLap,
                              color: colorScheme.tertiary,
                            ),
                          _isRunning
                              ? _buildControlButton(
                                  icon: Icons.pause,
                                  label: 'Stop',
                                  onPressed: _stopStopwatch,
                                  color: colorScheme.secondary,
                                )
                              : _buildControlButton(
                                  icon: Icons.play_arrow,
                                  label: 'Start',
                                  onPressed: _startStopwatch,
                                  color: colorScheme.primary,
                                  isLarge: true,
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLapItem(BuildContext context, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final lap = _laps[index];
    final lapNumber = lap['number'] as int;
    final lapTime = lap['lapTime'] as int;
    final totalTime = lap['totalTime'] as int;
    
    bool isLastLap = index == 0; // First in the list is the latest lap
    bool isFastest = _fastestLapIndex == index;
    bool isSlowest = _slowestLapIndex == index;
    
    Color labelColor;
    String labelText = '';
    
    if (isLastLap) {
      labelColor = colorScheme.primary;
      labelText = 'Current';
    } else if (isFastest) {
      labelColor = Colors.green;
      labelText = 'Fastest';
    } else if (isSlowest && _laps.length > 2) {
      labelColor = Colors.orange;
      labelText = 'Slowest';
    } else {
      labelColor = Colors.transparent;
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isFastest
            ? Colors.green.withOpacity(0.07)
            : (isSlowest && _laps.length > 2)
                ? Colors.orange.withOpacity(0.07)
                : isLastLap
                    ? colorScheme.primary.withOpacity(0.05)
                    : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Lap number
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLastLap
                    ? colorScheme.primary.withOpacity(0.1)
                    : colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              alignment: Alignment.center,
              child: Text(
                lapNumber.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isLastLap
                      ? colorScheme.primary
                      : colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Lap info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lap $lapNumber',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface.withOpacity(0.9),
                        ),
                      ),
                      Text(
                        _formatLapTime(lapTime),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isFastest
                              ? Colors.green
                              : (isSlowest && _laps.length > 2)
                                  ? Colors.orange
                                  : colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (labelText.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: labelColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            labelText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: labelColor,
                            ),
                          ),
                        )
                      else
                        const SizedBox(),
                      Text(
                        _formatTime(totalTime),
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isOutlined = false,
    bool isLarge = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(isLarge ? 50 : 40),
        child: Ink(
          decoration: BoxDecoration(
            color: isOutlined ? Colors.transparent : color.withOpacity(0.9),
            borderRadius: BorderRadius.circular(isLarge ? 50 : 40),
            border: isOutlined ? Border.all(color: color, width: 2) : null,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isLarge ? 32 : 24,
            vertical: 16,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isOutlined ? color : Colors.white,
                size: isLarge ? 28 : 24,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: isLarge ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: isOutlined ? color : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 