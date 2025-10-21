import 'package:json_annotation/json_annotation.dart';

import 'dartblock_value.dart';
import 'statement.dart';
part 'exception.g.dart';

/// An exception which can be thrown during the execution of a [DartBlockProgram].
@JsonSerializable(explicitToJson: true)
class DartBlockException implements Exception {
  /// The statement which caused the exception to be thrown.
  Statement? statement;

  /// The descriptive title of the exception.
  String title;

  /// A short explanation of the exception.
  String message;

  /// An explanation of the exception for internal usage, e.g., logging.
  ///
  /// It is not necessarily a complete sentence or paragraph, compared to the user-facing [message].
  String internalMessage;

  /// Whether the exception stems from Dart's own engine, or it is simply an unknown exception.
  ///
  /// If true, then it is a known exception specific to DartBlock.
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

  /// Used for the output of certain evaluation schemas.
  String describe({bool includeThrownBy = true}) {
    return "Exception: $message${statement != null && includeThrownBy ? '\n> Thrown by: ${statement!.toScript()}' : ''}";
  }
}

/// An exception thrown when DartBlock attempts to look up a variable's value by its name during execution, but it does not exist.
class VariableNotDeclaredException extends DartBlockException {
  /// The name of the variable being looked up.
  String variableName;
  VariableNotDeclaredException(this.variableName)
    : super(
        title: "Variable Not Declared",
        message: "Variable '$variableName' is not declared.",
      );
}

/// An exception thrown when DartBlock runs into a second [VariableDeclarationStatement] which is attempting to re-declare an existing statement, based on its name.
class VariableAlreadyDeclaredException extends DartBlockException {
  String variableName;
  VariableAlreadyDeclaredException(this.variableName)
    : super(
        title: "Variable Already Declared",
        message: "Variable '$variableName' is already declared.",
      );
}

/// An exception thrown when DartBlock attempts to execute a [VariableDeclarationStatement], based on the validation provided by [DartBlockValidator.validateVariableName].
class InvalidVariableNameException extends DartBlockException {
  /// The invalid variable name.
  String variableName;

  /// A short explanation as to why the variable name is invalid.
  String reason;
  InvalidVariableNameException(this.variableName, this.reason)
    : super(
        title: "Invalid Variable Name",
        message: "Variable name '$variableName' is invalid: $reason",
      );
}

/// An exception thrown when DartBlock attempts to execute a [VariableAssignmentStatement], where the type of the value being assigned does not match the type of the variable.
class VariableValueTypeMismatchException extends DartBlockException {
  /// The name of the variable to which the value is being assigned.
  String variableName;

  /// The type of the variable based on its prior declaration.
  DartBlockDataType expectedType;

  /// The type of the value being assigned to the variable.
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

/// An exception thrown when DartBlock attempts to retrieve the value associated with a [DartBlockVariable] or [DartBlockFunctionCallValue], where the type of the retrieved value does not match the expected type.
class DynamicValueTypeMismatchException extends DartBlockException {
  /// The variable or function call.
  DartBlockDynamicValue dynamicValue;

  /// The actual value associated with the variable or function call.
  dynamic concreteValue;

  /// The expected type, based on either the variable definition or the function's return type.
  Type expectedType;

  /// The actual type of the [concreteValue].
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

/// An exception thrown when DartBlock attempts to calculate the value of an expression, specifically a boolean or numeric expression, where the type of the calculated value does not match the expected type of the expression.
class ExpressionValueTypeMismatchException extends DartBlockException {
  /// The boolean ([DartBlockBooleanExpression]) or numeric ([DartBlockAlgebraicExpression]) expression.
  DartBlockExpressionValue dynamicValue;

  /// The value calculated when evaluating the expression.
  dynamic concreteValue;

  /// The expected type of the expression.
  Type expectedType;

  /// The actual type of the [concreteValue].
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

/// An exception thrown by DartBlock when calculating the value of a [DartBlockAlgebraicExpression].
///
/// Cases include:
/// - division by zero.
/// - the use of the module (%) operator with a negative right operand.
/// - a missing operator when both the left and right operand are non-null.
/// - the left operand and right operand both being null.
/// - the left operand, the right operand and the operator all being null.
/// - the left operand being null, the right operand being non-null and the operator being either '*', '/' or '%'.
///
/// See [DartBlockValueTreeAlgebraicOperatorNode.getValue] for the implementation details.
class MalformedAlgebraicExpressionException extends DartBlockException {
  /// The left operand of the algebraic expression.
  num? leftOperand;

  /// The right operand of the algebraic expression.
  num? rightOperand;

  /// The operator of the algebraic expression.
  DartBlockAlgebraicOperator? operator;

  /// A short explanation of the exception in the form of a sentence.
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

/// An exception thrown by DartBlock when calculating the value of a [DartBlockBooleanExpression].
///
/// Cases include:
/// - a missing operator (||, &&) when the left and right operand are non-null.
/// - the left operand and right operand being null while the operator is not null.
/// - the left operand, the right operand and the operator being null.
class MalformedBooleanLogicalExpressionException extends DartBlockException {
  /// The left operand of the boolean expression.
  bool? leftOperand;

  /// The right operand of the boolean expression.
  bool? rightOperand;

  /// The operator of the boolean expression.
  DartBlockBooleanOperator? operator;

  /// A short explanation of the exception in the form of a sentence.
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

/// An exception thrown by DartBlock when calculating the value of a [DartBlockBooleanExpression].
///
/// Cases include:
/// - the left operand and right operand being non-null, while the operator is null.
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

/// An exception thrown by DartBlock when calculating the value of a [DartBlockBooleanExpression].
///
/// Cases include:
/// - the left operand, the right operand and the operator being null. (example: `<operand>` `<operator>` `<operand>`)
/// - the operator being null, while the left operand and the right operand are non-null. (example: 4 `<operator>` 5)
/// - the left operand and the operator being null, while the right operand is non-null. (example: `<operand>` `<operator>` 5)
/// - the right operand and the operator being null, while the left operand is non-null. (example: 4 `<operator>` `<operand>`)
/// - the left operand and the right operand being null, while the operator is non-null. (example: `<operand>` == `<operand>`)
/// - the left operand being null, while the right operand and the operator are non-null. (example: `<operand>` == 5)
/// - the right operand being null, while the left operand and the operator are non-null. (example: 4 == `<operand>`)
class MalformedBooleanNumberComparisonExpressionException
    extends DartBlockException {
  /// The left operand of the boolean expression.
  bool? leftOperand;

  /// The right operand of the boolean expression.
  bool? rightOperand;

  /// The operator of the boolean expression.
  DartBlockNumberComparisonOperator? operator;

  /// A short explanation of the exception in the form of a sentence.
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

/// An exception thrown when DartBlock attempts to execute a [FunctionCallStatement], where the relevant custom function can not be retrieved based on the given name.
class UndefinedCustomFunctionException extends DartBlockException {
  /// The function name being looked up.
  String functionName;
  UndefinedCustomFunctionException(this.functionName)
    : super(
        title: "Undefined Function",
        message: "Function '$functionName' is not defined.",
      );
}

/// An exception thrown when DartBlock attempts to execute a [FunctionCallStatement], where the number of arguments passed to the function call does not match the expected number based on the parameter list of the function.
class CustomFunctionArgumentsCountException extends DartBlockException {
  /// The name of the function being called.
  final String functionName;

  /// The expected number of arguments, based on the number of function parameters
  final int expectedCount;

  /// The actual number of arguments to the function call.
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

/// An exception thrown when DartBlock attempts to execute a [FunctionCallStatement], where one of the argument's value type does not match the corresponding function parameter's type. (based on parameter position/index)
class CustomFunctionMissingArgumentException extends DartBlockException {
  /// The name of the function being called.
  final String functionName;

  /// The corresponding function parameter. (name and type)
  final DartBlockVariableDefinition variableDefinition;

  /// The position/index of the corresponding function parameter.
  final int parameterIndex;

  /// The actual type of the argument for the corresponding parameter.
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

/// An exception thrown when DartBlock attempts to execute a [FunctionCallStatement], where the custom function does not terminate with a [ReturnStatement].
class CustomFunctionMissingReturnValueException extends DartBlockException {
  /// The name of the function being called.
  final String functionName;

  /// The expected return type of the function.
  final DartBlockDataType returnType;
  CustomFunctionMissingReturnValueException(this.functionName, this.returnType)
    : super(
        title: "Function Missing Return Value",
        message:
            "Function '$functionName' must return a value of type $returnType.",
      );
}

/// An exception thrown when DartBlock attempts to execute a [FunctionCallStatement], where the relevant [ReturnStatement] in the function's body returns a value of the wrong type, compared to the expected return type of the function.
class CustomFunctionInvalidReturnValueTypeException extends DartBlockException {
  /// The name of the function being called.
  final String functionName;

  /// The expected return type of the function.
  final DartBlockDataType returnType;

  /// The actual type of the value returned by the function call.
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

/// An exception thrown when DartBlock attempts to execute a [FunctionCallStatement], where a [ReturnStatement] is executed as part of the function's body, but the function's return type is 'void'.
class CustomFunctionNoReturnValueExpectedException extends DartBlockException {
  final String functionName;
  CustomFunctionNoReturnValueExpectedException(this.functionName)
    : super(
        title: "Function Void Return",
        message:
            "Function '$functionName' has return type 'void', meaning it must not return a value.",
      );
}

/// An exception thrown when the JSON decoding via [Statement.fromJson] fails.
/// This is not a [DartBlockException] thrown during a program's execution or shown to the user.
class StatementSerializationException implements Exception {
  /// The type of the [Statement] being decoded, based on the JSON key 'statementType'.
  final String? statementTypeField;
  StatementSerializationException(this.statementTypeField);
  @override
  String toString() {
    return "Failed to deserialize Statement: could not identify type '$statementTypeField'.";
  }
}

/// An exception thrown when the JSON decoding via [DartBlockEvaluationSchema.fromJson] fails.
/// This is not a [DartBlockException] thrown during a program's execution or shown to the user.
class EvaluatorSchemaSerializationException implements Exception {
  /// The type of the [DartBlockEvaluationSchema] being decoded, based on the JSON key 'schemaType'.
  final String? evaluatorSchemaField;
  EvaluatorSchemaSerializationException(this.evaluatorSchemaField);
  @override
  String toString() {
    return "Failed to deserialize Evaluator Schema: could not identify type '$evaluatorSchemaField'.";
  }
}

/// An exception thrown when the JSON decoding via [DartBlockEvaluation.fromJson] fails.
/// This is not a [DartBlockException] thrown during a program's execution or shown to the user.
class EvaluatorEvaluationSerializationException implements Exception {
  /// The type of the [DartBlockEvaluation] being decoded, based on the JSON key 'evaluationType'.
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
