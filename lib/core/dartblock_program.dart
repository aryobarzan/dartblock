import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:dartblock_code/core/dartblock_executor.dart';
import 'package:dartblock_code/models/function.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/statement.dart';
part 'dartblock_program.g.dart';

/// Fixed values used across NeoTech to determine certain parameters and limits.
final class NeoTechConstantSettings {
  /// The maximum character length for variable names.
  static const variableNameLength = 48;

  /// The maximum character length for function names.
  static const functionNameLength = 48;
}

/// The full DartBlock program, containing both its default main function (entry point) and any additional custom functions defined by the user.
@JsonSerializable(explicitToJson: true)
class DartBlockProgram {
  /// The typed language associated with the DartBlock program.
  ///
  /// This affects certain behaviors which are language-specific.
  ///
  /// In the current version of DartBlock, only Java is supported.
  /// In that regard, DartBlock's integer division imitates Java's, i.e., it uses truncating division.
  final DartBlockTypedLanguage mainLanguage;

  /// The entry point of a DartBlock program.
  final DartBlockFunction mainFunction;

  /// Any additional custom functions defined in addition to the default main function.
  final List<DartBlockFunction> customFunctions;

  /// The version of DartBlock which was used to build this DartBlock program.
  final int version;

  /// The main constructor.
  DartBlockProgram.init(
    List<Statement> statements,
    this.customFunctions, {
    this.mainLanguage = DartBlockTypedLanguage.java,
  }) : version = 1,
       mainFunction = DartBlockFunction("main", null, [], statements);

  /// An example DartBlock program, available as an additional constructor.
  DartBlockProgram.example()
    : customFunctions = [],
      mainLanguage = DartBlockTypedLanguage.java,
      version = 1,
      mainFunction = DartBlockFunction("main", null, [], []) {
    addStatementToMain(
      VariableDeclarationStatement.init(
        "z",
        DartBlockDataType.integerType,
        DartBlockAlgebraicExpression.fromConstant(5),
      ),
    );

    addStatementToMain(
      VariableAssignmentStatement.init(
        "z",
        DartBlockAlgebraicExpression.fromConstant(12),
      ),
    );

    addStatementToMain(
      PrintStatement.init(
        DartBlockConcatenationValue.init([DartBlockVariable.init("z")]),
      ),
    );
    addStatementToMain(
      ForLoopStatement.init(
        VariableDeclarationStatement.init(
          "i",
          DartBlockDataType.integerType,
          DartBlockAlgebraicExpression.fromConstant(0),
        ),
        DartBlockBooleanExpression.init(
          DartBlockValueTreeBooleanNumberComparisonOperatorNode.init(
            DartBlockNumberComparisonOperator.less,
            DartBlockValueTreeBooleanGenericNumberNode.init(
              DartBlockAlgebraicExpression.init(
                DartBlockValueTreeAlgebraicDynamicNode.init(
                  DartBlockVariable.init("i"),
                  null,
                ),
              ),
              null,
            ),
            DartBlockValueTreeBooleanGenericNumberNode.init(
              DartBlockAlgebraicExpression.fromConstant(5),
              null,
            ),
            null,
          ),
        ),
        VariableAssignmentStatement.init(
          "i",
          DartBlockAlgebraicExpression.init(
            DartBlockValueTreeAlgebraicOperatorNode.init(
              DartBlockAlgebraicOperator.add,
              DartBlockValueTreeAlgebraicDynamicNode.init(
                DartBlockVariable.init("i"),
                null,
              ),
              DartBlockValueTreeAlgebraicConstantNode.init(1, false, null),
              null,
            ),
          ),
        ),
        [
          PrintStatement.init(
            DartBlockConcatenationValue.init([DartBlockVariable.init("i")]),
          ),
        ],
      ),
    );
  }

  /// Helper constructor, used internally for serialization. Do not use this constructor, instead opt for the .init() named constructor.
  ///
  /// DartBlock relies on automatically generated JSON serialization functions, based on the json_serializable package.
  /// The latter expects a non-named constructor for its generation.
  DartBlockProgram(
    this.mainLanguage,
    this.mainFunction,
    this.customFunctions,
    this.version,
  );

  factory DartBlockProgram.fromJson(Map<String, dynamic> json) =>
      _$DartBlockProgramFromJson(json);
  Map<String, dynamic> toJson() => _$DartBlockProgramToJson(this);

  /// Add a statement to the main function.
  void addStatementToMain(Statement statement) {
    mainFunction.statements.add(statement);
  }

  /// Export the DartBlock program to a typed language.
  ///
  /// - `Java`: creates a `Launcher` class which will contain the main function of the DartBlock as the main method, as well as the custom functions as static methods of the same class.
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    switch (language) {
      case DartBlockTypedLanguage.java:
        return "class Launcher {\n"
            "\t${mainFunction.toScript(language: language)}${customFunctions.isNotEmpty ? '\n\n\t' : ''}${customFunctions.map((e) => e.toScript(language: language)).join("\n\n\t")}"
            "\n}";
    }
  }

  /// Build a tree-based representation of the DartBlock program.
  ///
  /// The tree representation is used internally to enable:
  /// - the [NeoTechVariableCountEvaluationSchema] schema,
  /// - to determine the defined variables available in a given scope.
  DartBlockProgramTreeNode buildTree() {
    final DartBlockProgramTreeNode root = DartBlockProgramTreeRootNode();
    for (var customFunction in [mainFunction] + customFunctions) {
      customFunction.buildTree(root);
    }

    return root;
  }

  @override
  int get hashCode =>
      mainLanguage.hashCode +
      mainFunction.hashCode +
      customFunctions.map((e) => e.hashCode).sum +
      version.hashCode;

  @override
  bool operator ==(Object other) {
    return other is DartBlockProgram &&
        mainLanguage == other.mainLanguage &&
        mainFunction == other.mainFunction &&
        listEquals(customFunctions, other.customFunctions) &&
        version == other.version;
  }

  DartBlockProgram copy() {
    return DartBlockProgram(
      mainLanguage,
      mainFunction.copy(),
      List.from(customFunctions.map((e) => e.copy())),
      version,
    );
  }

  /// Whether the main function and any potential custom functions are all empty, i.e., they do not contain any statements.
  bool isEmpty() {
    return mainFunction.statements.isEmpty && customFunctions.isEmpty;
  }

  /// Generate a list of hints for the DartBlock program.
  ///
  /// The types of hints which can be generated (examples):
  /// - "4 custom functions are expected."
  /// - "2 variables are expected."
  /// - "2 for-loops are expected."
  List<String> getHints() {
    final List<String> hints = [];

    if (customFunctions.isNotEmpty) {
      final isSingular = customFunctions.length == 1;
      hints.add(
        "${customFunctions.length} custom function${isSingular ? "" : "s"} ${isSingular ? "is" : "are"} expected.",
      );
    }

    final variableDefinitions = buildTree()
        .findAllVariableDefinitions()
        .where((element) => !element.name.startsWith('_'))
        .toList();
    if (variableDefinitions.isNotEmpty) {
      final isSingular = variableDefinitions.length == 1;
      hints.add(
        """${variableDefinitions.length} variable${isSingular ? "" : "s"} ${isSingular ? "is" : "are"} expected.
Types: ${variableDefinitions.map((e) => e.dataType.toString()).toSet().join(', ')}""",
      );
    }

    final statementTypeUsageCount = getStatementTypeUsageCount();
    if (statementTypeUsageCount.isNotEmpty) {
      for (final entry in statementTypeUsageCount.entries) {
        switch (entry.key) {
          case StatementType.statementBlockStatement:
          case StatementType.whileLoopStatement:
            break;
          default:
            final isSingular = entry.value == 1;
            hints.add(
              "${entry.value} '${entry.key.toString()}' statement${isSingular ? "" : "s"} ${isSingular ? "is" : "are"} expected.",
            );
            break;
        }
      }
    }

    return hints;
  }

  /// Count the usage of each statement type across the main function and custom functions.
  Map<StatementType, int> getStatementTypeUsageCount() {
    return buildTree().getStatementTypeUsageCount();
  }

  /// Randomly re-order the statements in the main function, as well as the
  /// custom functions.
  ///
  /// If the 'deep' parameter is false, the shuffling will only be at the highest
  /// level, i.e., nested statements will not have their statements shuffled.
  ///
  /// Otherwise, all statements will be shuffled, e.g., a for-loop's body will
  /// also be shuffled.
  DartBlockProgram shuffle({bool deep = false}) {
    return DartBlockProgram(
      mainLanguage,
      mainFunction.shuffle(deep: deep),
      customFunctions.map((e) => e.shuffle(deep: deep)).toList(),
      version,
    );
  }

  /// Shorten the DartBlock program based on the given percentage value, by starting from the end of the program!
  ///
  /// `trimPercentage`: value in range [0.0, 1.0]
  ///
  /// This is a deep trim, i.e., the maximum depth of each function is calculated
  /// based on its tree representation. Then, the trimmed length is calculated
  /// based on maximum_depth*trimPercentage.
  DartBlockProgram trim({
    required double trimPercentage,
    bool trimMainFunction = true,
    bool trimCustomFunctions = true,
  }) {
    trimPercentage = 1.0 - max(0.0, min(1.0, trimPercentage));

    DartBlockFunction trimCustomFunction(DartBlockFunction customFunction) {
      /// Get the max depth of the function based on its tree-based representation.
      final int? customFunctionDepth = buildTree()
          .findNodeByKey(customFunction.hashCode)
          ?.getMaxDepth();
      if (customFunctionDepth != null && customFunctionDepth >= 0) {
        int trimToLength = (customFunctionDepth * trimPercentage).floor();

        return customFunction.trim(trimToLength);
      } else {
        return customFunction;
      }
    }

    /// Trim the main function.
    DartBlockFunction trimmedMainFunction = trimMainFunction
        ? trimCustomFunction(mainFunction)
        : mainFunction;

    /// Trim each custom function
    List<DartBlockFunction> trimmedCustomFunctions = [];
    if (trimCustomFunctions) {
      for (final customFunction in customFunctions) {
        DartBlockFunction trimmedCustomFunction = trimCustomFunction(
          customFunction,
        );
        trimmedCustomFunctions.add(trimmedCustomFunction);
      }
    } else {
      trimmedCustomFunctions = customFunctions;
    }

    return DartBlockProgram(
      mainLanguage,
      trimmedMainFunction,
      trimmedCustomFunctions,
      version,
    );
  }

  /// Retrieve the maximum depth of the DartBlock program across its main and custom functions, if the program is not empty.
  ///
  /// The counting is performed using the tree-based representation of the program.
  int? getMaxDepth() {
    int? maxDepth = buildTree()
        .findNodeByKey(mainFunction.hashCode)
        ?.getMaxDepth();
    for (final customFunction in customFunctions) {
      final int? customFunctionDepth = buildTree()
          .findNodeByKey(customFunction.hashCode)
          ?.getMaxDepth();
      maxDepth ??= customFunctionDepth;
      if (maxDepth != null &&
          customFunctionDepth != null &&
          customFunctionDepth > maxDepth) {
        maxDepth = customFunctionDepth;
      }
    }

    return maxDepth;
  }
}
