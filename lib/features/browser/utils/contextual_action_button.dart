import 'package:flutter/material.dart';

class ContextualActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final Duration rippleDuration;

  const ContextualActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.rippleDuration = const Duration(milliseconds: 400),
  });

  @override
  State<ContextualActionButton> createState() => _ContextualActionButtonState();
}

class _ContextualActionButtonState extends State<ContextualActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rippleController;
  late final Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();

    _rippleController = AnimationController(
      vsync: this,
      duration: widget.rippleDuration,
    );

    _rippleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _rippleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _rippleController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _onTap() {
    _rippleController.forward();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _rippleAnimation,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: _onTap,
          splashColor: widget.color?.withOpacity(0.3) ?? Colors.white24,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              widget.icon,
              color: widget.color ?? Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
