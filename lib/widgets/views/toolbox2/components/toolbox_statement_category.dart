import 'package:dartblock_code/widgets/views/toolbox/components/toolbox_statement_type.dart';
import 'package:flutter/material.dart';
import 'package:dartblock_code/models/statement.dart';

enum ToolboxStatementCategory {
  variables('Variables'),
  loops('Loops'),
  decisionStructures('Decision Structures'),
  other('Other');

  final String name;
  const ToolboxStatementCategory(this.name);

  IconData getIcon() {
    switch (this) {
      case ToolboxStatementCategory.variables:
        return Icons.code;
      case ToolboxStatementCategory.loops:
        return Icons.loop;
      case ToolboxStatementCategory.decisionStructures:
        return Icons.confirmation_number;
      case ToolboxStatementCategory.other:
        return Icons.devices_other;
    }
  }

  Widget getSymbol(double width, double height, {Color? color}) {
    switch (this) {
      case ToolboxStatementCategory.variables:
        return Icon(Icons.data_object, size: width);
      case ToolboxStatementCategory.loops:
        return Icon(Icons.loop, size: width);
      case ToolboxStatementCategory.decisionStructures:
        return Icon(Icons.alt_route, size: width);
      case ToolboxStatementCategory.other:
        return Icon(Icons.dashboard_outlined, size: width);
    }
  }
}

class DartBlockToolboxStatementCategoryWidget extends StatelessWidget {
  final ToolboxStatementCategory category;
  final Function()? onItemDragStart;
  final Function()? onItemDragEnd;
  const DartBlockToolboxStatementCategoryWidget({
    super.key,
    required this.category,
    this.onItemDragStart,
    this.onItemDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    List<StatementType> statementTypes;
    switch (category) {
      case ToolboxStatementCategory.variables:
        statementTypes = [
          StatementType.variableDeclarationStatement,
          StatementType.variableAssignmentStatement,
          StatementType.returnStatement,
          StatementType.customFunctionCallStatement,
        ];
        break;
      case ToolboxStatementCategory.loops:
        statementTypes = [
          StatementType.forLoopStatement,
          StatementType.whileLoopStatement,
          StatementType.breakStatement,
          StatementType.continueStatement,
        ];
        break;
      case ToolboxStatementCategory.decisionStructures:
        statementTypes = [StatementType.ifElseStatement];
        break;
      case ToolboxStatementCategory.other:
        statementTypes = [StatementType.printStatement];
    }

    List<Widget> items = [];
    for (var statementType in statementTypes) {
      if (statementType == StatementType.statementBlockStatement) {
        continue;
      }
      items.add(
        DartBlockToolboxStatementTypeWidget(
          statementType: statementType,
          onDragStart: onItemDragStart,
          onDragEnd: onItemDragEnd,
        ),
      );
    }

    return Wrap(spacing: 4, runSpacing: 0, children: items);
  }
}
