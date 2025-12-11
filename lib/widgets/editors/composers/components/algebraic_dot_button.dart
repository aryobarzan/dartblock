import 'package:flutter/material.dart';

class AlgebraicDotButton extends StatelessWidget {
  final Function() onTap;
  const AlgebraicDotButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 1),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () {
        onTap();
      },
      child: Text(
        ".",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
