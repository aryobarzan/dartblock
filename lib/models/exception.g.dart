// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exception.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DartBlockException _$NeoTechExceptionFromJson(Map<String, dynamic> json) =>
    DartBlockException(
      title: json['title'] as String,
      message: json['message'] as String,
      statement: json['statement'] == null
          ? null
          : Statement.fromJson(json['statement'] as Map<String, dynamic>),
    )
      ..internalMessage = json['internalMessage'] as String
      ..isGeneric = json['isGeneric'] as bool;

Map<String, dynamic> _$NeoTechExceptionToJson(DartBlockException instance) =>
    <String, dynamic>{
      'statement': instance.statement?.toJson(),
      'title': instance.title,
      'message': instance.message,
      'internalMessage': instance.internalMessage,
      'isGeneric': instance.isGeneric,
    };
