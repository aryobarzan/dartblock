// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dartblock_program.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DartBlockProgram _$NeoTechCoreFromJson(Map<String, dynamic> json) =>
    DartBlockProgram(
      $enumDecode(_$NeoTechLanguageEnumMap, json['mainLanguage']),
      DartBlockFunction.fromJson(json['mainFunction'] as Map<String, dynamic>),
      (json['customFunctions'] as List<dynamic>)
          .map((e) => DartBlockFunction.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['version'] as num).toInt(),
    );

Map<String, dynamic> _$NeoTechCoreToJson(DartBlockProgram instance) =>
    <String, dynamic>{
      'mainLanguage': _$NeoTechLanguageEnumMap[instance.mainLanguage]!,
      'mainFunction': instance.mainFunction.toJson(),
      'customFunctions':
          instance.customFunctions.map((e) => e.toJson()).toList(),
      'version': instance.version,
    };

const _$NeoTechLanguageEnumMap = {
  DartBlockTypedLanguage.java: 'java',
};
