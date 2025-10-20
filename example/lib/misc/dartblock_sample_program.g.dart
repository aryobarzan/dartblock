// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dartblock_sample_program.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DartBlockSampleProgram _$DartBlockSampleProgramFromJson(
  Map<String, dynamic> json,
) => DartBlockSampleProgram(
  json['title'] as String,
  json['description'] as String,
  (json['index'] as num).toInt(),
  DartBlockProgram.fromJson(json['program'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DartBlockSampleProgramToJson(
  DartBlockSampleProgram instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'index': instance.index,
  'program': instance.program,
};
