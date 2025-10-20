import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartblock_code/models/function.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/editors/composers/dartblock_value.dart';
import 'package:dartblock_code/widgets/views/symbols.dart';

class ReturnStatementEditor extends StatefulWidget {
  final ReturnStatement? statement;
  final Function(ReturnStatement) onSaved;

  final List<DartBlockVariableDefinition> existingVariableDefinitions;
  final List<DartBlockFunction> customFunctions;
  const ReturnStatementEditor({
    super.key,
    this.statement,
    required this.onSaved,
    required this.existingVariableDefinitions,
    required this.customFunctions,
  });

  @override
  State<ReturnStatementEditor> createState() => _ReturnStatementEditorState();
}

class _ReturnStatementEditorState extends State<ReturnStatementEditor> {
  DartBlockDataType dataType = DartBlockDataType.integerType;
  Map<DartBlockDataType, DartBlockValue?> valuesByType = {};
  @override
  void initState() {
    super.initState();
    for (var neoTechDataType in DartBlockDataType.values) {
      valuesByType[neoTechDataType] = null;
    }
    if (widget.statement != null) {
      dataType = widget.statement!.dataType;
      _updateValue(widget.statement!.value.copy());
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
                "Return Value",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            FilledButton.icon(
              onPressed: valuesByType[dataType] != null
                  ? () {
                      if (valuesByType[dataType] != null) {
                        HapticFeedback.mediumImpact();
                        widget.onSaved(
                          ReturnStatement.init(
                            dataType,
                            valuesByType[dataType]!,
                          ),
                        );
                      }
                    }
                  : null,
              label: Text(widget.statement != null ? "Save" : "Add"),
              icon: Icon(widget.statement != null ? Icons.check : Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text("Value type", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            spacing: 4,
            children: DartBlockDataType.values
                .map(
                  (elem) => ChoiceChip(
                    showCheckmark: false,
                    labelPadding: const EdgeInsets.only(left: 8),
                    avatar: NeoTechDataTypeIcon(dataType: elem),
                    label: Text(elem.toScript()),
                    selected: dataType == elem,
                    onSelected: (selected) {
                      if (elem != dataType) {
                        setState(() {
                          dataType = elem;
                        });
                      }
                    },
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 4),
        Text("Value", style: Theme.of(context).textTheme.titleMedium),
        DartBlockValueEditor(
          dataType: dataType,
          value: valuesByType[dataType],
          variableDefinitions: widget.existingVariableDefinitions,
          customFunctions: widget.customFunctions,
          onChange: (newValue) {
            setState(() {
              _updateValue(newValue);
            });
          },
        ),
      ],
    );
  }

  void _updateValue(DartBlockValue? newValue) {
    switch (dataType) {
      case DartBlockDataType.integerType:
      case DartBlockDataType.doubleType:
        if (newValue is DartBlockAlgebraicExpression) {
          valuesByType[DartBlockDataType.integerType] = newValue;
          valuesByType[DartBlockDataType.doubleType] = newValue;
        }
        break;
      case DartBlockDataType.booleanType:
        if (newValue is DartBlockBooleanExpression) {
          valuesByType[DartBlockDataType.booleanType] = newValue;
        }
        break;
      case DartBlockDataType.stringType:
        if (newValue is DartBlockConcatenationValue) {
          valuesByType[DartBlockDataType.stringType] = newValue;
        }
        break;
    }
  }
}
