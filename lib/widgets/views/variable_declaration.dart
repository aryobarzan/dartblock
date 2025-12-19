import 'package:flutter/material.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/dartblock_value_widgets.dart';
import 'package:dartblock_code/widgets/views/variable_definition.dart';

class VariableDeclarationStatementWidget extends StatelessWidget {
  final VariableDeclarationStatement statement;
  const VariableDeclarationStatementWidget({
    super.key,
    required this.statement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        VariableDefinitionWidget(
          variableDefinition: DartBlockVariableDefinition(
            statement.name,
            statement.dataType,
          ),
        ),
        Text(
          "=",
          style: Theme.of(context).textTheme.bodyMedium?.apply(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        DartBlockValueWidget(value: statement.value),
      ],
    );
  }
}
