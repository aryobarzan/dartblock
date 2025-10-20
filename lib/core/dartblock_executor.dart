import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:dartblock/core/dartblock_program.dart';
import 'package:dartblock/models/function.dart';
import 'package:dartblock/models/environment.dart';
import 'package:dartblock/models/exception.dart';
import 'package:dartblock/models/dartblock_value.dart';
import 'package:dartblock/models/statement.dart';

/// The executor for DartBlock programs.Serves for executing and keeping track of the execution of a NeoTechCore.
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

  /// Retrieve a [DartBlockFunction] based on its unique name.
  DartBlockFunction? retrieveCustomFunction(String name) {
    return ([program.mainFunction] + program.customFunctions)
        .where((customFunction) => customFunction.name == name)
        .firstOrNull;
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
    bool finishedExecution = false;

    try {
      final resultPort = ReceivePort();
      // Spawn a new isolate on which the DartBlockProgram should be executed.
      final isolate = await Isolate.spawn(
        (List<dynamic> args) async {
          SendPort resultPort = args[0];
          DartBlockExecutor executor = args[1];
          try {
            FunctionCallStatement.init("main", []).run(executor);
          } on DartBlockException catch (ex) {
            Isolate.exit(resultPort, [executor, ex]);
          } on Exception catch (ex) {
            Isolate.exit(resultPort, [executor, ex]);
          } on StackOverflowError catch (_) {
            // DartBlock relies on the StackOverflowError thrown by Dart's own execution engine.
            Isolate.exit(resultPort, [
              executor,
              DartBlockException(
                title: "Stack Overflow",
                message:
                    "The program was killed due to a stack overflow error. This can occur if you have a recursive function without an appropriate ending condition.",
              ),
            ]);
          } on Error catch (_) {
            // Any other (unknown) type of error which may occur.
            Isolate.exit(resultPort, [
              executor,
              DartBlockException(
                title: "Critical Error",
                message:
                    "The program was killed due to an unknown error. Ensure your program does not contain an infinite loop or a recursive function without an ending condition!",
              ),
            ]);
          }
          // Leave the isolate after the execution has finished and send back the DartBlockExecutor which contains the environment and execution output.
          Isolate.exit(resultPort, [executor, null]);
        },
        [resultPort.sendPort, this],

        /// Initially paused such that the timer can be started at the same time.
        paused: true,
        onExit: resultPort.sendPort,
      );

      /// Start the preventive timer, which aims to stop the execution (kill the isolate)
      /// after a certain amount of time in case it has not finished execution yet.
      Future.delayed(duration).then((value) {
        if (!finishedExecution) {
          isolate.kill(priority: Isolate.immediate);
        }
      });
      isolate.resume(isolate.pauseCapability!);
      final response = await resultPort.first;
      finishedExecution = true;

      /// This means the isolate was killed early.
      if (response == null) {
        _thrownException = DartBlockException(
          title: "Infinite Loop",
          message:
              "The program was killed due to its execution taking too long. Ensure your program does not contain an infinite loop or a recursive function without an ending condition!",
        );
      } else {
        DartBlockExecutor receivedExecutor = response[0];
        copyFrom(receivedExecutor);
        Exception? exception = response[1];
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
    } on DartBlockException catch (ex) {
      _thrownException = ex;
      printToConsole("Program execution interrupted by exception.");
    } on Exception catch (ex) {
      _thrownException = DartBlockException.fromException(exception: ex);
      printToConsole("Program execution interrupted by exception.");
    } on StackOverflowError catch (_) {
      _thrownException = DartBlockException(
        title: "Stack Overflow",
        message:
            "The program was killed due to a stack overflow error. This can occur if you have a recursive function without an appropriate ending condition.",
      );
      printToConsole("Program execution interrupted by exception.");
    } on Error catch (_) {
      _thrownException = DartBlockException(
        title: "Critical Error",
        message:
            "The program was killed due to an unknown error. Ensure your program does not contain an infinite loop or a recursive function without an ending condition!",
      );
      printToConsole("Program execution interrupted by exception.");
    }
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

abstract class DartBlockProgramTreeNodeAcceptor {
  DartBlockProgramTreeNode buildTree(DartBlockProgramTreeNode neoTechCoreNode);
}

sealed class DartBlockProgramTreeNode {
  final DartBlockProgramTreeNode? parent;
  final List<DartBlockProgramTreeNode> children = [];

  final int key;
  DartBlockProgramTreeNode(this.parent, {required this.key});

  List<DartBlockVariableDefinition> _getInherentVariableDefinitions();

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

  List<DartBlockVariableDefinition> findAllVariableDefinitions() {
    List<DartBlockVariableDefinition> foundVariableDefinitions =
        _getInherentVariableDefinitions();
    for (var child in children) {
      foundVariableDefinitions.addAll(child.findAllVariableDefinitions());
    }
    return foundVariableDefinitions.toSet().toList();
  }

  Map<StatementType, int> getStatementTypeUsageCount() {
    Map<StatementType, int> statementTypeCounts = {};
    final statementType = _getStatementType();
    if (statementType != null) {
      final currentCount = statementTypeCounts.containsKey(statementType)
          ? statementTypeCounts[statementType]! + 1
          : 1;
      statementTypeCounts[statementType] = currentCount;
    }
    for (var child in children) {
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

  StatementType? _getStatementType() {
    return null;
  }

  List<DartBlockVariableDefinition> findVariableDefinitions(
    int key, {
    bool includeNode = false,
  }) {
    var containingNode = findNodeByKey(key);

    if (!includeNode) {
      containingNode = containingNode?.parent;
    }
    if (containingNode != null) {
      return containingNode
          ._findVariableDefinitions(_getInherentVariableDefinitions())
          .toSet()
          .toList();
    } else {
      if (includeNode) {
        return _getInherentVariableDefinitions();
      } else {
        return [];
      }
    }
  }

  List<DartBlockVariableDefinition> _findVariableDefinitions(
    List<DartBlockVariableDefinition> result,
  ) {
    List<DartBlockVariableDefinition> definitions = [];
    definitions.addAll(_getInherentVariableDefinitions());

    if (parent == null) {
      return definitions + result;
    } else {
      return parent!._findVariableDefinitions(result + definitions);
    }
  }
}

class DartBlockProgramTreeRootNode extends DartBlockProgramTreeNode {
  DartBlockProgramTreeRootNode() : super(null, key: -1);

  @override
  List<DartBlockVariableDefinition> _getInherentVariableDefinitions() {
    return [];
  }
}

class DartBlockProgramTreeCustomFunctionNode extends DartBlockProgramTreeNode {
  final DartBlockFunction customFunction;
  DartBlockProgramTreeCustomFunctionNode(this.customFunction, super.parent)
    : super(key: customFunction.hashCode);

  @override
  List<DartBlockVariableDefinition> _getInherentVariableDefinitions() {
    return List.from(customFunction.parameters.map((e) => e.copy()));
  }

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

class DartBlockProgramTreeStatementNode extends DartBlockProgramTreeNode {
  final Statement statement;
  DartBlockProgramTreeStatementNode(this.statement, super.parent)
    : super(key: statement.hashCode);

  @override
  StatementType _getStatementType() {
    return statement.statementType;
  }

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
