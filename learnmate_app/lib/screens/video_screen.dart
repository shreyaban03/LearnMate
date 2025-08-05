import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen>
    with TickerProviderStateMixin {
  late AnimationController _avatarAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _avatarScaleAnimation;
  late Animation<double> _pulseAnimation;
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = true;
  double _progress = 0.0;
  Duration _totalDuration = const Duration(minutes: 2, seconds: 30);
  Duration _currentPosition = Duration.zero;
  
  String _topic = '';
  String _avatarName = 'Prof. Nova';
  String _audioUrl = '';
  List<Map<String, String>> _flashNotes = [];

  @override
  void initState() {
    super.initState();
    
    _avatarAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _avatarScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _avatarAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _avatarAnimationController.repeat(reverse: true);
    
    // Set up audio player listeners
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });
    
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _progress = _totalDuration.inMilliseconds > 0
              ? position.inMilliseconds / _totalDuration.inMilliseconds
              : 0.0;
        });
      }
    });
    
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _progress = 1.0;
        });
        _navigateToFlashNotes();
      }
    });
    
    // Simulate loading and prepare audio
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _prepareAudio();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get arguments passed from home screen
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _topic = args['topic'] ?? '';
      _avatarName = args['avatarName'] ?? 'Prof. Nova';
      _audioUrl = args['audioUrl'] ?? '';
      _flashNotes = List<Map<String, String>>.from(args['flashNotes'] ?? []);
    }
  }

  @override
  void dispose() {
    _avatarAnimationController.dispose();
    _pulseAnimationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _prepareAudio() async {
    try {
      // For demo purposes, we'll use a sample MP3 URL
      // In production, this would be the actual audio URL from the backend
      const sampleAudioUrl = 'https://www.soundjay.com/misc/sounds/bell-ringing-05.mp3';
      await _audioPlayer.setSourceUrl(sampleAudioUrl);
    } catch (e) {
      print('Error preparing audio: $e');
      // Fallback to simulation if audio fails
      setState(() {
        _totalDuration = const Duration(minutes: 2, seconds: 30);
      });
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        _pulseAnimationController.stop();
      } else {
        await _audioPlayer.resume();
        _pulseAnimationController.repeat(reverse: true);
      }
      
      setState(() {
        _isPlaying = !_isPlaying;
      });
    } catch (e) {
      print('Error toggling playback: $e');
      // Fallback to simulation
      setState(() {
        _isPlaying = !_isPlaying;
      });
      
      if (_isPlaying) {
        _pulseAnimationController.repeat(reverse: true);
        _startProgressSimulation();
      } else {
        _pulseAnimationController.stop();
      }
    }
  }

  void _startProgressSimulation() {
    if (!_isPlaying) return;
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _isPlaying) {
        setState(() {
          _progress += 0.001;
          _currentPosition = Duration(
            milliseconds: (_totalDuration.inMilliseconds * _progress).round(),
          );
          
          if (_progress >= 1.0) {
            _progress = 1.0;
            _isPlaying = false;
            _pulseAnimationController.stop();
            _navigateToFlashNotes();
            return;
          }
        });
        _startProgressSimulation();
      }
    });
  }

  Future<void> _seekTo(double value) async {
    final position = Duration(
      milliseconds: (_totalDuration.inMilliseconds * value).round(),
    );
    
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      print('Error seeking: $e');
      // Fallback to manual progress update
      setState(() {
        _progress = value;
        _currentPosition = position;
      });
    }
  }

  void _navigateToFlashNotes() {
    Navigator.pushReplacementNamed(
      context,
      '/flash_notes',
      arguments: {
        'topic': _topic,
        'flashNotes': _flashNotes,
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _avatarName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Live AI Lecture',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Avatar Section
          Expanded(
            flex: 3,
            child: Center(
              child: _isLoading
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                                Theme.of(context).colorScheme.tertiary,
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const CircularProgressIndicator(
                            strokeWidth: 6,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '🎭 Preparing your AI teacher...',
                          style: GoogleFonts.balooBhai2(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Getting ready to teach you about $_topic',
                          style: GoogleFonts.nunito(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : AnimatedBuilder(
                      animation: _avatarAnimationController,
                      builder: (context, child) {
                        return AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _avatarScaleAnimation.value * 
                                     (_isPlaying ? _pulseAnimation.value : 1.0),
                              child: Container(
                                width: 250,
                                height: 250,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                      Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                                      Theme.of(context).colorScheme.tertiary.withOpacity(0.4),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                                      blurRadius: 40,
                                      spreadRadius: 20,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Container(
                                    width: 180,
                                    height: 180,
                                    child: Lottie.asset(
                                      'assets/animations/ai_teacher_avatar.json',
                                      fit: BoxFit.contain,
                                      repeat: true,
                                      animate: true,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
          
          // Topic Display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Teaching: $_topic',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Audio Controls Section
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Progress Bar
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_currentPosition),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _formatDuration(_totalDuration),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Play Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _progress = math.max(0, _progress - 0.1);
                              _currentPosition = Duration(
                                milliseconds: (_totalDuration.inMilliseconds * _progress).round(),
                              );
                            });
                          },
                          icon: const Icon(Icons.replay_10),
                          iconSize: 32,
                        ),
                        
                        const SizedBox(width: 24),
                        
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: _isLoading ? null : _togglePlayPause,
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 24),
                        
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _progress = math.min(1.0, _progress + 0.1);
                              _currentPosition = Duration(
                                milliseconds: (_totalDuration.inMilliseconds * _progress).round(),
                              );
                            });
                          },
                          icon: const Icon(Icons.forward_10),
                          iconSize: 32,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Skip to Notes Button
                    TextButton(
                      onPressed: _navigateToFlashNotes,
                      child: Text(
                        'Skip to Flash Notes →',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
