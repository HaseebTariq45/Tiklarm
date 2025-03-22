import 'package:audioplayers/audioplayers.dart';
import 'package:tiklarm/services/settings_service.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  
  factory SoundService() {
    return _instance;
  }
  
  SoundService._internal();
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  final SettingsService _settingsService = SettingsService();
  
  // Play alarm sound based on settings
  Future<void> playAlarmSound() async {
    String sound = _settingsService.alarmSound.toLowerCase().replaceAll(' ', '_');
    if (sound == 'default') {
      sound = 'default_alarm';
    }
    
    // Set volume from settings
    await _audioPlayer.setVolume(_settingsService.alarmVolume);
    
    // Play selected sound
    await _audioPlayer.play(AssetSource('sounds/$sound.mp3'));
  }
  
  // Play timer completion sound
  Future<void> playTimerCompleteSound() async {
    // Set volume from settings
    await _audioPlayer.setVolume(_settingsService.alarmVolume);
    
    // Play timer complete sound
    await _audioPlayer.play(AssetSource('sounds/timer_complete.mp3'));
  }
  
  // Stop any playing sounds
  Future<void> stopSound() async {
    await _audioPlayer.stop();
  }
  
  // Dispose audio player resources
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
} 