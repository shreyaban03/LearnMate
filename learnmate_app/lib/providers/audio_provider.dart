import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

enum AudioStatus {
  stopped,
  playing,
  paused,
  loading,
  error,
}

class AudioProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioStatus _status = AudioStatus.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _currentUrl;
  String? _errorMessage;

  // Getters
  AudioStatus get status => _status;
  Duration get duration => _duration;
  Duration get position => _position;
  String? get currentUrl => _currentUrl;
  String? get errorMessage => _errorMessage;
  double get progress => _duration.inMilliseconds > 0 
      ? _position.inMilliseconds / _duration.inMilliseconds 
      : 0.0;
  bool get isPlaying => _status == AudioStatus.playing;
  bool get isPaused => _status == AudioStatus.paused;
  bool get isLoading => _status == AudioStatus.loading;

  AudioProvider() {
    _setupListeners();
  }

  void _setupListeners() {
    _audioPlayer.onDurationChanged.listen((duration) {
      _duration = duration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _position = position;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      _status = AudioStatus.stopped;
      _position = Duration.zero;
      notifyListeners();
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      switch (state) {
        case PlayerState.playing:
          _status = AudioStatus.playing;
          break;
        case PlayerState.paused:
          _status = AudioStatus.paused;
          break;
        case PlayerState.stopped:
          _status = AudioStatus.stopped;
          break;
        case PlayerState.completed:
          _status = AudioStatus.stopped;
          _position = Duration.zero;
          break;
        case PlayerState.disposed:
          _status = AudioStatus.stopped;
          break;
      }
      notifyListeners();
    });
  }

  // Load and play audio
  Future<bool> loadAndPlay(String url) async {
    try {
      _status = AudioStatus.loading;
      _currentUrl = url;
      _clearError();
      notifyListeners();

      await _audioPlayer.setSourceUrl(url);
      await _audioPlayer.resume();
      return true;
    } catch (e) {
      _handleError('Failed to load audio: ${e.toString()}');
      return false;
    }
  }

  // Play/Pause toggle
  Future<void> togglePlayPause() async {
    try {
      if (_status == AudioStatus.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
    } catch (e) {
      _handleError('Playback error: ${e.toString()}');
    }
  }

  // Seek to position
  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      _handleError('Seek error: ${e.toString()}');
    }
  }

  // Seek by percentage
  Future<void> seekToPercentage(double percentage) async {
    if (_duration.inMilliseconds > 0) {
      final position = Duration(
        milliseconds: (_duration.inMilliseconds * percentage).round(),
      );
      await seekTo(position);
    }
  }

  // Skip forward
  Future<void> skipForward([Duration amount = const Duration(seconds: 10)]) async {
    final newPosition = _position + amount;
    if (newPosition <= _duration) {
      await seekTo(newPosition);
    }
  }

  // Skip backward
  Future<void> skipBackward([Duration amount = const Duration(seconds: 10)]) async {
    final newPosition = _position - amount;
    if (newPosition >= Duration.zero) {
      await seekTo(newPosition);
    } else {
      await seekTo(Duration.zero);
    }
  }

  // Stop audio
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _position = Duration.zero;
      _status = AudioStatus.stopped;
      notifyListeners();
    } catch (e) {
      _handleError('Stop error: ${e.toString()}');
    }
  }

  // Set playback speed
  Future<void> setPlaybackRate(double rate) async {
    try {
      await _audioPlayer.setPlaybackRate(rate);
    } catch (e) {
      _handleError('Playback rate error: ${e.toString()}');
    }
  }

  void _handleError(String message) {
    _errorMessage = message;
    _status = AudioStatus.error;
    notifyListeners();
    debugPrint('AudioProvider Error: $message');
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
```

