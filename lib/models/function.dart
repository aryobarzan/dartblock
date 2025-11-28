import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:dartblock_code/core/dartblock_executor.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/statement.dart';
part 'function.g.dart';

/// Base class for all function types in DartBlock.
///
/// Functions can be either:
/// - [DartBlockCustomFunction]: User-defined functions with [Statement]s
/// - [DartBlockBuiltinFunction]: Built-in functions with native Dart implementations
sealed class DartBlockFunction {
  String name;
  DartBlockDataType? returnType;
  List<DartBlockVariableDefinition> parameters;

  DartBlockFunction(this.name, this.returnType, this.parameters);

  /// Execute the function with the given arguments.
  ///
  /// Returns the function's return value, or null for void functions.
  DartBlockValue? execute(DartBlockArbiter arbiter, List<DartBlockValue> args);

  DartBlockFunction copy();

  @override
  int get hashCode;

  @override
  bool operator ==(Object other);

  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  });
}

/// Built-in function with native Dart implementation.
///
/// Unlike [DartBlockCustomFunction] which executes a list of [Statement]s,
/// built-in functions execute native Dart code to provide functionality
/// that cannot be expressed in DartBlock statements (e.g., random
/// number generation).
class DartBlockBuiltinFunction extends DartBlockFunction {
  /// Native Dart implementation of the function.
  final DartBlockValue? Function(
    DartBlockArbiter arbiter,
    List<DartBlockValue> args,
  )
  implementation;

  DartBlockBuiltinFunction({
    required String name,
    required DartBlockDataType? returnType,
    required List<DartBlockVariableDefinition> parameters,
    required this.implementation,
  }) : super(name, returnType, parameters);

  /// Execute the built-in function with the provided arguments.
  ///
  /// Arguments are already validated by FunctionCallStatement.preExecute before
  /// this method is called, so no additional validation is needed here.
  @override
  DartBlockValue? execute(DartBlockArbiter arbiter, List<DartBlockValue> args) {
    return implementation(arbiter, args);
  }

  @override
  DartBlockBuiltinFunction copy() {
    return DartBlockBuiltinFunction(
      name: name,
      returnType: returnType,
      parameters: List.from(parameters.map((e) => e.copy())),
      implementation: implementation,
    );
  }

  @override
  int get hashCode =>
      name.hashCode +
      (returnType?.hashCode ?? 0) +
      parameters.fold(0, (sum, p) => sum + p.hashCode);

  @override
  bool operator ==(Object other) {
    return other is DartBlockBuiltinFunction &&
        name == other.name &&
        returnType == other.returnType &&
        parameters.length == other.parameters.length &&
        parameters.asMap().entries.every(
          (e) => e.value == other.parameters[e.key],
        );
  }

  // TODO: Implement language-specific script generation for built-in functions.
  // For example, "sqrt(...)" should be represented as "Math.sqrt(...)" in Java.
  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    return name;
  }
}

/// User-defined function with a list of statements to execute.
///
/// Custom functions are declared by the user in their DartBlock program and
/// execute a sequence of [Statement]s when called.
@JsonSerializable(explicitToJson: true)
class DartBlockCustomFunction extends DartBlockFunction
    implements DartBlockProgramTreeNodeAcceptor {
  List<Statement> statements;

  DartBlockCustomFunction(
    super.name,
    super.returnType,
    super.parameters,
    this.statements,
  );

  factory DartBlockCustomFunction.fromJson(Map<String, dynamic> json) =>
      _$DartBlockCustomFunctionFromJson(json);
  Map<String, dynamic> toJson() => _$DartBlockCustomFunctionToJson(this);

  /// Execute the custom function by running its statements in a new scope. (Statement._execute handles scope management.)
  @override
  DartBlockValue? execute(DartBlockArbiter arbiter, List<DartBlockValue> args) {
    for (var statement in statements) {
      try {
        statement.run(arbiter);
      } on ReturnStatementException catch (ex) {
        return ex.value;
      }
    }
    return null;
  }

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    switch (language) {
      case DartBlockTypedLanguage.java:
        if (name == 'main') {
          return "public static void main(String[] args) {${statements.map((e) => "\n\t\t${e.toScript(language: language)}").join("")}\n\t}";
        } else {
          return "static ${returnType != null ? returnType!.toScript(language: language) : 'void'} $name(${parameters.map((e) => e.toScript(language: language)).join(", ")}) {${statements.map((e) => "\n\t\t${e.toScript(language: language)}").join("")}\n\t}";
        }
    }
  }

  @override
  DartBlockProgramTreeNode buildTree(DartBlockProgramTreeNode programTreeNode) {
    // print("${name}: $hashCode");
    final node = DartBlockProgramTreeCustomFunctionNode(this, programTreeNode);
    DartBlockProgramTreeNode currentNode = node;
    // for (var variableDefinition in variableDefinitions) {
    //   final declarationStatement = VariableDeclarationStatement(
    //     variableDefinition.name,
    //     variableDefinition.dataType,
    //     null,
    //   );
    //   currentNode = declarationStatement.buildTree(currentNode);
    // }
    for (var statement in statements) {
      currentNode = statement.buildTree(currentNode);
    }
    programTreeNode.children.add(node);

    return node;
  }

  @override
  int get hashCode =>
      name.hashCode +
      (returnType != null ? returnType!.hashCode : 0) +
      parameters.map((e) => e.hashCode).sum +
      statements.map((e) => e.hashCode).sum;

  @override
  bool operator ==(Object other) {
    return other is DartBlockCustomFunction &&
        name == other.name &&
        returnType == other.returnType &&
        listEquals(parameters, other.parameters) &&
        listEquals(statements, other.statements);
  }

  @override
  DartBlockCustomFunction copy() {
    return DartBlockCustomFunction(
      name,
      returnType,
      List.from(parameters.map((e) => e.copy())),
      List.from(statements.map((e) => e.copy())),
    );
  }

  FunctionDefinition getAsFunctionDefinition() {
    return FunctionDefinition(name, returnType, parameters);
  }

  DartBlockCustomFunction shuffle({bool deep = false}) {
    return DartBlockCustomFunction(
      name,
      returnType,
      parameters,
      deep
            ? (statements.map((e) => e.shuffle()).toList()..shuffle())
            : statements
        ..shuffle(),
    );
  }

  DartBlockCustomFunction trim(int length) {
    List<Statement> trimmedStatements = [];
    if (length > 0) {
      for (final statement in statements) {
        final trimmedStatementResult = statement.trim(length);
        length = trimmedStatementResult.$2;
        if (trimmedStatementResult.$1 != null) {
          trimmedStatements.add(trimmedStatementResult.$1!);
        }
        if (length <= 0) {
          break;
        }
      }
    }

    return DartBlockCustomFunction(
      name,
      returnType,
      parameters,
      trimmedStatements,
    );
  }

  /// Whether it is the main function (entry point when executing [DartBlockProgram]).
  bool isMainFunction() {
    return name == "main";
  }
}

@JsonSerializable(explicitToJson: true)
class FunctionDefinition {
  final String name;
  final DartBlockDataType? returnType;
  final List<DartBlockVariableDefinition> parameters;
  FunctionDefinition(this.name, this.returnType, this.parameters);

  factory FunctionDefinition.fromJson(Map<String, dynamic> json) =>
      _$FunctionDefinitionFromJson(json);
  Map<String, dynamic> toJson() => _$FunctionDefinitionToJson(this);

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) {
    return other is FunctionDefinition &&
        name == other.name &&
        returnType == other.returnType &&
        parameters.toSet().intersection(other.parameters.toSet()).length ==
            parameters.length;
  }

  @override
  String toString() {
    return "$name(${parameters.map((e) => e.toString()).join(', ')}) => ${returnType == null ? 'void' : returnType.toString()}";
  }

  FunctionDefinition copy() {
    return FunctionDefinition(
      name,
      returnType,
      List.from(parameters.map((e) => e.copy())),
    );
  }
}
