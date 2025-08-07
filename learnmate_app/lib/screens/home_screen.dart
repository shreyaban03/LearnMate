## 2. Updated HomeScreen with Provider
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../widgets/prompt_input.dart';
import '../providers/auth_provider.dart';
import '../providers/lesson_provider.dart';

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
    
    // Load user's lesson history
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user?.uid != null) {
        context.read<LessonProvider>().loadLessonHistory(authProvider.user!.uid!);
      }
    });
  }

  void _initializeAnimations() {
    _chipAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    _submitAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _brainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _robotAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
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
    _headerAnimationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    
    _brainAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _robotAnimationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    
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
      _errorText = null;
    });
    
    _submitAnimationController.forward().then((_) {
      _submitAnimationController.reverse();
    });
    
    final authProvider = context.read<AuthProvider>();
    final lessonProvider = context.read<LessonProvider>();
    
    // Generate lesson using provider
    final success = await lessonProvider.generateMockLesson(_promptController.text.trim());
    // For real backend: await lessonProvider.generateLesson(_promptController.text.trim(), authProvider.user?.uid);
    
    if (success && mounted) {
      // Navigate to video screen with generated lesson
      Navigator.pushNamed(
        context,
        '/video',
        arguments: {
          'lesson': lessonProvider.currentLesson,
        },
      );
    } else if (lessonProvider.errorMessage != null && mounted) {
      setState(() {
        _errorText = lessonProvider.errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
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
                  
                  // Recent Lessons Section
                  _buildRecentLessons(theme),
                  
                  const SizedBox(height: 24),
                  
                  // Animated Topic Chips
                  _buildTopicChips(theme),
                  
                  const SizedBox(height: 32),
                  
                  // Prompt Input
                  Consumer<LessonProvider>(
                    builder: (context, lessonProvider, child) {
                      return PromptInput(
                        controller: _promptController,
                        hintText: 'Type your learning topic here...',
                        errorText: _errorText ?? lessonProvider.errorMessage,
                        isLoading: lessonProvider.isGenerating,
                        onSubmit: _submitPrompt,
                      );
                    },
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

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LearnMate',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Text(
                    'Welcome back, ${authProvider.user?.email?.split('@').first ?? 'Learner'}!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'profile':
                    // Navigate to profile
                    break;
                  case 'history':
                    // Show lesson history
                    _showLessonHistory(context);
                    break;
                  case 'settings':
                    // Navigate to settings
                    break;
                  case 'logout':
                    await authProvider.signOut();
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text('Profile'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'history',
                  child: Row(
                    children: [
                      Icon(Icons.history, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text('Lesson History'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings_outlined, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text('Settings'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: theme.colorScheme.error),
                      const SizedBox(width: 8),
                      Text('Sign Out', style: TextStyle(color: theme.colorScheme.error)),
                    ],
                  ),
                ),
              ],
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.menu_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentLessons(ThemeData theme) {
    return Consumer<LessonProvider>(
      builder: (context, lessonProvider, child) {
        if (lessonProvider.lessonHistory.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📚 Recent Lessons',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: lessonProvider.lessonHistory.take(5).length,
                itemBuilder: (context, index) {
                  final lesson = lessonProvider.lessonHistory[index];
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.1),
                          theme.colorScheme.secondary.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.topic,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lesson.avatarName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.play_circle_outline,
                              size: 16,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${lesson.flashNotes.length} notes',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
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
    return Consumer<LessonProvider>(
      builder: (context, lessonProvider, child) {
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
                  onPressed: lessonProvider.isGenerating ? null : _submitPrompt,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: lessonProvider.isGenerating
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
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
      },
    );
  }

  void _showLessonHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer<LessonProvider>(
        builder: (context, lessonProvider, child) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(Icons.history, color: Colors.blue),
                      const SizedBox(width: 12),
                      Text(
                        'Lesson History',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: lessonProvider.lessonHistory.isEmpty
                      ? const Center(
                          child: Text('No lessons yet. Start learning!'),
                        )
                      : ListView.builder(
                          itemCount: lessonProvider.lessonHistory.length,
                          itemBuilder: (context, index) {
                            final lesson = lessonProvider.lessonHistory[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                child: Text(
                                  lesson.topic.substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(lesson.topic),
                              subtitle: Text('${lesson.flashNotes.length} flash notes • ${lesson.avatarName}'),
                              trailing: const Icon(Icons.play_arrow),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(
                                  context,
                                  '/video',
                                  arguments: {'lesson': lesson},
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```
