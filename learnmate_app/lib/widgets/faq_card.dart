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
                Box
