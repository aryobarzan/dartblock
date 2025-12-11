import 'package:flutter/material.dart';

class ComposerCommonButton extends StatelessWidget {
  final Function()? onTap;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String tooltipMessage;
  const ComposerCommonButton({
    super.key,
    required this.onTap,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    required this.tooltipMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltipMessage,
      child: FilledButton(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 1),
          foregroundColor:
              foregroundColor ?? Theme.of(context).colorScheme.onSurface,
          backgroundColor:
              backgroundColor ??
              Theme.of(context).colorScheme.surfaceContainerHighest,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onTap,
        child: child,
      ),
    );
  }
}
