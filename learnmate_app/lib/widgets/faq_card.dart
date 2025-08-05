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
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _iconRotationAnimation;
  late Animation<Color?> _colorAnimation;
  
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _iconRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: const Color(0xFFF8F9FF),
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Color _getCardColor() {
    final colors = [
      const Color(0xFFE3F2FD), // Light Blue
      const Color(0xFFF3E5F5), // Light Purple
      const Color(0xFFE8F5E8), // Light Green
      const Color(0xFFFFF3E0), // Light Orange
      const Color(0xFFFFEBEE), // Light Pink
    ];
    return colors[widget.index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isExpanded
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                  : Colors.grey.shade200,
              width: _isExpanded ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isExpanded ? 0.1 : 0.05),
                blurRadius: _isExpanded ? 12 : 6,
                offset: Offset(0, _isExpanded ? 4 : 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                // Question Header
                InkWell(
                  onTap: _toggleExpansion,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Question Number
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${widget.index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Question Text
                        Expanded(
                          child: Text(
                            widget.question,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 1.3,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Expand Icon
                        RotationTransition(
                          turns: _iconRotationAnimation,
                          child: Icon(
                            Icons.expand_more,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Answer Section
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _getCardColor().withOpacity(0.3),
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Answer',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.answer,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
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
        );
      },
    );
  }
}
