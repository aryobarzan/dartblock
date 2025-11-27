// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dartblock_execution_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DartBlockExecutionResult _$DartBlockExecutionResultFromJson(
  Map<String, dynamic> json,
) => DartBlockExecutionResult(
  consoleOutput: (json['consoleOutput'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  environment: json['environment'] as Map<String, dynamic>,
  currentStatementBlockKey: (json['currentStatementBlockKey'] as num).toInt(),
  currentStatement: json['currentStatement'] as Map<String, dynamic>?,
  blockHistory: (json['blockHistory'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  exception: json['exception'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$DartBlockExecutionResultToJson(
  DartBlockExecutionResult instance,
) => <String, dynamic>{
  'consoleOutput': instance.consoleOutput,
  'environment': instance.environment,
  'currentStatementBlockKey': instance.currentStatementBlockKey,
  'currentStatement': instance.currentStatement,
  'blockHistory': instance.blockHistory,
  'exception': instance.exception,
};
