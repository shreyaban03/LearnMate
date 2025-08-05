import 'package:flutter/material.dart';
import '../widgets/faq_card.dart';

class FlashNotesScreen extends StatefulWidget {
  const FlashNotesScreen({super.key});

  @override
  State<FlashNotesScreen> createState() => _FlashNotesScreenState();
}

class _FlashNotesScreenState extends State<FlashNotesScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _cardsAnimationController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late List<Animation<double>> _cardAnimations;
  
  String _topic = '';
  List<Map<String, String>> _flashNotes = [];

  @override
  void initState() {
    super.initState();
    
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _cardsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOut,
    ));
    
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutBack,
    ));
    
    _headerAnimationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get arguments passed from video screen
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _topic = args['topic'] ?? '';
      _flashNotes = List<Map<String, String>>.from(args['flashNotes'] ?? []);
      
      // Initialize card animations based on the number of flash notes
      _cardAnimations = List.generate(
        _flashNotes.length,
        (index) => Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _cardsAnimationController,
          curve: Interval(
            index * 0.1,
            (index * 0.1) + 0.6,
            curve: Curves.elasticOut,
          ),
        )),
      );
      
      // Start card animations after header animation
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          _cardsAnimationController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardsAnimationController.dispose();
    super.dispose();
  }

  void _goBackToHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
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
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              AnimatedBuilder(
                animation: _headerAnimationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _headerFadeAnimation,
                    child: SlideTransition(
                      position: _headerSlideAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Back Button and Title Row
                            Row(
                              children: [
                                IconButton(
                                  onPressed: _goBackToHome,
                                  icon: Icon(
                                    Icons.arrow_back,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Flash Notes',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(width: 48), // Balance the back button
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Topic Display
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.topic,
                                    size: 20,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      _topic,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            Text(
                              'Quick Summary & Key Points',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // Flash Notes List
              Expanded(
                child: _flashNotes.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _flashNotes.length,
                        itemBuilder: (context, index) {
                          final note = _flashNotes[index];
                          return AnimatedBuilder(
                            animation: _cardAnimations.isNotEmpty ? _cardAnimations[index] : 
                                      const AlwaysStoppedAnimation(1.0),
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _cardAnimations.isNotEmpty ? _cardAnimations[index].value : 1.0,
                                child: Opacity(
                                  opacity: _cardAnimations.isNotEmpty ? _cardAnimations[index].value : 1.0,
                                  child: FaqCard(
                                    question: note['q'] ?? 'Question not available',
                                    answer: note['a'] ?? 'Answer not available',
                                    index: index,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
              
              // Bottom Action Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatItem(
                          icon: Icons.quiz,
                          label: 'Questions',
                          value: '${_flashNotes.length}',
                        ),
                        const SizedBox(width: 32),
                        _buildStatItem(
                          icon: Icons.timer,
                          label: 'Est. Time',
                          value: '${_flashNotes.length * 2} min',
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _goBackToHome,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            child: Text(
                              'Learn More',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Notes saved to your library!'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Theme.of(context).colorScheme.primary,
                            ),
                            child: const Text(
                              'Save Notes',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No flash notes available',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try asking about a different topic',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _goBackToHome,
            child: const Text('Ask New Question'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
