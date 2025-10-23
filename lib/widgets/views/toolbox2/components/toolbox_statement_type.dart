import 'package:dartblock_code/widgets/views/toolbox2/models/toolbox_configuration.dart';
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
    return Draggable<StatementType>(
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
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: categoryColor,
            borderRadius: BorderRadius.circular(ToolboxConfig.borderRadius),
            border: Border.all(color: Theme.of(context).colorScheme.surface),
          ),
          child: Icon(
            _getIconForType(statementType),
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
      ),
      child: Tooltip(
        message: _getTooltipForType(statementType),
        child: Container(
          width: ToolboxConfig.minTouchSize,
          height: ToolboxConfig.minTouchSize,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(ToolboxConfig.borderRadius),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          child: Icon(_getIconForType(statementType), color: categoryColor),
        ),
      ),
    );
  }

  IconData _getIconForType(StatementType type) {
    return switch (type) {
      StatementType.variableDeclarationStatement => Icons.add_circle_outline,
      StatementType.variableAssignmentStatement => Icons.edit_outlined,
      StatementType.forLoopStatement => Icons.loop,
      StatementType.whileLoopStatement => Icons.repeat,
      StatementType.ifElseStatement => Icons.call_split,
      StatementType.breakStatement => Icons.logout,
      StatementType.continueStatement => Icons.skip_next,
      StatementType.customFunctionCallStatement => Icons.functions,
      StatementType.returnStatement => Icons.keyboard_return,
      StatementType.printStatement => Icons.wysiwyg,
      _ => Icons.code,
    };
  }

  String _getTooltipForType(StatementType type) {
    return switch (type) {
      StatementType.variableDeclarationStatement => 'Declare Variable',
      StatementType.variableAssignmentStatement => 'Update Variable',
      StatementType.forLoopStatement => 'For Loop',
      StatementType.whileLoopStatement => 'While Loop',
      StatementType.ifElseStatement => 'If-Else',
      StatementType.breakStatement => 'Break',
      StatementType.continueStatement => 'Continue',
      StatementType.customFunctionCallStatement => 'Call Function',
      StatementType.returnStatement => 'Return',
      StatementType.printStatement => "Print",
      _ => type.toString(),
    };
  }
}
