import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiklarm/services/theme_service.dart';
import 'package:tiklarm/services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Theme settings
  late bool _useSystemTheme;
  late bool _isDarkMode;
  
  // Sound settings
  late String _alarmSound;
  late double _alarmVolume;
  late bool _vibrationEnabled;
  
  // Timer settings
  late bool _keepScreenOn;
  late String _timeFormat;
  
  // Notification settings
  late bool _showNotifications;
  
  @override
  void initState() {
    super.initState();
    
    // Get services
    final themeService = Provider.of<ThemeService>(context, listen: false);
    final settingsService = Provider.of<SettingsService>(context, listen: false);
    
    // Initialize settings from services
    _useSystemTheme = themeService.useSystemTheme;
    _isDarkMode = themeService.isDarkMode;
    
    _alarmSound = settingsService.alarmSound;
    _alarmVolume = settingsService.alarmVolume;
    _vibrationEnabled = settingsService.vibrationEnabled;
    _keepScreenOn = settingsService.keepScreenOn;
    _timeFormat = settingsService.timeFormat;
    _showNotifications = settingsService.showNotifications;
  }

  Future<void> _saveSettings() async {
    final themeService = Provider.of<ThemeService>(context, listen: false);
    final settingsService = Provider.of<SettingsService>(context, listen: false);
    
    // Save theme settings
    await themeService.setUseSystemTheme(_useSystemTheme);
    if (!_useSystemTheme) {
      await themeService.setDarkMode(_isDarkMode);
    }
    
    // Save other settings
    await settingsService.setAlarmSound(_alarmSound);
    await settingsService.setAlarmVolume(_alarmVolume);
    await settingsService.setVibrationEnabled(_vibrationEnabled);
    await settingsService.setKeepScreenOn(_keepScreenOn);
    await settingsService.setTimeFormat(_timeFormat);
    await settingsService.setShowNotifications(_showNotifications);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final settingsService = Provider.of<SettingsService>(context, listen: false);
    final themeService = Provider.of<ThemeService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        actions: [
          // Theme toggle button
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: () {
              themeService.toggleThemeMode();
            },
          ),
          // Save button with better styling
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                foregroundColor: colorScheme.onPrimaryContainer,
                backgroundColor: colorScheme.primaryContainer,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Appearance', colorScheme, Icons.palette_outlined),
          
          // Theme settings
          SwitchListTile(
            title: const Text('Use system theme'),
            subtitle: const Text('Follow your device theme settings'),
            value: _useSystemTheme,
            onChanged: (value) {
              setState(() {
                _useSystemTheme = value;
              });
              // Apply theme change immediately
              final themeService = Provider.of<ThemeService>(context, listen: false);
              themeService.setUseSystemTheme(value);
            },
            secondary: Icon(Icons.brightness_auto, color: colorScheme.primary),
          ),
          
          if (!_useSystemTheme)
            SwitchListTile(
              title: const Text('Dark mode'),
              subtitle: const Text('Use dark theme'),
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
                // Apply theme change immediately
                final themeService = Provider.of<ThemeService>(context, listen: false);
                themeService.setDarkMode(value);
              },
              secondary: Icon(
                _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: colorScheme.primary,
              ),
            ),
            
          // Time format settings
          ListTile(
            title: const Text('Time format'),
            subtitle: Text(_timeFormat == '24h' ? '24-hour format' : '12-hour format'),
            leading: Icon(Icons.access_time, color: colorScheme.primary),
            trailing: DropdownButton<String>(
              value: _timeFormat,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _timeFormat = newValue;
                  });
                  // Apply time format change immediately
                  settingsService.setTimeFormat(newValue);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Time format updated to ${newValue == '24h' ? '24-hour' : '12-hour'} format'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
              underline: Container(),
              items: const [
                DropdownMenuItem(
                  value: '12h', 
                  child: Text('12h', style: TextStyle(fontWeight: FontWeight.w500)),
                ),
                DropdownMenuItem(
                  value: '24h', 
                  child: Text('24h', style: TextStyle(fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
          
          _buildSectionHeader('Sound & Haptics', colorScheme, Icons.volume_up_outlined),
          
          // Alarm sound settings
          ListTile(
            title: const Text('Alarm sound'),
            subtitle: Text(_alarmSound),
            leading: Icon(Icons.music_note, color: colorScheme.primary),
            trailing: DropdownButton<String>(
              value: _alarmSound,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _alarmSound = newValue;
                  });
                }
              },
              underline: Container(),
              items: settingsService.availableAlarmSounds
                  .map((sound) => DropdownMenuItem(
                        value: sound,
                        child: Text(sound),
                      ))
                  .toList(),
            ),
          ),
          
          // Volume slider
          ListTile(
            title: Text('Alarm volume: ${(_alarmVolume * 100).round()}%'),
            leading: Icon(Icons.volume_up, color: colorScheme.primary),
            subtitle: Slider(
              value: _alarmVolume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              activeColor: colorScheme.primary,
              onChanged: (value) {
                setState(() {
                  _alarmVolume = value;
                });
              },
            ),
          ),
          
          // Vibration setting
          SwitchListTile(
            title: const Text('Vibrate on alarm'),
            subtitle: const Text('Device will vibrate when alarm goes off'),
            value: _vibrationEnabled,
            onChanged: (value) {
              setState(() {
                _vibrationEnabled = value;
              });
            },
            secondary: Icon(Icons.vibration, color: colorScheme.primary),
          ),
          
          _buildSectionHeader('Timer', colorScheme, Icons.timer_outlined),
          
          // Keep screen on setting
          SwitchListTile(
            title: const Text('Keep screen on'),
            subtitle: const Text('Prevent screen from turning off while timer is running'),
            value: _keepScreenOn,
            onChanged: (value) {
              setState(() {
                _keepScreenOn = value;
              });
            },
            secondary: Icon(Icons.screen_lock_portrait, color: colorScheme.primary),
          ),
          
          _buildSectionHeader('Notifications', colorScheme, Icons.notifications_outlined),
          
          // Show notifications setting
          SwitchListTile(
            title: const Text('Show notifications'),
            subtitle: const Text('Display notifications when timer completes'),
            value: _showNotifications,
            onChanged: (value) {
              setState(() {
                _showNotifications = value;
              });
            },
            secondary: Icon(Icons.notifications, color: colorScheme.primary),
          ),
          
          _buildSectionHeader('About', colorScheme, Icons.info_outline),
          
          ListTile(
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
            leading: Icon(Icons.info, color: colorScheme.primary),
          ),
          
          ListTile(
            title: const Text('Privacy Policy'),
            leading: Icon(Icons.privacy_tip, color: colorScheme.primary),
            onTap: () {
              // TODO: Navigate to privacy policy
            },
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, ColorScheme colorScheme, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: colorScheme.primary.withOpacity(0.8),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 1,
            color: colorScheme.primary.withOpacity(0.1),
          ),
        ],
      ),
    );
  }
} 