import 'package:flutter/material.dart';

class AnimatedIconAction extends StatefulWidget {
  const AnimatedIconAction({
    required this.onTap,
    required this.child,
    this.borderRadius,
    this.customBorder,
    this.enableHaptics = false,
    super.key,
  });

  final VoidCallback onTap;
  final Widget child;
  final BorderRadius? borderRadius;
  final ShapeBorder? customBorder;
  final bool enableHaptics;

  @override
  State<AnimatedIconAction> createState() => _AnimatedIconActionState();
}

class _AnimatedIconActionState extends State<AnimatedIconAction> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) {
      return;
    }
    setState(() {
      _isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      borderRadius: widget.borderRadius,
      customBorder: widget.customBorder,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
