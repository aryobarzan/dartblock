import 'dart:async';
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:dartblock_code/core/dartblock_execution_result.dart';
import 'package:flutter/foundation.dart';
import 'package:dartblock_code/core/dartblock_program.dart';
import 'package:dartblock_code/models/function.dart';
import 'package:dartblock_code/models/function_native.dart';
import 'package:dartblock_code/models/environment.dart';
import 'package:dartblock_code/models/exception.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/statement.dart';

class _IsolateArgs {
  final SendPort sendPort;
  final Map<String, dynamic> payload;
  _IsolateArgs(this.sendPort, this.payload);
}

// top-level worker entry
void _isolateEntry(_IsolateArgs args) {
  final SendPort resultSendPort = args.sendPort;
  try {
    final programJson = args.payload['program'] as Map<String, dynamic>;
    final program = DartBlockProgram.fromJson(programJson);

    final executor = DartBlockExecutor(program);
    try {
      FunctionCallStatement.init('main', []).run(executor);
      // send execution result as a Map (JSON serialization)
      resultSendPort.send(executor.getExecutionResult().toJson());
    } catch (ex, _) {
      final executionResult = executor.getExecutionResult();
      if (ex is DartBlockException) {
        executionResult.exception = ex.toJson();
      } else if (ex is StackOverflowError) {
        executionResult.exception = DartBlockException(
          title: "Stack Overflow",
          message:
              "The program was killed due to a stack overflow error. This can occur if you have a recursive function without an appropriate ending condition.",
        ).toJson();
      } else if (ex is Exception) {
        executionResult.exception = DartBlockException.fromException(
          exception: ex,
        ).toJson();
      } else {
        executionResult.exception = DartBlockException(
          title: "Critical Error",
          message:
              "The program was killed due to an unknown error. Ensure your program does not contain an infinite loop or a recursive function without an ending condition!",
        ).toJson();
      }
      resultSendPort.send(executionResult.toJson());
    }
  } catch (_) {}
}

/// The executor for DartBlock programs. Serves for executing and keeping track of the output of a [DartBlockProgram].
///
/// The DartBlockArbiter runs a given DartBlock program, keeps track of its [DartBlockEnvironment] and any potentially thrown [DartBlockException].
///
/// The output of the executed program is not tracked by this abstract class. A concrete implementation has to implement the `printToConsole()` function, which is used by DartBlock [PrintStatement]s.
///
/// A concrete implementation for this class is provided via [DartBlockExecutor].
abstract class DartBlockArbiter {
  /// The [DartBlockProgram] which should be executed.
  final DartBlockProgram program;
  DartBlockArbiter(this.program);

  /// The root environment.
  ///
  /// The root environment does not have a parent, and its key is always -1.
  final DartBlockEnvironment environment = DartBlockEnvironment(
    -1,
    children: [],
  );

  /// This property is set to the newest environment's key,
  /// indicating that the new scope ([DartBlockEnvironment]) is in effect.
  int _currentStatementBlockKey = -1;
  Statement? _currentStatement;

  /// The current environment's (scope's) key is kept track of by adding it to this list.
  final List<int> _blockHistory = [];

  /// Thrown [DartBlockException] from the last execution of the [DartBlockProgram].
  DartBlockException? _thrownException;

  /// Get the [DartBlockException] thrown during the last execution of the [DartBlockProgram].
  DartBlockException? get thrownException => _thrownException;

  /// Begin a new scope for variables, represented by a [DartBlockEnvironment] object.
  ///
  /// If `isIsolated` is false, the new environment is added as a child to the current
  /// environment.
  ///
  /// Otherwise, the new environment is added as a child to the root
  /// environment, indicating that it has its own separate (isolated) scope. For example, a custom function would have its own isolated scope (environment), rather than being a child of the main function's environment.
  void beginScope(int key, {isIsolated = false}) {
    _blockHistory.add(_currentStatementBlockKey);

    var currentEnvironment = _getCurrentEnvironment();
    if (isIsolated) {
      environment.addChild(
        DartBlockEnvironment(key, parent: environment, children: []),
      );
    } else {
      currentEnvironment.addChild(
        DartBlockEnvironment(key, parent: currentEnvironment, children: []),
      );
    }

    _currentStatementBlockKey = key;
  }

  /// End the current scope ([DartBlockEnvironment]) and return to the previous ('higher-up' or parent) scope.
  /// This is done by retrieving and removing the last element in the [_blockHistory] list.
  ///
  /// Should [_blockHistory] be empty, the root [DartBlockEnvironment] is set
  /// to the current environment. However, this case should normally never occur.
  void endScope(int key) {
    _currentStatementBlockKey = _blockHistory.isNotEmpty
        ? _blockHistory.removeLast()
        : environment.key;
  }

  /// Retrieve a function based on its unique name.
  ///
  /// Searches first in custom functions (including main), then in native functions.
  DartBlockFunction? retrieveFunction(String name) {
    // Search custom functions (including main)
    final allCustomFunctions = <DartBlockCustomFunction>[
      program.mainFunction,
      ...program.customFunctions,
    ];
    final customFunction = allCustomFunctions
        .where((func) => func.name == name)
        .firstOrNull;

    if (customFunction != null) {
      return customFunction;
    }

    // Search native functions
    return DartBlockNativeFunctions.getByName(name);
  }

  DartBlockEnvironment _getCurrentEnvironment() {
    return _findCurrentEnvironment(environment) ?? environment;
  }

  DartBlockEnvironment? _findCurrentEnvironment(
    DartBlockEnvironment environment,
  ) {
    /// Check the current Environment's key
    if (environment.key == _currentStatementBlockKey) {
      return environment;
    } else {
      /// Otherwise, go down the tree by checking the environment's children.
      for (var child in environment.children) {
        final result = _findCurrentEnvironment(child);
        if (result != null) return result;

        /// Warning: do not simply perform 'return _findCurrentEnvironment(child);'
        /// inside the for-loop. Instead, only return from the for-loop if one of
        /// the environment's children returns a non-null match. Otherwise, the search
        /// behavior is faulty.
      }
    }

    return null;
  }

  /// Used by [VariableDeclarationStatement] to declare a new variable with an optional initial value, i.e., its initial value can be null.
  void declareVariable(
    DartBlockDataType dataType,
    String name,
    DartBlockValue? value,
  ) {
    final currentEnvironment = _getCurrentEnvironment();
    currentEnvironment.declareVariable(this, name, dataType, value);
  }

  /// Used by [VariableAssignmentStatement] to update an existing (declared) variable's
  /// value.
  void assignValueToVariable(String name, DartBlockValue? value) {
    final currentEnvironment = _getCurrentEnvironment();
    currentEnvironment.assignValueToVariable(this, name, value);
  }

  /// Retrieve the value assigned to the given variable in the current scope ([DartBlockEnvironment]), based on its unique name.
  DartBlockValue? getVariableValue(String name) {
    final currentEnvironment = _getCurrentEnvironment();

    return currentEnvironment.get(name);
  }

  /// Print a message to the console.
  ///
  /// This function is used internally by [PrintStatement] and [DartBlockException].
  void printToConsole(String message);

  /// Whether a given value's type matches [expectedType].
  ///
  /// [value] does not necessarily have to be a value, e.g., it can also be a constant value.
  (bool, Type?) verifyDataTypeOfNeoValue(
    DartBlockDataType expectedType,
    DartBlockValue value,
  ) {
    final concreteValue = value.getValue(this);
    switch (expectedType) {
      case DartBlockDataType.integerType:
      case DartBlockDataType.doubleType:
        if (concreteValue is! num) {
          return (false, concreteValue.runtimeType);
        }
        break;
      case DartBlockDataType.booleanType:
        if (concreteValue is! bool) {
          return (false, concreteValue.runtimeType);
        }
        break;
      case DartBlockDataType.stringType:
        if (concreteValue is! String) {
          return (false, concreteValue.runtimeType);
        }
        break;
    }

    return (true, null);
  }

  /// Whether a given value's type matches [expectedType].
  ///
  /// Differently from [verifyDataTypeOfNeoValue], [value] can be of any type (dynamic).
  (bool, Type?) verifyDataTypeOfConcreteValue(
    DartBlockDataType expectedType,
    dynamic value,
  ) {
    final concreteValue = value;
    switch (expectedType) {
      case DartBlockDataType.integerType:
      case DartBlockDataType.doubleType:
        if (concreteValue is! num) {
          return (false, concreteValue.runtimeType);
        }
        break;
      case DartBlockDataType.booleanType:
        if (concreteValue is! bool) {
          return (false, concreteValue.runtimeType);
        }
        break;
      case DartBlockDataType.stringType:
        if (concreteValue is! String) {
          return (false, concreteValue.runtimeType);
        }
        break;
    }

    return (true, null);
  }
}

/// A concrete implementation of [DartBlockArbiter].
///
/// This class keeps track of the console output of the executed [DartBlockProgram], as well as the actual execution behavior.
class DartBlockExecutor extends DartBlockArbiter {
  /// The output to the console, line-by-line.
  final List<String> _consoleOutput = [];
  DartBlockExecutor(super.program);

  List<String> get consoleOutput => _consoleOutput;

  @override
  void printToConsole(String message) {
    _consoleOutput.add(message);
    if (kDebugMode) {
      print(message);
    }
  }

  /// Reset the state of the [DartBlockExecutor].
  ///
  /// This clears out the [DartBlockEnvironment], console output and thrown [DartBlockException].
  void _reset() {
    environment.clearChildren();
    environment.clearMemory();
    _currentStatementBlockKey = environment.key;
    _currentStatement = null;
    _consoleOutput.clear();
    _blockHistory.clear();
    _thrownException = null;
  }

  /// Execute the [DartBlockProgram].
  ///
  /// A new [Isolate] is spawned, on which the execution of the [DartBlockProgram] will occur.
  ///
  /// This ensures that the UI is not frozen during the execution.
  ///
  /// Additionally, a timer is applied.
  /// If the execution has not terminated after a set [Duration], it is automatically interrupted by killing the [Isolate]
  /// and throwing a [DartBlockException] indicating that the user's program may contain an infinite loop or a faulty recursive function without a proper ending condition.
  ///
  /// By default, the [Duration] is 5s, which is also the minimum duration allowed.
  ///
  /// IMPORTANT: as Dart does not support [Isolate]s on web platforms, the execution model is much more rudimentary:
  /// - The [DartBlockProgram] is executed on the main thread, meaning the UI will freeze until the execution has finished.
  /// - No timer is applied, meaning a faulty program whose execution never ends will lead to an indefinite stall of the app.
  ///
  /// More info on the web platform and isolates: https://docs.flutter.dev/perf/isolates#web-platforms-and-compute
  Future<void> execute({Duration duration = const Duration(seconds: 5)}) async {
    if (duration.inSeconds < 5) {
      duration = Duration(seconds: 5);
    }

    // Reset the environment to wipe traces of the previous execution.
    _reset();
    if (kIsWeb) {
      _executeWeb();
      return;
    }

    final resultPort = ReceivePort();
    final errorPort = ReceivePort();
    final exitPort = ReceivePort();
    Isolate? isolate;
    Timer? timeoutTimer;
    StreamSubscription? resultSub;
    StreamSubscription? errorSub;
    StreamSubscription? exitSub;
    final completer = Completer<Map<String, dynamic>?>();

    try {
      // serializable payload
      final Map<String, dynamic> payload = {'program': program.toJson()};
      isolate = await Isolate.spawn<_IsolateArgs>(
        _isolateEntry, // top-level function
        _IsolateArgs(resultPort.sendPort, payload),
        paused: true,
        onError: errorPort.sendPort,
        onExit: exitPort.sendPort,
      );

      // Listen for the worker result
      resultSub = resultPort.listen((message) {
        if (!completer.isCompleted) {
          completer.complete(message as Map<String, dynamic>?);
        }
      });

      // Listen for uncaught errors from the isolate runtime
      errorSub = errorPort.listen((message) {
        if (!completer.isCompleted) {
          completer.completeError(message);
        }
      });

      // If isolate exits without sending a payload
      exitSub = exitPort.listen((_) {
        if (!completer.isCompleted) completer.complete(null);
      });

      // Start the timeout timer that kills the isolate after the given duration.
      timeoutTimer = Timer(duration, () {
        if (!completer.isCompleted) {
          try {
            isolate?.kill(priority: Isolate.immediate);
          } catch (_) {}
          completer.complete(null);
        }
      });

      // Resume (start) isolate and wait for completion/timeout/error
      isolate.resume(isolate.pauseCapability!);
      final responseMap = await completer.future;

      // Cleanup listeners + ports + timer
      await resultSub.cancel();
      await errorSub.cancel();
      await exitSub.cancel();
      resultPort.close();
      errorPort.close();
      exitPort.close();
      timeoutTimer.cancel();

      // Handle the resultMap (null => timeout/killed)
      if (responseMap == null) {
        // treat as timeout
        _thrownException = DartBlockException(
          title: "Infinite Loop",
          message:
              "The program was killed due to timeout. Ensure your program does not contain an infinite loop or a recursive function without an ending condition!",
        );
        printToConsole("Program execution interrupted by exception.");
        return;
      }

      final response = DartBlockExecutionResult.fromJson(responseMap);

      // Apply state of isolate's executor to this executor
      _consoleOutput
        ..clear()
        ..addAll(response.consoleOutput);
      final env = response.getEnvironment();
      if (env != null) {
        environment.copyFrom(env); // deep copy
      }
      _currentStatementBlockKey = response.currentStatementBlockKey;
      _currentStatement = response.getCurrentStatement();
      _blockHistory
        ..clear()
        ..addAll(response.blockHistory);
      _thrownException = response.getException();

      if (_thrownException != null) {
        printToConsole("Program execution interrupted by exception.");
      } else {
        printToConsole("Program execution finished successfully.");
      }
    } catch (ex) {
      // Should normally never occur.
      _thrownException = DartBlockException(
        title: "Critical Error",
        message:
            "The program was killed due to an unknown error. Ensure your program does not contain an infinite loop or a recursive function without an ending condition!",
      );
      printToConsole("Program execution interrupted by exception.");
    } finally {
      // clean-up
      try {
        await resultSub?.cancel();
        await errorSub?.cancel();
        await exitSub?.cancel();
      } catch (_) {}
      resultPort.close();
      errorPort.close();
      exitPort.close();
      timeoutTimer?.cancel();
    }
  }

  DartBlockExecutionResult getExecutionResult() {
    return DartBlockExecutionResult(
      consoleOutput: consoleOutput,
      environment: environment.toJson(),
      currentStatementBlockKey: _currentStatementBlockKey,
      currentStatement: _currentStatement?.toJson(),
      blockHistory: List.from(_blockHistory),
      exception: _thrownException?.toJson(),
    );
  }

  /// Rudimentary execution model for the web platform, without the usage of isolates.
  ///
  /// Limitations:
  /// - No infinite execution prevention: if a faulty program's execution never ends, the entire UI of DartBlock will remain frozen.
  ///   - Recommendation: offer a separate refresh button in your web app to reload your embedded DartBlock element.
  /// - UI block: due to the DartBlock program being executed on the same main isolate, the UI will remain frozen and unusable until the execution has finished.
  void _executeWeb() {
    Exception? exception;
    try {
      FunctionCallStatement.init("main", []).run(this);
    } on DartBlockException catch (ex) {
      exception = ex;
    } on Exception catch (ex) {
      exception = ex;
    } on StackOverflowError catch (_) {
      exception = DartBlockException(
        title: "Stack Overflow",
        message:
            "The program was killed due to a stack overflow error. This can occur if you have a recursive function without an appropriate ending condition.",
      );
    } on Error catch (_) {
      exception = DartBlockException(
        title: "Critical Error",
        message:
            "The program was killed due to an unknown error. Ensure your program does not contain an infinite loop or a recursive function without an ending condition!",
      );
    }

    if (exception != null) {
      if (exception is DartBlockException) {
        _thrownException = exception;
        printToConsole("Program execution interrupted by exception.");
      } else {
        _thrownException = DartBlockException.fromException(
          exception: exception,
        );
        printToConsole("Program execution interrupted by exception.");
      }
    } else {
      printToConsole("Program execution finished successfully.");
    }
  }

  /// Copy the state of another [DartBlockExecutor] into this one.
  ///
  /// This includes its console output, environment and any potentially thrown exception.
  void copyFrom(DartBlockExecutor executor) {
    _consoleOutput.clear();
    _consoleOutput.addAll(executor.consoleOutput);
    environment.copyFrom(executor.environment);
    _currentStatementBlockKey = executor._currentStatementBlockKey;
    _currentStatement = executor._currentStatement;
    _blockHistory.clear();
    _blockHistory.addAll(executor._blockHistory);
    _thrownException = executor._thrownException;
  }
}

/// Visitor pattern for the tree representation of DartBlock components.
abstract class DartBlockProgramTreeNodeAcceptor {
  DartBlockProgramTreeNode buildTree(DartBlockProgramTreeNode programTreeNode);
}

/// The tree-based representation of a DartBlock component (Statement, Function) as a node.
///
/// A node can have an optional parent node, as well as a list of child nodes.
///
/// The purpose of this tree representation is to primarily keep track of the variable scopes.
/// As such, by traversing upward from a given node, we can determine the variables which have already been declared
/// and which are usable in the current scope.
///
/// A second usage of this tree representation is to enable the evaluation schema [DartBlockVariableCountEvaluationSchema].
///
/// ----
/// Technical details:
/// - The root node, defined by the concrete [DartBlockProgramTreeRootNode], has no parent. The root node is created by [DartBlockProgram.buildTree].
/// - The child nodes of [DartBlockProgramTreeRootNode] are the main [DartBlockFunction] and any additional custom [DartBlockFunction]. The concrete implementation is given by [DartBlockProgramTreeCustomFunctionNode].
/// - Each [DartBlockProgramTreeCustomFunctionNode] has as a singular child the first [Statement] in its body. The concrete implementation is given by [DartBlockProgramTreeStatementNode].
/// - Compound [Statement]s, such as [WhileLoopStatement], again have the first [Statement] in their body as a singular child.
/// - Special cases include [IfElseStatement] and [ForLoopStatement]:
///   - [IfElseStatement]: it has a child for its if-body, another for its else-body and one for each additional else-if clause's body.
///   - [ForLoopStatement]: if its [ForLoopStatement.initStatement] is not null, it is its singular chilld. Otherwise, the starting child is the first statement of its body.
sealed class DartBlockProgramTreeNode {
  /// The parent node.
  ///
  /// It can be null, signifying it is the root node.
  final DartBlockProgramTreeNode? parent;

  /// The list of child nodes.
  ///
  /// A node is not limited to a fixed number of children, though most DartBlock components have a singular child.
  final List<DartBlockProgramTreeNode> children = [];

  /// A unique key which the node is associated with.
  ///
  /// Used for looking up nodes in tree traversal.
  final int key;
  DartBlockProgramTreeNode(this.parent, {required this.key});

  /// The list of variable definitions inherent to a singular node. In other words, the variables defined in that node.
  ///
  /// As an example, [DartBlockProgramTreeCustomFunctionNode] defines a list of declared variables corresponding to the parameters of the [DartBlockFunction].
  /// Aside from functions, a [VariableDeclarationStatement] also inherently defines a variable in its scope. Otherwise, no other statement type defines any inherent variables.
  ///
  /// ----
  /// Explainer: The tree representation of a DartBlockProgram is used to track the variable scope for a given location (Statement) in the program, which is done via upward traversal.
  /// Primarily, the variable definitions are retrieved from [VariableDeclarationStatement]s, but a [DartBlockFunction] is a special case which can define multiple variables in a singular [DartBlockProgramTreeCustomFunctionNode].
  List<DartBlockVariableDefinition> _getInherentVariableDefinitions();

  /// Return this node if its [key] matches.
  /// Otherwise, perform downward traversal to find matches in the child nodes.
  DartBlockProgramTreeNode? findNodeByKey(int key) {
    if (this.key == key) {
      return this;
    } else {
      for (var child in children) {
        final foundNode = child.findNodeByKey(key);
        if (foundNode != null) {
          return foundNode;
        }
      }
    }

    return null;
  }

  /// Get the depth of this node.
  ///
  /// If it has no children, its depth is simply 1.
  /// Otherwise, find the highest depth based on its child nodes.
  int getMaxDepth() {
    if (children.isEmpty) {
      return 1;
    } else {
      List<int> depths = List.generate(children.length, (index) => 1);
      for (var (index, child) in children.indexed) {
        depths[index] += child.getMaxDepth();
      }
      return depths.max;
    }
  }

  /// Retrieve the list of variables defined in the scope given by the starting node, based on its [key].
  /// Based on the starting node, upward traversal is used to find all preceding variable definitions.
  ///
  /// If [includeNode] is true, the starting node's own variable definitions are also included.
  /// Otherwise, the search starts from the parent node of the starting node.
  List<DartBlockVariableDefinition> findVariableDefinitions(
    int key, {
    bool includeNode = false,
  }) {
    var containingNode = findNodeByKey(key);

    if (!includeNode) {
      containingNode = containingNode?.parent;
    }
    if (containingNode != null) {
      /// We pass _getInherentVariableDefinitions() as an argument, as we want to include the inherent variable definitions
      /// of the current (this) node as well.
      return containingNode
          ._findVariableDefinitions(_getInherentVariableDefinitions())
          .toSet()
          .toList();
    } else {
      /// If the node based on the given [key] does not exist, simply return the inherent variable definitions
      /// of the current (this) node, if [includeNode] is true.
      if (includeNode) {
        return _getInherentVariableDefinitions();
      } else {
        return [];
      }
    }
  }

  /// Retrieve the variable definitions of this node's scope.
  ///
  /// If its parent node is null, simply return the concatenation of [existingDefinitions] and this node's inherent variable definitions.
  /// Otherwise, return the former concatenation as well as any variable definitions defined higher up, until we reach a node with no parent node.
  List<DartBlockVariableDefinition> _findVariableDefinitions(
    List<DartBlockVariableDefinition> existingDefinitions,
  ) {
    List<DartBlockVariableDefinition> definitions = [];
    definitions.addAll(existingDefinitions);
    definitions.addAll(_getInherentVariableDefinitions());

    if (parent == null) {
      return definitions;
    } else {
      return parent!._findVariableDefinitions(definitions);
    }
  }

  /// Retrieve all variable definitions in the current node and its child nodes.
  ///
  /// This function performs the opposite of [findVariableDefinitions], as it performs a downward traversal until it reaches nodes with no more child nodes.
  ///
  /// This function is not used for the actual execution logic of a [DartBlockProgram].
  /// Instead, it is used to enable secondary functionalities, such as the generation of hints using [DartBlockProgram.getHints], as well as [DartBlockVariableCountEvaluationSchema].
  List<DartBlockVariableDefinition> findAllVariableDefinitions() {
    List<DartBlockVariableDefinition> foundVariableDefinitions =
        _getInherentVariableDefinitions();
    for (var child in children) {
      foundVariableDefinitions.addAll(child.findAllVariableDefinitions());
    }
    return foundVariableDefinitions.toSet().toList();
  }

  /// Count the number of usage of each [StatementType] by way of downward traversal.
  Map<StatementType, int> getStatementTypeUsageCount() {
    Map<StatementType, int> statementTypeCounts = {};
    final statementType = _getStatementType();
    if (statementType != null) {
      statementTypeCounts[statementType] =
          statementTypeCounts.containsKey(statementType)
          ? statementTypeCounts[statementType]! + 1
          : 1;
    }
    for (final child in children) {
      final childStatementTypeCounts = child.getStatementTypeUsageCount();
      for (final entry in childStatementTypeCounts.entries) {
        if (statementTypeCounts.containsKey(entry.key)) {
          statementTypeCounts[entry.key] =
              statementTypeCounts[entry.key]! + entry.value;
        } else {
          statementTypeCounts[entry.key] = entry.value;
        }
      }
    }
    return statementTypeCounts;
  }

  /// Get the [StatementType] associated with the [Statement] represented by this node.
  ///
  /// Only [DartBlockProgramTreeStatementNode] returns a non-null value.
  StatementType? _getStatementType() {
    return null;
  }
}

/// The root node of the tree representation of a [DartBlockProgram].
///
/// The node key is always -1.
///
/// The root node has no parent.
class DartBlockProgramTreeRootNode extends DartBlockProgramTreeNode {
  DartBlockProgramTreeRootNode() : super(null, key: -1);

  @override
  List<DartBlockVariableDefinition> _getInherentVariableDefinitions() {
    return [];
  }
}

/// The node for a [DartBlockCustomFunction] in the tree representation.
class DartBlockProgramTreeCustomFunctionNode extends DartBlockProgramTreeNode {
  final DartBlockCustomFunction customFunction;
  DartBlockProgramTreeCustomFunctionNode(this.customFunction, super.parent)
    : super(key: customFunction.hashCode);

  /// The parameters of this [DartBlockCustomFunction] are its inherent variable definitions.
  @override
  List<DartBlockVariableDefinition> _getInherentVariableDefinitions() {
    return List.from(customFunction.parameters.map((e) => e.copy()));
  }

  /// Retrieve the maximum depth of this [DartBlockFunction].
  ///
  /// If it has no child nodes, its depth is 0.
  /// Otherwise, retrieve the maximum depth from its child nodes (statements of its body).
  @override
  int getMaxDepth() {
    if (children.isEmpty) {
      return 0;
    } else {
      List<int> depths = List.generate(children.length, (index) => 0);
      for (var (index, child) in children.indexed) {
        depths[index] += child.getMaxDepth();
      }
      return depths.max;
    }
  }
}

/// The node for a [Statement] in the tree representation.
class DartBlockProgramTreeStatementNode extends DartBlockProgramTreeNode {
  final Statement statement;
  DartBlockProgramTreeStatementNode(this.statement, super.parent)
    : super(key: statement.hashCode);

  @override
  StatementType _getStatementType() {
    return statement.statementType;
  }

  /// The inherent variable definitions of this statement's node.
  ///
  /// Currently, only a [VariableDeclarationStatement] can have an inherent variable definition.
  @override
  List<DartBlockVariableDefinition> _getInherentVariableDefinitions() {
    if (statement is VariableDeclarationStatement) {
      final variableDeclarationStatement =
          statement as VariableDeclarationStatement;

      return [
        DartBlockVariableDefinition(
          variableDeclarationStatement.name,
          variableDeclarationStatement.dataType,
        ),
      ];
    } else {
      return [];
    }
  }
}
