import 'dart:math' as math;
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/exception.dart';
import 'package:dartblock_code/models/function.dart';

/// Registry of all built-in functions available in DartBlock programs.
class DartBlockBuiltinFunctions {
  /// Generate a random integer between min (inclusive) and max (inclusive).
  static final randomInt = DartBlockBuiltinFunction(
    name: 'randomInt',
    returnType: DartBlockDataType.integerType,
    parameters: [
      DartBlockVariableDefinition('min', DartBlockDataType.integerType),
      DartBlockVariableDefinition('max', DartBlockDataType.integerType),
    ],
    implementation: (arbiter, args) {
      final min = args[0].getValue(arbiter) as int;
      final max = args[1].getValue(arbiter) as int;

      if (min > max) {
        throw DartBlockException(
          title: 'Invalid Range',
          message: 'min ($min) cannot be greater than max ($max)',
        );
      }

      final random = math.Random();
      final value = min + random.nextInt(max - min + 1);
      return DartBlockAlgebraicExpression.fromConstant(value);
    },
  );

  /// Calculate the square root of a number.
  static final sqrt = DartBlockBuiltinFunction(
    name: 'sqrt',
    returnType: DartBlockDataType.doubleType,
    parameters: [
      DartBlockVariableDefinition('value', DartBlockDataType.doubleType),
    ],
    implementation: (arbiter, args) {
      final value = args[0].getValue(arbiter) as num;
      if (value < 0) {
        throw DartBlockException(
          title: 'Math Error',
          message: 'Cannot take square root of negative number',
        );
      }
      return DartBlockAlgebraicExpression.fromConstant(
        math.sqrt(value.toDouble()),
      );
    },
  );

  /// Calculate the absolute value of a number.
  static final abs = DartBlockBuiltinFunction(
    name: 'abs',
    returnType: DartBlockDataType.doubleType,
    parameters: [
      DartBlockVariableDefinition('value', DartBlockDataType.doubleType),
    ],
    implementation: (arbiter, args) {
      final value = args[0].getValue(arbiter) as num;
      return DartBlockAlgebraicExpression.fromConstant(value.abs().toDouble());
    },
  );

  /// Raise a number to a power.
  static final pow = DartBlockBuiltinFunction(
    name: 'pow',
    returnType: DartBlockDataType.doubleType,
    parameters: [
      DartBlockVariableDefinition('base', DartBlockDataType.doubleType),
      DartBlockVariableDefinition('exponent', DartBlockDataType.doubleType),
    ],
    implementation: (arbiter, args) {
      final base = args[0].getValue(arbiter) as num;
      final exponent = args[1].getValue(arbiter) as num;
      return DartBlockAlgebraicExpression.fromConstant(
        math.pow(base, exponent).toDouble(),
      );
    },
  );

  /// Round a number to the nearest integer.
  static final round = DartBlockBuiltinFunction(
    name: 'round',
    returnType: DartBlockDataType.integerType,
    parameters: [
      DartBlockVariableDefinition('value', DartBlockDataType.doubleType),
    ],
    implementation: (arbiter, args) {
      final value = args[0].getValue(arbiter) as num;
      return DartBlockAlgebraicExpression.fromConstant(value.round());
    },
  );

  /// Get the minimum of two numbers.
  static final min = DartBlockBuiltinFunction(
    name: 'min',
    returnType: DartBlockDataType.doubleType,
    parameters: [
      DartBlockVariableDefinition('a', DartBlockDataType.doubleType),
      DartBlockVariableDefinition('b', DartBlockDataType.doubleType),
    ],
    implementation: (arbiter, args) {
      final a = args[0].getValue(arbiter) as num;
      final b = args[1].getValue(arbiter) as num;
      return DartBlockAlgebraicExpression.fromConstant(
        a < b ? a.toDouble() : b.toDouble(),
      );
    },
  );

  /// Get the maximum of two numbers.
  static final max = DartBlockBuiltinFunction(
    name: 'max',
    returnType: DartBlockDataType.doubleType,
    parameters: [
      DartBlockVariableDefinition('a', DartBlockDataType.doubleType),
      DartBlockVariableDefinition('b', DartBlockDataType.doubleType),
    ],
    implementation: (arbiter, args) {
      final a = args[0].getValue(arbiter) as num;
      final b = args[1].getValue(arbiter) as num;
      return DartBlockAlgebraicExpression.fromConstant(
        a > b ? a.toDouble() : b.toDouble(),
      );
    },
  );

  /// List of all available built-in functions.
  ///
  /// These are automatically available in all DartBlock programs without
  /// needing to be declared by the user.
  static final List<DartBlockBuiltinFunction> all = [
    randomInt,
    sqrt,
    abs,
    pow,
    round,
    min,
    max,
  ];

  /// Lookup a built-in function by name.
  static DartBlockBuiltinFunction? getByName(String name) {
    return all.cast<DartBlockBuiltinFunction?>().firstWhere(
      (f) => f?.name == name,
      orElse: () => null,
    );
  }
}
