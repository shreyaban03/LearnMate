import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../widgets/prompt_input.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  
  // Animation controllers
  late AnimationController _chipAnimationController;
  late AnimationController _submitAnimationController;
  late AnimationController _brainAnimationController;
  late AnimationController _robotAnimationController;
  late AnimationController _headerAnimationController;
  
  // Animations
  late List<Animation<double>> _chipAnimations;
  late Animation<double> _submitScaleAnimation;
  late Animation<double> _brainSlideAnimation;
  late Animation<double> _robotSlideAnimation;
  late Animation<double> _brainFadeAnimation;
  late Animation<double> _robotFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;
  
  bool _isLoading = false;
  String? _errorText;
  
  final List<String> _suggestedTopics = [
    '🔬 Quantum Physics',
    '🤖 Machine Learning', 
    '🏛️ Ancient History',
    '🌍 Climate Change',
    '🚀 Space Exploration',
    '🧠 Human Psychology',
    '💰 Cryptocurrency',
    '🎨 Art History',
    '⚡ Renewable Energy',
    '🧬 Neuroscience',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Chip animations
    _chipAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    // Submit button animation
    _submitAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // Brain animation controller
    _brainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Robot animation controller  
    _robotAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Header animation controller
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create staggered animations for chips
    _chipAnimations = List.generate(
      _suggestedTopics.length,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _chipAnimationController,
        curve: Interval(
          index * 0.08,
          (index * 0.08) + 0.5,
          curve: Curves.elasticOut,
        ),
      )),
    );

    _submitScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _submitAnimationController,
      curve: Curves.easeInOut,
    ));

    // Brain slide animation (from left)
    _brainSlideAnimation = Tween<double>(
      begin: -150.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _brainAnimationController,
      curve: Curves.elasticOut,
    ));

    _brainFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _brainAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Robot slide animation (from right)
    _robotSlideAnimation = Tween<double>(
      begin: 150.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _robotAnimationController,
      curve: Curves.elasticOut,
    ));

    _robotFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _robotAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Header animations
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutBack,
    ));

    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimationSequence() async {
    // Start header animation first
    _headerAnimationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Start brain and robot animations with slight delay
    _brainAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _robotAnimationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Start chip animations last
    _chipAnimationController.forward();
  }

  @override
  void dispose() {
    _chipAnimationController.dispose();
    _submitAnimationController.dispose();
    _brainAnimationController.dispose();
    _robotAnimationController.dispose();
    _headerAnimationController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  void _selectTopic(String topic) {
    setState(() {
      _promptController.text = topic.replaceAll(RegExp(r'[🔬🤖🏛️🌍🚀🧠💰🎨⚡🧬]\s'), '');
      _errorText = null;
    });
  }

  Future<void> _submitPrompt() async {
    if (_promptController.text.trim().isEmpty) {
      setState(() {
        _errorText = 'Please enter a topic to learn about';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorText = null;
    });
    
    _submitAnimationController.forward().then((_) {
      _submitAnimationController.reverse();
    });
    
    // Simulate API call to /generate_lesson
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      
      // Navigate to video screen with dummy data
      Navigator.pushNamed(
        context,
        '/video',
        arguments: {
          'topic': _promptController.text.trim(),
          'audioUrl': 'https://example.com/audio.mp3',
          'avatarName': _generateRandomAvatarName(),
          'flashNotes': _generateDummyFlashNotes(_promptController.text.trim()),
        },
      );
    }
  }

  String _generateRandomAvatarName() {
    final names = [
      'Prof. Nova',
      'Dr. Sage',
      'Prof. Luna',
      'Dr. Cosmos',
      'Prof. Iris',
      'Dr. Phoenix',
      'Prof. Atlas',
      'Dr. Vega',
    ];
    names.shuffle();
    return names.first;
  }

  List<Map<String, String>> _generateDummyFlashNotes(String topic) {
    return [
      {
        'q': 'What is $topic?',
        'a': 'This is a comprehensive explanation of $topic that covers the fundamental concepts and principles.',
      },
      {
        'q': 'How does $topic work?',
        'a': 'The mechanism behind $topic involves several key processes and interactions that work together.',
      },
      {
        'q': 'Where is $topic used?',
        'a': '$topic has applications in various fields and industries, making it highly relevant in today\'s world.',
      },
      {
        'q': 'Why is $topic important?',
        'a': 'Understanding $topic is crucial because it impacts many aspects of our daily lives and future developments.',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.background,
              theme.colorScheme.surface,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Animated Header with Lottie characters
                  const SizedBox(height: 10),
                  _buildAnimatedHeader(theme),
                  
                  const SizedBox(height: 32),
                  
                  // Animated Topic Chips
                  _buildTopicChips(theme),
                  
                  const SizedBox(height: 32),
                  
                  // Prompt Input
                  PromptInput(
                    controller: _promptController,
                    hintText: 'Type your learning topic here...',
                    errorText: _errorText,
                    isLoading: _isLoading,
                    onSubmit: _submitPrompt,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Submit Button
                  _buildSubmitButton(theme),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader(ThemeData theme) {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: FadeTransition(
        opacity: _headerFadeAnimation,
        child: Column(
          children: [
            // Lottie characters row
            SizedBox(
              height: 120,
              child: Stack(
                children: [
                  // Brain animation (left side)
                  AnimatedBuilder(
                    animation: Listenable.merge([_brainSlideAnimation, _brainFadeAnimation]),
                    builder: (context, child) {
                      return Positioned(
                        left: _brainSlideAnimation.value,
                        child: Opacity(
                          opacity: _brainFadeAnimation.value,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Lottie.asset(
                              'assets/lottie/funny_brain.json',
                              width: 80,
                              height: 80,
                              fit: BoxFit.contain,
                              repeat: true,
                              animate: true,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Robot animation (right side)
                  AnimatedBuilder(
                    animation: Listenable.merge([_robotSlideAnimation, _robotFadeAnimation]),
                    builder: (context, child) {
                      return Positioned(
                        right: _robotSlideAnimation.value,
                        child: Opacity(
                          opacity: _robotFadeAnimation.value,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Lottie.asset(
                              'assets/lottie/ai_robot.json',
                              width: 80,
                              height: 80,
                              fit: BoxFit.contain,
                              repeat: true,
                              animate: true,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title text
            Text(
              'What do you want to\nlearn today?',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.2,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Choose a topic below or type your own question',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicChips(ThemeData theme) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: List.generate(
            _suggestedTopics.length,
            (index) => AnimatedBuilder(
              animation: _chipAnimations[index],
              builder: (context, child) {
                return Transform.scale(
                  scale: _chipAnimations[index].value,
                  child: Opacity(
                    opacity: _chipAnimations[index].value,
                    child: _buildTopicChip(_suggestedTopics[index], theme),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicChip(String topic, ThemeData theme) {
    return GestureDetector(
      onTap: () => _selectTopic(topic),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              theme.colorScheme.surface,
              theme.colorScheme.primary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          topic,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return AnimatedBuilder(
      animation: _submitScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _submitScaleAnimation.value,
          child: Container(
            width: double.infinity,
            height: 60,
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
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitPrompt,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Preparing your lesson...',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      '🎯 Teach Me Now!',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
