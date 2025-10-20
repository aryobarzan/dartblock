import 'dart:math';

import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:dartblock_code/core/dartblock_executor.dart';
import 'package:dartblock_code/core/dartblock_program.dart';
import 'package:dartblock_code/models/function.dart';
import 'package:dartblock_code/models/exception.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/statement.dart';
part 'evaluator.g.dart';

// exact same (disallow changes, only reordering)

/// Used by Script and Print evaluators
double _similarity(String a, String b) {
  a = a.toUpperCase();
  b = b.toUpperCase();

  return (1 - _damerau(a, b) / (max(a.length, b.length)));
}

/// Damerau-Levenshtein
/// Source: https://github.com/kseo/edit_distance/blob/master/lib/src/damerau.dart
int _damerau(String s1, String s2) {
  int inf = s1.length + s2.length;

  Map<int, int> da = <int, int>{};

  for (var d = 0; d < s1.length; d++) {
    if (!da.containsKey(s1.codeUnitAt(d))) {
      da[s1.codeUnitAt(d)] = 0;
    }
  }

  for (var d = 0; d < s2.length; d++) {
    if (!da.containsKey(s2.codeUnitAt(d))) {
      da[s2.codeUnitAt(d)] = 0;
    }
  }

  List<List<int>> h = List<List<int>>.generate(
    s1.length + 2,
    (_) => List<int>.filled(s2.length + 2, 0, growable: false),
    growable: false,
  );

  for (var i = 0; i <= s1.length; i++) {
    h[i + 1][0] = inf;
    h[i + 1][1] = i;
  }

  for (var j = 0; j <= s2.length; j++) {
    h[0][j + 1] = inf;
    h[1][j + 1] = j;
  }

  for (var i = 1; i <= s1.length; i++) {
    int db = 0;

    for (var j = 1; j <= s2.length; j++) {
      int i1 = da[s2.codeUnitAt(j - 1)]!;
      int j1 = db;

      int cost = 1;
      if (s1.codeUnitAt(i - 1) == s2.codeUnitAt(j - 1)) {
        cost = 0;
        db = j;
      }

      h[i + 1][j + 1] = [
        h[i][j] + cost, // substitution
        h[i + 1][j] + 1, // insertion
        h[i][j + 1] + 1, // deletion
        h[i1][j1] + (i - i1 - 1) + 1 + (j - j1 - 1),
      ].reduce((acc, val) => min(acc, val));
    }
    da[s1.codeUnitAt(i - 1)] = i;
  }

  return h[s1.length + 1][s2.length + 1];
}

@JsonSerializable(explicitToJson: true)
class DartBlockEvaluator {
  List<DartBlockEvaluationSchema> schemas;
  DartBlockEvaluator(this.schemas);

  Future<DartBlockEvaluationResult> evaluate(
    DartBlockProgram sampleSolution,
    DartBlockProgram inputProgram,
  ) async {
    final List<DartBlockEvaluation> schemaEvaluations = [];
    for (final schema in schemas) {
      final schemaEvaluation = await schema.evaluate(
        sampleSolution,
        inputProgram,
      );
      schemaEvaluations.add(schemaEvaluation);
    }

    return DartBlockEvaluationResult(schemaEvaluations);
  }

  factory DartBlockEvaluator.fromJson(Map<String, dynamic> json) =>
      _$DartBlockEvaluatorFromJson(json);
  Map<String, dynamic> toJson() => _$DartBlockEvaluatorToJson(this);

  DartBlockEvaluator copy() {
    return DartBlockEvaluator(List.from(schemas.map((e) => e.copy())));
  }
}

@JsonSerializable(explicitToJson: true)
final class DartBlockEvaluationResult {
  List<DartBlockEvaluation> evaluations;
  DartBlockEvaluationResult(this.evaluations);

  bool isCorrect() {
    if (evaluations.isEmpty) {
      return true;
    } else {
      return evaluations.where((element) => !element.isCorrect).isEmpty;
    }
  }

  DartBlockEvaluationResult copy() {
    return DartBlockEvaluationResult(List.from(evaluations));
  }

  factory DartBlockEvaluationResult.fromJson(Map<String, dynamic> json) =>
      _$DartBlockEvaluationResultFromJson(json);
  Map<String, dynamic> toJson() => _$DartBlockEvaluationResultToJson(this);

  @override
  String toString() {
    var text = isCorrect() ? 'Correct!' : 'Wrong!';
    for (final evaluation in evaluations) {
      text += "\n${evaluation.toString()}";
    }
    return text;
  }
}

@JsonEnum()
enum DartBlockEvaluationSchemaType {
  @JsonValue('functionDefinition')
  functionDefinition('functionDefinition'),
  @JsonValue('functionOutput')
  functionOutput('functionOutput'),
  @JsonValue('script')
  script('script'),
  @JsonValue('variableCount')
  variableCount('variableCount'),
  @JsonValue('environment')
  environment('environment'),
  @JsonValue('print')
  print('print');

  final String jsonValue;
  const DartBlockEvaluationSchemaType(this.jsonValue);

  @override
  String toString() {
    switch (this) {
      case DartBlockEvaluationSchemaType.functionDefinition:
        return 'Function Definition';
      case DartBlockEvaluationSchemaType.functionOutput:
        return 'Function Call Output';
      case DartBlockEvaluationSchemaType.script:
        return 'Script';
      case DartBlockEvaluationSchemaType.variableCount:
        return 'Variable Count';
      case DartBlockEvaluationSchemaType.environment:
        return 'Environment';
      case DartBlockEvaluationSchemaType.print:
        return 'Print';
    }
  }

  String describe({bool extended = false}) {
    switch (this) {
      case DartBlockEvaluationSchemaType.functionDefinition:
        return """Check if specific functions have been defined, based on name, parameters and return type.
The actual behavior and output of the functions is not verified.""";
      case DartBlockEvaluationSchemaType.functionOutput:
        return """Check if sample function calls result in the same output.
This is a stricter variant of the 'Function Definition' schema.""";
      case DartBlockEvaluationSchemaType.script:
        return """Check if the script of the user's answer matches the script of the sample solution.
${extended ? """This is a purely String-based comparison using the Damerau-Levenshtein metric.
Adjust the similarity threshold parameter to determine how strict the evaluation should be: a lower value allows more divergence from the sample solution.""" : ""}""";
      case DartBlockEvaluationSchemaType.variableCount:
        return """Check if the user's program contains fewer than or exactly the same number of variable declarations as the sample solution.
Use the additional parameter to indicate whether variable names starting with an underscore '_" should be ignored in the count.""";
      case DartBlockEvaluationSchemaType.environment:
        return """Check if, post-execution, the user's program leads to the same variable declarations, including identical values, as the sample solution post-execution.
Use the additional parameter to indicate whether variable names starting with an underscore '_" should be ignored.""";
      case DartBlockEvaluationSchemaType.print:
        return """Check if, post-execution, the user's program has the same console output (Print statements) as the sample solution post-execution.
Order of output is taken into account.""";
    }
  }
}

sealed class DartBlockEvaluationSchema {
  DartBlockEvaluationSchemaType schemaType;
  bool isEnabled;
  DartBlockEvaluationSchema(this.isEnabled, {required this.schemaType});

  factory DartBlockEvaluationSchema.fromJson(Map<String, dynamic> json) {
    DartBlockEvaluationSchemaType? kind;
    if (json.containsKey('schemaType')) {
      for (var schemaType in DartBlockEvaluationSchemaType.values) {
        if (json["schemaType"] == schemaType.jsonValue) {
          kind = schemaType;
          break;
        }
      }
    }

    if (kind == null) {
      throw EvaluatorSchemaSerializationException(
        json.containsKey("schemaType") ? json["schemaType"] : "UNKNOWN",
      );
    }
    switch (kind) {
      case DartBlockEvaluationSchemaType.functionDefinition:
        return DartBlockFunctionDefinitionEvaluationSchema.fromJson(json);
      case DartBlockEvaluationSchemaType.functionOutput:
        return DartBlockFunctionOutputEvaluationSchema.fromJson(json);
      case DartBlockEvaluationSchemaType.script:
        return DartBlockScriptEvaluationSchema.fromJson(json);
      case DartBlockEvaluationSchemaType.variableCount:
        return DartBlockVariableCountEvaluationSchema.fromJson(json);
      case DartBlockEvaluationSchemaType.environment:
        return DartBlockEnvironmentEvaluationSchema.fromJson(json);
      case DartBlockEvaluationSchemaType.print:
        return DartBlockPrintEvaluationSchema.fromJson(json);
    }
  }
  Map<String, dynamic> toJson();

  Future<DartBlockEvaluation> evaluate(
    DartBlockProgram solutionCore,
    DartBlockProgram answerCore,
  );

  Future<String?> isSchemaValid(DartBlockProgram neoTechCore);

  DartBlockEvaluationSchema copy();
}

@JsonSerializable(explicitToJson: true)
class DartBlockFunctionDefinitionEvaluationSchema
    extends DartBlockEvaluationSchema {
  final List<FunctionDefinition> functionDefinitions;
  DartBlockFunctionDefinitionEvaluationSchema(
    super.isEnabled,
    this.functionDefinitions,
  ) : super(schemaType: DartBlockEvaluationSchemaType.functionDefinition);

  factory DartBlockFunctionDefinitionEvaluationSchema.fromJson(
    Map<String, dynamic> json,
  ) => _$DartBlockFunctionDefinitionEvaluationSchemaFromJson(json);
  @override
  Map<String, dynamic> toJson() =>
      _$DartBlockFunctionDefinitionEvaluationSchemaToJson(this);

  @override
  Future<DartBlockEvaluation> evaluate(
    DartBlockProgram solutionCore,
    DartBlockProgram answerCore,
  ) async {
    final List<FunctionDefinition> correctFunctionDefinitions = [];
    final List<FunctionDefinition> missingFunctionDefinitions = [];
    final List<(FunctionDefinition, FunctionDefinition)>
    wrongFunctionDefinitions = [];

    for (final functionDefinition in functionDefinitions) {
      final answerFunctionDefinition = answerCore.customFunctions
          .firstWhereOrNull(
            (element) =>
                element.getAsFunctionDefinition().name ==
                functionDefinition.name,
          )
          ?.getAsFunctionDefinition();
      if (answerFunctionDefinition != null) {
        if (answerFunctionDefinition == functionDefinition) {
          correctFunctionDefinitions.add(functionDefinition);
        } else {
          wrongFunctionDefinitions.add((
            functionDefinition,
            answerFunctionDefinition,
          ));
        }
      } else {
        missingFunctionDefinitions.add(functionDefinition);
      }
    }

    return DartBlockFunctionDefinitionEvaluation.init(
      correctFunctionDefinitions,
      missingFunctionDefinitions,
      wrongFunctionDefinitions,
    );
  }

  @override
  Future<String?> isSchemaValid(DartBlockProgram neoTechCore) async {
    if (functionDefinitions.isEmpty) {
      return 'At least 1 sample function definition is required.';
    }
    final availableFunctionDefinitions = neoTechCore.customFunctions
        .map((e) => e.getAsFunctionDefinition())
        .toList();
    for (final functionDefinition in functionDefinitions) {
      if (!availableFunctionDefinitions.contains(functionDefinition)) {
        return "The function definition '${functionDefinition.toString()}' does not exist.";
      }
    }
    return null;
  }

  @override
  DartBlockFunctionDefinitionEvaluationSchema copy() {
    return DartBlockFunctionDefinitionEvaluationSchema(
      isEnabled,
      List.from(functionDefinitions.map((e) => e.copy())),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class DartBlockFunctionOutputEvaluationSchema
    extends DartBlockEvaluationSchema {
  final List<FunctionCallStatement> sampleFunctionCalls;
  DartBlockFunctionOutputEvaluationSchema(
    super.isEnabled,
    this.sampleFunctionCalls,
  ) : super(schemaType: DartBlockEvaluationSchemaType.functionOutput);

  factory DartBlockFunctionOutputEvaluationSchema.fromJson(
    Map<String, dynamic> json,
  ) => _$DartBlockFunctionOutputEvaluationSchemaFromJson(json);
  @override
  Map<String, dynamic> toJson() =>
      _$DartBlockFunctionOutputEvaluationSchemaToJson(this);

  @override
  Future<DartBlockEvaluation> evaluate(
    DartBlockProgram solutionCore,
    DartBlockProgram answerCore,
  ) async {
    final solutionExecutor = DartBlockExecutor(solutionCore);
    final answerExecutor = DartBlockExecutor(answerCore);
    final List<(FunctionCallStatement, String?)> correctFunctionCalls = [];
    final List<(FunctionCallStatement, String?, String?, DartBlockException?)>
    wrongFunctionCalls = [];
    // Used to execute each function call once and catch any exceptions (step 1. below)
    final answerCoreCopy = answerCore.copy();
    for (final sampleFunctionCall in sampleFunctionCalls) {
      // if (answerCore.customFunctions.firstWhereOrNull((element) =>
      //         element.name == sampleFunctionCall.customFunctionName) ==
      //     null) {}
      try {
        /// 1. Try running the program using the given sample function call.
        /// If an exception occurs (infinite loop, stack overflow, etc.), catch
        /// it and log as a failed function call.
        answerCoreCopy.mainFunction.statements.clear();
        answerCoreCopy.mainFunction.statements.add(sampleFunctionCall);
        final copyExecutor = DartBlockExecutor(answerCoreCopy);
        await copyExecutor.execute();
        if (copyExecutor.thrownException != null) {
          wrongFunctionCalls.add((
            sampleFunctionCall,
            null,
            null,
            copyExecutor.thrownException,
          ));
          continue;
        }

        /// 2. Otherwise, the program does not crash outright with the function call.
        /// In that case, actually check the output of the function call and compare
        /// to expected output.
        final expectedValue = DartBlockFunctionCallValue.init(
          sampleFunctionCall,
        ).getValue(solutionExecutor);
        final actualValue = DartBlockFunctionCallValue.init(
          sampleFunctionCall,
        ).getValue(answerExecutor);
        final isCorrect = expectedValue == actualValue;
        if (isCorrect) {
          correctFunctionCalls.add((
            sampleFunctionCall,
            actualValue.toString(),
          ));
        } else {
          wrongFunctionCalls.add((
            sampleFunctionCall,
            expectedValue?.toString(),
            actualValue?.toString(),
            null,
          ));
        }
      } on DartBlockException catch (ex) {
        wrongFunctionCalls.add((sampleFunctionCall, null, null, ex));
      } on Exception catch (ex) {
        wrongFunctionCalls.add((
          sampleFunctionCall,
          null,
          null,
          DartBlockException.fromException(exception: ex),
        ));
      }
    }

    return DartBlockFunctionOutputEvaluation.init(
      correctFunctionCalls,
      wrongFunctionCalls,
    );
  }

  @override
  Future<String?> isSchemaValid(DartBlockProgram neoTechCore) async {
    if (sampleFunctionCalls.isEmpty) {
      return 'At least 1 sample function call is required.';
    }
    final copy = neoTechCore.copy();
    for (final sampleFunctionCall in sampleFunctionCalls) {
      try {
        copy.mainFunction.statements.clear();
        copy.mainFunction.statements.add(sampleFunctionCall);
        final solutionExecutor = DartBlockExecutor(copy);
        await solutionExecutor.execute();
        if (solutionExecutor.thrownException != null) {
          return "The function call '${sampleFunctionCall.toString()}' is invalid: ${solutionExecutor.thrownException.toString()}";
        }
        // FunctionCallValue.init(sampleFunctionCall).getValue(solutionExecutor);
      } on Exception catch (ex) {
        return "The function call '${sampleFunctionCall.toString()}' is invalid: ${ex.toString()}";
      }
    }
    return null;
  }

  @override
  DartBlockFunctionOutputEvaluationSchema copy() {
    return DartBlockFunctionOutputEvaluationSchema(
      isEnabled,
      List.from(sampleFunctionCalls.map((e) => e.copy())),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class DartBlockScriptEvaluationSchema extends DartBlockEvaluationSchema {
  final double similarityThreshold;
  DartBlockScriptEvaluationSchema(super.isEnabled, this.similarityThreshold)
    : super(schemaType: DartBlockEvaluationSchemaType.script);

  factory DartBlockScriptEvaluationSchema.fromJson(Map<String, dynamic> json) =>
      _$DartBlockScriptEvaluationSchemaFromJson(json);
  @override
  Map<String, dynamic> toJson() =>
      _$DartBlockScriptEvaluationSchemaToJson(this);

  @override
  Future<DartBlockEvaluation> evaluate(
    DartBlockProgram solutionCore,
    DartBlockProgram answerCore,
  ) async {
    final solutionScript = solutionCore.toScript();
    final answerScript = answerCore.toScript();

    return DartBlockScriptEvaluation.init(
      _similarity(solutionScript, answerScript),
      similarityThreshold,
      solutionScript,
      answerScript,
    );
  }

  @override
  Future<String?> isSchemaValid(DartBlockProgram neoTechCore) async {
    return null;
  }

  @override
  DartBlockScriptEvaluationSchema copy() {
    return DartBlockScriptEvaluationSchema(isEnabled, similarityThreshold);
  }
}

@JsonSerializable(explicitToJson: true)
class DartBlockVariableCountEvaluationSchema extends DartBlockEvaluationSchema {
  final bool ignoreVariablesStartingWithUnderscore;
  DartBlockVariableCountEvaluationSchema(
    super.isEnabled,
    this.ignoreVariablesStartingWithUnderscore,
  ) : super(schemaType: DartBlockEvaluationSchemaType.variableCount);

  factory DartBlockVariableCountEvaluationSchema.fromJson(
    Map<String, dynamic> json,
  ) => _$DartBlockVariableCountEvaluationSchemaFromJson(json);
  @override
  Map<String, dynamic> toJson() =>
      _$DartBlockVariableCountEvaluationSchemaToJson(this);

  @override
  Future<DartBlockEvaluation> evaluate(
    DartBlockProgram solutionCore,
    DartBlockProgram answerCore,
  ) async {
    var solutionVariableDefinitions = solutionCore
        .buildTree()
        .findAllVariableDefinitions();
    if (ignoreVariablesStartingWithUnderscore) {
      solutionVariableDefinitions
          .where((element) => !element.name.startsWith('_'))
          .toList();
    }
    final answerVariableDefinitions = answerCore
        .buildTree()
        .findAllVariableDefinitions();

    return DartBlockVariableCountEvaluation.init(
      solutionVariableDefinitions,
      answerVariableDefinitions,
    );
  }

  @override
  Future<String?> isSchemaValid(DartBlockProgram neoTechCore) async {
    return null;
  }

  @override
  DartBlockVariableCountEvaluationSchema copy() {
    return DartBlockVariableCountEvaluationSchema(
      isEnabled,
      ignoreVariablesStartingWithUnderscore,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class DartBlockEnvironmentEvaluationSchema extends DartBlockEvaluationSchema {
  final bool ignoreVariablesStartingWithUnderscore;
  DartBlockEnvironmentEvaluationSchema(
    super.isEnabled,
    this.ignoreVariablesStartingWithUnderscore,
  ) : super(schemaType: DartBlockEvaluationSchemaType.environment);

  factory DartBlockEnvironmentEvaluationSchema.fromJson(
    Map<String, dynamic> json,
  ) => _$DartBlockEnvironmentEvaluationSchemaFromJson(json);
  @override
  Map<String, dynamic> toJson() =>
      _$DartBlockEnvironmentEvaluationSchemaToJson(this);

  @override
  Future<DartBlockEvaluation> evaluate(
    DartBlockProgram solutionCore,
    DartBlockProgram answerCore,
  ) async {
    final solutionExecutor = DartBlockExecutor(solutionCore);
    final answerExecutor = DartBlockExecutor(answerCore);

    final List<(DartBlockVariableDefinition, String?)>
    missingVariableDefinitions = [];
    final List<(DartBlockVariableDefinition, String?, DartBlockDataType)>
    wrongVariableDefinitionTypes = [];
    final List<(DartBlockVariableDefinition, String?, String?)>
    wrongVariableDefinitionValues = [];
    final List<(DartBlockVariableDefinition, String?)>
    correctVariableDefinitions = [];
    try {
      await solutionExecutor.execute();
      await answerExecutor.execute();
      final solutionMemory = solutionExecutor.environment.getAllValues(
        solutionExecutor,
      );
      if (ignoreVariablesStartingWithUnderscore) {
        solutionMemory.removeWhere((key, value) => key.name.startsWith('_'));
      }
      final answerMemory = answerExecutor.environment.getAllValues(
        answerExecutor,
      );
      for (final solutionEntry in solutionMemory.entries) {
        if (answerMemory.containsKey(solutionEntry.key)) {
          final answerMemoryKey = answerMemory.keys.firstWhere(
            (element) => element == solutionEntry.key,
          );
          if (answerMemoryKey.dataType == solutionEntry.key.dataType) {
            final answerValue = answerMemory[solutionEntry.key];
            if (answerValue == solutionEntry.value) {
              correctVariableDefinitions.add((
                solutionEntry.key,
                solutionEntry.value,
              ));
            } else {
              wrongVariableDefinitionValues.add((
                solutionEntry.key,
                solutionEntry.value,
                answerValue,
              ));
            }
          } else {
            wrongVariableDefinitionTypes.add((
              solutionEntry.key,
              solutionEntry.value,
              answerMemoryKey.dataType,
            ));
          }
        } else {
          missingVariableDefinitions.add((
            solutionEntry.key,
            solutionEntry.value,
          ));
        }
      }
    } on DartBlockException catch (ex) {
      return DartBlockEnvironmentEvaluation.init(
        missingVariableDefinitions,
        wrongVariableDefinitionTypes,
        wrongVariableDefinitionValues,
        correctVariableDefinitions,
        ex,
      );
    } on Exception catch (ex) {
      return DartBlockEnvironmentEvaluation.init(
        missingVariableDefinitions,
        wrongVariableDefinitionTypes,
        wrongVariableDefinitionValues,
        correctVariableDefinitions,
        DartBlockException.fromException(exception: ex),
      );
    }

    return DartBlockEnvironmentEvaluation.init(
      missingVariableDefinitions,
      wrongVariableDefinitionTypes,
      wrongVariableDefinitionValues,
      correctVariableDefinitions,
      answerExecutor.thrownException,
    );
  }

  @override
  Future<String?> isSchemaValid(DartBlockProgram neoTechCore) async {
    final solutionExecutor = DartBlockExecutor(neoTechCore);
    try {
      await solutionExecutor.execute();
    } on Exception catch (ex) {
      return "The sample program is invalid: ${ex.toString()}";
    }
    return null;
  }

  @override
  DartBlockEnvironmentEvaluationSchema copy() {
    return DartBlockEnvironmentEvaluationSchema(
      isEnabled,
      ignoreVariablesStartingWithUnderscore,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class DartBlockPrintEvaluationSchema extends DartBlockEvaluationSchema {
  final double similarityThreshold;
  DartBlockPrintEvaluationSchema(super.isEnabled, this.similarityThreshold)
    : super(schemaType: DartBlockEvaluationSchemaType.print);

  factory DartBlockPrintEvaluationSchema.fromJson(Map<String, dynamic> json) =>
      _$DartBlockPrintEvaluationSchemaFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DartBlockPrintEvaluationSchemaToJson(this);

  @override
  Future<DartBlockEvaluation> evaluate(
    DartBlockProgram solutionCore,
    DartBlockProgram answerCore,
  ) async {
    final solutionExecutor = DartBlockExecutor(solutionCore);
    final answerExecutor = DartBlockExecutor(answerCore);
    try {
      await solutionExecutor.execute();
      await answerExecutor.execute();
      if (answerExecutor.thrownException != null) {
        return DartBlockPrintEvaluation.init(
          similarityThreshold,
          [],
          answerExecutor.thrownException,
        );
      }
    } on DartBlockException catch (ex) {
      return DartBlockPrintEvaluation.init(similarityThreshold, [], ex);
    } on Exception catch (ex) {
      return DartBlockPrintEvaluation.init(
        similarityThreshold,
        [],
        DartBlockException.fromException(exception: ex),
      );
    }

    List<(String, String?, DartBlockPrintEvaluationType, double?)>
    printEvaluations = [];
    for (final (index, line) in solutionExecutor.consoleOutput.indexed) {
      if (index < answerExecutor.consoleOutput.length) {
        final userLine = answerExecutor.consoleOutput[index];
        final similarity = _similarity(line, userLine);
        if (similarity >= similarityThreshold) {
          printEvaluations.add((
            line,
            userLine,
            DartBlockPrintEvaluationType.correct,
            similarity,
          ));
        } else {
          printEvaluations.add((
            line,
            userLine,
            DartBlockPrintEvaluationType.wrong,
            similarity,
          ));
        }
      } else {
        printEvaluations.add((
          line,
          null,
          DartBlockPrintEvaluationType.missing,
          null,
        ));
      }
    }

    return DartBlockPrintEvaluation.init(
      similarityThreshold,
      printEvaluations,
      null,
    );
  }

  @override
  Future<String?> isSchemaValid(DartBlockProgram neoTechCore) async {
    final solutionExecutor = DartBlockExecutor(neoTechCore);
    try {
      await solutionExecutor.execute();
    } on Exception catch (ex) {
      return "The sample program is invalid: ${ex.toString()}";
    }
    return null;
  }

  @override
  DartBlockPrintEvaluationSchema copy() {
    return DartBlockPrintEvaluationSchema(isEnabled, similarityThreshold);
  }
}

sealed class DartBlockEvaluation {
  final DartBlockEvaluationSchemaType evaluationType;
  final bool isCorrect;
  @JsonKey(name: 'neoTechException')
  final DartBlockException? dartBlockException;
  DartBlockEvaluation(
    this.evaluationType,
    this.isCorrect,
    this.dartBlockException,
  );

  factory DartBlockEvaluation.fromJson(Map<String, dynamic> json) {
    DartBlockEvaluationSchemaType? kind;
    if (json.containsKey('evaluationType')) {
      for (var schemaType in DartBlockEvaluationSchemaType.values) {
        if (json["evaluationType"] == schemaType.jsonValue) {
          kind = schemaType;
          break;
        }
      }
    }

    if (kind == null) {
      throw EvaluatorEvaluationSerializationException(
        json.containsKey("evaluationType") ? json["evaluationType"] : "UNKNOWN",
      );
    }
    switch (kind) {
      case DartBlockEvaluationSchemaType.functionDefinition:
        return DartBlockFunctionDefinitionEvaluation.fromJson(json);
      case DartBlockEvaluationSchemaType.functionOutput:
        return DartBlockFunctionOutputEvaluation.fromJson(json);
      case DartBlockEvaluationSchemaType.script:
        return DartBlockScriptEvaluation.fromJson(json);
      case DartBlockEvaluationSchemaType.variableCount:
        return DartBlockVariableCountEvaluation.fromJson(json);
      case DartBlockEvaluationSchemaType.environment:
        return DartBlockEnvironmentEvaluation.fromJson(json);
      case DartBlockEvaluationSchemaType.print:
        return DartBlockPrintEvaluation.fromJson(json);
    }
  }
  Map<String, dynamic> toJson();

  @override
  String toString() {
    return dartBlockException != null
        ? "- An exception was thrown when evaluating your program: ${dartBlockException!.message}"
        : '';
  }
}

@JsonSerializable(explicitToJson: true)
class DartBlockFunctionDefinitionEvaluation extends DartBlockEvaluation {
  /// (Function Call, Actual Value)
  final List<FunctionDefinition> correctFunctionDefinitions;
  final List<FunctionDefinition> missingFunctionDefinitions;

  /// (Expected, Wrong)
  final List<(FunctionDefinition, FunctionDefinition)> wrongFunctionDefinitions;
  DartBlockFunctionDefinitionEvaluation.init(
    this.correctFunctionDefinitions,
    this.missingFunctionDefinitions,
    this.wrongFunctionDefinitions,
  ) : super(
        DartBlockEvaluationSchemaType.functionDefinition,
        wrongFunctionDefinitions.isEmpty && missingFunctionDefinitions.isEmpty,
        null,
      );
  DartBlockFunctionDefinitionEvaluation(
    this.correctFunctionDefinitions,
    this.missingFunctionDefinitions,
    this.wrongFunctionDefinitions,
    super.evaluationType,
    super.isCorrect,
    super.dartBlockException,
  );

  factory DartBlockFunctionDefinitionEvaluation.fromJson(
    Map<String, dynamic> json,
  ) => _$DartBlockFunctionDefinitionEvaluationFromJson(json);
  @override
  Map<String, dynamic> toJson() =>
      _$DartBlockFunctionDefinitionEvaluationToJson(this);

  @override
  String toString() {
    String text = super.toString();
    if (correctFunctionDefinitions.isNotEmpty) {
      text +=
          '\n - Correct function definitions: ${correctFunctionDefinitions.map((e) => e.name).join(', ')}';
    }
    if (missingFunctionDefinitions.isNotEmpty) {
      text +=
          '\n - Missing function definitions: ${missingFunctionDefinitions.map((e) => e.toString()).join(', ')}';
    }

    for (final wrongFunctionDefinition in wrongFunctionDefinitions) {
      text +=
          '\n - Wrong function definition: ${wrongFunctionDefinition.$2.toString()} (Expected: ${wrongFunctionDefinition.$1.toString()})';
    }
    return text;
  }
}

@JsonSerializable(explicitToJson: true)
class DartBlockFunctionOutputEvaluation extends DartBlockEvaluation {
  /// (Function Call, Actual Value)
  final List<(FunctionCallStatement, String?)> correctFunctionCalls;

  /// (Function Call, Expected Value, Actual Value, NeoTechException)
  final List<(FunctionCallStatement, String?, String?, DartBlockException?)>
  wrongFunctionCalls;
  DartBlockFunctionOutputEvaluation.init(
    this.correctFunctionCalls,
    this.wrongFunctionCalls,
  ) : super(
        DartBlockEvaluationSchemaType.functionOutput,
        wrongFunctionCalls.isEmpty,
        null,
      );
  DartBlockFunctionOutputEvaluation(
    this.correctFunctionCalls,
    this.wrongFunctionCalls,
    super.evaluationType,
    super.isCorrect,
    super.dartBlockException,
  );

  factory DartBlockFunctionOutputEvaluation.fromJson(
    Map<String, dynamic> json,
  ) => _$DartBlockFunctionOutputEvaluationFromJson(json);
  @override
  Map<String, dynamic> toJson() =>
      _$DartBlockFunctionOutputEvaluationToJson(this);

  @override
  String toString() {
    String text = super.toString();
    for (final correctFunctionCall in correctFunctionCalls) {
      text +=
          '\n- Correct: ${correctFunctionCall.$1.toString()}${correctFunctionCall.$2 != null ? ' => ${correctFunctionCall.$2}' : ''}';
    }
    for (final wrongFunctionCall in wrongFunctionCalls) {
      if (wrongFunctionCall.$4 != null) {
        text +=
            '\n- Wrong: ${wrongFunctionCall.$1.toString()} → ${wrongFunctionCall.$4!.describe(includeThrownBy: false)}';
      } else {
        text +=
            '\n- Wrong: ${wrongFunctionCall.$1.toString()}${wrongFunctionCall.$3 != null ? ' => ${wrongFunctionCall.$3}' : ''}${wrongFunctionCall.$2 != null ? ' (Expected: ${wrongFunctionCall.$2})' : ''}';
      }
    }
    return text;
  }
}

@JsonSerializable(explicitToJson: true)
class DartBlockScriptEvaluation extends DartBlockEvaluation {
  final double matchScore;
  final double similarityThreshold;

  final String solutionScript;
  final String answerScript;
  DartBlockScriptEvaluation.init(
    this.matchScore,
    this.similarityThreshold,
    this.solutionScript,
    this.answerScript,
  ) : super(
        DartBlockEvaluationSchemaType.script,
        matchScore >= similarityThreshold,
        null,
      );
  DartBlockScriptEvaluation(
    this.matchScore,
    this.similarityThreshold,
    this.solutionScript,
    this.answerScript,
    super.evaluationType,
    super.isCorrect,
    super.dartBlockException,
  );

  factory DartBlockScriptEvaluation.fromJson(Map<String, dynamic> json) =>
      _$DartBlockScriptEvaluationFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DartBlockScriptEvaluationToJson(this);

  @override
  String toString() {
    return "${super.toString()}\n- Script: ${(matchScore * 100).round()}% match";
  }
}

@JsonSerializable(explicitToJson: true)
class DartBlockVariableCountEvaluation extends DartBlockEvaluation {
  final List<DartBlockVariableDefinition> solutionVariableDefinitions;
  final List<DartBlockVariableDefinition> answerVariableDefinitions;
  DartBlockVariableCountEvaluation.init(
    this.solutionVariableDefinitions,
    this.answerVariableDefinitions,
  ) : super(
        DartBlockEvaluationSchemaType.variableCount,
        answerVariableDefinitions.length <= solutionVariableDefinitions.length,
        null,
      );
  DartBlockVariableCountEvaluation(
    this.solutionVariableDefinitions,
    this.answerVariableDefinitions,
    super.evaluationType,
    super.isCorrect,
    super.dartBlockException,
  );

  factory DartBlockVariableCountEvaluation.fromJson(
    Map<String, dynamic> json,
  ) => _$DartBlockVariableCountEvaluationFromJson(json);
  @override
  Map<String, dynamic> toJson() =>
      _$DartBlockVariableCountEvaluationToJson(this);

  @override
  String toString() {
    return "${super.toString()}\n- ${answerVariableDefinitions.length} variables (Maximum: ${solutionVariableDefinitions.length})";
  }
}

@JsonSerializable(explicitToJson: true)
class DartBlockEnvironmentEvaluation extends DartBlockEvaluation {
  @JsonKey(defaultValue: [])
  final List<(DartBlockVariableDefinition, String?)> missingVariableDefinitions;
  @JsonKey(defaultValue: [])
  final List<(DartBlockVariableDefinition, String?, DartBlockDataType)>
  wrongVariableDefinitionTypes;
  @JsonKey(defaultValue: [])
  final List<(DartBlockVariableDefinition, String?, String?)>
  wrongVariableDefinitionValues;
  @JsonKey(defaultValue: [])
  final List<(DartBlockVariableDefinition, String?)> correctVariableDefinitions;

  DartBlockEnvironmentEvaluation.init(
    this.missingVariableDefinitions,
    this.wrongVariableDefinitionTypes,
    this.wrongVariableDefinitionValues,
    this.correctVariableDefinitions,
    DartBlockException? neoTechException,
  ) : super(
        DartBlockEvaluationSchemaType.environment,
        neoTechException == null &&
            missingVariableDefinitions.isEmpty &&
            wrongVariableDefinitionTypes.isEmpty &&
            wrongVariableDefinitionValues.isEmpty,
        neoTechException,
      );
  DartBlockEnvironmentEvaluation(
    this.missingVariableDefinitions,
    this.wrongVariableDefinitionTypes,
    this.wrongVariableDefinitionValues,
    this.correctVariableDefinitions,
    super.evaluationType,
    super.isCorrect,
    super.dartBlockException,
  );

  factory DartBlockEnvironmentEvaluation.fromJson(Map<String, dynamic> json) =>
      _$DartBlockEnvironmentEvaluationFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DartBlockEnvironmentEvaluationToJson(this);

  @override
  String toString() {
    var text = super.toString();
    if (missingVariableDefinitions.isNotEmpty) {
      text +=
          "\n- Missing variables: ${missingVariableDefinitions.map((e) => "${e.$1.dataType.toString()} ${e.$1.name}").join(", ")}";
    }
    if (wrongVariableDefinitionTypes.isNotEmpty) {
      text +=
          "\n- Wrong variable types: ${wrongVariableDefinitionTypes.map((e) => "${e.$1.toString()} (got ${e.$3.toString()})").join(", ")}";
    }
    if (wrongVariableDefinitionValues.isNotEmpty) {
      text +=
          "\n- Wrong variable values: ${wrongVariableDefinitionValues.map((e) => "${e.$1.toString()} = ${e.$2} (got ${e.$3})").join(", ")}";
    }
    if (correctVariableDefinitions.isNotEmpty) {
      text +=
          "\n- Correct variables: ${correctVariableDefinitions.map((e) => "${e.$1.toString()} = ${e.$2}").join(", ")}";
    }

    return text;
  }
}

@JsonEnum()
enum DartBlockPrintEvaluationType {
  @JsonValue('correct')
  correct,
  @JsonValue('wrong')
  wrong,
  @JsonValue('missing')
  missing;

  @override
  String toString() {
    switch (this) {
      case DartBlockPrintEvaluationType.correct:
        return "Correct";
      case DartBlockPrintEvaluationType.wrong:
        return "Wrong";
      case DartBlockPrintEvaluationType.missing:
        return "Missing";
    }
  }
}

@JsonSerializable(explicitToJson: true)
class DartBlockPrintEvaluation extends DartBlockEvaluation {
  final double similarityThreshold;

  /// (Expected, Actual, EvaluationType, Similarity [0.0-1.0])
  final List<(String, String?, DartBlockPrintEvaluationType, double?)>
  printEvaluations;

  DartBlockPrintEvaluation.init(
    this.similarityThreshold,
    this.printEvaluations,
    DartBlockException? neoTechException,
  ) : super(
        DartBlockEvaluationSchemaType.print,
        neoTechException == null &&
            printEvaluations
                .where(
                  (element) =>
                      element.$3 != DartBlockPrintEvaluationType.correct,
                )
                .isEmpty,
        neoTechException,
      );
  DartBlockPrintEvaluation(
    this.similarityThreshold,
    this.printEvaluations,
    super.evaluationType,
    super.isCorrect,
    super.dartBlockException,
  );

  factory DartBlockPrintEvaluation.fromJson(Map<String, dynamic> json) =>
      _$DartBlockPrintEvaluationFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DartBlockPrintEvaluationToJson(this);

  @override
  String toString() {
    var text = super.toString();
    if (printEvaluations.isNotEmpty) {
      text += "\nPrint evaluation (line-by-line):";
    }
    for (final (index, printEvaluation) in printEvaluations.indexed) {
      final similarityPercentage = printEvaluation.$4 != null
          ? (printEvaluation.$4! * 100).round()
          : null;
      switch (printEvaluation.$3) {
        case DartBlockPrintEvaluationType.correct:
          text +=
              "\n[Line #${index + 1} - Correct] Expected '${printEvaluation.$1}'${similarityPercentage != null && similarityPercentage < 1 ? " → $similarityPercentage% match (Your output: ${printEvaluation.$2})" : ""}";
          break;
        case DartBlockPrintEvaluationType.wrong:
          text +=
              "\n[Line #${index + 1} - Wrong] Expected '${printEvaluation.$1}'${similarityPercentage != null && similarityPercentage < 1 ? " → Got '${printEvaluation.$2}" : ""}'";
          break;
        case DartBlockPrintEvaluationType.missing:
          text +=
              "\n[Line #${index + 1} - Missing] Expected '${printEvaluation.$1}'";
          break;
      }
    }

    return text;
  }
}
