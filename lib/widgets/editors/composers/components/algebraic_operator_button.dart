import 'package:flutter/material.dart';
import 'package:dartblock/models/dartblock_value.dart';

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
      ),
      onPressed: () {
        onTap(algebraicOperator);
      },
      child: Text(
        algebraicOperator.text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
