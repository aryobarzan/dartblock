import 'package:json_annotation/json_annotation.dart';

import 'dartblock_value.dart';
import 'statement.dart';
part 'exception.g.dart';

@JsonSerializable(explicitToJson: true)
class DartBlockException implements Exception {
  Statement? statement;
  String title;
  String message;
  String internalMessage;
  bool isGeneric;
  DartBlockException({
    required this.title,
    required this.message,
    this.statement,
  }) : isGeneric = false,
       internalMessage = '';
  DartBlockException.fromException({
    required Exception exception,
    this.statement,
  }) : isGeneric = true,
       title = "Exception",
       internalMessage = exception.toString(),
       message =
           "An unknown error occurred. This may be due to your program containing an infinite loop or due to a stack overflow in case of a faulty recursive function.";

  factory DartBlockException.fromJson(Map<String, dynamic> json) =>
      _$DartBlockExceptionFromJson(json);
  Map<String, dynamic> toJson() => _$DartBlockExceptionToJson(this);

  @override
  String toString() {
    return "Exception: $message${statement != null ? '\n> Thrown by: ${statement!.toScript()}' : ''}";
  }

  String describe({bool includeThrownBy = true}) {
    return "Exception: $message${statement != null && includeThrownBy ? '\n> Thrown by: ${statement!.toScript()}' : ''}";
  }
}

///
class VariableNotDeclaredException extends DartBlockException {
  String variableName;
  VariableNotDeclaredException(this.variableName)
    : super(
        title: "Variable Not Declared",
        message: "Variable '$variableName' is not declared.",
      );
}

class VariableAlreadyDeclaredException extends DartBlockException {
  String variableName;
  VariableAlreadyDeclaredException(this.variableName)
    : super(
        title: "Variable Already Declared",
        message: "Variable '$variableName' is already declared.",
      );
}

class InvalidVariableNameException extends DartBlockException {
  String variableName;
  String reason;
  InvalidVariableNameException(this.variableName, this.reason)
    : super(
        title: "Invalid Variable Name",
        message: "Variable name '$variableName' is invalid: $reason",
      );
}

class VariableValueTypeMismatchException extends DartBlockException {
  String variableName;
  DartBlockDataType expectedType;
  Type gotType;
  VariableValueTypeMismatchException(
    this.variableName,
    this.expectedType,
    this.gotType,
  ) : super(
        title: "Value Type Mismatch",
        message:
            "Value type mismatch for variable '$variableName': expected type '$expectedType', got '$gotType'.",
      );
}

class DynamicValueTypeMismatchException extends DartBlockException {
  DartBlockDynamicValue dynamicValue;
  dynamic concreteValue;
  Type expectedType;
  Type gotType;
  DynamicValueTypeMismatchException(
    this.dynamicValue,
    this.concreteValue,
    this.expectedType,
    this.gotType,
  ) : super(
        title: "Value Type Mismatch",
        message:
            "Value type mismatch for '${dynamicValue.toString()}': expected type '$expectedType', got '$gotType'${concreteValue != null ? '($concreteValue)' : ''}.${concreteValue == null && dynamicValue is DartBlockVariable ? '\nEnsure you have assigned an initial value to the variable!' : ''}",
      );
}

class ExpressionValueTypeMismatchException extends DartBlockException {
  DartBlockExpressionValue dynamicValue;
  dynamic concreteValue;
  Type expectedType;
  Type gotType;
  ExpressionValueTypeMismatchException(
    this.dynamicValue,
    this.concreteValue,
    this.expectedType,
    this.gotType,
  ) : super(
        title: "Value Type Mismatch",
        message:
            "Value type mismatch for '${dynamicValue.toString()}': expected type '$expectedType', got '$gotType' ($concreteValue).",
      );
}

class MalformedAlgebraicExpressionException extends DartBlockException {
  num? leftOperand;
  num? rightOperand;
  DartBlockAlgebraicOperator? operator;
  String reason;
  MalformedAlgebraicExpressionException(
    this.leftOperand,
    this.rightOperand,
    this.operator,
    this.reason,
  ) : super(
        title: "Malformed Algebraic Expression",
        message: "Malformed algebraic expression: $reason",
      );
}

class MalformedBooleanLogicalExpressionException extends DartBlockException {
  bool? leftOperand;
  bool? rightOperand;
  DartBlockBooleanOperator? operator;
  String reason;
  MalformedBooleanLogicalExpressionException(
    this.leftOperand,
    this.rightOperand,
    this.operator,
    this.reason,
  ) : super(
        title: "Malformed Boolean Expression",
        message: "Malformed boolean expression: $reason",
      );
}

class MalformedBooleanEqualityExpressionException extends DartBlockException {
  bool? leftOperand;
  bool? rightOperand;
  DartBlockEqualityOperator? operator;
  String reason;
  MalformedBooleanEqualityExpressionException(
    this.leftOperand,
    this.rightOperand,
    this.operator,
    this.reason,
  ) : super(
        title: "Malformed Boolean Expression",
        message: "Malformed boolean expression: $reason",
      );
}

class MalformedBooleanNumberComparisonExpressionException
    extends DartBlockException {
  bool? leftOperand;
  bool? rightOperand;
  DartBlockNumberComparisonOperator? operator;
  String reason;
  MalformedBooleanNumberComparisonExpressionException(
    this.leftOperand,
    this.rightOperand,
    this.operator,
    this.reason,
  ) : super(
        title: "Malformed Boolean Expression",
        message: "Malformed boolean expression: $reason",
      );
}

// class ValueTypeMismatchException extends NeoTechException {
//   NeoTechDataType expectedType;
//   Type gotType;
//   ValueTypeMismatchException(this.expectedType, this.gotType)
//       : super(
//             message:
//                 "Value type mismatch - expected type '$expectedType', got '$gotType'.");
// }
class UndefinedCustomFunctionException extends DartBlockException {
  String functionName;
  UndefinedCustomFunctionException(this.functionName)
    : super(
        title: "Undefined Function",
        message: "Function '$functionName' is not defined.",
      );
}

class CustomFunctionArgumentsCountException extends DartBlockException {
  final String functionName;
  final int expectedCount;
  final int gotCount;
  CustomFunctionArgumentsCountException(
    this.functionName,
    this.expectedCount,
    this.gotCount,
  ) : super(
        title: "Function Arguments Missing",
        message:
            "Function '$functionName' expects $expectedCount argument${expectedCount == 1 ? '' : 's'}, got $gotCount instead.",
      );
}

class CustomFunctionMissingArgumentException extends DartBlockException {
  final String functionName;
  final DartBlockVariableDefinition variableDefinition;
  final int parameterIndex;
  final Type gotType;
  CustomFunctionMissingArgumentException(
    this.functionName,
    this.variableDefinition,
    this.parameterIndex,
    this.gotType,
  ) : super(
        title: "Function Wrong Argument Type",
        message:
            "Function '$functionName' expects an argument '${variableDefinition.name}' of type ${variableDefinition.dataType} at index $parameterIndex, but got $gotType.",
      );
}

class CustomFunctionMissingReturnValueException extends DartBlockException {
  final String functionName;
  final DartBlockDataType returnType;
  CustomFunctionMissingReturnValueException(this.functionName, this.returnType)
    : super(
        title: "Function Missing Return Value",
        message:
            "Function '$functionName' must return a value of type $returnType.",
      );
}

class CustomFunctionInvalidReturnValueTypeException extends DartBlockException {
  final String functionName;
  final DartBlockDataType returnType;
  final Type gotType;
  CustomFunctionInvalidReturnValueTypeException(
    this.functionName,
    this.returnType,
    this.gotType,
  ) : super(
        title: "Function Wrong Return Value Type",
        message:
            "Function '$functionName' must return a value of type $returnType, but it returned type $gotType.",
      );
}

class CustomFunctionNoReturnValueExpectedException extends DartBlockException {
  final String functionName;
  CustomFunctionNoReturnValueExpectedException(this.functionName)
    : super(
        title: "Function Void Return",
        message:
            "Function '$functionName' has return type 'void', meaning it must not return a value.",
      );
}

/// Not thrown by program execution, but for serialization/deserialization of Statement objects
class StatementSerializationException implements Exception {
  final String? statementTypeField;
  StatementSerializationException(this.statementTypeField);
  @override
  String toString() {
    return "Failed to deserialize Statement: could not identify type '$statementTypeField'.";
  }
}

class EvaluatorSchemaSerializationException implements Exception {
  final String? evaluatorSchemaField;
  EvaluatorSchemaSerializationException(this.evaluatorSchemaField);
  @override
  String toString() {
    return "Failed to deserialize Evaluator Schema: could not identify type '$evaluatorSchemaField'.";
  }
}

class EvaluatorEvaluationSerializationException implements Exception {
  final String? evaluationTypeField;
  EvaluatorEvaluationSerializationException(this.evaluationTypeField);
  @override
  String toString() {
    return "Failed to deserialize Evaluation: could not identify type '$evaluationTypeField'.";
  }
}

/// unused
// class ArithmeticExpressionInvalidType implements Exception {
//   NeoValue value;
//   ArithmeticExpressionInvalidType(this.value);
//   @override
//   String toString() {
//     return "EXCEPTION - $value is not a valid type for arithmetic expressions: only numbers are allowed.";
//   }
// }
// class ConditionConditionalTypesMismatch implements Exception {
//   Type typeX;
//   Type typeY;
//   ConditionConditionalTypesMismatch(this.typeX, this.typeY);
//   @override
//   String toString() {
//     return "EXCEPTION - a value of type $typeX is not comparable to a value of type $typeY.";
//   }
// }
// class StopExecutionError extends Error {}

// class SkipExecutionError extends Error {}
