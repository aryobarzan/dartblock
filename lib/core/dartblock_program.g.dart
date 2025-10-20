// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dartblock_program.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DartBlockProgram _$DartBlockProgramFromJson(Map<String, dynamic> json) =>
    DartBlockProgram(
      $enumDecode(_$DartBlockTypedLanguageEnumMap, json['mainLanguage']),
      DartBlockFunction.fromJson(json['mainFunction'] as Map<String, dynamic>),
      (json['customFunctions'] as List<dynamic>)
          .map((e) => DartBlockFunction.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['version'] as num).toInt(),
    );

Map<String, dynamic> _$DartBlockProgramToJson(
  DartBlockProgram instance,
) => <String, dynamic>{
  'mainLanguage': _$DartBlockTypedLanguageEnumMap[instance.mainLanguage]!,
  'mainFunction': instance.mainFunction.toJson(),
  'customFunctions': instance.customFunctions.map((e) => e.toJson()).toList(),
  'version': instance.version,
};

const _$DartBlockTypedLanguageEnumMap = {DartBlockTypedLanguage.java: 'java'};
