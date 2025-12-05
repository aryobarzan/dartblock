import 'dart:math' as math;
import 'package:collection/collection.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/exception.dart';
import 'package:dartblock_code/models/function.dart';

/// Registry of all native functions available in DartBlock programs.
class DartBlockNativeFunctions {
  /// Generate a random integer between min (inclusive) and max (inclusive).
  static final randomInt = DartBlockNativeFunction(
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
      final value = min + random.nextInt(max - min);
      return DartBlockAlgebraicExpression.fromConstant(value);
    },
    category: DartBlockNativeFunctionCategory.random,
    type: DartBlockNativeFunctionType.randomInt,
    description:
        'Generate a random integer between min (inclusive) and max (exclusive).',
  );

  /// Calculate the square root of a number.
  static final sqrt = DartBlockNativeFunction(
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
    category: DartBlockNativeFunctionCategory.math,
    type: DartBlockNativeFunctionType.sqrt,
    description: 'Calculate the square root of a number.',
  );

  /// Calculate the absolute value of a number.
  static final abs = DartBlockNativeFunction(
    name: 'abs',
    returnType: DartBlockDataType.doubleType,
    parameters: [
      DartBlockVariableDefinition('value', DartBlockDataType.doubleType),
    ],
    implementation: (arbiter, args) {
      final value = args[0].getValue(arbiter) as num;
      return DartBlockAlgebraicExpression.fromConstant(value.abs().toDouble());
    },
    category: DartBlockNativeFunctionCategory.math,
    type: DartBlockNativeFunctionType.abs,
    description: 'Calculate the absolute value of a number.',
  );

  /// Raise a number to a power.
  static final pow = DartBlockNativeFunction(
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
    category: DartBlockNativeFunctionCategory.math,
    type: DartBlockNativeFunctionType.pow,
    description: 'Raise a number to a power.',
  );

  /// Round a number to the nearest integer.
  static final round = DartBlockNativeFunction(
    name: 'round',
    returnType: DartBlockDataType.integerType,
    parameters: [
      DartBlockVariableDefinition('value', DartBlockDataType.doubleType),
    ],
    implementation: (arbiter, args) {
      final value = args[0].getValue(arbiter) as num;
      return DartBlockAlgebraicExpression.fromConstant(value.round());
    },
    category: DartBlockNativeFunctionCategory.math,
    type: DartBlockNativeFunctionType.round,
    description: 'Round a number to the nearest integer.',
  );

  /// Get the minimum of two numbers.
  static final min = DartBlockNativeFunction(
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
    category: DartBlockNativeFunctionCategory.math,
    type: DartBlockNativeFunctionType.min,
    description: 'Get the minimum of two numbers.',
  );

  /// Get the maximum of two numbers.
  static final max = DartBlockNativeFunction(
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
    category: DartBlockNativeFunctionCategory.math,
    type: DartBlockNativeFunctionType.max,
    description: 'Get the maximum of two numbers.',
  );

  /// List of all available built-in functions.
  ///
  /// These are automatically available in all DartBlock programs without
  /// needing to be declared by the user.
  static final List<DartBlockNativeFunction> all = [
    randomInt,
    sqrt,
    abs,
    pow,
    round,
    min,
    max,
  ];

  /// Lookup a built-in function by name.
  static DartBlockNativeFunction? getByName(String name) {
    return all.firstWhereOrNull((f) => f.name == name);
  }

  static List<DartBlockNativeFunction> filter(
    List<DartBlockNativeFunctionCategory> categories,
    List<DartBlockNativeFunctionType> types,
  ) {
    return all
        .where((f) => categories.contains(f.category) && types.contains(f.type))
        .toList(growable: false);
  }
}
