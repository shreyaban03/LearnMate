import 'package:flutter/material.dart';

class FaqCard extends StatefulWidget {
  final String question;
  final String answer;
  final int index;

  const FaqCard({
    super.key,
    required this.question,
    required this.answer,
    this.index = 0,
  });

  @override
  State<FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<FaqCard>
    with TickerProviderStateMixin {
  late AnimationController _expansionController;
  late AnimationController _glowController;
  late AnimationController _bounceController;
  
  late Animation<double> _expandAnimation;
  late Animation<double> _iconRotationAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _shadowAnimation;
  
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _expansionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _expandAnimation = CurvedAnimation(
      parent: _expansionController,
      curve: Curves.easeInOut,
    );
    
    _iconRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _expansionController,
      curve: Curves.easeInOut,
    ));
    
    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: _getExpandedColor().withOpacity(0.1),
    ).animate(_expansionController);

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));

    _shadowAnimation = Tween<double>(
      begin: 0.05,
      end: 0.15,
    ).animate(_expansionController);

    // Start subtle glow animation
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _expansionController.dispose();
    _glowController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    // Bounce animation
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });
    
    if (_isExpanded) {
      _expansionController.forward();
    } else {
      _expansionController.reverse();
    }
  }

  Color _getCardColor() {
    final theme = Theme.of(context);
    final colors = [
      theme.colorScheme.primary.withOpacity(0.1),
      theme.colorScheme.secondary.withOpacity(0.1),
      theme.colorScheme.tertiary.withOpacity(0.1),
      theme.colorScheme.surface.withOpacity(0.5),
      Colors.purple.withOpacity(0.1),
    ];
    return colors[widget.index % colors.length];
  }

  Color _getExpandedColor() {
    final theme = Theme.of(context);
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.onSurface,
      Colors.purple,
    ];
    return colors[widget.index % colors.length];
  }

  LinearGradient _getGradient() {
    final theme = Theme.of(context);
    final gradients = [
      LinearGradient(
        colors: [
          theme.colorScheme.primary.withOpacity(0.1),
          theme.colorScheme.secondary.withOpacity(0.05),
        ],
      ),
      LinearGradient(
        colors: [
          theme.colorScheme.secondary.withOpacity(0.1),
          theme.colorScheme.tertiary.withOpacity(0.05),
        ],
      ),
      LinearGradient(
        colors: [
          theme.colorScheme.tertiary.withOpacity(0.1),
          theme.colorScheme.primary.withOpacity(0.05),
        ],
      ),
    ];
    return gradients[widget.index % gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        _expansionController,
        _glowAnimation,
        _bounceAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: _getGradient(),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isExpanded
                    ? _getExpandedColor().withOpacity(0.4)
                    : theme.colorScheme.primary.withOpacity(0.2),
                width: _isExpanded ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_shadowAnimation.value),
                  blurRadius: _isExpanded ? 20 : 10,
                  offset: Offset(0, _isExpanded ? 8 : 4),
                ),
                if (_isExpanded)
                  BoxShadow(
                    color: _getExpandedColor().withOpacity(
                      0.3 * _glowAnimation.value,
                    ),
                    blurRadius: 15,
                    offset: const Offset(0, 0),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  // Question Header
                  InkWell(
                    onTap: _toggleExpansion,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: _isExpanded ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getExpandedColor().withOpacity(0.1),
                            _getExpandedColor().withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ) : null,
                      ),
                      child: Row(
                        children: [
                          // Enhanced Question Number
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _getExpandedColor(),
                                  _getExpandedColor().withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: _getExpandedColor().withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '${widget.index + 1}',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Question Text
                          Expanded(
                            child: Text(
                              widget.question,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                                height: 1.3,
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // Enhanced Expand Icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getExpandedColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: RotationTransition(
                              turns: _iconRotationAnimation,
                              child: Icon(
                                Icons.expand_more_rounded,
                                color: _getExpandedColor(),
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Answer Section with Enhanced Animation
                  SizeTransition(
                    sizeFactor: _expandAnimation,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _getExpandedColor().withOpacity(0.05),
                            _getExpandedColor().withOpacity(0.15),
                          ],
                        ),
                        border: Border(
                          top: BorderSide(
                            color: _getExpandedColor().withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Answer Header
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _getExpandedColor(),
                                        _getExpandedColor().withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.lightbulb_outline_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Answer',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: _getExpandedColor(),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getExpandedColor().withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '💡',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Answer Content
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getExpandedColor().withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                widget.answer,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.6,
                                  color: theme.colorScheme.onSurface.withOpacity(0.8),
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
            ),
          ),
        );
      },
    );
  }
}
