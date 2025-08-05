import 'package:flutter/material.dart';
import '../widgets/prompt_input.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  late AnimationController _chipAnimationController;
  late AnimationController _submitAnimationController;
  late List<Animation<double>> _chipAnimations;
  late Animation<double> _submitScaleAnimation;
  
  bool _isLoading = false;
  String? _errorText;
  
  final List<String> _suggestedTopics = [
    'Quantum Physics',
    'Machine Learning',
    'Ancient History',
    'Climate Change',
    'Space Exploration',
    'Human Psychology',
    'Cryptocurrency',
    'Art History',
    'Renewable Energy',
    'Neuroscience',
  ];

  @override
  void initState() {
    super.initState();
    
    _chipAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _submitAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _submitScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _submitAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Create staggered animations for chips
    _chipAnimations = List.generate(
      _suggestedTopics.length,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _chipAnimationController,
        curve: Interval(
          index * 0.1,
          (index * 0.1) + 0.6,
          curve: Curves.elasticOut,
        ),
      )),
    );
    
    _chipAnimationController.forward();
  }

  @override
  void dispose() {
    _chipAnimationController.dispose();
    _submitAnimationController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  void _selectTopic(String topic) {
    setState(() {
      _promptController.text = topic;
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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.background,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header
                const SizedBox(height: 20),
                Text(
                  'What do you want to learn today?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a topic or type your own question',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Animated Topic Chips
                Expanded(
                  flex: 2,
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
                                child: _buildTopicChip(_suggestedTopics[index]),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
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
                AnimatedBuilder(
                  animation: _submitScaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _submitScaleAnimation.value,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitPrompt,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Preparing your lesson...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                  'Teach Me 📚',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicChip(String topic) {
    return GestureDetector(
      onTap: () => _selectTopic(topic),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Theme.of(context).colorScheme.surface,
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          topic,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
