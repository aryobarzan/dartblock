// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatementBlock _$StatementBlockFromJson(Map<String, dynamic> json) =>
    StatementBlock(
      (json['statements'] as List<dynamic>)
          .map((e) => Statement.fromJson(e as Map<String, dynamic>))
          .toList(),
      $enumDecode(_$StatementTypeEnumMap, json['statementType']),
      json['statementId'] as String,
      json['isIsolated'] as bool,
    );

Map<String, dynamic> _$StatementBlockToJson(StatementBlock instance) =>
    <String, dynamic>{
      'statementType': _$StatementTypeEnumMap[instance.statementType]!,
      'statementId': instance.statementId,
      'isIsolated': instance.isIsolated,
      'statements': instance.statements.map((e) => e.toJson()).toList(),
    };

const _$StatementTypeEnumMap = {
  StatementType.statementBlockStatement: 'statementBlockStatement',
  StatementType.printStatement: 'printStatement',
  StatementType.returnStatement: 'returnStatement',
  StatementType.ifElseStatement: 'ifElseStatement',
  StatementType.forLoopStatement: 'forLoopStatement',
  StatementType.whileLoopStatement: 'whileLoopStatement',
  StatementType.variableDeclarationStatement: 'variableDeclarationStatement',
  StatementType.variableAssignmentStatement: 'variableAssignmentStatement',
  StatementType.customFunctionCallStatement: 'customFunctionCallStatement',
  StatementType.breakStatement: 'breakStatement',
  StatementType.continueStatement: 'continueStatement',
};

VariableDeclarationStatement _$VariableDeclarationStatementFromJson(
  Map<String, dynamic> json,
) => VariableDeclarationStatement(
  json['name'] as String,
  $enumDecode(_$DartBlockDataTypeEnumMap, json['dataType']),
  json['value'] == null
      ? null
      : DartBlockValue<dynamic>.fromJson(json['value'] as Map<String, dynamic>),
  $enumDecode(_$StatementTypeEnumMap, json['statementType']),
  json['statementId'] as String,
);

Map<String, dynamic> _$VariableDeclarationStatementToJson(
  VariableDeclarationStatement instance,
) => <String, dynamic>{
  'statementType': _$StatementTypeEnumMap[instance.statementType]!,
  'statementId': instance.statementId,
  'name': instance.name,
  'dataType': _$DartBlockDataTypeEnumMap[instance.dataType]!,
  'value': instance.value?.toJson(),
};

const _$DartBlockDataTypeEnumMap = {
  DartBlockDataType.integerType: 'integerType',
  DartBlockDataType.doubleType: 'doubleType',
  DartBlockDataType.booleanType: 'booleanType',
  DartBlockDataType.stringType: 'stringType',
};

VariableAssignmentStatement _$VariableAssignmentStatementFromJson(
  Map<String, dynamic> json,
) => VariableAssignmentStatement(
  json['name'] as String,
  json['value'] == null
      ? null
      : DartBlockValue<dynamic>.fromJson(json['value'] as Map<String, dynamic>),
  $enumDecode(_$StatementTypeEnumMap, json['statementType']),
  json['statementId'] as String,
);

Map<String, dynamic> _$VariableAssignmentStatementToJson(
  VariableAssignmentStatement instance,
) => <String, dynamic>{
  'statementType': _$StatementTypeEnumMap[instance.statementType]!,
  'statementId': instance.statementId,
  'name': instance.name,
  'value': instance.value?.toJson(),
};

ReturnStatement _$ReturnStatementFromJson(Map<String, dynamic> json) =>
    ReturnStatement(
      $enumDecode(_$DartBlockDataTypeEnumMap, json['dataType']),
      DartBlockValue<dynamic>.fromJson(json['value'] as Map<String, dynamic>),
      $enumDecode(_$StatementTypeEnumMap, json['statementType']),
      json['statementId'] as String,
    );

Map<String, dynamic> _$ReturnStatementToJson(ReturnStatement instance) =>
    <String, dynamic>{
      'statementType': _$StatementTypeEnumMap[instance.statementType]!,
      'statementId': instance.statementId,
      'dataType': _$DartBlockDataTypeEnumMap[instance.dataType]!,
      'value': instance.value.toJson(),
    };

BreakStatement _$BreakStatementFromJson(Map<String, dynamic> json) =>
    BreakStatement(
      $enumDecode(_$StatementTypeEnumMap, json['statementType']),
      json['statementId'] as String,
    );

Map<String, dynamic> _$BreakStatementToJson(BreakStatement instance) =>
    <String, dynamic>{
      'statementType': _$StatementTypeEnumMap[instance.statementType]!,
      'statementId': instance.statementId,
    };

ContinueStatement _$ContinueStatementFromJson(Map<String, dynamic> json) =>
    ContinueStatement(
      $enumDecode(_$StatementTypeEnumMap, json['statementType']),
      json['statementId'] as String,
    );

Map<String, dynamic> _$ContinueStatementToJson(ContinueStatement instance) =>
    <String, dynamic>{
      'statementType': _$StatementTypeEnumMap[instance.statementType]!,
      'statementId': instance.statementId,
    };

IfElseStatement _$IfElseStatementFromJson(
  Map<String, dynamic> json,
) => IfElseStatement(
  DartBlockBooleanExpression.fromJson(
    json['ifCondition'] as Map<String, dynamic>,
  ),
  StatementBlock.fromJson(json['ifThenStatementBlock'] as Map<String, dynamic>),
  (json['elseIfStatementBlocks'] as List<dynamic>)
      .map(
        (e) => _$recordConvert(
          e,
          ($jsonValue) => (
            DartBlockBooleanExpression.fromJson(
              $jsonValue[r'$1'] as Map<String, dynamic>,
            ),
            StatementBlock.fromJson($jsonValue[r'$2'] as Map<String, dynamic>),
          ),
        ),
      )
      .toList(),
  StatementBlock.fromJson(json['elseStatementBlock'] as Map<String, dynamic>),
  $enumDecode(_$StatementTypeEnumMap, json['statementType']),
  json['statementId'] as String,
);

Map<String, dynamic> _$IfElseStatementToJson(
  IfElseStatement instance,
) => <String, dynamic>{
  'statementType': _$StatementTypeEnumMap[instance.statementType]!,
  'statementId': instance.statementId,
  'ifCondition': instance.ifCondition.toJson(),
  'ifThenStatementBlock': instance.ifThenStatementBlock.toJson(),
  'elseIfStatementBlocks': instance.elseIfStatementBlocks
      .map((e) => <String, dynamic>{r'$1': e.$1.toJson(), r'$2': e.$2.toJson()})
      .toList(),
  'elseStatementBlock': instance.elseStatementBlock.toJson(),
};

$Rec _$recordConvert<$Rec>(Object? value, $Rec Function(Map) convert) =>
    convert(value as Map<String, dynamic>);

ForLoopStatement _$ForLoopStatementFromJson(Map<String, dynamic> json) =>
    ForLoopStatement(
      json['initStatement'] == null
          ? null
          : Statement.fromJson(json['initStatement'] as Map<String, dynamic>),
      DartBlockBooleanExpression.fromJson(
        json['condition'] as Map<String, dynamic>,
      ),
      json['postStatement'] == null
          ? null
          : Statement.fromJson(json['postStatement'] as Map<String, dynamic>),
      (json['bodyStatements'] as List<dynamic>)
          .map((e) => Statement.fromJson(e as Map<String, dynamic>))
          .toList(),
      $enumDecode(_$StatementTypeEnumMap, json['statementType']),
      json['statementId'] as String,
      json['isIsolated'] as bool,
    );

Map<String, dynamic> _$ForLoopStatementToJson(ForLoopStatement instance) =>
    <String, dynamic>{
      'statementType': _$StatementTypeEnumMap[instance.statementType]!,
      'statementId': instance.statementId,
      'isIsolated': instance.isIsolated,
      'initStatement': instance.initStatement?.toJson(),
      'condition': instance.condition.toJson(),
      'postStatement': instance.postStatement?.toJson(),
      'bodyStatements': instance.bodyStatements.map((e) => e.toJson()).toList(),
    };

WhileLoopStatement _$WhileLoopStatementFromJson(Map<String, dynamic> json) =>
    WhileLoopStatement(
      json['isDoWhile'] as bool,
      DartBlockBooleanExpression.fromJson(
        json['condition'] as Map<String, dynamic>,
      ),
      (json['bodyStatements'] as List<dynamic>)
          .map((e) => Statement.fromJson(e as Map<String, dynamic>))
          .toList(),
      $enumDecode(_$StatementTypeEnumMap, json['statementType']),
      json['statementId'] as String,
      json['isIsolated'] as bool,
    );

Map<String, dynamic> _$WhileLoopStatementToJson(WhileLoopStatement instance) =>
    <String, dynamic>{
      'statementType': _$StatementTypeEnumMap[instance.statementType]!,
      'statementId': instance.statementId,
      'isIsolated': instance.isIsolated,
      'isDoWhile': instance.isDoWhile,
      'condition': instance.condition.toJson(),
      'bodyStatements': instance.bodyStatements.map((e) => e.toJson()).toList(),
    };

FunctionCallStatement _$FunctionCallStatementFromJson(
  Map<String, dynamic> json,
) => FunctionCallStatement(
  json['customFunctionName'] as String,
  (json['arguments'] as List<dynamic>)
      .map((e) => DartBlockValue<dynamic>.fromJson(e as Map<String, dynamic>))
      .toList(),
  $enumDecode(_$StatementTypeEnumMap, json['statementType']),
  json['statementId'] as String,
  json['isIsolated'] as bool,
);

Map<String, dynamic> _$FunctionCallStatementToJson(
  FunctionCallStatement instance,
) => <String, dynamic>{
  'statementType': _$StatementTypeEnumMap[instance.statementType]!,
  'statementId': instance.statementId,
  'isIsolated': instance.isIsolated,
  'customFunctionName': instance.functionName,
  'arguments': instance.arguments.map((e) => e.toJson()).toList(),
};

PrintStatement _$PrintStatementFromJson(Map<String, dynamic> json) =>
    PrintStatement(
      DartBlockConcatenationValue.fromJson(
        json['value'] as Map<String, dynamic>,
      ),
      $enumDecode(_$StatementTypeEnumMap, json['statementType']),
      json['statementId'] as String,
    );

Map<String, dynamic> _$PrintStatementToJson(PrintStatement instance) =>
    <String, dynamic>{
      'statementType': _$StatementTypeEnumMap[instance.statementType]!,
      'statementId': instance.statementId,
      'value': instance.value.toJson(),
    };
