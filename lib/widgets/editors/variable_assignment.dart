import 'package:collection/collection.dart';
import 'package:dartblock_code/widgets/helpers/provider_aware_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartblock_code/models/function.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/editors/composers/boolean_value.dart';
import 'package:dartblock_code/widgets/editors/composers/number_value.dart';
import 'package:dartblock_code/widgets/editors/composers/value_concatenation.dart';
import 'package:dartblock_code/widgets/views/variable_definition.dart';

class VariableAssignmentEditor extends StatefulWidget {
  final VariableAssignmentStatement? statement;
  final Function(VariableAssignmentStatement) onSaved;

  final List<DartBlockVariableDefinition> existingVariableDefinitions;
  final List<DartBlockCustomFunction> customFunctions;
  const VariableAssignmentEditor({
    super.key,
    this.statement,
    required this.onSaved,
    required this.existingVariableDefinitions,
    required this.customFunctions,
  });

  @override
  State<VariableAssignmentEditor> createState() =>
      _VariableAssignmentEditorState();
}

class _VariableAssignmentEditorState extends State<VariableAssignmentEditor> {
  String? variableName;
  Map<DartBlockDataType, DartBlockValue?> valuesByType = {};
  DartBlockVariableDefinition? selectedVariableDefinition;
  bool variableToEditDoesNotExistByName = false;
  @override
  void initState() {
    super.initState();
    for (var neoTechDataType in DartBlockDataType.values) {
      valuesByType[neoTechDataType] = null;
    }
    if (widget.statement != null) {
      variableName = widget.statement!.name;
      selectedVariableDefinition = widget.existingVariableDefinitions
          .firstWhereOrNull(
            (element) => element.name == widget.statement!.name,
          );
      if (selectedVariableDefinition == null) {
        variableToEditDoesNotExistByName = true;
      } else {
        if (selectedVariableDefinition!.dataType ==
                DartBlockDataType.integerType ||
            selectedVariableDefinition!.dataType ==
                DartBlockDataType.doubleType) {
          valuesByType[DartBlockDataType.integerType] = widget.statement!.value;
          valuesByType[DartBlockDataType.doubleType] = widget.statement!.value;
        } else {
          valuesByType[selectedVariableDefinition!.dataType] =
              widget.statement!.value;
        }
      }
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
                "Update Variable",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            FilledButton.icon(
              onPressed: selectedVariableDefinition != null
                  ? () {
                      if (selectedVariableDefinition != null) {
                        HapticFeedback.mediumImpact();
                        widget.onSaved(
                          VariableAssignmentStatement.init(
                            selectedVariableDefinition!.name,
                            _getValue(),
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
        if (variableToEditDoesNotExistByName &&
            selectedVariableDefinition == null)
          Text(
            "The variable '$variableName' does not exist. Select a different variable to update or declare the variable first.",
            style: Theme.of(context).textTheme.bodyMedium?.apply(
              color: Theme.of(context).colorScheme.error,
              fontStyle: FontStyle.italic,
            ),
          ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ProviderAwareDropdownButton(
            isExpanded: true,
            hint: const Text("Select a variable..."),
            underline: const SizedBox(),
            value: selectedVariableDefinition,
            items: widget.existingVariableDefinitions
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: VariableDefinitionWidget(variableDefinition: e),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != selectedVariableDefinition) {
                setState(() {
                  selectedVariableDefinition = value;
                });
              }
            },
          ),
        ),
        const SizedBox(height: 8),
        if (selectedVariableDefinition == null)
          Text(
            "Select a variable to update its value.",
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          )
        else
          _buildValueEditor(),
      ],
    );
  }

  Widget _buildValueEditor() {
    if (selectedVariableDefinition != null) {
      switch (selectedVariableDefinition!.dataType) {
        case DartBlockDataType.integerType:
        case DartBlockDataType.doubleType:
          return NumberValueComposer(
            value: _getIntegerDoubleValue()?.compositionNode,
            variableDefinitions: widget.existingVariableDefinitions,
            onChange: (newValue) {
              valuesByType[DartBlockDataType.integerType] = newValue != null
                  ? DartBlockAlgebraicExpression.init(newValue)
                  : null;
              valuesByType[DartBlockDataType.doubleType] = newValue != null
                  ? DartBlockAlgebraicExpression.init(newValue)
                  : null;
            },
          );
        case DartBlockDataType.booleanType:
          return BooleanValueComposer(
            value: _getBooleanValue()?.compositionNode,
            variableDefinitions: widget.existingVariableDefinitions,
            onChange: (newValue) {
              valuesByType[DartBlockDataType.booleanType] = newValue != null
                  ? DartBlockBooleanExpression.init(newValue)
                  : null;
            },
          );
        case DartBlockDataType.stringType:
          return ConcatenationValueComposer(
            value: _getStringValue(),
            variableDefinitions: widget.existingVariableDefinitions,
            onInteract: () {},
            onChange: (newValue) {
              valuesByType[DartBlockDataType.stringType] = newValue;
            },
          );
      }
    } else {
      return const SizedBox();
    }
  }

  DartBlockValue? _getValue() {
    if (selectedVariableDefinition != null) {
      switch (selectedVariableDefinition!.dataType) {
        case DartBlockDataType.integerType:
        case DartBlockDataType.doubleType:
          return _getIntegerDoubleValue();
        case DartBlockDataType.booleanType:
          return _getBooleanValue();
        case DartBlockDataType.stringType:
          return _getStringValue();
      }
    } else {
      return null;
    }
  }

  DartBlockAlgebraicExpression? _getIntegerDoubleValue() {
    if (valuesByType.containsKey(DartBlockDataType.integerType)) {
      final integerValue = valuesByType[DartBlockDataType.integerType];
      if (integerValue != null &&
          integerValue is DartBlockAlgebraicExpression) {
        return integerValue;
      }
    } else if (valuesByType.containsKey(DartBlockDataType.doubleType)) {
      final doubleValue = valuesByType[DartBlockDataType.doubleType];
      if (doubleValue != null && doubleValue is DartBlockAlgebraicExpression) {
        return doubleValue;
      }
    }

    return null;
  }

  DartBlockBooleanExpression? _getBooleanValue() {
    if (valuesByType.containsKey(DartBlockDataType.booleanType)) {
      final booleanValue = valuesByType[DartBlockDataType.booleanType];
      if (booleanValue != null && booleanValue is DartBlockBooleanExpression) {
        return booleanValue;
      }
    }

    return null;
  }

  DartBlockConcatenationValue? _getStringValue() {
    if (valuesByType.containsKey(DartBlockDataType.stringType)) {
      final concatenationValue = valuesByType[DartBlockDataType.stringType];
      if (concatenationValue != null &&
          concatenationValue is DartBlockConcatenationValue) {
        return concatenationValue;
      }
    }

    return null;
  }
}
