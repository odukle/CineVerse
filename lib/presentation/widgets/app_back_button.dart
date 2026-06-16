import 'package:flutter/material.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.color = Colors.white,
    this.onPressed,
    this.tooltip = 'Back',
  });

  final Color color;
  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed:
          onPressed ??
          () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).maybePop();
            }
          },
      icon: Icon(Icons.arrow_back_rounded, color: color),
    );
  }
}
