import 'package:flutter/material.dart';

class PromptInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onSubmit;
  final String? errorText;
  final bool isLoading;

  const PromptInput({
    super.key,
    required this.controller,
    this.hintText = 'What would you like to learn?',
    this.onSubmit,
    this.errorText,
    this.isLoading = false,
  });

  @override
  State<PromptInput> createState() => _PromptInputState();
}

class _PromptInputState extends State<PromptInput>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Start subtle glow animation
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _handleFocus(bool hasFocus) {
    setState(() {
      _isFocused = hasFocus;
    });
    
    if (hasFocus) {
      _scaleController.forward();
    } else {
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    // Main shadow
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    // Glow effect when focused
                    if (_isFocused)
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(
                          0.2 * _glowAnimation.value,
                        ),
                        blurRadius: 25,
                        offset: const Offset(0, 0),
                      ),
                  ],
                ),
                child: Focus(
                  onFocusChange: _handleFocus,
                  child: TextField(
                    controller: widget.controller,
                    maxLines: null,
                    minLines: 3,
                    enabled: !widget.isLoading,
                    onSubmitted: (_) => widget.onSubmit?.call(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.4,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: theme.inputDecorationTheme.hintStyle,
                      
                      // Enhanced prefix icon with gradient
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(10),
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
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      
                      // Loading indicator or submit hint
                      suffixIcon: widget.isLoading
                          ? Container(
                              margin: const EdgeInsets.all(16),
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary,
                                ),
                              ),
                            )
                          : Container(
                              margin: const EdgeInsets.all(12),
                              child: IconButton(
                                onPressed: widget.onSubmit,
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.send_rounded,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                      
                      // Apply theme's input decoration
                      filled: theme.inputDecorationTheme.filled,
                      fillColor: theme.inputDecorationTheme.fillColor,
                      border: theme.inputDecorationTheme.border,
                      enabledBorder: theme.inputDecorationTheme.enabledBorder,
                      focusedBorder: theme.inputDecorationTheme.focusedBorder?.copyWith(
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 3,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        
        // Error text with smooth animation
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: widget.errorText != null
              ? Container(
                  key: ValueKey(widget.errorText),
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.error.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: theme.colorScheme.error,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.errorText!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
