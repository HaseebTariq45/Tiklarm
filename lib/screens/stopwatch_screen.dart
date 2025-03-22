import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tiklarm/services/timer_service.dart';
import 'package:flutter/foundation.dart';

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
  late Animation<double> _scaleAnimation;
  
  // For tracking fastest and slowest laps
  int? _fastestLapIndex;
  int? _slowestLapIndex;
  
  // Service for wakelock management
  final TimerService _timerService = TimerService();

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
    
    // Scale animation for UI elements
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    
    // Rotation animation for the decorative elements
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    
    // Wave animation for the background elements
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    
    // Start background animations
    _rotationController.repeat();
    _waveController.repeat(reverse: true);
    
    // Add a small delay for initial animations
    Future.delayed(const Duration(milliseconds: 200), () {
      _pulseController.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _rotationController.dispose();
    _waveController.dispose();
    
    // Ensure wakelock is disabled when leaving screen
    try {
      _timerService.handleWakelock(false);
    } catch (e) {
      debugPrint('Error disabling wakelock: $e');
    }
    
    super.dispose();
  }

  void _startStopwatch() {
    if (!_isRunning) {
      setState(() {
        _isRunning = true;
        _stopwatch.start();
        _pulseController.repeat(reverse: true);
      });
      
      _startTimer();
      
      // Enable wakelock if running
      try {
        _timerService.handleWakelock(true);
      } catch (e) {
        debugPrint('Error enabling wakelock: $e');
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        // This will trigger a rebuild to update the displayed time
      });
    });
  }

  void _stopStopwatch() {
    if (_isRunning) {
      setState(() {
        _isRunning = false;
        _stopwatch.stop();
        _pulseController.stop();
      });
      _timer?.cancel();
      
      // Disable wakelock when stopped
      try {
        _timerService.handleWakelock(false);
      } catch (e) {
        debugPrint('Error disabling wakelock: $e');
      }
    }
  }

  void _resetStopwatch() {
    setState(() {
      _stopwatch.reset();
      _laps.clear();
      _lapCounter = 1;
      _fastestLapIndex = null;
      _slowestLapIndex = null;
    });
    
    // Ensure wakelock is disabled on reset
    try {
      _timerService.handleWakelock(false);
    } catch (e) {
      debugPrint('Error disabling wakelock: $e');
    }
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
    
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Color(0xFF1A1A2E),
                      Color(0xFF16213E),
                      Color(0xFF1A1A2E),
                    ]
                  : [
                      colorScheme.primary.withOpacity(0.05),
                      colorScheme.primary.withOpacity(0.1),
                      colorScheme.primary.withOpacity(0.05),
                    ],
            ),
          ),
          child: CustomPaint(
            painter: BackgroundPainter(
              waveValue: _waveController.value,
              rotationValue: _rotationController.value,
              isDark: isDark,
              colorScheme: colorScheme,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Stopwatch display with animations
                AnimatedBuilder(
                  animation: Listenable.merge([_pulseAnimation, _scaleAnimation]),
                  builder: (context, child) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 30, bottom: 20),
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Column(
                          children: [
                            // Primary timer display
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                // Animated rings
                                ...List.generate(3, (index) {
                                  final delay = index * 0.33;
                                  final offsetAngle = index * math.pi / 3;
                                  return AnimatedBuilder(
                                    animation: _rotationController,
                                    builder: (context, child) {
                                      return Transform.rotate(
                                        angle: _rotationController.value * 2 * math.pi + offsetAngle,
                                        child: Container(
                                          width: 260 - (index * 10),
                                          height: 260 - (index * 10),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              width: 1.5,
                                              color: colorScheme.primary.withOpacity(
                                                _isRunning ? 
                                                  0.1 + (0.1 * math.sin((_rotationController.value + delay) * math.pi * 2)) : 
                                                  0.1,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),
                                
                                // Main time container
                                Transform.scale(
                                  scale: _isRunning ? _pulseAnimation.value : 1.0,
                                  child: Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark ? 
                                        Colors.black.withOpacity(0.4) : 
                                        Colors.white.withOpacity(0.7),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorScheme.primary.withOpacity(isDark ? 0.2 : 0.1),
                                          blurRadius: 20,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                        child: Container(
                                          color: Colors.transparent,
                                          padding: const EdgeInsets.all(16),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                // Main timer text
                                                ShaderMask(
                                                  shaderCallback: (bounds) {
                                                    return LinearGradient(
                                                      colors: [
                                                        colorScheme.primary,
                                                        colorScheme.primary.withBlue(
                                                          math.min(255, colorScheme.primary.blue + 40)
                                                        ),
                                                      ],
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                    ).createShader(bounds);
                                                  },
                                                  child: Text(
                                                    _formatTime(_stopwatch.elapsedMilliseconds),
                                                    style: TextStyle(
                                                      fontSize: 38,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 1,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                
                                                // Status indicator
                                                AnimatedContainer(
                                                  duration: const Duration(milliseconds: 300),
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 16, 
                                                    vertical: 6
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _isRunning
                                                        ? colorScheme.primary.withOpacity(0.15)
                                                        : Colors.grey.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(
                                                      color: _isRunning
                                                          ? colorScheme.primary.withOpacity(0.3)
                                                          : Colors.grey.withOpacity(0.2),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      if (_isRunning)
                                                        Container(
                                                          width: 8,
                                                          height: 8,
                                                          margin: const EdgeInsets.only(right: 6),
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            color: colorScheme.primary,
                                                          ),
                                                        ),
                                                      Text(
                                                        _isRunning ? 'Running' : 'Ready',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w500,
                                                          color: _isRunning
                                                              ? colorScheme.primary
                                                              : colorScheme.onSurface.withOpacity(0.6),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                // Lap counter and statistics
                if (_laps.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark 
                        ? Colors.black.withOpacity(0.2) 
                        : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? colorScheme.primary.withOpacity(0.1)
                            : colorScheme.primary.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Lap counter
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_laps.length} ${_laps.length == 1 ? 'Lap' : 'Laps'}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Best: ${_fastestLapIndex != null ? _formatLapTime(_laps[_fastestLapIndex!]['lapTime']) : "--:--"}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        
                        // Total time
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total Time',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatTime(_stopwatch.elapsedMilliseconds),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                
                // Lap list
                Expanded(
                  child: _laps.isEmpty
                      ? Center(
                          child: AnimatedOpacity(
                            opacity: 0.7,
                            duration: const Duration(milliseconds: 500),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark
                                        ? colorScheme.surface.withOpacity(0.1)
                                        : colorScheme.primary.withOpacity(0.05),
                                  ),
                                  child: Icon(
                                    Icons.flag_outlined,
                                    size: 40,
                                    color: colorScheme.primary.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.black.withOpacity(0.1)
                                        : Colors.white.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'No laps recorded',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: colorScheme.onSurface.withOpacity(0.8),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Press the lap button while running\nto record lap times',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          decoration: BoxDecoration(
                            color: isDark 
                              ? Colors.black.withOpacity(0.1) 
                              : Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark
                                  ? colorScheme.primary.withOpacity(0.1)
                                  : colorScheme.primary.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                                itemCount: _laps.length,
                                itemBuilder: (context, index) {
                                  // Reverse the index to show newest laps at the top
                                  int reversedIndex = _laps.length - 1 - index;
                                  return _buildLapItem(context, reversedIndex);
                                },
                              ),
                            ),
                          ),
                        ),
                ),
                
                // Control buttons
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? Colors.black.withOpacity(0.2) 
                        : Colors.white.withOpacity(0.8),
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
                          icon: Icons.refresh_rounded,
                          label: 'Reset',
                          onPressed: _stopwatch.elapsedMilliseconds > 0 ? _resetStopwatch : null,
                          color: colorScheme.error,
                          isOutlined: true,
                        ),
                        if (_isRunning)
                          _buildControlButton(
                            icon: Icons.flag_rounded,
                            label: 'Lap',
                            onPressed: _recordLap,
                            color: colorScheme.tertiary,
                          ),
                        _isRunning
                            ? _buildControlButton(
                                icon: Icons.pause_rounded,
                                label: 'Stop',
                                onPressed: _stopStopwatch,
                                color: colorScheme.secondary,
                              )
                            : _buildControlButton(
                                icon: Icons.play_arrow_rounded,
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
    );
  }

  Widget _buildLapItem(BuildContext context, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: isFastest
            ? Colors.green.withOpacity(isDark ? 0.1 : 0.07)
            : (isSlowest && _laps.length > 2)
                ? Colors.orange.withOpacity(isDark ? 0.1 : 0.07)
                : isLastLap
                    ? colorScheme.primary.withOpacity(isDark ? 0.1 : 0.07)
                    : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Lap number
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLastLap
                    ? colorScheme.primary.withOpacity(0.15)
                    : isFastest
                        ? Colors.green.withOpacity(0.1)
                        : isSlowest && _laps.length > 2
                            ? Colors.orange.withOpacity(0.1)
                            : colorScheme.surfaceVariant.withOpacity(0.15),
                border: Border.all(
                  color: isLastLap
                      ? colorScheme.primary.withOpacity(0.3)
                      : isFastest
                          ? Colors.green.withOpacity(0.3)
                          : isSlowest && _laps.length > 2
                              ? Colors.orange.withOpacity(0.3)
                              : Colors.transparent,
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                lapNumber.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isLastLap
                      ? colorScheme.primary
                      : isFastest
                          ? Colors.green
                          : isSlowest && _laps.length > 2
                              ? Colors.orange
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
                      Row(
                        children: [
                          Text(
                            'Lap $lapNumber',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface.withOpacity(0.9),
                            ),
                          ),
                          if (labelText.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
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
                            ),
                        ],
                      ),
                      Text(
                        _formatLapTime(lapTime),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
                  Text(
                    'Total: ${_formatTime(totalTime)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
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
    required VoidCallback? onPressed,
    required Color color,
    bool isOutlined = false,
    bool isLarge = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedOpacity(
      opacity: onPressed == null ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(isLarge ? 26 : 22),
          child: Ink(
            decoration: BoxDecoration(
              color: isOutlined 
                ? Colors.transparent 
                : isDark 
                    ? color.withOpacity(0.8) 
                    : color.withOpacity(0.9),
              borderRadius: BorderRadius.circular(isLarge ? 26 : 22),
              border: isOutlined ? Border.all(color: color, width: 2) : null,
              boxShadow: isOutlined || onPressed == null
                  ? null
                  : [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isLarge ? 32 : 24,
              vertical: 14,
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
                    fontSize: isLarge ? 17 : 15,
                    fontWeight: FontWeight.bold,
                    color: isOutlined ? color : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom background painter for animated visual elements
class BackgroundPainter extends CustomPainter {
  final double waveValue;
  final double rotationValue;
  final bool isDark;
  final ColorScheme colorScheme;
  
  BackgroundPainter({
    required this.waveValue,
    required this.rotationValue,
    required this.isDark,
    required this.colorScheme,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    
    // Paint for the circles
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Draw decorative elements
    _drawDecorations(canvas, size, paint);
  }
  
  void _drawDecorations(Canvas canvas, Size size, Paint paint) {
    final width = size.width;
    final height = size.height;
    
    // Draw top-right decoration
    paint.color = isDark
        ? colorScheme.primary.withOpacity(0.1)
        : colorScheme.primary.withOpacity(0.1);
        
    final topRightCircleX = width * 0.9 + (width * 0.1 * math.sin(waveValue * math.pi));
    final topRightCircleY = height * 0.15 + (height * 0.05 * math.cos(waveValue * math.pi));
    final topRightCircleRadius = width * 0.2 + (width * 0.02 * math.sin(waveValue * math.pi * 2));
    
    canvas.drawCircle(
      Offset(topRightCircleX, topRightCircleY),
      topRightCircleRadius,
      paint,
    );
    
    // Draw bottom-left decoration
    paint.color = isDark
        ? colorScheme.secondary.withOpacity(0.1)
        : colorScheme.secondary.withOpacity(0.1);
        
    final bottomLeftCircleX = width * 0.15 + (width * 0.05 * math.cos(waveValue * math.pi));
    final bottomLeftCircleY = height * 0.85 + (height * 0.03 * math.sin(waveValue * math.pi));
    final bottomLeftCircleRadius = width * 0.25 + (width * 0.015 * math.cos(waveValue * math.pi * 2));
    
    canvas.drawCircle(
      Offset(bottomLeftCircleX, bottomLeftCircleY),
      bottomLeftCircleRadius,
      paint,
    );
    
    // Draw a third decoration
    paint.color = isDark
        ? colorScheme.tertiary.withOpacity(0.1)
        : colorScheme.tertiary.withOpacity(0.1);
        
    final thirdCircleX = width * 0.3 + (width * 0.03 * math.sin(waveValue * math.pi * 1.5));
    final thirdCircleY = height * 0.3 + (height * 0.02 * math.cos(waveValue * math.pi * 1.5));
    final thirdCircleRadius = width * 0.15 + (width * 0.01 * math.sin(waveValue * math.pi * 3));
    
    canvas.drawCircle(
      Offset(thirdCircleX, thirdCircleY),
      thirdCircleRadius,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) {
    return oldDelegate.waveValue != waveValue || 
           oldDelegate.rotationValue != rotationValue;
  }
} 