// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evaluator.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DartBlockEvaluator _$DartBlockEvaluatorFromJson(Map<String, dynamic> json) =>
    DartBlockEvaluator(
      (json['schemas'] as List<dynamic>)
          .map(
            (e) =>
                DartBlockEvaluationSchema.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$DartBlockEvaluatorToJson(DartBlockEvaluator instance) =>
    <String, dynamic>{
      'schemas': instance.schemas.map((e) => e.toJson()).toList(),
    };

DartBlockEvaluationResult _$DartBlockEvaluationResultFromJson(
  Map<String, dynamic> json,
) => DartBlockEvaluationResult(
  (json['evaluations'] as List<dynamic>)
      .map((e) => DartBlockEvaluation.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DartBlockEvaluationResultToJson(
  DartBlockEvaluationResult instance,
) => <String, dynamic>{
  'evaluations': instance.evaluations.map((e) => e.toJson()).toList(),
};

DartBlockFunctionDefinitionEvaluationSchema
_$DartBlockFunctionDefinitionEvaluationSchemaFromJson(
  Map<String, dynamic> json,
) =>
    DartBlockFunctionDefinitionEvaluationSchema(
        json['isEnabled'] as bool,
        (json['functionDefinitions'] as List<dynamic>)
            .map((e) => FunctionDefinition.fromJson(e as Map<String, dynamic>))
            .toList(),
      )
      ..schemaType = $enumDecode(
        _$DartBlockEvaluationSchemaTypeEnumMap,
        json['schemaType'],
      );

Map<String, dynamic> _$DartBlockFunctionDefinitionEvaluationSchemaToJson(
  DartBlockFunctionDefinitionEvaluationSchema instance,
) => <String, dynamic>{
  'schemaType': _$DartBlockEvaluationSchemaTypeEnumMap[instance.schemaType]!,
  'isEnabled': instance.isEnabled,
  'functionDefinitions': instance.functionDefinitions
      .map((e) => e.toJson())
      .toList(),
};

const _$DartBlockEvaluationSchemaTypeEnumMap = {
  DartBlockEvaluationSchemaType.functionDefinition: 'functionDefinition',
  DartBlockEvaluationSchemaType.functionOutput: 'functionOutput',
  DartBlockEvaluationSchemaType.script: 'script',
  DartBlockEvaluationSchemaType.variableCount: 'variableCount',
  DartBlockEvaluationSchemaType.environment: 'environment',
  DartBlockEvaluationSchemaType.print: 'print',
};

DartBlockFunctionOutputEvaluationSchema
_$DartBlockFunctionOutputEvaluationSchemaFromJson(Map<String, dynamic> json) =>
    DartBlockFunctionOutputEvaluationSchema(
        json['isEnabled'] as bool,
        (json['sampleFunctionCalls'] as List<dynamic>)
            .map(
              (e) => FunctionCallStatement.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      )
      ..schemaType = $enumDecode(
        _$DartBlockEvaluationSchemaTypeEnumMap,
        json['schemaType'],
      );

Map<String, dynamic> _$DartBlockFunctionOutputEvaluationSchemaToJson(
  DartBlockFunctionOutputEvaluationSchema instance,
) => <String, dynamic>{
  'schemaType': _$DartBlockEvaluationSchemaTypeEnumMap[instance.schemaType]!,
  'isEnabled': instance.isEnabled,
  'sampleFunctionCalls': instance.sampleFunctionCalls
      .map((e) => e.toJson())
      .toList(),
};

DartBlockScriptEvaluationSchema _$DartBlockScriptEvaluationSchemaFromJson(
  Map<String, dynamic> json,
) =>
    DartBlockScriptEvaluationSchema(
        json['isEnabled'] as bool,
        (json['similarityThreshold'] as num).toDouble(),
      )
      ..schemaType = $enumDecode(
        _$DartBlockEvaluationSchemaTypeEnumMap,
        json['schemaType'],
      );

Map<String, dynamic> _$DartBlockScriptEvaluationSchemaToJson(
  DartBlockScriptEvaluationSchema instance,
) => <String, dynamic>{
  'schemaType': _$DartBlockEvaluationSchemaTypeEnumMap[instance.schemaType]!,
  'isEnabled': instance.isEnabled,
  'similarityThreshold': instance.similarityThreshold,
};

DartBlockVariableCountEvaluationSchema
_$DartBlockVariableCountEvaluationSchemaFromJson(Map<String, dynamic> json) =>
    DartBlockVariableCountEvaluationSchema(
        json['isEnabled'] as bool,
        json['ignoreVariablesStartingWithUnderscore'] as bool,
      )
      ..schemaType = $enumDecode(
        _$DartBlockEvaluationSchemaTypeEnumMap,
        json['schemaType'],
      );

Map<String, dynamic> _$DartBlockVariableCountEvaluationSchemaToJson(
  DartBlockVariableCountEvaluationSchema instance,
) => <String, dynamic>{
  'schemaType': _$DartBlockEvaluationSchemaTypeEnumMap[instance.schemaType]!,
  'isEnabled': instance.isEnabled,
  'ignoreVariablesStartingWithUnderscore':
      instance.ignoreVariablesStartingWithUnderscore,
};

DartBlockEnvironmentEvaluationSchema
_$DartBlockEnvironmentEvaluationSchemaFromJson(Map<String, dynamic> json) =>
    DartBlockEnvironmentEvaluationSchema(
        json['isEnabled'] as bool,
        json['ignoreVariablesStartingWithUnderscore'] as bool,
      )
      ..schemaType = $enumDecode(
        _$DartBlockEvaluationSchemaTypeEnumMap,
        json['schemaType'],
      );

Map<String, dynamic> _$DartBlockEnvironmentEvaluationSchemaToJson(
  DartBlockEnvironmentEvaluationSchema instance,
) => <String, dynamic>{
  'schemaType': _$DartBlockEvaluationSchemaTypeEnumMap[instance.schemaType]!,
  'isEnabled': instance.isEnabled,
  'ignoreVariablesStartingWithUnderscore':
      instance.ignoreVariablesStartingWithUnderscore,
};

DartBlockPrintEvaluationSchema _$DartBlockPrintEvaluationSchemaFromJson(
  Map<String, dynamic> json,
) =>
    DartBlockPrintEvaluationSchema(
        json['isEnabled'] as bool,
        (json['similarityThreshold'] as num).toDouble(),
      )
      ..schemaType = $enumDecode(
        _$DartBlockEvaluationSchemaTypeEnumMap,
        json['schemaType'],
      );

Map<String, dynamic> _$DartBlockPrintEvaluationSchemaToJson(
  DartBlockPrintEvaluationSchema instance,
) => <String, dynamic>{
  'schemaType': _$DartBlockEvaluationSchemaTypeEnumMap[instance.schemaType]!,
  'isEnabled': instance.isEnabled,
  'similarityThreshold': instance.similarityThreshold,
};

DartBlockFunctionDefinitionEvaluation
_$DartBlockFunctionDefinitionEvaluationFromJson(Map<String, dynamic> json) =>
    DartBlockFunctionDefinitionEvaluation(
      (json['correctFunctionDefinitions'] as List<dynamic>)
          .map((e) => FunctionDefinition.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['missingFunctionDefinitions'] as List<dynamic>)
          .map((e) => FunctionDefinition.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['wrongFunctionDefinitions'] as List<dynamic>)
          .map(
            (e) => _$recordConvert(
              e,
              ($jsonValue) => (
                FunctionDefinition.fromJson(
                  $jsonValue[r'$1'] as Map<String, dynamic>,
                ),
                FunctionDefinition.fromJson(
                  $jsonValue[r'$2'] as Map<String, dynamic>,
                ),
              ),
            ),
          )
          .toList(),
      $enumDecode(
        _$DartBlockEvaluationSchemaTypeEnumMap,
        json['evaluationType'],
      ),
      json['isCorrect'] as bool,
      json['neoTechException'] == null
          ? null
          : DartBlockException.fromJson(
              json['neoTechException'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$DartBlockFunctionDefinitionEvaluationToJson(
  DartBlockFunctionDefinitionEvaluation instance,
) => <String, dynamic>{
  'evaluationType':
      _$DartBlockEvaluationSchemaTypeEnumMap[instance.evaluationType]!,
  'isCorrect': instance.isCorrect,
  'neoTechException': instance.dartBlockException?.toJson(),
  'correctFunctionDefinitions': instance.correctFunctionDefinitions
      .map((e) => e.toJson())
      .toList(),
  'missingFunctionDefinitions': instance.missingFunctionDefinitions
      .map((e) => e.toJson())
      .toList(),
  'wrongFunctionDefinitions': instance.wrongFunctionDefinitions
      .map((e) => <String, dynamic>{r'$1': e.$1.toJson(), r'$2': e.$2.toJson()})
      .toList(),
};

$Rec _$recordConvert<$Rec>(Object? value, $Rec Function(Map) convert) =>
    convert(value as Map<String, dynamic>);

DartBlockFunctionOutputEvaluation _$DartBlockFunctionOutputEvaluationFromJson(
  Map<String, dynamic> json,
) => DartBlockFunctionOutputEvaluation(
  (json['correctFunctionCalls'] as List<dynamic>)
      .map(
        (e) => _$recordConvert(
          e,
          ($jsonValue) => (
            FunctionCallStatement.fromJson(
              $jsonValue[r'$1'] as Map<String, dynamic>,
            ),
            $jsonValue[r'$2'] as String?,
          ),
        ),
      )
      .toList(),
  (json['wrongFunctionCalls'] as List<dynamic>)
      .map(
        (e) => _$recordConvert(
          e,
          ($jsonValue) => (
            FunctionCallStatement.fromJson(
              $jsonValue[r'$1'] as Map<String, dynamic>,
            ),
            $jsonValue[r'$2'] as String?,
            $jsonValue[r'$3'] as String?,
            $jsonValue[r'$4'] == null
                ? null
                : DartBlockException.fromJson(
                    $jsonValue[r'$4'] as Map<String, dynamic>,
                  ),
          ),
        ),
      )
      .toList(),
  $enumDecode(_$DartBlockEvaluationSchemaTypeEnumMap, json['evaluationType']),
  json['isCorrect'] as bool,
  json['neoTechException'] == null
      ? null
      : DartBlockException.fromJson(
          json['neoTechException'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$DartBlockFunctionOutputEvaluationToJson(
  DartBlockFunctionOutputEvaluation instance,
) => <String, dynamic>{
  'evaluationType':
      _$DartBlockEvaluationSchemaTypeEnumMap[instance.evaluationType]!,
  'isCorrect': instance.isCorrect,
  'neoTechException': instance.dartBlockException?.toJson(),
  'correctFunctionCalls': instance.correctFunctionCalls
      .map((e) => <String, dynamic>{r'$1': e.$1.toJson(), r'$2': e.$2})
      .toList(),
  'wrongFunctionCalls': instance.wrongFunctionCalls
      .map(
        (e) => <String, dynamic>{
          r'$1': e.$1.toJson(),
          r'$2': e.$2,
          r'$3': e.$3,
          r'$4': e.$4?.toJson(),
        },
      )
      .toList(),
};

DartBlockScriptEvaluation _$DartBlockScriptEvaluationFromJson(
  Map<String, dynamic> json,
) => DartBlockScriptEvaluation(
  (json['matchScore'] as num).toDouble(),
  (json['similarityThreshold'] as num).toDouble(),
  json['solutionScript'] as String,
  json['answerScript'] as String,
  $enumDecode(_$DartBlockEvaluationSchemaTypeEnumMap, json['evaluationType']),
  json['isCorrect'] as bool,
  json['neoTechException'] == null
      ? null
      : DartBlockException.fromJson(
          json['neoTechException'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$DartBlockScriptEvaluationToJson(
  DartBlockScriptEvaluation instance,
) => <String, dynamic>{
  'evaluationType':
      _$DartBlockEvaluationSchemaTypeEnumMap[instance.evaluationType]!,
  'isCorrect': instance.isCorrect,
  'neoTechException': instance.dartBlockException?.toJson(),
  'matchScore': instance.matchScore,
  'similarityThreshold': instance.similarityThreshold,
  'solutionScript': instance.solutionScript,
  'answerScript': instance.answerScript,
};

DartBlockVariableCountEvaluation _$DartBlockVariableCountEvaluationFromJson(
  Map<String, dynamic> json,
) => DartBlockVariableCountEvaluation(
  (json['solutionVariableDefinitions'] as List<dynamic>)
      .map(
        (e) => DartBlockVariableDefinition.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  (json['answerVariableDefinitions'] as List<dynamic>)
      .map(
        (e) => DartBlockVariableDefinition.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  $enumDecode(_$DartBlockEvaluationSchemaTypeEnumMap, json['evaluationType']),
  json['isCorrect'] as bool,
  json['neoTechException'] == null
      ? null
      : DartBlockException.fromJson(
          json['neoTechException'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$DartBlockVariableCountEvaluationToJson(
  DartBlockVariableCountEvaluation instance,
) => <String, dynamic>{
  'evaluationType':
      _$DartBlockEvaluationSchemaTypeEnumMap[instance.evaluationType]!,
  'isCorrect': instance.isCorrect,
  'neoTechException': instance.dartBlockException?.toJson(),
  'solutionVariableDefinitions': instance.solutionVariableDefinitions
      .map((e) => e.toJson())
      .toList(),
  'answerVariableDefinitions': instance.answerVariableDefinitions
      .map((e) => e.toJson())
      .toList(),
};

DartBlockEnvironmentEvaluation _$DartBlockEnvironmentEvaluationFromJson(
  Map<String, dynamic> json,
) => DartBlockEnvironmentEvaluation(
  (json['missingVariableDefinitions'] as List<dynamic>?)
          ?.map(
            (e) => _$recordConvert(
              e,
              ($jsonValue) => (
                DartBlockVariableDefinition.fromJson(
                  $jsonValue[r'$1'] as Map<String, dynamic>,
                ),
                $jsonValue[r'$2'] as String?,
              ),
            ),
          )
          .toList() ??
      [],
  (json['wrongVariableDefinitionTypes'] as List<dynamic>?)
          ?.map(
            (e) => _$recordConvert(
              e,
              ($jsonValue) => (
                DartBlockVariableDefinition.fromJson(
                  $jsonValue[r'$1'] as Map<String, dynamic>,
                ),
                $jsonValue[r'$2'] as String?,
                $enumDecode(_$DartBlockDataTypeEnumMap, $jsonValue[r'$3']),
              ),
            ),
          )
          .toList() ??
      [],
  (json['wrongVariableDefinitionValues'] as List<dynamic>?)
          ?.map(
            (e) => _$recordConvert(
              e,
              ($jsonValue) => (
                DartBlockVariableDefinition.fromJson(
                  $jsonValue[r'$1'] as Map<String, dynamic>,
                ),
                $jsonValue[r'$2'] as String?,
                $jsonValue[r'$3'] as String?,
              ),
            ),
          )
          .toList() ??
      [],
  (json['correctVariableDefinitions'] as List<dynamic>?)
          ?.map(
            (e) => _$recordConvert(
              e,
              ($jsonValue) => (
                DartBlockVariableDefinition.fromJson(
                  $jsonValue[r'$1'] as Map<String, dynamic>,
                ),
                $jsonValue[r'$2'] as String?,
              ),
            ),
          )
          .toList() ??
      [],
  $enumDecode(_$DartBlockEvaluationSchemaTypeEnumMap, json['evaluationType']),
  json['isCorrect'] as bool,
  json['neoTechException'] == null
      ? null
      : DartBlockException.fromJson(
          json['neoTechException'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$DartBlockEnvironmentEvaluationToJson(
  DartBlockEnvironmentEvaluation instance,
) => <String, dynamic>{
  'evaluationType':
      _$DartBlockEvaluationSchemaTypeEnumMap[instance.evaluationType]!,
  'isCorrect': instance.isCorrect,
  'neoTechException': instance.dartBlockException?.toJson(),
  'missingVariableDefinitions': instance.missingVariableDefinitions
      .map((e) => <String, dynamic>{r'$1': e.$1.toJson(), r'$2': e.$2})
      .toList(),
  'wrongVariableDefinitionTypes': instance.wrongVariableDefinitionTypes
      .map(
        (e) => <String, dynamic>{
          r'$1': e.$1.toJson(),
          r'$2': e.$2,
          r'$3': _$DartBlockDataTypeEnumMap[e.$3]!,
        },
      )
      .toList(),
  'wrongVariableDefinitionValues': instance.wrongVariableDefinitionValues
      .map(
        (e) => <String, dynamic>{
          r'$1': e.$1.toJson(),
          r'$2': e.$2,
          r'$3': e.$3,
        },
      )
      .toList(),
  'correctVariableDefinitions': instance.correctVariableDefinitions
      .map((e) => <String, dynamic>{r'$1': e.$1.toJson(), r'$2': e.$2})
      .toList(),
};

const _$DartBlockDataTypeEnumMap = {
  DartBlockDataType.integerType: 'integerType',
  DartBlockDataType.doubleType: 'doubleType',
  DartBlockDataType.booleanType: 'booleanType',
  DartBlockDataType.stringType: 'stringType',
};

DartBlockPrintEvaluation _$DartBlockPrintEvaluationFromJson(
  Map<String, dynamic> json,
) => DartBlockPrintEvaluation(
  (json['similarityThreshold'] as num).toDouble(),
  (json['printEvaluations'] as List<dynamic>)
      .map(
        (e) => _$recordConvert(
          e,
          ($jsonValue) => (
            $jsonValue[r'$1'] as String,
            $jsonValue[r'$2'] as String?,
            $enumDecode(
              _$DartBlockPrintEvaluationTypeEnumMap,
              $jsonValue[r'$3'],
            ),
            ($jsonValue[r'$4'] as num?)?.toDouble(),
          ),
        ),
      )
      .toList(),
  $enumDecode(_$DartBlockEvaluationSchemaTypeEnumMap, json['evaluationType']),
  json['isCorrect'] as bool,
  json['neoTechException'] == null
      ? null
      : DartBlockException.fromJson(
          json['neoTechException'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$DartBlockPrintEvaluationToJson(
  DartBlockPrintEvaluation instance,
) => <String, dynamic>{
  'evaluationType':
      _$DartBlockEvaluationSchemaTypeEnumMap[instance.evaluationType]!,
  'isCorrect': instance.isCorrect,
  'neoTechException': instance.dartBlockException?.toJson(),
  'similarityThreshold': instance.similarityThreshold,
  'printEvaluations': instance.printEvaluations
      .map(
        (e) => <String, dynamic>{
          r'$1': e.$1,
          r'$2': e.$2,
          r'$3': _$DartBlockPrintEvaluationTypeEnumMap[e.$3]!,
          r'$4': e.$4,
        },
      )
      .toList(),
};

const _$DartBlockPrintEvaluationTypeEnumMap = {
  DartBlockPrintEvaluationType.correct: 'correct',
  DartBlockPrintEvaluationType.wrong: 'wrong',
  DartBlockPrintEvaluationType.missing: 'missing',
};
