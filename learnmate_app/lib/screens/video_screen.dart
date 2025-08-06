import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _avatarAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _loadingAnimationController;
  late AnimationController _controlsAnimationController;
  late AnimationController _progressAnimationController;
  
  // Animations
  late Animation<double> _avatarScaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _loadingFadeAnimation;
  late Animation<Offset> _controlsSlideAnimation;
  late Animation<double> _controlsFadeAnimation;
  late Animation<double> _progressGlowAnimation;

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

  // Sample fallback URL
  static const _fallbackAudioUrl =
      'https://www.soundjay.com/misc/sounds/bell-ringing-05.mp3';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupAudioListeners();
    _startLoadingSequence();
  }

  void _initializeAnimations() {
    _avatarAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _avatarScaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _avatarAnimationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    _loadingFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _loadingAnimationController,
      curve: Curves.easeOut,
    ));

    _controlsSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controlsAnimationController,
      curve: Curves.easeOutBack,
    ));

    _controlsFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controlsAnimationController,
      curve: Curves.easeOut,
    ));

    _progressGlowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupAudioListeners() {
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
  }

  void _startLoadingSequence() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => _isLoading = false);
      _loadingAnimationController.forward();
      
      await Future.delayed(const Duration(milliseconds: 300));
      _controlsAnimationController.forward();
      _prepareAudio();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    _loadingAnimationController.dispose();
    _controlsAnimationController.dispose();
    _progressAnimationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _prepareAudio() async {
    final url = _audioUrl.isNotEmpty ? _audioUrl : _fallbackAudioUrl;
    try {
      await _audioPlayer.setSourceUrl(url);
    } catch (e) {
      debugPrint('Error loading audio "$url": $e');
      setState(() {
        _totalDuration = const Duration(minutes: 2, seconds: 30);
      });
      _startProgressSimulation();
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
      setState(() => _isPlaying = !_isPlaying);
    } catch (e) {
      debugPrint('Playback toggle error: $e');
      setState(() => _isPlaying = !_isPlaying);
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
      debugPrint('Seek error: $e');
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
    return '${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A0A0B),
              const Color(0xFF1A1A2E),
              theme.colorScheme.primary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced AppBar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _avatarName,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '🎓 Live AI Lecture',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red, Colors.red.shade700],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'LIVE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Avatar Section with Loading State
              Expanded(
                flex: 3,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Loading State
                      if (_isLoading)
                        FadeTransition(
                          opacity: _loadingFadeAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 140,
                                height: 140,
                                child: Lottie.asset(
                                  'assets/lottie/loading.json',
                                  fit: BoxFit.contain,
                                  repeat: true,
                                  animate: true,
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                '🎭 Preparing your AI teacher...',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Getting ready to teach you about $_topic',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      
                      // Avatar Display
                      if (!_isLoading)
                        AnimatedBuilder(
                          animation: Listenable.merge([
                            _avatarAnimationController,
                            _pulseAnimation,
                          ]),
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _avatarScaleAnimation.value * 
                                     (_isPlaying ? _pulseAnimation.value : 1.0),
                              child: Container(
                                width: 280,
                                height: 280,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      theme.colorScheme.primary.withOpacity(0.3),
                                      theme.colorScheme.secondary.withOpacity(0.2),
                                      theme.colorScheme.tertiary.withOpacity(0.1),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withOpacity(0.6),
                                      blurRadius: 60,
                                      spreadRadius: 20,
                                    ),
                                    BoxShadow(
                                      color: theme.colorScheme.secondary.withOpacity(0.4),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Lottie.asset(
                                      'assets/lottie/ai_teacher_avatar.json',
                                      fit: BoxFit.contain,
                                      repeat: true,
                                      animate: true,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),

              // Topic Display
              if (!_isLoading)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.2),
                        theme.colorScheme.secondary.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.school,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Teaching: $_topic',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Audio Controls Section
              SlideTransition(
                position: _controlsSlideAnimation,
                child: FadeTransition(
                  opacity: _controlsFadeAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Drag Handle
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          
                          const SizedBox(height: 24),

                          // Progress Bar with Glow Effect
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(_currentPosition),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(_totalDuration),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              AnimatedBuilder(
                                animation: _progressGlowAnimation,
                                builder: (context, child) {
                                  return Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      boxShadow: _isPlaying ? [
                                        BoxShadow(
                                          color: theme.colorScheme.primary.withOpacity(
                                            0.4 * _progressGlowAnimation.value,
                                          ),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ] : null,
                                    ),
                                    child: LinearProgressIndicator(
                                      value: _progress,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        theme.colorScheme.primary,
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Enhanced Play Controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildControlButton(
                                icon: Icons.replay_10,
                                onPressed: () {
                                  setState(() {
                                    _progress = math.max(0, _progress - 0.1);
                                    _currentPosition = Duration(
                                      milliseconds: (_totalDuration.inMilliseconds * _progress).round(),
                                    );
                                  });
                                },
                              ),
                              
                              // Main Play Button
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.secondary,
                                      theme.colorScheme.tertiary,
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: _isLoading ? null : _togglePlayPause,
                                  icon: Icon(
                                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                ),
                              ),
                              
                              _buildControlButton(
                                icon: Icons.forward_10,
                                onPressed: () {
                                  setState(() {
                                    _progress = math.min(1.0, _progress + 0.1);
                                    _currentPosition = Duration(
                                      milliseconds: (_totalDuration.inMilliseconds * _progress).round(),
                                    );
                                  });
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Skip Button
                          TextButton(
                            onPressed: _navigateToFlashNotes,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Skip to Flash Notes',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 18,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
      ),
    );
  }
}
