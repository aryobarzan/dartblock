import 'package:flutter/material.dart';
import 'package:dartblock_code/models/function.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/widgets/editors/composers/boolean_value.dart';
import 'package:dartblock_code/widgets/editors/composers/number_value.dart';
import 'package:dartblock_code/widgets/editors/composers/value_concatenation.dart';

class DartBlockValueEditor extends StatelessWidget {
  final DartBlockDataType dataType;
  final DartBlockValue? value;
  final List<DartBlockVariableDefinition> variableDefinitions;
  final List<DartBlockFunction> customFunctions;
  final Function(DartBlockValue?) onChange;
  const DartBlockValueEditor({
    super.key,
    required this.dataType,
    this.value,
    required this.variableDefinitions,
    required this.customFunctions,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    switch (dataType) {
      case DartBlockDataType.integerType:
      case DartBlockDataType.doubleType:
        final DartBlockAlgebraicExpression? algebraicExpression =
            (value != null && value is DartBlockAlgebraicExpression)
            ? value! as DartBlockAlgebraicExpression
            : null;
        return NumberValueComposer(
          value: algebraicExpression?.compositionNode,
          variableDefinitions: variableDefinitions,
          customFunctions: customFunctions,
          onChange: (newValue) {
            onChange(
              newValue != null
                  ? DartBlockAlgebraicExpression.init(newValue)
                  : null,
            );
          },
        );
      case DartBlockDataType.booleanType:
        final DartBlockBooleanExpression? booleanExpression =
            (value != null && value is DartBlockBooleanExpression)
            ? value! as DartBlockBooleanExpression
            : null;
        return BooleanValueComposer(
          value: booleanExpression?.compositionNode,
          variableDefinitions: variableDefinitions,
          customFunctions: customFunctions,
          onChange: (newValue) {
            onChange(
              newValue != null
                  ? DartBlockBooleanExpression.init(newValue)
                  : null,
            );
          },
        );
      case DartBlockDataType.stringType:
        final DartBlockConcatenationValue? concatenationValue =
            (value != null && value is DartBlockConcatenationValue)
            ? value! as DartBlockConcatenationValue
            : null;
        return ConcatenationValueComposer(
          value: concatenationValue,
          variableDefinitions: variableDefinitions,
          customFunctions: customFunctions,
          onChange: (newValue) {
            onChange(newValue);
          },
          onInteract: () {},
        );
    }
  }
}
