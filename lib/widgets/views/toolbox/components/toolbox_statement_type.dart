import 'package:flutter/material.dart';
import 'package:dartblock_code/models/statement.dart';

class DartBlockToolboxStatementTypeWidget extends StatelessWidget {
  final StatementType statementType;
  final Function()? onDragStart;
  final Function()? onDragEnd;
  const DartBlockToolboxStatementTypeWidget({
    super.key,
    required this.statementType,
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable(
      data: statementType,
      delay: const Duration(milliseconds: 150),
      feedback: _build(context, true),
      onDragStarted: onDragStart,
      onDragEnd: (details) {
        if (onDragEnd != null) {
          onDragEnd!();
        }
      },
      onDraggableCanceled: (velocity, offset) {
        if (onDragEnd != null) {
          onDragEnd!();
        }
      },
      onDragCompleted: () {
        if (onDragEnd != null) {
          onDragEnd!();
        }
      },
      child: _build(context, false),
    );
  }

  Widget _build(BuildContext context, bool isDragging) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: !isDragging
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isDragging)
            Icon(
              Icons.add,
              size: 18,
              color: !isDragging
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onPrimary,
            ),
          Text(
            statementType.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: !isDragging
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
