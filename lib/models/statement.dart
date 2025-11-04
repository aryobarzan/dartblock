import 'package:dartblock_code/widgets/views/toolbox/models/toolbox_configuration.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:dartblock_code/core/dartblock_executor.dart';
import 'package:dartblock_code/models/function.dart';
import 'package:dartblock_code/models/exception.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/dartblock_validator.dart';
import 'package:uuid/uuid.dart';
part 'statement.g.dart';

/// The conventional (typed) programming languages available to export a DartBlock program to.
@JsonEnum()
enum DartBlockTypedLanguage {
  java;

  String getFileExtension() {
    return switch (this) {
      DartBlockTypedLanguage.java => 'java',
    };
  }
}

/// The category to which a [Statement] belongs.
///
/// This [StatementCategory] is not used as a property of [Statement], but simply used for the categorization of the different [Statement]s in the toolbox widget of DartBlock.
enum StatementCategory {
  variable,
  loop,
  decisionStructure,
  function,
  other;

  @override
  String toString() {
    return switch (this) {
      StatementCategory.variable => 'Variable',
      StatementCategory.loop => 'Loop',
      StatementCategory.decisionStructure => 'Decision Structure',
      StatementCategory.function => 'Function',
      StatementCategory.other => 'Other',
    };
  }

  /// Retrieve a visualization of the statement category.
  Widget getIconData(double width) {
    return switch (this) {
      StatementCategory.variable => Icon(
        Icons.data_object,
        size: width,
        color: ToolboxConfig.categoryColors[StatementCategory.variable],
      ),
      // const Text('(x)', style: TextStyle(fontSize: 14)),
      StatementCategory.loop => Icon(
        Icons.loop,
        size: width,
        color: ToolboxConfig.categoryColors[StatementCategory.loop],
      ),
      StatementCategory.decisionStructure => Icon(
        Icons.alt_route,
        size: width,
        color:
            ToolboxConfig.categoryColors[StatementCategory.decisionStructure],
      ),
      StatementCategory.function => Icon(
        Icons.alt_route,
        size: width,
        color: ToolboxConfig.categoryColors[StatementCategory.function],
      ),
      StatementCategory.other => Icon(
        Icons.dashboard_outlined,
        size: width,
        color: ToolboxConfig.categoryColors[StatementCategory.other],
      ),
    };
  }
}

/// The type of a [Statement].
@JsonEnum()
enum StatementType {
  @JsonValue('statementBlockStatement')
  statementBlockStatement('statementBlockStatement'),
  @JsonValue('printStatement')
  printStatement('printStatement'),
  @JsonValue('returnStatement')
  returnStatement('returnStatement'),
  @JsonValue('ifElseStatement')
  ifElseStatement('ifElseStatement'),
  @JsonValue('forLoopStatement')
  forLoopStatement('forLoopStatement'),
  @JsonValue('whileLoopStatement')
  whileLoopStatement('whileLoopStatement'),
  @JsonValue('variableDeclarationStatement')
  variableDeclarationStatement('variableDeclarationStatement'),
  @JsonValue('variableAssignmentStatement')
  variableAssignmentStatement('variableAssignmentStatement'),
  @JsonValue('customFunctionCallStatement')
  customFunctionCallStatement('customFunctionCallStatement'),
  @JsonValue('breakStatement')
  breakStatement('breakStatement'),
  @JsonValue('continueStatement')
  continueStatement('continueStatement');

  final String jsonValue;
  const StatementType(this.jsonValue);

  @override
  String toString() {
    switch (this) {
      case StatementType.statementBlockStatement:
        return "Statement Block";
      case StatementType.printStatement:
        return "Print";
      case StatementType.returnStatement:
        return "Return Value";
      case StatementType.ifElseStatement:
        return "If-Then-Else";
      case StatementType.forLoopStatement:
        return "For-Loop";
      case StatementType.whileLoopStatement:
        return "While-Loop";
      case StatementType.variableDeclarationStatement:
        return "Declare Variable";
      case StatementType.variableAssignmentStatement:
        return "Update Variable";
      case StatementType.customFunctionCallStatement:
        return "Call Function";
      case StatementType.breakStatement:
        return "Break";
      case StatementType.continueStatement:
        return "Continue";
    }
  }

  /// A short, imperative sentence to describe what will happen when the user is about to drop a dragged [StatementType] onto a location in their program.
  String describeAdd() {
    switch (this) {
      case StatementType.variableDeclarationStatement:
        return "Declare a new variable...";
      case StatementType.variableAssignmentStatement:
        return "Update an existing variable's value...";
      case StatementType.forLoopStatement:
        return "Add a for-loop...";
      case StatementType.whileLoopStatement:
        return "Add a while-loop...";
      case StatementType.ifElseStatement:
        return "Add a if-then-else decision structure...";
      case StatementType.customFunctionCallStatement:
        return "Call a custom function...";
      case StatementType.printStatement:
        return "Print to the console...";
      case StatementType.returnStatement:
        return "Return a value from your function...";
      case StatementType.statementBlockStatement:
        return "Add a statement block...";
      case StatementType.breakStatement:
        return "Exit the loop.";
      case StatementType.continueStatement:
        return "Skip the rest of the loop and restart from the top.";
    }
  }

  /// Whether the [Statement] has no additional properties.
  ///
  /// If true, it means the [StatementType] does not require an editor widget, as there would be nothing to edit.
  ///
  /// Simple statements can directly be added to the program.
  ///
  /// [BreakStatement] and [ContinueStatement] are considered simple statements.
  bool isSimple() {
    switch (this) {
      case StatementType.breakStatement:
      case StatementType.continueStatement:
        return true;
      default:
        return false;
    }
  }

  /// The order priority when visualizing the [StatementType] in the [StatementTypePicker].
  ///
  /// Statement types are shown in ascending order based on this priority. See
  int getOrderValue() {
    switch (this) {
      /// [StatementBlock] is not a [Statement] which is directly created by the user.
      /// Rather, it simply represents a list of statements in the same scope, e.g., the body of a for-loop.
      ///
      /// For that reason, it is assigned an arbitrarily high value which can be ignored.
      case StatementType.statementBlockStatement:
        return 999;
      case StatementType.printStatement:
        return 9;
      case StatementType.returnStatement:
        return 8;
      case StatementType.ifElseStatement:
        return 6;
      case StatementType.forLoopStatement:
        return 2;
      case StatementType.whileLoopStatement:
        return 3;
      case StatementType.variableDeclarationStatement:
        return 0;
      case StatementType.variableAssignmentStatement:
        return 1;
      case StatementType.customFunctionCallStatement:
        return 7;
      case StatementType.breakStatement:
        return 4;
      case StatementType.continueStatement:
        return 5;
    }
  }

  /// Retrieve the category to which the [StatementType] belongs.
  StatementCategory getCategory() {
    return switch (this) {
      StatementType.variableDeclarationStatement => StatementCategory.variable,
      StatementType.variableAssignmentStatement => StatementCategory.variable,

      StatementType.forLoopStatement => StatementCategory.loop,
      StatementType.whileLoopStatement => StatementCategory.loop,
      StatementType.breakStatement => StatementCategory.loop,
      StatementType.continueStatement => StatementCategory.loop,

      StatementType.ifElseStatement => StatementCategory.decisionStructure,

      StatementType.customFunctionCallStatement => StatementCategory.function,
      StatementType.returnStatement => StatementCategory.function,

      StatementType.printStatement => StatementCategory.other,
      StatementType.statementBlockStatement => StatementCategory.other,
    };
  }

  /// Retrieve the symbolic icon for the [StatementType].
  IconData getIconData() {
    return switch (this) {
      StatementType.variableDeclarationStatement => Icons.add_circle_outline,
      StatementType.variableAssignmentStatement => Icons.edit_outlined,
      StatementType.forLoopStatement => Icons.loop,
      StatementType.whileLoopStatement => Icons.repeat,
      StatementType.ifElseStatement => Icons.call_split,
      StatementType.breakStatement => Icons.logout,
      StatementType.continueStatement => Icons.skip_next,
      StatementType.customFunctionCallStatement => Icons.functions,
      StatementType.returnStatement => Icons.keyboard_return,
      StatementType.printStatement => Icons.wysiwyg,
      _ => Icons.code,
    };
  }

  /// Retrieve a short, explanatory description of the [StatementType].
  String getTooltip() {
    return switch (this) {
      StatementType.variableDeclarationStatement => 'Declare Variable',
      StatementType.variableAssignmentStatement => 'Update Variable',
      StatementType.forLoopStatement => 'For Loop',
      StatementType.whileLoopStatement => 'While Loop',
      StatementType.ifElseStatement => 'If-Else',
      StatementType.breakStatement => 'Break',
      StatementType.continueStatement => 'Continue',
      StatementType.customFunctionCallStatement => 'Call Function',
      StatementType.returnStatement => 'Return',
      StatementType.printStatement => "Print",
      _ => toString(),
    };
  }
}

/// The core class which represents an instruction in DartBlock, e.g., a variable declaration or a for-loop.
sealed class Statement implements DartBlockProgramTreeNodeAcceptor {
  /// The type of the [Statement].
  ///
  /// Primarily used for the JSON encoding/decoding process.
  @JsonKey(name: "statementType")
  final StatementType statementType;

  /// A unique identifier.
  @JsonKey(name: "statementId")
  final String statementId;

  /// The main constructor to use to manually create a new [Statement] object.
  Statement.init(this.statementType) : statementId = const Uuid().v4();

  /// Helper constructor for json_serializable package.
  Statement(this.statementType, this.statementId);

  /// Decode a [Statement] object from a given JSON object (Map).
  factory Statement.fromJson(Map<String, dynamic> json) {
    StatementType? kind;

    /// Use the 'statementType' key in the JSON Map to determine which concrete implementation of Statement to use for the decoding.
    if (json.containsKey('statementType')) {
      for (var statementType in StatementType.values) {
        if (json["statementType"] == statementType.jsonValue) {
          kind = statementType;
          break;
        }
      }
    }

    if (kind == null) {
      throw StatementSerializationException(
        json.containsKey("statementType") ? json["statementType"] : "UNKNOWN",
      );
    }

    /// Based on the determined [StatementType], call the corresponding concrete [Statement] class' `fromJson` function.
    switch (kind) {
      case StatementType.statementBlockStatement:
        return StatementBlock.fromJson(json);
      case StatementType.printStatement:
        return PrintStatement.fromJson(json);
      case StatementType.returnStatement:
        return ReturnStatement.fromJson(json);
      case StatementType.ifElseStatement:
        return IfElseStatement.fromJson(json);
      case StatementType.forLoopStatement:
        return ForLoopStatement.fromJson(json);
      case StatementType.whileLoopStatement:
        return WhileLoopStatement.fromJson(json);
      case StatementType.variableDeclarationStatement:
        return VariableDeclarationStatement.fromJson(json);
      case StatementType.variableAssignmentStatement:
        return VariableAssignmentStatement.fromJson(json);
      case StatementType.customFunctionCallStatement:
        return FunctionCallStatement.fromJson(json);
      case StatementType.breakStatement:
        return BreakStatement.fromJson(json);
      case StatementType.continueStatement:
        return ContinueStatement.fromJson(json);
    }
  }

  /// Encode the [Statement] object to JSON.
  Map<String, dynamic> toJson();

  /// Execute the [Statement], using the given [DartBlockArbiter].
  void run(DartBlockArbiter arbiter) {
    try {
      _execute(arbiter);
    } on DartBlockException catch (neoTechException) {
      /// Designate this [Statement] as the cause of the thrown [DartBlockException].
      neoTechException.statement ??= this;
      rethrow;
    } on ReturnStatementException {
      /// CRITICAL: [ReturnStatementException] is a special class used to propagate the return value in the body of a [DartBlockFunction].
      /// Simply rethrow it to move it up the stack.
      rethrow;
    } on Exception catch (ex) {
      // A common Dart Exception not known by DartBlock: we wrap it in our own [DartBlockException].
      throw DartBlockException.fromException(exception: ex, statement: this);
    } on StackOverflowError catch (_) {
      // Thrown by Dart, e.g., in the case of a faulty recursive function call (missing ending condition).
      throw DartBlockException(
        title: "Stack Overflow",
        message:
            "The program was killed due to a stack overflow error. This can occur if you have a recursive function without an appropriate ending condition.",
        statement: this,
      );
    } on Error catch (err) {
      // Very generic error thrown by Dart: we wrap it in our own [DartBlockException].
      if (kDebugMode) {
        print(err);
      }
      throw DartBlockException(
        title: "Critical Error",
        message:
            "The program was killed due to an unknown error. Ensure your program does not contain an infinite loop or a recursive function without an ending condition!",
        statement: this,
      );
    }
  }

  void _execute(DartBlockArbiter arbiter);

  @override
  String toString();

  /// Export the [Statement] to its equivalent textual representation in a typed language.
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  });

  /// Create a deep copy of the [Statement].
  Statement copy();

  /// Shuffle the contents of the [Statement].
  ///
  /// This is only relevant for compound [Statement]s, such as [ForLoopStatement].
  ///
  /// Non-compound statements, e.g., [VariableDeclarationStatement], simply return themselves.
  Statement shuffle() => this;

  /// Trim the contents of the [Statement].
  ///
  /// This is only relevant for compound [Statement]s, such as [ForLoopStatement].
  ///
  /// Non-compound statements, e.g., [VariableDeclarationStatement], simply return themselves.
  (Statement?, int) trim(int remaining) {
    if (remaining <= 0) {
      return (null, 0);
    } else {
      return (this, remaining - 1);
    }
  }

  // @override
  // int get hashCode => statementId.hashCode;

  // @override
  // bool operator ==(Object other) {
  //   return other is Statement && statementId == other.statementId;
  // }
}

abstract class StatementContextPreExecutionResult {}

abstract class StatementContextBodyExecutionResult {}

abstract class StatementContextPostExecutionResult {}

sealed class StatementContext<T extends StatementContextPostExecutionResult?>
    extends Statement {
  bool isIsolated;
  StatementContext.init(super.statementType, {this.isIsolated = false})
    : super.init();
  StatementContext(super.statementType, super.statementId, this.isIsolated);

  StatementContextPreExecutionResult? preExecute(DartBlockArbiter arbiter);

  StatementContextBodyExecutionResult? bodyExecute(
    DartBlockArbiter arbiter,
    covariant StatementContextPreExecutionResult? preExecutionResult,
  );

  T? postExecute(
    DartBlockArbiter arbiter,
    covariant StatementContextBodyExecutionResult? bodyExecutionResult,
  );
  @JsonKey(includeFromJson: false, includeToJson: false)
  int _lastExecutionCode = const Uuid().v4().hashCode;

  @nonVirtual
  @override
  T? _execute(DartBlockArbiter arbiter) {
    final preExecutionResult = preExecute(arbiter);

    /// IMPORTANT: do not rely on hashCode of this class itself.
    /// In a recursive function, the same function might be called multiple times,
    /// but because they use isolated Environments, you will run into issues where
    /// the app says the parameters are already declared!
    /// Instead, generate a unique code to identiy each call of the same function.
    _lastExecutionCode = const Uuid().v4().hashCode;
    arbiter.beginScope(_lastExecutionCode, isIsolated: isIsolated);
    final bodyExecutionResult = bodyExecute(arbiter, preExecutionResult);
    arbiter.endScope(_lastExecutionCode);

    return postExecute(arbiter, bodyExecutionResult);
  }

  @override
  T? run(DartBlockArbiter arbiter) {
    // The body of this run override is identical to the super's method body (Statement),
    // except here run() has a non-void return type T?, requiring the statement
    // 'return _execute(arbiter);' instead!
    try {
      return _execute(arbiter);
    } on DartBlockException catch (neoTechException) {
      neoTechException.statement ??= this;
      rethrow;
    } on ReturnStatementException {
      /// IMPORTANT: End the block, as the error being thrown causes the endBlock call
      /// to never be reached inside _execute!!!!
      arbiter.endScope(_lastExecutionCode);

      /// Do not do anything here!! ReturnStatementException is a very special
      /// type used to propagate a return value in a function's body.
      rethrow;
    } on Exception catch (ex) {
      throw DartBlockException.fromException(exception: ex, statement: this);
    } on StackOverflowError catch (_) {
      throw DartBlockException(
        title: "Stack Overflow",
        message:
            "The program was killed due to a stack overflow error. This can occur if you have a recursive function without an appropriate ending condition.",
        statement: this,
      );
    } on Error catch (err) {
      if (kDebugMode) {
        print(err);
      }
      throw DartBlockException(
        title: "Critical Error",
        message:
            "The program was killed due to an unknown error. Ensure your program does not contain an infinite loop or a recursive function without an ending condition!",
        statement: this,
      );
    }
  }
}

@JsonSerializable(explicitToJson: true)
class StatementBlock extends StatementContext {
  List<Statement> statements = [];
  StatementBlock.init({List<Statement>? statements, super.isIsolated = false})
    : super.init(StatementType.statementBlockStatement) {
    if (statements != null) {
      this.statements = statements;
    }
  }
  StatementBlock(
    this.statements,
    super.statementType,
    super.statementId,
    super.isIsolated,
  );

  factory StatementBlock.fromJson(Map<String, dynamic> json) =>
      _$StatementBlockFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$StatementBlockToJson(this);

  void addStatement(Statement statement) {
    if (!statements.contains(statement)) {
      statements.add(statement);
    }
  }

  @override
  StatementContextPreExecutionResult? preExecute(DartBlockArbiter arbiter) {
    return null;
  }

  @override
  StatementContextBodyExecutionResult? bodyExecute(
    DartBlockArbiter arbiter,
    covariant StatementContextPreExecutionResult? preExecutionResult,
  ) {
    for (var statement in statements) {
      statement.run(arbiter);
    }

    return null;
  }

  @override
  StatementContextPostExecutionResult? postExecute(
    DartBlockArbiter arbiter,
    StatementContextBodyExecutionResult? bodyExecutionResult,
  ) {
    return null;
  }

  @override
  DartBlockProgramTreeNode buildTree(DartBlockProgramTreeNode programTreeNode) {
    final DartBlockProgramTreeNode node = DartBlockProgramTreeStatementNode(
      this,
      programTreeNode,
    );
    var currentNode = node;
    for (var statement in statements) {
      currentNode = statement.buildTree(currentNode);
    }
    programTreeNode.children.add(node);

    return node;
  }

  // @override
  // List<VariableDefinition> findVariableDefinitions(
  //   Statement? untilStatement,
  //   List<VariableDefinition> result,
  // ) {
  //   for (var statement in statements) {
  //     result.addAll(statement.findVariableDefinitions(untilStatement, result));
  //     if (statement == untilStatement) {
  //       return result;
  //     }
  //   }

  //   return result;
  // }

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    switch (language) {
      case DartBlockTypedLanguage.java:
        return statements
            .map((e) => "\t\t\t${e.toScript(language: language)}")
            .join('\n');
    }
  }

  @override
  StatementBlock copy() {
    return StatementBlock.init(
      statements: List.from(statements.map((e) => e.copy())),
      isIsolated: isIsolated,
    );
  }

  @override
  StatementBlock shuffle() {
    return StatementBlock.init(
      statements: statements..shuffle(),
      isIsolated: isIsolated,
    );
  }

  @override
  (StatementBlock?, int) trim(int remaining) {
    if (remaining <= 0) {
      return (null, 0);
    } else {
      final trimmedStatementBlock = StatementBlock.init(
        statements: [],
        isIsolated: isIsolated,
      );
      for (final statement in statements) {
        final trimmingResult = statement.trim(remaining);
        remaining = trimmingResult.$2;
        if (trimmingResult.$1 == null) {
          break;
        } else {
          trimmedStatementBlock.statements.add(trimmingResult.$1!);
        }
        if (remaining == 0) {
          break;
        }
      }
      return (trimmedStatementBlock, remaining);
    }
  }
}

/// Variables
@JsonSerializable(explicitToJson: true)
class VariableDeclarationStatement extends Statement {
  final String name;
  final DartBlockDataType dataType;
  final DartBlockValue? value;

  VariableDeclarationStatement.init(this.name, this.dataType, this.value)
    : super.init(StatementType.variableDeclarationStatement);
  VariableDeclarationStatement(
    this.name,
    this.dataType,
    this.value,
    super.statementType,
    super.statementId,
  );

  factory VariableDeclarationStatement.fromJson(Map<String, dynamic> json) =>
      _$VariableDeclarationStatementFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$VariableDeclarationStatementToJson(this);

  @override
  void _execute(DartBlockArbiter arbiter) {
    final nameValidation = DartBlockValidator.validateVariableName(name);
    if (nameValidation != null) {
      throw InvalidVariableNameException(name, nameValidation);
    }
    arbiter.declareVariable(dataType, name, value);
  }

  @override
  DartBlockProgramTreeNode buildTree(DartBlockProgramTreeNode programTreeNode) {
    final DartBlockProgramTreeNode node = DartBlockProgramTreeStatementNode(
      this,
      programTreeNode,
    );
    programTreeNode.children.add(node);

    return node;
  }

  @override
  String toString() {
    return "${value.runtimeType} $name${value != null ? " = $value" : ""};";
  }

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    switch (language) {
      case DartBlockTypedLanguage.java:
        return "${dataType.toScript(language: language)} $name${value != null ? " = ${value!.toScript(language: language)}" : ""};";
    }
  }

  @override
  VariableDeclarationStatement copy() {
    return VariableDeclarationStatement.init(name, dataType, value?.copy());
  }
}

/// Shouldn't value be nullable?
@JsonSerializable(explicitToJson: true)
class VariableAssignmentStatement extends Statement {
  final String name;
  final DartBlockValue? value;

  VariableAssignmentStatement.init(this.name, this.value)
    : super.init(StatementType.variableAssignmentStatement);
  VariableAssignmentStatement(
    this.name,
    this.value,
    super.statementType,
    super.statementId,
  );

  factory VariableAssignmentStatement.fromJson(Map<String, dynamic> json) =>
      _$VariableAssignmentStatementFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$VariableAssignmentStatementToJson(this);

  @override
  void _execute(DartBlockArbiter arbiter) {
    arbiter.assignValueToVariable(name, value);
  }

  @override
  DartBlockProgramTreeNode buildTree(DartBlockProgramTreeNode programTreeNode) {
    final DartBlockProgramTreeNode node = DartBlockProgramTreeStatementNode(
      this,
      programTreeNode,
    );
    programTreeNode.children.add(node);

    return node;
  }

  @override
  String toString() {
    return "$name = $value;";
  }

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    switch (language) {
      case DartBlockTypedLanguage.java:
        return "$name = ${value?.toScript(language: language)};";
    }
  }

  @override
  VariableAssignmentStatement copy() {
    return VariableAssignmentStatement.init(name, value?.copy());
  }
}

/// Return value

@JsonSerializable(explicitToJson: true)
class ReturnStatement extends Statement {
  DartBlockDataType dataType;
  DartBlockValue value;
  ReturnStatement.init(this.dataType, this.value)
    : super.init(StatementType.returnStatement);
  ReturnStatement(
    this.dataType,
    this.value,
    super.statementType,
    super.statementId,
  );

  factory ReturnStatement.fromJson(Map<String, dynamic> json) =>
      _$ReturnStatementFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ReturnStatementToJson(this);

  @override
  void _execute(DartBlockArbiter arbiter) {
    /// Important: Fetch the concrete (constant) value, then wrap it again in
    /// an appropriate NeoValue class. This is due to the fact that variable scopes are changed
    /// after return statements, meaning if this 'value' contains for example a NeoVariable,
    /// its associated value needs to be fetched before the variable scope is changed.
    final constantValue = value.getValue(arbiter);
    switch (dataType) {
      case DartBlockDataType.integerType:
      case DartBlockDataType.doubleType:
        if (constantValue is num) {
          throw ReturnStatementException(
            DartBlockAlgebraicExpression.fromConstant(constantValue),
          );
        }
        break;
      case DartBlockDataType.booleanType:
        if (constantValue is bool) {
          throw ReturnStatementException(
            DartBlockBooleanExpression.fromConstant(constantValue),
          );
        }
        break;
      case DartBlockDataType.stringType:
        if (constantValue is String) {
          throw ReturnStatementException(
            DartBlockConcatenationValue.init([
              DartBlockStringValue.init(constantValue),
            ]),
          );
        }
        break;
    }
  }

  @override
  DartBlockProgramTreeNode buildTree(DartBlockProgramTreeNode programTreeNode) {
    final DartBlockProgramTreeNode node = DartBlockProgramTreeStatementNode(
      this,
      programTreeNode,
    );
    programTreeNode.children.add(node);

    return node;
  }

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    switch (language) {
      case DartBlockTypedLanguage.java:
        return 'return ${value.toScript(language: language)};';
    }
  }

  @override
  ReturnStatement copy() {
    return ReturnStatement.init(dataType, value.copy());
  }
}

class ReturnStatementException implements Exception {
  DartBlockValue value;
  ReturnStatementException(this.value);
}

@JsonSerializable(explicitToJson: true)
class BreakStatement extends Statement {
  BreakStatement.init() : super.init(StatementType.breakStatement);
  BreakStatement(super.statementType, super.statementId);
  factory BreakStatement.fromJson(Map<String, dynamic> json) =>
      _$BreakStatementFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$BreakStatementToJson(this);

  @override
  void _execute(DartBlockArbiter arbiter) {
    throw BreakStatementException(statement: this);
  }

  @override
  DartBlockProgramTreeNode buildTree(DartBlockProgramTreeNode programTreeNode) {
    final DartBlockProgramTreeNode node = DartBlockProgramTreeStatementNode(
      this,
      programTreeNode,
    );
    programTreeNode.children.add(node);

    return node;
  }

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    switch (language) {
      case DartBlockTypedLanguage.java:
        return 'break;';
    }
  }

  @override
  BreakStatement copy() {
    return BreakStatement.init();
  }
}

class BreakStatementException extends DartBlockException {
  BreakStatementException({BreakStatement? super.statement})
    : super(
        title: "Break",
        message:
            "Break statements can only be used inside for-loops and while-loops.",
      );
}

@JsonSerializable(explicitToJson: true)
class ContinueStatement extends Statement {
  ContinueStatement.init() : super.init(StatementType.continueStatement);
  ContinueStatement(super.statementType, super.statementId);

  factory ContinueStatement.fromJson(Map<String, dynamic> json) =>
      _$ContinueStatementFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ContinueStatementToJson(this);

  @override
  void _execute(DartBlockArbiter arbiter) {
    throw ContinueStatementException(statement: this);
  }

  @override
  DartBlockProgramTreeNode buildTree(DartBlockProgramTreeNode programTreeNode) {
    final DartBlockProgramTreeNode node = DartBlockProgramTreeStatementNode(
      this,
      programTreeNode,
    );
    programTreeNode.children.add(node);

    return node;
  }

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    switch (language) {
      case DartBlockTypedLanguage.java:
        return 'continue;';
    }
  }

  @override
  ContinueStatement copy() {
    return ContinueStatement.init();
  }
}

class ContinueStatementException extends DartBlockException {
  ContinueStatementException({ContinueStatement? super.statement})
    : super(
        title: "Continue",
        message:
            "Continue statements can only be used inside for-loops and while-loops.",
      );
}

/// Decision Structures
@JsonSerializable(explicitToJson: true)
class IfElseStatement extends Statement {
  final DartBlockBooleanExpression ifCondition;
  final StatementBlock ifThenStatementBlock;
  final List<(DartBlockBooleanExpression, StatementBlock)>
  elseIfStatementBlocks;
  final StatementBlock elseStatementBlock;

  IfElseStatement.init(
    this.ifCondition,
    this.ifThenStatementBlock,
    this.elseIfStatementBlocks,
    this.elseStatementBlock,
  ) : super.init(StatementType.ifElseStatement);
  IfElseStatement(
    this.ifCondition,
    this.ifThenStatementBlock,
    this.elseIfStatementBlocks,
    this.elseStatementBlock,
    super.statementType,
    super.statementId,
  );

  factory IfElseStatement.fromJson(Map<String, dynamic> json) =>
      _$IfElseStatementFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$IfElseStatementToJson(this);
  @override
  void _execute(DartBlockArbiter arbiter) {
    if (ifCondition.getValue(arbiter)) {
      ifThenStatementBlock.run(arbiter);
    } else {
      bool executeElseBlock = true;
      for (var elseIfStatementBlock in elseIfStatementBlocks) {
        if (elseIfStatementBlock.$1.getValue(arbiter)) {
          executeElseBlock = false;
          elseIfStatementBlock.$2.run(arbiter);
          break;
        }
      }
      if (executeElseBlock) {
        elseStatementBlock.run(arbiter);
      }
    }
  }

  @override
  DartBlockProgramTreeNode buildTree(DartBlockProgramTreeNode programTreeNode) {
    final DartBlockProgramTreeNode node = DartBlockProgramTreeStatementNode(
      this,
      programTreeNode,
    );
    ifThenStatementBlock.buildTree(node);
    for (var elseIfStatementBlock in elseIfStatementBlocks) {
      elseIfStatementBlock.$2.buildTree(node);
    }
    elseStatementBlock.buildTree(node);
    programTreeNode.children.add(node);

    return node;
  }

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    switch (language) {
      case DartBlockTypedLanguage.java:
        var text =
            "if (${ifCondition.toScript(language: language)}) {\n${ifThenStatementBlock.toScript(language: language)}\n\t}";
        for (var elseIfStatementBlock in elseIfStatementBlocks) {
          text +=
              " else if (${elseIfStatementBlock.$1.toScript(language: language)}) {\n${elseIfStatementBlock.$2.toScript(language: language)}\n\t}";
        }
        text +=
            " else {\n${elseStatementBlock.toScript(language: language)}\n\t}";
        return text;
    }
  }

  @override
  IfElseStatement copy() {
    return IfElseStatement.init(
      ifCondition.copy(),
      ifThenStatementBlock.copy(),
      List.from(elseIfStatementBlocks.map((e) => (e.$1, e.$2.copy()))),
      elseStatementBlock.copy(),
    );
  }

  @override
  (IfElseStatement?, int) trim(int remaining) {
    if (remaining <= 0) {
      return (null, 0);
    } else {
      final trimmedIfThenStatementBlockResult = ifThenStatementBlock.trim(
        remaining,
      );
      remaining = trimmedIfThenStatementBlockResult.$2;
      List<(DartBlockBooleanExpression, StatementBlock)>
      trimmedElseIfStatementBlocks = [];
      StatementBlock trimmedElseStatementBlock;

      if (remaining > 0) {
        for (final elseIfStatementBlock in elseIfStatementBlocks) {
          final trimmedElseIfStatementBlockResult = elseIfStatementBlock.$2
              .trim(remaining);
          remaining = trimmedElseIfStatementBlockResult.$2;
          if (trimmedElseIfStatementBlockResult.$1 != null) {
            trimmedElseIfStatementBlocks.add((
              elseIfStatementBlock.$1,
              trimmedElseIfStatementBlockResult.$1!,
            ));
          }
          if (remaining <= 0) {
            break;
          }
        }
      }
      if (remaining > 0) {
        final trimmedElseStatementBlockResult = elseStatementBlock.trim(
          remaining,
        );
        remaining = trimmedElseStatementBlockResult.$2;
        if (trimmedElseStatementBlockResult.$1 != null) {
          trimmedElseStatementBlock = trimmedElseStatementBlockResult.$1!;
        } else {
          trimmedElseStatementBlock = StatementBlock.init(
            statements: [],
            isIsolated: elseStatementBlock.isIsolated,
          );
        }
      } else {
        trimmedElseStatementBlock = StatementBlock.init(
          statements: [],
          isIsolated: elseStatementBlock.isIsolated,
        );
      }

      return (
        IfElseStatement.init(
          ifCondition,
          trimmedIfThenStatementBlockResult.$1 ??
              StatementBlock.init(
                statements: [],
                isIsolated: ifThenStatementBlock.isIsolated,
              ),
          trimmedElseIfStatementBlocks,
          trimmedElseStatementBlock,
        ),
        remaining,
      );
    }
  }
}

/// Loops

// class WhileLoop extends Statement<void> {
//   Condition condition;
//   StatementBlock block;
//   WhileLoop(this.condition, this.block);
//   @override
//   void execute(NeoTechArbiter arbiter) {
//     while (condition.evaluate(arbiter)) {
//       block.execute(arbiter);
//     }
//   }

//   @override
//   String toScript({NeoTechLanguage language = NeoTechLanguage.java}) {
//     switch (language) {
//       case NeoTechLanguage.java:
//         return "while (${condition.toScript(language: language)}) {\n${block.toScript(language: language)}\n}";
//     }
//   }
// }

// class DoWhileLoop extends WhileLoop {
//   DoWhileLoop(super.condition, super.block);
//   @override
//   void execute(NeoTechArbiter arbiter) {
//     do {
//       block.execute(arbiter);
//     } while (condition.evaluate(arbiter));
//   }

//   @override
//   String toScript({NeoTechLanguage language = NeoTechLanguage.java}) {
//     switch (language) {
//       case NeoTechLanguage.java:
//         return "do {\n${block.toScript(language: language)}\n} while (${condition.toScript(language: language)})}";
//     }
//   }
// }
@JsonSerializable(explicitToJson: true)
class ForLoopStatement extends StatementContext {
  Statement? initStatement;
  DartBlockBooleanExpression condition;
  Statement? postStatement;
  List<Statement> bodyStatements;
  ForLoopStatement.init(
    this.initStatement,
    this.condition,
    this.postStatement,
    this.bodyStatements,
  ) : super.init(StatementType.forLoopStatement);
  ForLoopStatement(
    this.initStatement,
    this.condition,
    this.postStatement,
    this.bodyStatements,
    super.statementType,
    super.statementId,
    super.isIsolated,
  );

  factory ForLoopStatement.fromJson(Map<String, dynamic> json) =>
      _$ForLoopStatementFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ForLoopStatementToJson(this);
  @override
  StatementContextPreExecutionResult? preExecute(DartBlockArbiter arbiter) {
    return null;
  }

  @override
  StatementContextBodyExecutionResult? bodyExecute(
    DartBlockArbiter arbiter,
    covariant StatementContextPreExecutionResult? preExecutionResult,
  ) {
    initStatement?.run(arbiter);

    bool breakExecution = false;
    while (condition.getValue(arbiter)) {
      for (var statement in bodyStatements) {
        try {
          statement.run(arbiter);
        } on BreakStatementException catch (_) {
          breakExecution = true;
          break;
        } on ContinueStatementException catch (_) {
          break;
        }
      }
      if (breakExecution) {
        break;
      }

      postStatement?.run(arbiter);
    }

    return null;
  }

  @override
  StatementContextPostExecutionResult? postExecute(
    DartBlockArbiter arbiter,
    StatementContextBodyExecutionResult? bodyExecutionResult,
  ) {
    return null;
  }

  @override
  DartBlockProgramTreeNode buildTree(DartBlockProgramTreeNode programTreeNode) {
    final DartBlockProgramTreeNode node = DartBlockProgramTreeStatementNode(
      this,
      programTreeNode,
    );
    final initNode = initStatement?.buildTree(node);
    var currentNode = initNode ?? node;
    for (var statement in bodyStatements) {
      currentNode = statement.buildTree(currentNode);
    }
    postStatement?.buildTree(currentNode);

    programTreeNode.children.add(node);

    return node;
  }

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    switch (language) {
      case DartBlockTypedLanguage.java:
        var postStatementString = postStatement != null
            ? postStatement!.toScript(language: language)
            : "";
        if (postStatementString.length >= 2 &&
            postStatementString.endsWith(';')) {
          postStatementString = postStatementString.substring(
            0,
            postStatementString.length - 1,
          );
        }
        return "for (${initStatement != null ? initStatement!.toScript(language: language) : ""} ${condition.toScript(language: language)}; $postStatementString) {\n${bodyStatements.map((e) => "\t\t\t${e.toScript(language: language)}").join("\n\t")}\n\t\t}";
    }
  }

  @override
  ForLoopStatement copy() {
    return ForLoopStatement.init(
      initStatement?.copy(),
      condition.copy(),
      postStatement?.copy(),
      List.from(bodyStatements.map((e) => e.copy())),
    );
  }

  @override
  ForLoopStatement shuffle() {
    return ForLoopStatement.init(
      initStatement,
      condition,
      postStatement,
      bodyStatements.map((e) => e.shuffle()).toList()..shuffle(),
    );
  }

  @override
  (ForLoopStatement?, int) trim(int remaining) {
    if (remaining <= 0) {
      return (null, 0);
    } else {
      // For loop statement itself consumes 1
      remaining--;
      Statement? trimmedInitStatement;
      if (initStatement != null && remaining > 0) {
        trimmedInitStatement = initStatement;
        remaining--;
      }

      List<Statement> trimmedBodyStatements = [];
      for (final statement in bodyStatements) {
        final trimmedStatementResult = statement.trim(remaining);
        remaining = trimmedStatementResult.$2;
        if (trimmedStatementResult.$1 != null) {
          trimmedBodyStatements.add(trimmedStatementResult.$1!);
        }
        if (remaining <= 0) {
          break;
        }
      }

      Statement? trimmedPostStatement;
      if (postStatement != null && remaining > 0) {
        trimmedPostStatement = postStatement;
        remaining--;
      }

      return (
        ForLoopStatement.init(
          trimmedInitStatement,
          condition,
          trimmedPostStatement,
          trimmedBodyStatements,
        ),
        remaining,
      );
    }
  }
}

@JsonSerializable(explicitToJson: true)
class WhileLoopStatement extends StatementContext {
  bool isDoWhile;
  DartBlockBooleanExpression condition;
  List<Statement> bodyStatements;
  WhileLoopStatement.init(this.isDoWhile, this.condition, this.bodyStatements)
    : super.init(StatementType.whileLoopStatement);
  WhileLoopStatement(
    this.isDoWhile,
    this.condition,
    this.bodyStatements,
    super.statementType,
    super.statementId,
    super.isIsolated,
  );

  factory WhileLoopStatement.fromJson(Map<String, dynamic> json) =>
      _$WhileLoopStatementFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$WhileLoopStatementToJson(this);
  @override
  StatementContextPreExecutionResult? preExecute(DartBlockArbiter arbiter) {
    return null;
  }

  @override
  StatementContextBodyExecutionResult? bodyExecute(
    DartBlockArbiter arbiter,
    covariant StatementContextPreExecutionResult? preExecutionResult,
  ) {
    if (isDoWhile) {
      _executeBody(arbiter);
    }
    while (condition.getValue(arbiter)) {
      // If _executeBody returns false, it means a break statement was encountered.
      // In that case, exit the loop.
      bool repeatLoop = _executeBody(arbiter);
      if (!repeatLoop) {
        break;
      }
    }

    return null;
  }

  bool _executeBody(DartBlockArbiter arbiter) {
    for (var statement in bodyStatements) {
      try {
        statement.run(arbiter);
      } on BreakStatementException catch (_) {
        return false;
      } on ContinueStatementException catch (_) {
        // Return true, i.e., the loop should still be repeated in case its condition
        // still holds, but the current iteration should be stopped by simply
        // returning here.
        return true;
      }
    }

    return true;
  }

  @override
  StatementContextPostExecutionResult? postExecute(
    DartBlockArbiter arbiter,
    StatementContextBodyExecutionResult? bodyExecutionResult,
  ) {
    return null;
  }

  @override
  DartBlockProgramTreeNode buildTree(DartBlockProgramTreeNode programTreeNode) {
    final DartBlockProgramTreeNode node = DartBlockProgramTreeStatementNode(
      this,
      programTreeNode,
    );
    var currentNode = node;
    for (var statement in bodyStatements) {
      currentNode = statement.buildTree(currentNode);
    }

    programTreeNode.children.add(node);

    return node;
  }

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    switch (language) {
      case DartBlockTypedLanguage.java:
        if (isDoWhile) {
          return "do {\n${bodyStatements.map((e) => "\t\t\t${e.toScript(language: language)}").join("\n\t")}\n\t} while (${condition.toScript(language: language)});";
        }
        return "while (${condition.toScript(language: language)}) {\n${bodyStatements.map((e) => "\t\t\t${e.toScript(language: language)}").join("\n\t")}\n\t}";
    }
  }

  @override
  WhileLoopStatement copy() {
    return WhileLoopStatement.init(
      isDoWhile,
      condition.copy(),
      List.from(bodyStatements.map((e) => e.copy())),
    );
  }

  @override
  WhileLoopStatement shuffle() {
    return WhileLoopStatement.init(
      isDoWhile,
      condition,
      bodyStatements.map((e) => e.shuffle()).toList()..shuffle(),
    );
  }

  @override
  (WhileLoopStatement?, int) trim(int remaining) {
    if (remaining <= 0) {
      return (null, 0);
    } else {
      List<Statement> trimmedBodyStatements = [];
      for (final statement in bodyStatements) {
        final trimmedStatementResult = statement.trim(remaining);
        remaining = trimmedStatementResult.$2;
        if (trimmedStatementResult.$1 != null) {
          trimmedBodyStatements.add(trimmedStatementResult.$1!);
        }
        if (remaining <= 0) {
          break;
        }
      }

      return (
        WhileLoopStatement.init(isDoWhile, condition, trimmedBodyStatements),
        remaining,
      );
    }
  }
}

/// Function calls

class FunctionCallPreExecutionResult
    extends StatementContextPreExecutionResult {
  final DartBlockFunction customFunction;
  final List<VariableDeclarationStatement> parameterDeclarations;
  FunctionCallPreExecutionResult(
    this.customFunction,
    this.parameterDeclarations,
  );
}

class FunctionCallBodyExecutionResult
    extends StatementContextBodyExecutionResult {
  final DartBlockFunction customFunction;
  final DartBlockValue? returnValue;
  FunctionCallBodyExecutionResult(this.customFunction, this.returnValue);
}

class FunctionCallPostExecutionResult
    extends StatementContextPostExecutionResult {
  final DartBlockFunction customFunction;
  final dynamic returnValue;
  FunctionCallPostExecutionResult(this.customFunction, this.returnValue);
}

@JsonSerializable(explicitToJson: true)
class FunctionCallStatement
    extends StatementContext<FunctionCallPostExecutionResult> {
  final String customFunctionName;
  List<DartBlockValue> arguments;
  FunctionCallStatement.init(this.customFunctionName, this.arguments)
    : super.init(StatementType.customFunctionCallStatement, isIsolated: true);
  FunctionCallStatement(
    this.customFunctionName,
    this.arguments,
    super.statementType,
    super.statementId,
    super.isIsolated,
  );

  factory FunctionCallStatement.fromJson(Map<String, dynamic> json) =>
      _$FunctionCallStatementFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$FunctionCallStatementToJson(this);

  @override
  FunctionCallPreExecutionResult? preExecute(DartBlockArbiter arbiter) {
    final DartBlockFunction? customFunction = arbiter.retrieveCustomFunction(
      customFunctionName,
    );
    if (customFunction == null) {
      throw UndefinedCustomFunctionException(customFunctionName);
    }

    if (customFunction.parameters.length != arguments.length) {
      throw CustomFunctionArgumentsCountException(
        customFunctionName,
        customFunction.parameters.length,
        arguments.length,
      );
    }
    List<VariableDeclarationStatement> parameterDeclarations = [];
    for (var (idx, argument) in arguments.indexed) {
      /// Get the concrete value in the preExecute step, as the variable scope
      /// (Environment) has not yet changed.
      final concreteValue = argument.getValue(arbiter);
      final expectedParameter = customFunction.parameters[idx];

      final (isCorrectType, givenWrongType) = arbiter
          .verifyDataTypeOfConcreteValue(
            expectedParameter.dataType,
            concreteValue,
          );
      if (isCorrectType) {
        /// Re-convert the concrete value back to a wrapper NeoValue object,
        /// based on the expected data type of the corresponding function parameter.
        DartBlockValue? passedValue;
        if (concreteValue != null) {
          switch (expectedParameter.dataType) {
            case DartBlockDataType.integerType:
            case DartBlockDataType.doubleType:
              if (concreteValue is num) {
                passedValue = DartBlockAlgebraicExpression.fromConstant(
                  concreteValue,
                );
              }
              break;
            case DartBlockDataType.booleanType:
              if (concreteValue is bool) {
                passedValue = DartBlockBooleanExpression.fromConstant(
                  concreteValue,
                );
              }
              break;
            case DartBlockDataType.stringType:
              if (concreteValue is String) {
                passedValue = DartBlockConcatenationValue.init([
                  DartBlockStringValue.init(concreteValue),
                ]);
              }
              break;
          }
        }
        parameterDeclarations.add(
          VariableDeclarationStatement.init(
            expectedParameter.name,
            expectedParameter.dataType,

            /// Do NOT use argument here, as it will cause issues in certain cases, e.g.,
            /// if the value contains a NeoVariable which only exists in the current
            /// variable scope. Remember that the variable scope changes to a new,
            /// isolated one after preExecute, hence, we use passedValue here.
            passedValue,
          ),
        );
      } else {
        throw CustomFunctionMissingArgumentException(
          customFunctionName,
          expectedParameter,
          idx,
          givenWrongType!,
        );
      }
    }

    return FunctionCallPreExecutionResult(
      customFunction,
      parameterDeclarations,
    );
  }

  @override
  FunctionCallBodyExecutionResult bodyExecute(
    DartBlockArbiter arbiter,
    FunctionCallPreExecutionResult preExecutionResult,
  ) {
    for (var parameterDeclaration in preExecutionResult.parameterDeclarations) {
      parameterDeclaration.run(arbiter);
    }
    for (var statement in preExecutionResult.customFunction.statements) {
      try {
        statement.run(arbiter);
      } on ReturnStatementException catch (ex) {
        return FunctionCallBodyExecutionResult(
          preExecutionResult.customFunction,
          ex.value,
        );
      }
    }

    return FunctionCallBodyExecutionResult(
      preExecutionResult.customFunction,
      null,
    );
  }

  @override
  FunctionCallPostExecutionResult? postExecute(
    DartBlockArbiter arbiter,
    FunctionCallBodyExecutionResult bodyExecutionResult,
  ) {
    if (bodyExecutionResult.customFunction.returnType != null) {
      if (bodyExecutionResult.returnValue == null) {
        throw CustomFunctionMissingReturnValueException(
          customFunctionName,
          bodyExecutionResult.customFunction.returnType!,
        );
      } else {
        final (isCorrectType, givenWrongType) = arbiter
            .verifyDataTypeOfNeoValue(
              bodyExecutionResult.customFunction.returnType!,
              bodyExecutionResult.returnValue!,
            );
        if (!isCorrectType) {
          throw CustomFunctionInvalidReturnValueTypeException(
            customFunctionName,
            bodyExecutionResult.customFunction.returnType!,
            givenWrongType!,
          );
        }
      }
    } else {
      if (bodyExecutionResult.returnValue != null) {}
    }

    return FunctionCallPostExecutionResult(
      bodyExecutionResult.customFunction,
      bodyExecutionResult.returnValue?.getValue(arbiter),
    );
  }

  @override
  DartBlockProgramTreeNode buildTree(DartBlockProgramTreeNode programTreeNode) {
    final DartBlockProgramTreeNode node = DartBlockProgramTreeStatementNode(
      this,
      programTreeNode,
    );
    programTreeNode.children.add(node);

    return node;
  }

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    switch (language) {
      case DartBlockTypedLanguage.java:
        return "$customFunctionName(${arguments.join(", ")});";
    }
  }

  @override
  String toString() {
    return "$customFunctionName(${arguments.join(", ")})";
  }

  @override
  FunctionCallStatement copy() {
    return FunctionCallStatement.init(
      customFunctionName,
      List.from(arguments.map((e) => e.copy())),
    );
  }
}

/// Miscellaneous
@JsonSerializable(explicitToJson: true)
class PrintStatement extends Statement {
  final DartBlockConcatenationValue value;

  PrintStatement.init(this.value) : super.init(StatementType.printStatement);
  PrintStatement(this.value, super.statementType, super.statementId);
  factory PrintStatement.fromJson(Map<String, dynamic> json) =>
      _$PrintStatementFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PrintStatementToJson(this);
  @override
  void _execute(DartBlockArbiter arbiter) {
    arbiter.printToConsole(value.getValue(arbiter).toString());
  }

  @override
  DartBlockProgramTreeNode buildTree(DartBlockProgramTreeNode programTreeNode) {
    final DartBlockProgramTreeNode node = DartBlockProgramTreeStatementNode(
      this,
      programTreeNode,
    );
    programTreeNode.children.add(node);

    return node;
  }

  @override
  String toString() {
    return "print($value);";
  }

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    var valueScript = value.toScript(language: language);
    if (valueScript.endsWith(';') && valueScript.length > 1) {
      valueScript = valueScript.substring(0, valueScript.length - 1);
    }
    switch (language) {
      case DartBlockTypedLanguage.java:
        return 'System.out.println($valueScript);';
    }
  }

  @override
  PrintStatement copy() {
    return PrintStatement.init(value.copy());
  }
}
