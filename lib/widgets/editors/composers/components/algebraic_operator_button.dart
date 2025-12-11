import 'package:flutter/material.dart';
import 'package:dartblock_code/models/dartblock_value.dart';

class AlgebraicOperatorButton extends StatelessWidget {
  final DartBlockAlgebraicOperator algebraicOperator;
  final Function(DartBlockAlgebraicOperator operator) onTap;
  const AlgebraicOperatorButton({
    super.key,
    required this.algebraicOperator,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 1),
        backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () {
        onTap(algebraicOperator);
      },
      child: Text(
        algebraicOperator.text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }
}
