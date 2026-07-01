import 'package:flutter/material.dart';

/// A focusable container widget optimized for Android TV remote navigation.
/// 
/// This widget provides visual feedback when focused using D-pad navigation,
/// with smooth animations and customizable styling.
class TvFocusable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onFocusChange;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? focusColor;
  final Color? hoverColor;
  final Duration focusAnimationDuration;
  final bool enabled;
  final String? semanticsLabel;

  const TvFocusable({
    super.key,
    required this.child,
    this.onTap,
    this.onFocusChange,
    this.padding,
    this.margin,
    this.borderRadius,
    this.focusColor,
    this.hoverColor,
    this.focusAnimationDuration = const Duration(milliseconds: 200),
    this.enabled = true,
    this.semanticsLabel,
  });

  @override
  State<TvFocusable> createState() => _TvFocusableState();
}

class _TvFocusableState extends State<TvFocusable>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.focusAnimationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: widget.focusColor ?? Colors.blue.withOpacity(0.3),
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleFocusChange(bool hasFocus) {
    setState(() {
      _isFocused = hasFocus;
    });

    if (hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    widget.onFocusChange?.call();
  }

  void _handleHoverChange(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderRadius = widget.borderRadius ?? 12.0;
    final effectivePadding = widget.padding ?? const EdgeInsets.all(16.0);
    final effectiveMargin = widget.margin ?? const EdgeInsets.all(8.0);

    return MouseRegion(
      onEnter: (_) => _handleHoverChange(true),
      onExit: (_) => _handleHoverChange(false),
      child: Focus(
        autofocus: false,
        onFocusChange: _handleFocusChange,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                margin: effectiveMargin,
                decoration: BoxDecoration(
                  color: _isFocused || _isHovered
                      ? (widget.hoverColor ?? theme.cardColor)
                      : null,
                  borderRadius: BorderRadius.circular(effectiveBorderRadius),
                  border: _isFocused
                      ? Border.all(
                          color: widget.focusColor ?? theme.colorScheme.primary,
                          width: 3,
                        )
                      : null,
                  boxShadow: _isFocused
                      ? [
                          BoxShadow(
                            color: widget.focusColor ??
                                theme.colorScheme.primary.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.enabled ? widget.onTap : null,
                    borderRadius: BorderRadius.circular(effectiveBorderRadius),
                    enableFeedback: true,
                    child: Padding(
                      padding: effectivePadding,
                      child: Opacity(
                        opacity: widget.enabled ? 1.0 : 0.5,
                        child: Semantics(
                          label: widget.semanticsLabel,
                          button: widget.onTap != null,
                          child: widget.child,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A focusable button widget specifically designed for Android TV.
/// 
/// Combines [TvFocusable] with an icon and label for easy remote navigation.
class TvButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const TvButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveForegroundColor =
        foregroundColor ?? theme.colorScheme.onPrimary;
    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.primary;

    return TvFocusable(
      onTap: enabled ? onPressed : null,
      enabled: enabled,
      borderRadius: 12.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: enabled ? effectiveBackgroundColor : Colors.grey[700],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: effectiveForegroundColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: effectiveForegroundColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A focusable icon button widget for Android TV.
class TvIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool enabled;
  final double size;
  final Color? color;

  const TvIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.enabled = true,
    this.size = 56.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget button = TvFocusable(
      onTap: enabled ? onPressed : null,
      enabled: enabled,
      padding: EdgeInsets.zero,
      borderRadius: 50.0,
      child: Icon(
        icon,
        size: 32,
        color: enabled ? (color ?? theme.colorScheme.onSurface) : Colors.grey,
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
