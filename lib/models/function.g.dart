// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'function.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DartBlockFunction _$DartBlockFunctionFromJson(Map<String, dynamic> json) =>
    DartBlockFunction(
      json['name'] as String,
      $enumDecodeNullable(_$DartBlockDataTypeEnumMap, json['returnType']),
      (json['parameters'] as List<dynamic>)
          .map(
            (e) =>
                DartBlockVariableDefinition.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      (json['statements'] as List<dynamic>)
          .map((e) => Statement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DartBlockFunctionToJson(DartBlockFunction instance) =>
    <String, dynamic>{
      'name': instance.name,
      'returnType': _$DartBlockDataTypeEnumMap[instance.returnType],
      'parameters': instance.parameters.map((e) => e.toJson()).toList(),
      'statements': instance.statements.map((e) => e.toJson()).toList(),
    };

const _$DartBlockDataTypeEnumMap = {
  DartBlockDataType.integerType: 'integerType',
  DartBlockDataType.doubleType: 'doubleType',
  DartBlockDataType.booleanType: 'booleanType',
  DartBlockDataType.stringType: 'stringType',
};

FunctionDefinition _$FunctionDefinitionFromJson(Map<String, dynamic> json) =>
    FunctionDefinition(
      json['name'] as String,
      $enumDecodeNullable(_$DartBlockDataTypeEnumMap, json['returnType']),
      (json['parameters'] as List<dynamic>)
          .map(
            (e) =>
                DartBlockVariableDefinition.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$FunctionDefinitionToJson(FunctionDefinition instance) =>
    <String, dynamic>{
      'name': instance.name,
      'returnType': _$DartBlockDataTypeEnumMap[instance.returnType],
      'parameters': instance.parameters.map((e) => e.toJson()).toList(),
    };
