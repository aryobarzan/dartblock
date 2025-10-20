// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evaluator.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DartBlockEvaluator _$NeoTechEvaluatorFromJson(Map<String, dynamic> json) =>
    DartBlockEvaluator(
      (json['schemas'] as List<dynamic>)
          .map((e) =>
              DartBlockEvaluationSchema.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NeoTechEvaluatorToJson(DartBlockEvaluator instance) =>
    <String, dynamic>{
      'schemas': instance.schemas.map((e) => e.toJson()).toList(),
    };

DartBlockEvaluationResult _$NeoTechEvaluationResultFromJson(
        Map<String, dynamic> json) =>
    DartBlockEvaluationResult(
      (json['evaluations'] as List<dynamic>)
          .map((e) => DartBlockEvaluation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NeoTechEvaluationResultToJson(
        DartBlockEvaluationResult instance) =>
    <String, dynamic>{
      'evaluations': instance.evaluations.map((e) => e.toJson()).toList(),
    };

DartBlockFunctionDefinitionEvaluationSchema
    _$NeoTechFunctionDefinitionEvaluationSchemaFromJson(
            Map<String, dynamic> json) =>
        DartBlockFunctionDefinitionEvaluationSchema(
          json['isEnabled'] as bool,
          (json['functionDefinitions'] as List<dynamic>)
              .map(
                  (e) => FunctionDefinition.fromJson(e as Map<String, dynamic>))
              .toList(),
        )..schemaType = $enumDecode(
            _$NeoTechEvaluationSchemaTypeEnumMap, json['schemaType']);

Map<String, dynamic> _$NeoTechFunctionDefinitionEvaluationSchemaToJson(
        DartBlockFunctionDefinitionEvaluationSchema instance) =>
    <String, dynamic>{
      'schemaType': _$NeoTechEvaluationSchemaTypeEnumMap[instance.schemaType]!,
      'isEnabled': instance.isEnabled,
      'functionDefinitions':
          instance.functionDefinitions.map((e) => e.toJson()).toList(),
    };

const _$NeoTechEvaluationSchemaTypeEnumMap = {
  DartBlockEvaluationSchemaType.functionDefinition: 'functionDefinition',
  DartBlockEvaluationSchemaType.functionOutput: 'functionOutput',
  DartBlockEvaluationSchemaType.script: 'script',
  DartBlockEvaluationSchemaType.variableCount: 'variableCount',
  DartBlockEvaluationSchemaType.environment: 'environment',
  DartBlockEvaluationSchemaType.print: 'print',
};

DartBlockFunctionOutputEvaluationSchema
    _$NeoTechFunctionOutputEvaluationSchemaFromJson(
            Map<String, dynamic> json) =>
        DartBlockFunctionOutputEvaluationSchema(
          json['isEnabled'] as bool,
          (json['sampleFunctionCalls'] as List<dynamic>)
              .map((e) =>
                  FunctionCallStatement.fromJson(e as Map<String, dynamic>))
              .toList(),
        )..schemaType = $enumDecode(
            _$NeoTechEvaluationSchemaTypeEnumMap, json['schemaType']);

Map<String, dynamic> _$NeoTechFunctionOutputEvaluationSchemaToJson(
        DartBlockFunctionOutputEvaluationSchema instance) =>
    <String, dynamic>{
      'schemaType': _$NeoTechEvaluationSchemaTypeEnumMap[instance.schemaType]!,
      'isEnabled': instance.isEnabled,
      'sampleFunctionCalls':
          instance.sampleFunctionCalls.map((e) => e.toJson()).toList(),
    };

DartBlockScriptEvaluationSchema _$NeoTechScriptEvaluationSchemaFromJson(
        Map<String, dynamic> json) =>
    DartBlockScriptEvaluationSchema(
      json['isEnabled'] as bool,
      (json['similarityThreshold'] as num).toDouble(),
    )..schemaType =
        $enumDecode(_$NeoTechEvaluationSchemaTypeEnumMap, json['schemaType']);

Map<String, dynamic> _$NeoTechScriptEvaluationSchemaToJson(
        DartBlockScriptEvaluationSchema instance) =>
    <String, dynamic>{
      'schemaType': _$NeoTechEvaluationSchemaTypeEnumMap[instance.schemaType]!,
      'isEnabled': instance.isEnabled,
      'similarityThreshold': instance.similarityThreshold,
    };

DartBlockVariableCountEvaluationSchema
    _$NeoTechVariableCountEvaluationSchemaFromJson(Map<String, dynamic> json) =>
        DartBlockVariableCountEvaluationSchema(
          json['isEnabled'] as bool,
          json['ignoreVariablesStartingWithUnderscore'] as bool,
        )..schemaType = $enumDecode(
            _$NeoTechEvaluationSchemaTypeEnumMap, json['schemaType']);

Map<String, dynamic> _$NeoTechVariableCountEvaluationSchemaToJson(
        DartBlockVariableCountEvaluationSchema instance) =>
    <String, dynamic>{
      'schemaType': _$NeoTechEvaluationSchemaTypeEnumMap[instance.schemaType]!,
      'isEnabled': instance.isEnabled,
      'ignoreVariablesStartingWithUnderscore':
          instance.ignoreVariablesStartingWithUnderscore,
    };

DartBlockEnvironmentEvaluationSchema
    _$NeoTechEnvironmentEvaluationSchemaFromJson(Map<String, dynamic> json) =>
        DartBlockEnvironmentEvaluationSchema(
          json['isEnabled'] as bool,
          json['ignoreVariablesStartingWithUnderscore'] as bool,
        )..schemaType = $enumDecode(
            _$NeoTechEvaluationSchemaTypeEnumMap, json['schemaType']);

Map<String, dynamic> _$NeoTechEnvironmentEvaluationSchemaToJson(
        DartBlockEnvironmentEvaluationSchema instance) =>
    <String, dynamic>{
      'schemaType': _$NeoTechEvaluationSchemaTypeEnumMap[instance.schemaType]!,
      'isEnabled': instance.isEnabled,
      'ignoreVariablesStartingWithUnderscore':
          instance.ignoreVariablesStartingWithUnderscore,
    };

DartBlockPrintEvaluationSchema _$NeoTechPrintEvaluationSchemaFromJson(
        Map<String, dynamic> json) =>
    DartBlockPrintEvaluationSchema(
      json['isEnabled'] as bool,
      (json['similarityThreshold'] as num).toDouble(),
    )..schemaType =
        $enumDecode(_$NeoTechEvaluationSchemaTypeEnumMap, json['schemaType']);

Map<String, dynamic> _$NeoTechPrintEvaluationSchemaToJson(
        DartBlockPrintEvaluationSchema instance) =>
    <String, dynamic>{
      'schemaType': _$NeoTechEvaluationSchemaTypeEnumMap[instance.schemaType]!,
      'isEnabled': instance.isEnabled,
      'similarityThreshold': instance.similarityThreshold,
    };

DartBlockFunctionDefinitionEvaluation
    _$NeoTechFunctionDefinitionEvaluationFromJson(Map<String, dynamic> json) =>
        DartBlockFunctionDefinitionEvaluation(
          (json['correctFunctionDefinitions'] as List<dynamic>)
              .map(
                  (e) => FunctionDefinition.fromJson(e as Map<String, dynamic>))
              .toList(),
          (json['missingFunctionDefinitions'] as List<dynamic>)
              .map(
                  (e) => FunctionDefinition.fromJson(e as Map<String, dynamic>))
              .toList(),
          (json['wrongFunctionDefinitions'] as List<dynamic>)
              .map((e) => _$recordConvert(
                    e,
                    ($jsonValue) => (
                      FunctionDefinition.fromJson(
                          $jsonValue[r'$1'] as Map<String, dynamic>),
                      FunctionDefinition.fromJson(
                          $jsonValue[r'$2'] as Map<String, dynamic>),
                    ),
                  ))
              .toList(),
          $enumDecode(
              _$NeoTechEvaluationSchemaTypeEnumMap, json['evaluationType']),
          json['isCorrect'] as bool,
          json['neoTechException'] == null
              ? null
              : DartBlockException.fromJson(
                  json['neoTechException'] as Map<String, dynamic>),
        );

Map<String, dynamic> _$NeoTechFunctionDefinitionEvaluationToJson(
        DartBlockFunctionDefinitionEvaluation instance) =>
    <String, dynamic>{
      'evaluationType':
          _$NeoTechEvaluationSchemaTypeEnumMap[instance.evaluationType]!,
      'isCorrect': instance.isCorrect,
      'neoTechException': instance.neoTechException?.toJson(),
      'correctFunctionDefinitions':
          instance.correctFunctionDefinitions.map((e) => e.toJson()).toList(),
      'missingFunctionDefinitions':
          instance.missingFunctionDefinitions.map((e) => e.toJson()).toList(),
      'wrongFunctionDefinitions': instance.wrongFunctionDefinitions
          .map((e) => <String, dynamic>{
                r'$1': e.$1.toJson(),
                r'$2': e.$2.toJson(),
              })
          .toList(),
    };

$Rec _$recordConvert<$Rec>(
  Object? value,
  $Rec Function(Map) convert,
) =>
    convert(value as Map<String, dynamic>);

DartBlockFunctionOutputEvaluation _$NeoTechFunctionOutputEvaluationFromJson(
        Map<String, dynamic> json) =>
    DartBlockFunctionOutputEvaluation(
      (json['correctFunctionCalls'] as List<dynamic>)
          .map((e) => _$recordConvert(
                e,
                ($jsonValue) => (
                  FunctionCallStatement.fromJson(
                      $jsonValue[r'$1'] as Map<String, dynamic>),
                  $jsonValue[r'$2'] as String?,
                ),
              ))
          .toList(),
      (json['wrongFunctionCalls'] as List<dynamic>)
          .map((e) => _$recordConvert(
                e,
                ($jsonValue) => (
                  FunctionCallStatement.fromJson(
                      $jsonValue[r'$1'] as Map<String, dynamic>),
                  $jsonValue[r'$2'] as String?,
                  $jsonValue[r'$3'] as String?,
                  $jsonValue[r'$4'] == null
                      ? null
                      : DartBlockException.fromJson(
                          $jsonValue[r'$4'] as Map<String, dynamic>),
                ),
              ))
          .toList(),
      $enumDecode(_$NeoTechEvaluationSchemaTypeEnumMap, json['evaluationType']),
      json['isCorrect'] as bool,
      json['neoTechException'] == null
          ? null
          : DartBlockException.fromJson(
              json['neoTechException'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NeoTechFunctionOutputEvaluationToJson(
        DartBlockFunctionOutputEvaluation instance) =>
    <String, dynamic>{
      'evaluationType':
          _$NeoTechEvaluationSchemaTypeEnumMap[instance.evaluationType]!,
      'isCorrect': instance.isCorrect,
      'neoTechException': instance.neoTechException?.toJson(),
      'correctFunctionCalls': instance.correctFunctionCalls
          .map((e) => <String, dynamic>{
                r'$1': e.$1.toJson(),
                r'$2': e.$2,
              })
          .toList(),
      'wrongFunctionCalls': instance.wrongFunctionCalls
          .map((e) => <String, dynamic>{
                r'$1': e.$1.toJson(),
                r'$2': e.$2,
                r'$3': e.$3,
                r'$4': e.$4?.toJson(),
              })
          .toList(),
    };

DartBlockScriptEvaluation _$NeoTechScriptEvaluationFromJson(
        Map<String, dynamic> json) =>
    DartBlockScriptEvaluation(
      (json['matchScore'] as num).toDouble(),
      (json['similarityThreshold'] as num).toDouble(),
      json['solutionScript'] as String,
      json['answerScript'] as String,
      $enumDecode(_$NeoTechEvaluationSchemaTypeEnumMap, json['evaluationType']),
      json['isCorrect'] as bool,
      json['neoTechException'] == null
          ? null
          : DartBlockException.fromJson(
              json['neoTechException'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NeoTechScriptEvaluationToJson(
        DartBlockScriptEvaluation instance) =>
    <String, dynamic>{
      'evaluationType':
          _$NeoTechEvaluationSchemaTypeEnumMap[instance.evaluationType]!,
      'isCorrect': instance.isCorrect,
      'neoTechException': instance.neoTechException?.toJson(),
      'matchScore': instance.matchScore,
      'similarityThreshold': instance.similarityThreshold,
      'solutionScript': instance.solutionScript,
      'answerScript': instance.answerScript,
    };

DartBlockVariableCountEvaluation _$NeoTechVariableCountEvaluationFromJson(
        Map<String, dynamic> json) =>
    DartBlockVariableCountEvaluation(
      (json['solutionVariableDefinitions'] as List<dynamic>)
          .map((e) =>
              DartBlockVariableDefinition.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['answerVariableDefinitions'] as List<dynamic>)
          .map((e) =>
              DartBlockVariableDefinition.fromJson(e as Map<String, dynamic>))
          .toList(),
      $enumDecode(_$NeoTechEvaluationSchemaTypeEnumMap, json['evaluationType']),
      json['isCorrect'] as bool,
      json['neoTechException'] == null
          ? null
          : DartBlockException.fromJson(
              json['neoTechException'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NeoTechVariableCountEvaluationToJson(
        DartBlockVariableCountEvaluation instance) =>
    <String, dynamic>{
      'evaluationType':
          _$NeoTechEvaluationSchemaTypeEnumMap[instance.evaluationType]!,
      'isCorrect': instance.isCorrect,
      'neoTechException': instance.neoTechException?.toJson(),
      'solutionVariableDefinitions':
          instance.solutionVariableDefinitions.map((e) => e.toJson()).toList(),
      'answerVariableDefinitions':
          instance.answerVariableDefinitions.map((e) => e.toJson()).toList(),
    };

DartBlockEnvironmentEvaluation _$NeoTechEnvironmentEvaluationFromJson(
        Map<String, dynamic> json) =>
    DartBlockEnvironmentEvaluation(
      (json['missingVariableDefinitions'] as List<dynamic>?)
              ?.map((e) => _$recordConvert(
                    e,
                    ($jsonValue) => (
                      DartBlockVariableDefinition.fromJson(
                          $jsonValue[r'$1'] as Map<String, dynamic>),
                      $jsonValue[r'$2'] as String?,
                    ),
                  ))
              .toList() ??
          [],
      (json['wrongVariableDefinitionTypes'] as List<dynamic>?)
              ?.map((e) => _$recordConvert(
                    e,
                    ($jsonValue) => (
                      DartBlockVariableDefinition.fromJson(
                          $jsonValue[r'$1'] as Map<String, dynamic>),
                      $jsonValue[r'$2'] as String?,
                      $enumDecode(_$NeoTechDataTypeEnumMap, $jsonValue[r'$3']),
                    ),
                  ))
              .toList() ??
          [],
      (json['wrongVariableDefinitionValues'] as List<dynamic>?)
              ?.map((e) => _$recordConvert(
                    e,
                    ($jsonValue) => (
                      DartBlockVariableDefinition.fromJson(
                          $jsonValue[r'$1'] as Map<String, dynamic>),
                      $jsonValue[r'$2'] as String?,
                      $jsonValue[r'$3'] as String?,
                    ),
                  ))
              .toList() ??
          [],
      (json['correctVariableDefinitions'] as List<dynamic>?)
              ?.map((e) => _$recordConvert(
                    e,
                    ($jsonValue) => (
                      DartBlockVariableDefinition.fromJson(
                          $jsonValue[r'$1'] as Map<String, dynamic>),
                      $jsonValue[r'$2'] as String?,
                    ),
                  ))
              .toList() ??
          [],
      $enumDecode(_$NeoTechEvaluationSchemaTypeEnumMap, json['evaluationType']),
      json['isCorrect'] as bool,
      json['neoTechException'] == null
          ? null
          : DartBlockException.fromJson(
              json['neoTechException'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NeoTechEnvironmentEvaluationToJson(
        DartBlockEnvironmentEvaluation instance) =>
    <String, dynamic>{
      'evaluationType':
          _$NeoTechEvaluationSchemaTypeEnumMap[instance.evaluationType]!,
      'isCorrect': instance.isCorrect,
      'neoTechException': instance.neoTechException?.toJson(),
      'missingVariableDefinitions': instance.missingVariableDefinitions
          .map((e) => <String, dynamic>{
                r'$1': e.$1.toJson(),
                r'$2': e.$2,
              })
          .toList(),
      'wrongVariableDefinitionTypes': instance.wrongVariableDefinitionTypes
          .map((e) => <String, dynamic>{
                r'$1': e.$1.toJson(),
                r'$2': e.$2,
                r'$3': _$NeoTechDataTypeEnumMap[e.$3]!,
              })
          .toList(),
      'wrongVariableDefinitionValues': instance.wrongVariableDefinitionValues
          .map((e) => <String, dynamic>{
                r'$1': e.$1.toJson(),
                r'$2': e.$2,
                r'$3': e.$3,
              })
          .toList(),
      'correctVariableDefinitions': instance.correctVariableDefinitions
          .map((e) => <String, dynamic>{
                r'$1': e.$1.toJson(),
                r'$2': e.$2,
              })
          .toList(),
    };

const _$NeoTechDataTypeEnumMap = {
  DartBlockDataType.integerType: 'integerType',
  DartBlockDataType.doubleType: 'doubleType',
  DartBlockDataType.booleanType: 'booleanType',
  DartBlockDataType.stringType: 'stringType',
};

DartBlockPrintEvaluation _$NeoTechPrintEvaluationFromJson(
        Map<String, dynamic> json) =>
    DartBlockPrintEvaluation(
      (json['similarityThreshold'] as num).toDouble(),
      (json['printEvaluations'] as List<dynamic>)
          .map((e) => _$recordConvert(
                e,
                ($jsonValue) => (
                  $jsonValue[r'$1'] as String,
                  $jsonValue[r'$2'] as String?,
                  $enumDecode(
                      _$NeoTechPrintEvaluationTypeEnumMap, $jsonValue[r'$3']),
                  ($jsonValue[r'$4'] as num?)?.toDouble(),
                ),
              ))
          .toList(),
      $enumDecode(_$NeoTechEvaluationSchemaTypeEnumMap, json['evaluationType']),
      json['isCorrect'] as bool,
      json['neoTechException'] == null
          ? null
          : DartBlockException.fromJson(
              json['neoTechException'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NeoTechPrintEvaluationToJson(
        DartBlockPrintEvaluation instance) =>
    <String, dynamic>{
      'evaluationType':
          _$NeoTechEvaluationSchemaTypeEnumMap[instance.evaluationType]!,
      'isCorrect': instance.isCorrect,
      'neoTechException': instance.neoTechException?.toJson(),
      'similarityThreshold': instance.similarityThreshold,
      'printEvaluations': instance.printEvaluations
          .map((e) => <String, dynamic>{
                r'$1': e.$1,
                r'$2': e.$2,
                r'$3': _$NeoTechPrintEvaluationTypeEnumMap[e.$3]!,
                r'$4': e.$4,
              })
          .toList(),
    };

const _$NeoTechPrintEvaluationTypeEnumMap = {
  DartBlockPrintEvaluationType.correct: 'correct',
  DartBlockPrintEvaluationType.wrong: 'wrong',
  DartBlockPrintEvaluationType.missing: 'missing',
};
