import 'dart:math';

import 'package:flutter/material.dart';

class AlgebraicDigitButton extends StatelessWidget {
  final int digit;
  final Function(int digit) onTap;
  AlgebraicDigitButton({super.key, required int digit, required this.onTap})
    : digit = max(0, min(9, digit));

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 1),
      ),
      onPressed: () {
        onTap(digit);
      },
      child: Text(
        digit.toString(),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
