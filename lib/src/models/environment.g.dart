// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DartBlockEnvironment _$DartBlockEnvironmentFromJson(
  Map<String, dynamic> json,
) => DartBlockEnvironment(
  (json['key'] as num).toInt(),
  children: (json['children'] as List<dynamic>)
      .map((e) => DartBlockEnvironment.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DartBlockEnvironmentToJson(
  DartBlockEnvironment instance,
) => <String, dynamic>{
  'key': instance.key,
  'children': instance.children.map((e) => e.toJson()).toList(),
};
