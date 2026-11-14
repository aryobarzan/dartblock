import 'package:material_ui/material_ui.dart';
import 'package:dartblock_code/src/models/dartblock_value.dart';
import 'package:dartblock_code/src/models/statement.dart';
import 'package:dartblock_code/src/widgets/dartblock_value_widgets.dart';
import 'package:dartblock_code/src/widgets/views/variable_definition.dart';

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
