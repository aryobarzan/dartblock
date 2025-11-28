import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartblock_code/models/function.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/editors/composers/value_concatenation.dart';

class PrintStatementEditor extends StatefulWidget {
  final PrintStatement? statement;
  final Function(PrintStatement) onSaved;

  final List<DartBlockVariableDefinition> existingVariableDefinitions;
  final List<DartBlockCustomFunction> customFunctions;
  const PrintStatementEditor({
    super.key,
    this.statement,
    required this.onSaved,
    required this.existingVariableDefinitions,
    required this.customFunctions,
  });

  @override
  State<PrintStatementEditor> createState() => _PrintStatementEditorState();
}

class _PrintStatementEditorState extends State<PrintStatementEditor> {
  late DartBlockConcatenationValue concatenationValue;
  @override
  void initState() {
    super.initState();
    if (widget.statement != null) {
      concatenationValue = widget.statement!.value.copy();
    } else {
      concatenationValue = DartBlockConcatenationValue.init([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Print",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            FilledButton.icon(
              onPressed: concatenationValue.values.isNotEmpty
                  ? () {
                      if (concatenationValue.values.isNotEmpty) {
                        HapticFeedback.mediumImpact();
                        widget.onSaved(PrintStatement.init(concatenationValue));
                      }
                    }
                  : null,
              label: Text(widget.statement != null ? "Save" : "Add"),
              icon: Icon(widget.statement != null ? Icons.check : Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ConcatenationValueComposer(
          value: concatenationValue,
          variableDefinitions: widget.existingVariableDefinitions,
          customFunctions: widget.customFunctions,
          onInteract: () {},
          onChange: (newValue) {
            setState(() {
              concatenationValue =
                  newValue ?? DartBlockConcatenationValue.init([]);
            });
          },
        ),
      ],
    );
  }
}
