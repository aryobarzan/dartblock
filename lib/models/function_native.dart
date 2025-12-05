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

  static final lowercase = DartBlockNativeFunction(
    name: 'lowercase',
    returnType: DartBlockDataType.stringType,
    parameters: [
      DartBlockVariableDefinition('text', DartBlockDataType.stringType),
    ],
    implementation: (arbiter, args) {
      final text = args[0].getValue(arbiter) as String;
      return DartBlockConcatenationValue.fromConstant(text.toLowerCase());
    },
    category: DartBlockNativeFunctionCategory.string,
    type: DartBlockNativeFunctionType.lowercase,
    description: 'Convert text to lowercase.',
  );

  static final uppercase = DartBlockNativeFunction(
    name: 'uppercase',
    returnType: DartBlockDataType.stringType,
    parameters: [
      DartBlockVariableDefinition('text', DartBlockDataType.stringType),
    ],
    implementation: (arbiter, args) {
      final text = args[0].getValue(arbiter) as String;
      return DartBlockConcatenationValue.fromConstant(text.toUpperCase());
    },
    category: DartBlockNativeFunctionCategory.string,
    type: DartBlockNativeFunctionType.uppercase,
    description: 'Convert text to uppercase.',
  );

  static final startsWith = DartBlockNativeFunction(
    name: 'startsWith',
    returnType: DartBlockDataType.booleanType,
    parameters: [
      DartBlockVariableDefinition('text', DartBlockDataType.stringType),
      DartBlockVariableDefinition('pattern', DartBlockDataType.stringType),
    ],
    implementation: (arbiter, args) {
      final text = args[0].getValue(arbiter) as String;
      final pattern = args[1].getValue(arbiter) as String;
      return DartBlockBooleanExpression.fromConstant(text.startsWith(pattern));
    },
    category: DartBlockNativeFunctionCategory.string,
    type: DartBlockNativeFunctionType.startsWith,
    description: 'Check if text starts with a given pattern.',
  );

  static final endsWith = DartBlockNativeFunction(
    name: 'endsWith',
    returnType: DartBlockDataType.booleanType,
    parameters: [
      DartBlockVariableDefinition('text', DartBlockDataType.stringType),
      DartBlockVariableDefinition('pattern', DartBlockDataType.stringType),
    ],
    implementation: (arbiter, args) {
      final text = args[0].getValue(arbiter) as String;
      final pattern = args[1].getValue(arbiter) as String;
      return DartBlockBooleanExpression.fromConstant(text.endsWith(pattern));
    },
    category: DartBlockNativeFunctionCategory.string,
    type: DartBlockNativeFunctionType.endsWith,
    description: 'Check if text ends with a given pattern.',
  );

  static final contains = DartBlockNativeFunction(
    name: 'contains',
    returnType: DartBlockDataType.booleanType,
    parameters: [
      DartBlockVariableDefinition('text', DartBlockDataType.stringType),
      DartBlockVariableDefinition('pattern', DartBlockDataType.stringType),
    ],
    implementation: (arbiter, args) {
      final text = args[0].getValue(arbiter) as String;
      final pattern = args[1].getValue(arbiter) as String;
      return DartBlockBooleanExpression.fromConstant(text.contains(pattern));
    },
    category: DartBlockNativeFunctionCategory.string,
    type: DartBlockNativeFunctionType.contains,
    description: 'Check if text contains a given pattern.',
  );

  static final substring = DartBlockNativeFunction(
    name: 'substring',
    returnType: DartBlockDataType.stringType,
    parameters: [
      DartBlockVariableDefinition('text', DartBlockDataType.stringType),
      DartBlockVariableDefinition('start', DartBlockDataType.integerType),
      DartBlockVariableDefinition('end', DartBlockDataType.integerType),
    ],
    implementation: (arbiter, args) {
      final text = args[0].getValue(arbiter) as String;
      final start = args[1].getValue(arbiter) as int;
      final end = args[2].getValue(arbiter) as int;
      if (start < 0 || end < 0) {
        throw DartBlockException(
          title: 'Invalid Indices',
          message: 'Start and end indices cannot be negative.',
        );
      }
      if (start > end || end > text.length) {
        throw DartBlockException(
          title: 'Invalid Indices',
          message:
              'Start index cannot be greater than end index, and end index cannot exceed text length.',
        );
      }
      return DartBlockConcatenationValue.fromConstant(
        text.substring(start, end),
      );
    },
    category: DartBlockNativeFunctionCategory.string,
    type: DartBlockNativeFunctionType.substring,
    description:
        'Get a substring of the text, from start index (inclusive) to end index (exclusive).',
  );

  /// List of all available native functions.
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
    lowercase,
    uppercase,
    startsWith,
    endsWith,
    contains,
    substring,
  ];

  /// Lookup a native function by name.
  static DartBlockNativeFunction? getByName(String name) {
    return all.firstWhereOrNull((f) => f.name == name);
  }

  /// Filter native functions by category and type.
  static List<DartBlockNativeFunction> filter(
    List<DartBlockNativeFunctionCategory> categories,
    List<DartBlockNativeFunctionType> types,
  ) {
    return all
        .where((f) => categories.contains(f.category) && types.contains(f.type))
        .toList(growable: false);
  }
}
