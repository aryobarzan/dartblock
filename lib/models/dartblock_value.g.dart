// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dartblock_value.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DartBlockVariableDefinition _$VariableDefinitionFromJson(
        Map<String, dynamic> json) =>
    DartBlockVariableDefinition(
      json['name'] as String,
      $enumDecode(_$NeoTechDataTypeEnumMap, json['dataType']),
    );

Map<String, dynamic> _$VariableDefinitionToJson(
        DartBlockVariableDefinition instance) =>
    <String, dynamic>{
      'name': instance.name,
      'dataType': _$NeoTechDataTypeEnumMap[instance.dataType]!,
    };

const _$NeoTechDataTypeEnumMap = {
  DartBlockDataType.integerType: 'integerType',
  DartBlockDataType.doubleType: 'doubleType',
  DartBlockDataType.booleanType: 'booleanType',
  DartBlockDataType.stringType: 'stringType',
};

DartBlockVariable _$NeoVariableFromJson(Map<String, dynamic> json) =>
    DartBlockVariable(
      json['name'] as String,
      $enumDecode(_$DynamicValueTypeEnumMap, json['dynamicValueType']),
      $enumDecode(_$NeoValueTypeEnumMap, json['neoValueType']),
    );

Map<String, dynamic> _$NeoVariableToJson(DartBlockVariable instance) =>
    <String, dynamic>{
      'neoValueType': _$NeoValueTypeEnumMap[instance.valueType]!,
      'dynamicValueType': _$DynamicValueTypeEnumMap[instance.dynamicValueType]!,
      'name': instance.name,
    };

const _$DynamicValueTypeEnumMap = {
  DartBlockDynamicValueType.variable: 'variable',
  DartBlockDynamicValueType.functionCall: 'functionCall',
};

const _$NeoValueTypeEnumMap = {
  DartBlockValueType.dynamicValue: 'dynamicValue',
  DartBlockValueType.stringValue: 'stringValue',
  DartBlockValueType.concatenationValue: 'concatenationValue',
  DartBlockValueType.expressionValue: 'expressionValue',
};

DartBlockFunctionCallValue _$FunctionCallValueFromJson(
        Map<String, dynamic> json) =>
    DartBlockFunctionCallValue(
      FunctionCallStatement.fromJson(
          json['customFunctionCall'] as Map<String, dynamic>),
      $enumDecode(_$DynamicValueTypeEnumMap, json['dynamicValueType']),
      $enumDecode(_$NeoValueTypeEnumMap, json['neoValueType']),
    );

Map<String, dynamic> _$FunctionCallValueToJson(
        DartBlockFunctionCallValue instance) =>
    <String, dynamic>{
      'neoValueType': _$NeoValueTypeEnumMap[instance.valueType]!,
      'dynamicValueType': _$DynamicValueTypeEnumMap[instance.dynamicValueType]!,
      'customFunctionCall': instance.customFunctionCall.toJson(),
    };

DartBlockStringValue _$StringValueFromJson(Map<String, dynamic> json) =>
    DartBlockStringValue(
      json['value'] as String,
      $enumDecode(_$NeoValueTypeEnumMap, json['neoValueType']),
    );

Map<String, dynamic> _$StringValueToJson(DartBlockStringValue instance) =>
    <String, dynamic>{
      'neoValueType': _$NeoValueTypeEnumMap[instance.valueType]!,
      'value': instance.value,
    };

DartBlockConcatenationValue _$ConcatenationValueFromJson(
        Map<String, dynamic> json) =>
    DartBlockConcatenationValue(
      (json['values'] as List<dynamic>)
          .map((e) =>
              DartBlockValue<dynamic>.fromJson(e as Map<String, dynamic>))
          .toList(),
      $enumDecode(_$NeoValueTypeEnumMap, json['neoValueType']),
    );

Map<String, dynamic> _$ConcatenationValueToJson(
        DartBlockConcatenationValue instance) =>
    <String, dynamic>{
      'neoValueType': _$NeoValueTypeEnumMap[instance.valueType]!,
      'values': instance.values.map((e) => e.toJson()).toList(),
    };

DartBlockAlgebraicExpression _$AlgebraicExpressionFromJson(
        Map<String, dynamic> json) =>
    DartBlockAlgebraicExpression(
      DartBlockValueTreeAlgebraicNode.fromJson(
          json['compositionNode'] as Map<String, dynamic>),
      $enumDecode(_$NeoValueTypeEnumMap, json['neoValueType']),
      $enumDecode(_$ExpressionValueTypeEnumMap, json['expressionValueType']),
    );

Map<String, dynamic> _$AlgebraicExpressionToJson(
        DartBlockAlgebraicExpression instance) =>
    <String, dynamic>{
      'neoValueType': _$NeoValueTypeEnumMap[instance.valueType]!,
      'expressionValueType':
          _$ExpressionValueTypeEnumMap[instance.expressionValueType]!,
      'compositionNode': instance.compositionNode.toJson(),
    };

const _$ExpressionValueTypeEnumMap = {
  DartBlockExpressionValueType.algebraic: 'algebraic',
  DartBlockExpressionValueType.boolean: 'boolean',
};

DartBlockBooleanExpression _$BooleanExpressionFromJson(
        Map<String, dynamic> json) =>
    DartBlockBooleanExpression(
      DartBlockValueTreeBooleanNode.fromJson(
          json['compositionNode'] as Map<String, dynamic>),
      $enumDecode(_$NeoValueTypeEnumMap, json['neoValueType']),
      $enumDecode(_$ExpressionValueTypeEnumMap, json['expressionValueType']),
    );

Map<String, dynamic> _$BooleanExpressionToJson(
        DartBlockBooleanExpression instance) =>
    <String, dynamic>{
      'neoValueType': _$NeoValueTypeEnumMap[instance.valueType]!,
      'expressionValueType':
          _$ExpressionValueTypeEnumMap[instance.expressionValueType]!,
      'compositionNode': instance.compositionNode.toJson(),
    };

DartBlockValueTreeAlgebraicConstantNode _$NeoValueAlgebraicConstantNodeFromJson(
        Map<String, dynamic> json) =>
    DartBlockValueTreeAlgebraicConstantNode(
      json['value'] as num,
      json['hasPendingDot'] as bool,
      $enumDecode(
          _$NeoValueAlgebraicNodeTypeEnumMap, json['neoValueNumericNodeType']),
      $enumDecode(_$NeoValueNodeTypeEnumMap, json['neoValueNodeType']),
      json['nodeKey'] as String,
    );

Map<String, dynamic> _$NeoValueAlgebraicConstantNodeToJson(
        DartBlockValueTreeAlgebraicConstantNode instance) =>
    <String, dynamic>{
      'neoValueNodeType': _$NeoValueNodeTypeEnumMap[instance.neoValueNodeType]!,
      'nodeKey': instance.nodeKey,
      'neoValueNumericNodeType':
          _$NeoValueAlgebraicNodeTypeEnumMap[instance.neoValueNumericNodeType]!,
      'value': instance.value,
      'hasPendingDot': instance.hasPendingDot,
    };

const _$NeoValueAlgebraicNodeTypeEnumMap = {
  DartBlockValueTreeAlgebraicNodeType.constant: 'constant',
  DartBlockValueTreeAlgebraicNodeType.dynamic: 'dynamic',
  DartBlockValueTreeAlgebraicNodeType.algebraicOperator: 'algebraicOperator',
};

const _$NeoValueNodeTypeEnumMap = {
  DartBlockValueTreeNodeType.algebraic: 'algebraic',
  DartBlockValueTreeNodeType.boolean: 'boolean',
};

DartBlockValueTreeAlgebraicDynamicNode _$NeoValueAlgebraicDynamicNodeFromJson(
        Map<String, dynamic> json) =>
    DartBlockValueTreeAlgebraicDynamicNode(
      DartBlockDynamicValue.fromJson(json['value'] as Map<String, dynamic>),
      $enumDecode(
          _$NeoValueAlgebraicNodeTypeEnumMap, json['neoValueNumericNodeType']),
      $enumDecode(_$NeoValueNodeTypeEnumMap, json['neoValueNodeType']),
      json['nodeKey'] as String,
    );

Map<String, dynamic> _$NeoValueAlgebraicDynamicNodeToJson(
        DartBlockValueTreeAlgebraicDynamicNode instance) =>
    <String, dynamic>{
      'neoValueNodeType': _$NeoValueNodeTypeEnumMap[instance.neoValueNodeType]!,
      'nodeKey': instance.nodeKey,
      'neoValueNumericNodeType':
          _$NeoValueAlgebraicNodeTypeEnumMap[instance.neoValueNumericNodeType]!,
      'value': instance.value.toJson(),
    };

DartBlockValueTreeAlgebraicOperatorNode _$NeoValueAlgebraicOperatorNodeFromJson(
        Map<String, dynamic> json) =>
    DartBlockValueTreeAlgebraicOperatorNode(
      json['leftChild'] == null
          ? null
          : DartBlockValueTreeAlgebraicNode.fromJson(
              json['leftChild'] as Map<String, dynamic>),
      $enumDecodeNullable(_$AlgebraicOperatorEnumMap, json['operator']),
      json['rightChild'] == null
          ? null
          : DartBlockValueTreeAlgebraicNode.fromJson(
              json['rightChild'] as Map<String, dynamic>),
      $enumDecode(
          _$NeoValueAlgebraicNodeTypeEnumMap, json['neoValueNumericNodeType']),
      $enumDecode(_$NeoValueNodeTypeEnumMap, json['neoValueNodeType']),
      json['nodeKey'] as String,
    );

Map<String, dynamic> _$NeoValueAlgebraicOperatorNodeToJson(
        DartBlockValueTreeAlgebraicOperatorNode instance) =>
    <String, dynamic>{
      'neoValueNodeType': _$NeoValueNodeTypeEnumMap[instance.neoValueNodeType]!,
      'nodeKey': instance.nodeKey,
      'neoValueNumericNodeType':
          _$NeoValueAlgebraicNodeTypeEnumMap[instance.neoValueNumericNodeType]!,
      'leftChild': instance.leftChild?.toJson(),
      'rightChild': instance.rightChild?.toJson(),
      'operator': _$AlgebraicOperatorEnumMap[instance.operator],
    };

const _$AlgebraicOperatorEnumMap = {
  DartBlockAlgebraicOperator.add: 'add',
  DartBlockAlgebraicOperator.subtract: 'subtract',
  DartBlockAlgebraicOperator.multiply: 'multiply',
  DartBlockAlgebraicOperator.divide: 'divide',
  DartBlockAlgebraicOperator.modulo: 'modulo',
};

DartBlockValueTreeBooleanGenericNumberNode
    _$NeoValueBooleanGenericNumberNodeFromJson(Map<String, dynamic> json) =>
        DartBlockValueTreeBooleanGenericNumberNode(
          $enumDecode(_$NeoValueBooleanGenericNodeTypeEnumMap,
              json['neoValueLogicalGenericNodeType']),
          DartBlockAlgebraicExpression.fromJson(
              json['value'] as Map<String, dynamic>),
          $enumDecode(_$NeoValueBooleanNodeTypeEnumMap,
              json['neoValueLogicalNodeType']),
          $enumDecode(_$NeoValueNodeTypeEnumMap, json['neoValueNodeType']),
          json['nodeKey'] as String,
        );

Map<String, dynamic> _$NeoValueBooleanGenericNumberNodeToJson(
        DartBlockValueTreeBooleanGenericNumberNode instance) =>
    <String, dynamic>{
      'neoValueNodeType': _$NeoValueNodeTypeEnumMap[instance.neoValueNodeType]!,
      'nodeKey': instance.nodeKey,
      'neoValueLogicalNodeType':
          _$NeoValueBooleanNodeTypeEnumMap[instance.neoValueLogicalNodeType]!,
      'neoValueLogicalGenericNodeType': _$NeoValueBooleanGenericNodeTypeEnumMap[
          instance.neoValueLogicalGenericNodeType]!,
      'value': instance.value.toJson(),
    };

const _$NeoValueBooleanGenericNodeTypeEnumMap = {
  DartBlockValueTreeBooleanGenericNodeType.number: 'number',
  DartBlockValueTreeBooleanGenericNodeType.concatenation: 'concatenation',
};

const _$NeoValueBooleanNodeTypeEnumMap = {
  DartBlockValueTreeBooleanNodeType.constant: 'constant',
  DartBlockValueTreeBooleanNodeType.dynamic: 'dynamic',
  DartBlockValueTreeBooleanNodeType.generic: 'generic',
  DartBlockValueTreeBooleanNodeType.booleanOperator: 'booleanOperator',
  DartBlockValueTreeBooleanNodeType.equalityOperator: 'equalityOperator',
  DartBlockValueTreeBooleanNodeType.numericComparisonOperator:
      'numericComparisonOperator',
};

DartBlockValueTreeBooleanGenericConcatenationNode
    _$NeoValueBooleanGenericConcatenationNodeFromJson(
            Map<String, dynamic> json) =>
        DartBlockValueTreeBooleanGenericConcatenationNode(
          $enumDecode(_$NeoValueBooleanGenericNodeTypeEnumMap,
              json['neoValueLogicalGenericNodeType']),
          DartBlockConcatenationValue.fromJson(
              json['value'] as Map<String, dynamic>),
          $enumDecode(_$NeoValueBooleanNodeTypeEnumMap,
              json['neoValueLogicalNodeType']),
          $enumDecode(_$NeoValueNodeTypeEnumMap, json['neoValueNodeType']),
          json['nodeKey'] as String,
        );

Map<String, dynamic> _$NeoValueBooleanGenericConcatenationNodeToJson(
        DartBlockValueTreeBooleanGenericConcatenationNode instance) =>
    <String, dynamic>{
      'neoValueNodeType': _$NeoValueNodeTypeEnumMap[instance.neoValueNodeType]!,
      'nodeKey': instance.nodeKey,
      'neoValueLogicalNodeType':
          _$NeoValueBooleanNodeTypeEnumMap[instance.neoValueLogicalNodeType]!,
      'neoValueLogicalGenericNodeType': _$NeoValueBooleanGenericNodeTypeEnumMap[
          instance.neoValueLogicalGenericNodeType]!,
      'value': instance.value.toJson(),
    };

DartBlockValueTreeBooleanConstantNode _$NeoValueBooleanConstantNodeFromJson(
        Map<String, dynamic> json) =>
    DartBlockValueTreeBooleanConstantNode(
      json['value'] as bool,
      $enumDecode(
          _$NeoValueBooleanNodeTypeEnumMap, json['neoValueLogicalNodeType']),
      $enumDecode(_$NeoValueNodeTypeEnumMap, json['neoValueNodeType']),
      json['nodeKey'] as String,
    );

Map<String, dynamic> _$NeoValueBooleanConstantNodeToJson(
        DartBlockValueTreeBooleanConstantNode instance) =>
    <String, dynamic>{
      'neoValueNodeType': _$NeoValueNodeTypeEnumMap[instance.neoValueNodeType]!,
      'nodeKey': instance.nodeKey,
      'neoValueLogicalNodeType':
          _$NeoValueBooleanNodeTypeEnumMap[instance.neoValueLogicalNodeType]!,
      'value': instance.value,
    };

DartBlockValueTreeBooleanDynamicNode _$NeoValueBooleanDynamicNodeFromJson(
        Map<String, dynamic> json) =>
    DartBlockValueTreeBooleanDynamicNode(
      DartBlockDynamicValue.fromJson(json['value'] as Map<String, dynamic>),
      $enumDecode(
          _$NeoValueBooleanNodeTypeEnumMap, json['neoValueLogicalNodeType']),
      $enumDecode(_$NeoValueNodeTypeEnumMap, json['neoValueNodeType']),
      json['nodeKey'] as String,
    );

Map<String, dynamic> _$NeoValueBooleanDynamicNodeToJson(
        DartBlockValueTreeBooleanDynamicNode instance) =>
    <String, dynamic>{
      'neoValueNodeType': _$NeoValueNodeTypeEnumMap[instance.neoValueNodeType]!,
      'nodeKey': instance.nodeKey,
      'neoValueLogicalNodeType':
          _$NeoValueBooleanNodeTypeEnumMap[instance.neoValueLogicalNodeType]!,
      'value': instance.value.toJson(),
    };

DartBlockValueTreeBooleanOperatorNode _$NeoValueBooleanOperatorNodeFromJson(
        Map<String, dynamic> json) =>
    DartBlockValueTreeBooleanOperatorNode(
      json['leftChild'] == null
          ? null
          : DartBlockValueTreeBooleanNode.fromJson(
              json['leftChild'] as Map<String, dynamic>),
      $enumDecodeNullable(_$BooleanOperatorEnumMap, json['operator']),
      json['rightChild'] == null
          ? null
          : DartBlockValueTreeBooleanNode.fromJson(
              json['rightChild'] as Map<String, dynamic>),
      $enumDecode(
          _$NeoValueBooleanNodeTypeEnumMap, json['neoValueLogicalNodeType']),
      $enumDecode(_$NeoValueNodeTypeEnumMap, json['neoValueNodeType']),
      json['nodeKey'] as String,
    );

Map<String, dynamic> _$NeoValueBooleanOperatorNodeToJson(
        DartBlockValueTreeBooleanOperatorNode instance) =>
    <String, dynamic>{
      'neoValueNodeType': _$NeoValueNodeTypeEnumMap[instance.neoValueNodeType]!,
      'nodeKey': instance.nodeKey,
      'neoValueLogicalNodeType':
          _$NeoValueBooleanNodeTypeEnumMap[instance.neoValueLogicalNodeType]!,
      'leftChild': instance.leftChild?.toJson(),
      'rightChild': instance.rightChild?.toJson(),
      'operator': _$BooleanOperatorEnumMap[instance.operator],
    };

const _$BooleanOperatorEnumMap = {
  DartBlockBooleanOperator.and: 'and',
  DartBlockBooleanOperator.or: 'or',
};

DartBlockValueTreeBooleanEqualityOperatorNode
    _$NeoValueBooleanEqualityOperatorNodeFromJson(Map<String, dynamic> json) =>
        DartBlockValueTreeBooleanEqualityOperatorNode(
          json['leftChild'] == null
              ? null
              : DartBlockValueTreeBooleanNode.fromJson(
                  json['leftChild'] as Map<String, dynamic>),
          $enumDecodeNullable(_$EqualityOperatorEnumMap, json['operator']),
          json['rightChild'] == null
              ? null
              : DartBlockValueTreeBooleanNode.fromJson(
                  json['rightChild'] as Map<String, dynamic>),
          $enumDecode(_$NeoValueBooleanNodeTypeEnumMap,
              json['neoValueLogicalNodeType']),
          $enumDecode(_$NeoValueNodeTypeEnumMap, json['neoValueNodeType']),
          json['nodeKey'] as String,
        );

Map<String, dynamic> _$NeoValueBooleanEqualityOperatorNodeToJson(
        DartBlockValueTreeBooleanEqualityOperatorNode instance) =>
    <String, dynamic>{
      'neoValueNodeType': _$NeoValueNodeTypeEnumMap[instance.neoValueNodeType]!,
      'nodeKey': instance.nodeKey,
      'neoValueLogicalNodeType':
          _$NeoValueBooleanNodeTypeEnumMap[instance.neoValueLogicalNodeType]!,
      'leftChild': instance.leftChild?.toJson(),
      'rightChild': instance.rightChild?.toJson(),
      'operator': _$EqualityOperatorEnumMap[instance.operator],
    };

const _$EqualityOperatorEnumMap = {
  DartBlockEqualityOperator.equal: 'equal',
  DartBlockEqualityOperator.notEqual: 'notEqual',
};

DartBlockValueTreeBooleanNumberComparisonOperatorNode
    _$NeoValueBooleanNumberComparisonOperatorNodeFromJson(
            Map<String, dynamic> json) =>
        DartBlockValueTreeBooleanNumberComparisonOperatorNode(
          json['leftChild'] == null
              ? null
              : DartBlockValueTreeBooleanGenericNumberNode.fromJson(
                  json['leftChild'] as Map<String, dynamic>),
          $enumDecodeNullable(
              _$NumberComparisonOperatorEnumMap, json['operator']),
          json['rightChild'] == null
              ? null
              : DartBlockValueTreeBooleanGenericNumberNode.fromJson(
                  json['rightChild'] as Map<String, dynamic>),
          $enumDecode(_$NeoValueBooleanNodeTypeEnumMap,
              json['neoValueLogicalNodeType']),
          $enumDecode(_$NeoValueNodeTypeEnumMap, json['neoValueNodeType']),
          json['nodeKey'] as String,
        );

Map<String, dynamic> _$NeoValueBooleanNumberComparisonOperatorNodeToJson(
        DartBlockValueTreeBooleanNumberComparisonOperatorNode instance) =>
    <String, dynamic>{
      'neoValueNodeType': _$NeoValueNodeTypeEnumMap[instance.neoValueNodeType]!,
      'nodeKey': instance.nodeKey,
      'neoValueLogicalNodeType':
          _$NeoValueBooleanNodeTypeEnumMap[instance.neoValueLogicalNodeType]!,
      'leftChild': instance.leftChild?.toJson(),
      'rightChild': instance.rightChild?.toJson(),
      'operator': _$NumberComparisonOperatorEnumMap[instance.operator],
    };

const _$NumberComparisonOperatorEnumMap = {
  DartBlockNumberComparisonOperator.greater: 'greater',
  DartBlockNumberComparisonOperator.greaterOrEqual: 'greaterOrEqual',
  DartBlockNumberComparisonOperator.equal: 'equal',
  DartBlockNumberComparisonOperator.notEqual: 'notEqual',
  DartBlockNumberComparisonOperator.less: 'less',
  DartBlockNumberComparisonOperator.lessOrEqual: 'lessOrEqual',
};
