import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:dartblock_code/core/dartblock_executor.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/statement.dart';
part 'function.g.dart';

@JsonSerializable(explicitToJson: true)
class DartBlockFunction implements DartBlockProgramTreeNodeAcceptor {
  String name;
  DartBlockDataType? returnType;
  List<DartBlockVariableDefinition> parameters;
  List<Statement> statements;
  DartBlockFunction(
    this.name,
    this.returnType,
    this.parameters,
    this.statements,
  );

  factory DartBlockFunction.fromJson(Map<String, dynamic> json) =>
      _$DartBlockFunctionFromJson(json);
  Map<String, dynamic> toJson() => _$DartBlockFunctionToJson(this);

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
  DartBlockProgramTreeNode buildTree(DartBlockProgramTreeNode neoTechCoreNode) {
    // print("${name}: $hashCode");
    final node = DartBlockProgramTreeCustomFunctionNode(this, neoTechCoreNode);
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
    neoTechCoreNode.children.add(node);

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
    return other is DartBlockFunction &&
        name == other.name &&
        returnType == other.returnType &&
        listEquals(parameters, other.parameters) &&
        listEquals(statements, other.statements);
  }

  DartBlockFunction copy() {
    return DartBlockFunction(
      name,
      returnType,
      List.from(parameters.map((e) => e.copy())),
      List.from(statements.map((e) => e.copy())),
    );
  }

  FunctionDefinition getAsFunctionDefinition() {
    return FunctionDefinition(name, returnType, parameters);
  }

  DartBlockFunction shuffle({bool deep = false}) {
    return DartBlockFunction(
      name,
      returnType,
      parameters,
      deep
            ? (statements.map((e) => e.shuffle()).toList()..shuffle())
            : statements
        ..shuffle(),
    );
  }

  DartBlockFunction trim(int length) {
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

    return DartBlockFunction(name, returnType, parameters, trimmedStatements);
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
