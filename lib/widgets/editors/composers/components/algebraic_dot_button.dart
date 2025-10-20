import 'package:flutter/material.dart';

class AlgebraicDotButton extends StatelessWidget {
  final Function() onTap;
  const AlgebraicDotButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        onTap();
      },
      child: Text(
        ".",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
