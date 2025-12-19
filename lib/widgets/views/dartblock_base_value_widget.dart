import 'package:flutter/material.dart';

class DartblockBaseValueWidget extends StatelessWidget {
  final Color color;
  final String label;
  final BorderRadius? borderRadius;
  const DartblockBaseValueWidget({
    super.key,
    required this.color,
    required this.label,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius, //BorderRadius.circular(4),
        border: Border(left: BorderSide(color: color, width: 4)),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.apply(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
