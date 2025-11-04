import 'package:dartblock_code/widgets/views/toolbox/models/toolbox_configuration.dart';
import 'package:flutter/material.dart';
import 'package:dartblock_code/models/statement.dart';

class DartBlockToolboxStatementTypeWidget extends StatelessWidget {
  final StatementType statementType;
  final Color categoryColor;
  final Function()? onDragStart;
  final Function()? onDragEnd;
  const DartBlockToolboxStatementTypeWidget({
    super.key,
    required this.statementType,
    required this.categoryColor,
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<StatementType>(
      /// We add a slight delay to avoid conflicting with the scrollable nature of the toolbox itself.
      delay: Duration(milliseconds: 100),
      data: statementType,
      onDragStarted: () {
        if (onDragStart != null) {
          onDragStart!();
        }
      },
      onDragEnd: (_) {
        if (onDragEnd != null) {
          onDragEnd!();
        }
      },
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(ToolboxConfig.borderRadius),
        child: _buildCore(context, statementType, true),
      ),
      child: Tooltip(
        message: statementType.getTooltip(),
        child: _buildCore(context, statementType, false),
      ),
    );
  }

  Widget _buildCore(BuildContext context, StatementType type, isBeingDragged) {
    bool showLabel = MediaQuery.of(context).size.width > 700 ? true : false;
    final icon = Icon(
      statementType.getIconData(),
      color: isBeingDragged
          ? Theme.of(context).colorScheme.surface
          : categoryColor,
    );
    return Container(
      // width: ToolboxConfig.minTouchSize,
      height: ToolboxConfig.minTouchSize,
      width: showLabel ? null : ToolboxConfig.minTouchSize,
      decoration: BoxDecoration(
        color: isBeingDragged
            ? categoryColor
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(ToolboxConfig.borderRadius),
        border: Border.all(
          color: isBeingDragged
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: showLabel
          ? Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                icon,
                Text(
                  statementType.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.apply(
                    color: isBeingDragged
                        ? Theme.of(context).colorScheme.surface
                        : null,
                  ),
                ),
              ],
            )
          : icon,
    );
  }
}
