import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartblock_code/core/dartblock_program.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/dartblock_validator.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/editors/composers/boolean_value.dart';
import 'package:dartblock_code/widgets/editors/composers/number_value.dart';
import 'package:dartblock_code/widgets/editors/composers/value_concatenation.dart';
import 'package:dartblock_code/widgets/editors/dartblock_data_type_picker.dart';

class VariableDeclarationEditor extends StatefulWidget {
  final VariableDeclarationStatement? statement;
  final Function(VariableDeclarationStatement) onSaved;

  final List<DartBlockVariableDefinition> existingVariableDefinitions;
  const VariableDeclarationEditor({
    super.key,
    this.statement,
    required this.onSaved,
    required this.existingVariableDefinitions,
  });

  @override
  State<VariableDeclarationEditor> createState() =>
      _VariableDeclarationEditorState();
}

class _VariableDeclarationEditorState extends State<VariableDeclarationEditor> {
  DartBlockDataType dataType = DartBlockDataType.integerType;
  TextEditingController nameTEC = TextEditingController();
  final FocusNode variableNameTECFocusNode = FocusNode();
  Map<DartBlockDataType, DartBlockValue?> valuesByType = {};
  final GlobalKey<FormState> nameFormKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    for (var neoTechDataType in DartBlockDataType.values) {
      valuesByType[neoTechDataType] = null;
    }
    if (widget.statement != null) {
      dataType = widget.statement!.dataType;
      nameTEC.text = widget.statement!.name;
      if (dataType == DartBlockDataType.integerType ||
          dataType == DartBlockDataType.doubleType) {
        valuesByType[DartBlockDataType.integerType] = widget.statement!.value;
        valuesByType[DartBlockDataType.doubleType] = widget.statement!.value;
      } else {
        valuesByType[dataType] = widget.statement!.value;
      }
    }
  }

  /// store initial value for all possible data types in case user switches between them
  @override
  Widget build(BuildContext context) {
    return Form(
      key: nameFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Declare Variable",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  final isValid = nameFormKey.currentState?.validate() ?? false;
                  if (isValid) {
                    HapticFeedback.mediumImpact();
                    widget.onSaved(
                      VariableDeclarationStatement.init(
                        nameTEC.text,
                        dataType,
                        _getValue(),
                      ),
                    );
                  }
                },
                label: Text(widget.statement != null ? "Save" : "Add"),
                icon: Icon(widget.statement != null ? Icons.check : Icons.add),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DartBlockDataTypePicker.noVoid(
                dataType: dataType,
                onChanged: (selectedDataType) {
                  if (dataType != selectedDataType &&
                      selectedDataType != null) {
                    setState(() {
                      dataType = selectedDataType;
                    });
                  }
                },
              ),
              Flexible(
                child: TextFormField(
                  focusNode: variableNameTECFocusNode,
                  autofocus: false,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                      NeoTechConstantSettings.variableNameLength,
                    ),
                    FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z\$_]")),
                  ],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Name",
                  ),
                  controller: nameTEC,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name must not be empty.';
                    }
                    if (widget.existingVariableDefinitions.any(
                      (element) => element.name == value,
                    )) {
                      return 'A variable with that name already exists.';
                    }

                    final nameValidation =
                        DartBlockValidator.validateVariableName(value);

                    return nameValidation;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (dataType == DartBlockDataType.integerType ||
              dataType == DartBlockDataType.doubleType)
            NumberValueComposer(
              value: _getIntegerDoubleValue()?.compositionNode,
              variableDefinitions: widget.existingVariableDefinitions,
              valueLabel: "Initial value (optional):",
              onChange: (newValue) {
                valuesByType[DartBlockDataType.integerType] = newValue != null
                    ? DartBlockAlgebraicExpression.init(newValue)
                    : null;
                valuesByType[DartBlockDataType.doubleType] = newValue != null
                    ? DartBlockAlgebraicExpression.init(newValue)
                    : null;
              },
            )
          else if (dataType == DartBlockDataType.booleanType)
            BooleanValueComposer(
              value: _getBooleanValue()?.compositionNode,
              variableDefinitions: widget.existingVariableDefinitions,
              valueLabel: "Initial value (optional):",
              onChange: (newValue) {
                valuesByType[DartBlockDataType.booleanType] = newValue != null
                    ? DartBlockBooleanExpression.init(newValue)
                    : null;
              },
            )
          else if (dataType == DartBlockDataType.stringType)
            ConcatenationValueComposer(
              value: _getStringValue(),
              variableDefinitions: widget.existingVariableDefinitions,
              valueLabel: "Initial value (optional):",
              onInteract: () {
                variableNameTECFocusNode.unfocus();
              },
              onChange: (newValue) {
                valuesByType[DartBlockDataType.stringType] = newValue;
              },
            ),
        ],
      ),
    );
  }

  DartBlockValue? _getValue() {
    switch (dataType) {
      case DartBlockDataType.integerType:
      case DartBlockDataType.doubleType:
        return _getIntegerDoubleValue();
      case DartBlockDataType.booleanType:
        return _getBooleanValue();
      case DartBlockDataType.stringType:
        return _getStringValue();
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
