// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dartblock_value.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DartBlockVariableDefinition _$DartBlockVariableDefinitionFromJson(
  Map<String, dynamic> json,
) => DartBlockVariableDefinition(
  json['name'] as String,
  $enumDecode(_$DartBlockDataTypeEnumMap, json['dataType']),
);

Map<String, dynamic> _$DartBlockVariableDefinitionToJson(
  DartBlockVariableDefinition instance,
) => <String, dynamic>{
  'name': instance.name,
  'dataType': _$DartBlockDataTypeEnumMap[instance.dataType]!,
};

const _$DartBlockDataTypeEnumMap = {
  DartBlockDataType.integerType: 'integerType',
  DartBlockDataType.doubleType: 'doubleType',
  DartBlockDataType.booleanType: 'booleanType',
  DartBlockDataType.stringType: 'stringType',
};

DartBlockVariable _$DartBlockVariableFromJson(Map<String, dynamic> json) =>
    DartBlockVariable(
      json['name'] as String,
      $enumDecode(_$DartBlockDynamicValueTypeEnumMap, json['dynamicValueType']),
      $enumDecode(_$DartBlockValueTypeEnumMap, json['neoValueType']),
    );

Map<String, dynamic> _$DartBlockVariableToJson(DartBlockVariable instance) =>
    <String, dynamic>{
      'neoValueType': _$DartBlockValueTypeEnumMap[instance.valueType]!,
      'dynamicValueType':
          _$DartBlockDynamicValueTypeEnumMap[instance.dynamicValueType]!,
      'name': instance.name,
    };

const _$DartBlockDynamicValueTypeEnumMap = {
  DartBlockDynamicValueType.variable: 'variable',
  DartBlockDynamicValueType.functionCall: 'functionCall',
};

const _$DartBlockValueTypeEnumMap = {
  DartBlockValueType.dynamicValue: 'dynamicValue',
  DartBlockValueType.stringValue: 'stringValue',
  DartBlockValueType.concatenationValue: 'concatenationValue',
  DartBlockValueType.expressionValue: 'expressionValue',
};

DartBlockFunctionCallValue _$DartBlockFunctionCallValueFromJson(
  Map<String, dynamic> json,
) => DartBlockFunctionCallValue(
  FunctionCallStatement.fromJson(
    json['customFunctionCall'] as Map<String, dynamic>,
  ),
  $enumDecode(_$DartBlockDynamicValueTypeEnumMap, json['dynamicValueType']),
  $enumDecode(_$DartBlockValueTypeEnumMap, json['neoValueType']),
);

Map<String, dynamic> _$DartBlockFunctionCallValueToJson(
  DartBlockFunctionCallValue instance,
) => <String, dynamic>{
  'neoValueType': _$DartBlockValueTypeEnumMap[instance.valueType]!,
  'dynamicValueType':
      _$DartBlockDynamicValueTypeEnumMap[instance.dynamicValueType]!,
  'customFunctionCall': instance.customFunctionCall.toJson(),
};

DartBlockStringValue _$DartBlockStringValueFromJson(
  Map<String, dynamic> json,
) => DartBlockStringValue(
  json['value'] as String,
  $enumDecode(_$DartBlockValueTypeEnumMap, json['neoValueType']),
);

Map<String, dynamic> _$DartBlockStringValueToJson(
  DartBlockStringValue instance,
) => <String, dynamic>{
  'neoValueType': _$DartBlockValueTypeEnumMap[instance.valueType]!,
  'value': instance.value,
};

DartBlockConcatenationValue _$DartBlockConcatenationValueFromJson(
  Map<String, dynamic> json,
) => DartBlockConcatenationValue(
  (json['values'] as List<dynamic>)
      .map((e) => DartBlockValue<dynamic>.fromJson(e as Map<String, dynamic>))
      .toList(),
  $enumDecode(_$DartBlockValueTypeEnumMap, json['neoValueType']),
);

Map<String, dynamic> _$DartBlockConcatenationValueToJson(
  DartBlockConcatenationValue instance,
) => <String, dynamic>{
  'neoValueType': _$DartBlockValueTypeEnumMap[instance.valueType]!,
  'values': instance.values.map((e) => e.toJson()).toList(),
};

DartBlockAlgebraicExpression _$DartBlockAlgebraicExpressionFromJson(
  Map<String, dynamic> json,
) => DartBlockAlgebraicExpression(
  DartBlockValueTreeAlgebraicNode.fromJson(
    json['compositionNode'] as Map<String, dynamic>,
  ),
  $enumDecode(_$DartBlockValueTypeEnumMap, json['neoValueType']),
  $enumDecode(
    _$DartBlockExpressionValueTypeEnumMap,
    json['expressionValueType'],
  ),
);

Map<String, dynamic> _$DartBlockAlgebraicExpressionToJson(
  DartBlockAlgebraicExpression instance,
) => <String, dynamic>{
  'neoValueType': _$DartBlockValueTypeEnumMap[instance.valueType]!,
  'expressionValueType':
      _$DartBlockExpressionValueTypeEnumMap[instance.expressionValueType]!,
  'compositionNode': instance.compositionNode.toJson(),
};

const _$DartBlockExpressionValueTypeEnumMap = {
  DartBlockExpressionValueType.algebraic: 'algebraic',
  DartBlockExpressionValueType.boolean: 'boolean',
};

DartBlockBooleanExpression _$DartBlockBooleanExpressionFromJson(
  Map<String, dynamic> json,
) => DartBlockBooleanExpression(
  DartBlockValueTreeBooleanNode.fromJson(
    json['compositionNode'] as Map<String, dynamic>,
  ),
  $enumDecode(_$DartBlockValueTypeEnumMap, json['neoValueType']),
  $enumDecode(
    _$DartBlockExpressionValueTypeEnumMap,
    json['expressionValueType'],
  ),
);

Map<String, dynamic> _$DartBlockBooleanExpressionToJson(
  DartBlockBooleanExpression instance,
) => <String, dynamic>{
  'neoValueType': _$DartBlockValueTypeEnumMap[instance.valueType]!,
  'expressionValueType':
      _$DartBlockExpressionValueTypeEnumMap[instance.expressionValueType]!,
  'compositionNode': instance.compositionNode.toJson(),
};

DartBlockValueTreeAlgebraicConstantNode
_$DartBlockValueTreeAlgebraicConstantNodeFromJson(Map<String, dynamic> json) =>
    DartBlockValueTreeAlgebraicConstantNode(
      json['value'] as num,
      json['hasPendingDot'] as bool,
      $enumDecode(
        _$DartBlockValueTreeAlgebraicNodeTypeEnumMap,
        json['neoValueNumericNodeType'],
      ),
      $enumDecode(
        _$DartBlockValueTreeNodeTypeEnumMap,
        json['neoValueNodeType'],
      ),
      json['nodeKey'] as String,
    );

Map<String, dynamic> _$DartBlockValueTreeAlgebraicConstantNodeToJson(
  DartBlockValueTreeAlgebraicConstantNode instance,
) => <String, dynamic>{
  'neoValueNodeType': _$DartBlockValueTreeNodeTypeEnumMap[instance.nodeType]!,
  'nodeKey': instance.nodeKey,
  'neoValueNumericNodeType':
      _$DartBlockValueTreeAlgebraicNodeTypeEnumMap[instance.numericNodeType]!,
  'value': instance.value,
  'hasPendingDot': instance.hasPendingDot,
};

const _$DartBlockValueTreeAlgebraicNodeTypeEnumMap = {
  DartBlockValueTreeAlgebraicNodeType.constant: 'constant',
  DartBlockValueTreeAlgebraicNodeType.dynamic: 'dynamic',
  DartBlockValueTreeAlgebraicNodeType.algebraicOperator: 'algebraicOperator',
};

const _$DartBlockValueTreeNodeTypeEnumMap = {
  DartBlockValueTreeNodeType.algebraic: 'algebraic',
  DartBlockValueTreeNodeType.boolean: 'boolean',
};

DartBlockValueTreeAlgebraicDynamicNode
_$DartBlockValueTreeAlgebraicDynamicNodeFromJson(Map<String, dynamic> json) =>
    DartBlockValueTreeAlgebraicDynamicNode(
      DartBlockDynamicValue.fromJson(json['value'] as Map<String, dynamic>),
      $enumDecode(
        _$DartBlockValueTreeAlgebraicNodeTypeEnumMap,
        json['neoValueNumericNodeType'],
      ),
      $enumDecode(
        _$DartBlockValueTreeNodeTypeEnumMap,
        json['neoValueNodeType'],
      ),
      json['nodeKey'] as String,
    );

Map<String, dynamic> _$DartBlockValueTreeAlgebraicDynamicNodeToJson(
  DartBlockValueTreeAlgebraicDynamicNode instance,
) => <String, dynamic>{
  'neoValueNodeType': _$DartBlockValueTreeNodeTypeEnumMap[instance.nodeType]!,
  'nodeKey': instance.nodeKey,
  'neoValueNumericNodeType':
      _$DartBlockValueTreeAlgebraicNodeTypeEnumMap[instance.numericNodeType]!,
  'value': instance.value.toJson(),
};

DartBlockValueTreeAlgebraicOperatorNode
_$DartBlockValueTreeAlgebraicOperatorNodeFromJson(
  Map<String, dynamic> json,
) => DartBlockValueTreeAlgebraicOperatorNode(
  json['leftChild'] == null
      ? null
      : DartBlockValueTreeAlgebraicNode.fromJson(
          json['leftChild'] as Map<String, dynamic>,
        ),
  $enumDecodeNullable(_$DartBlockAlgebraicOperatorEnumMap, json['operator']),
  json['rightChild'] == null
      ? null
      : DartBlockValueTreeAlgebraicNode.fromJson(
          json['rightChild'] as Map<String, dynamic>,
        ),
  $enumDecode(
    _$DartBlockValueTreeAlgebraicNodeTypeEnumMap,
    json['neoValueNumericNodeType'],
  ),
  $enumDecode(_$DartBlockValueTreeNodeTypeEnumMap, json['neoValueNodeType']),
  json['nodeKey'] as String,
);

Map<String, dynamic> _$DartBlockValueTreeAlgebraicOperatorNodeToJson(
  DartBlockValueTreeAlgebraicOperatorNode instance,
) => <String, dynamic>{
  'neoValueNodeType': _$DartBlockValueTreeNodeTypeEnumMap[instance.nodeType]!,
  'nodeKey': instance.nodeKey,
  'neoValueNumericNodeType':
      _$DartBlockValueTreeAlgebraicNodeTypeEnumMap[instance.numericNodeType]!,
  'leftChild': instance.leftChild?.toJson(),
  'rightChild': instance.rightChild?.toJson(),
  'operator': _$DartBlockAlgebraicOperatorEnumMap[instance.operator],
};

const _$DartBlockAlgebraicOperatorEnumMap = {
  DartBlockAlgebraicOperator.add: 'add',
  DartBlockAlgebraicOperator.subtract: 'subtract',
  DartBlockAlgebraicOperator.multiply: 'multiply',
  DartBlockAlgebraicOperator.divide: 'divide',
  DartBlockAlgebraicOperator.modulo: 'modulo',
};

DartBlockValueTreeBooleanGenericNumberNode
_$DartBlockValueTreeBooleanGenericNumberNodeFromJson(
  Map<String, dynamic> json,
) => DartBlockValueTreeBooleanGenericNumberNode(
  $enumDecode(
    _$DartBlockValueTreeBooleanGenericNodeTypeEnumMap,
    json['neoValueLogicalGenericNodeType'],
  ),
  DartBlockAlgebraicExpression.fromJson(json['value'] as Map<String, dynamic>),
  $enumDecode(
    _$DartBlockValueTreeBooleanNodeTypeEnumMap,
    json['neoValueLogicalNodeType'],
  ),
  $enumDecode(_$DartBlockValueTreeNodeTypeEnumMap, json['neoValueNodeType']),
  json['nodeKey'] as String,
);

Map<String, dynamic> _$DartBlockValueTreeBooleanGenericNumberNodeToJson(
  DartBlockValueTreeBooleanGenericNumberNode instance,
) => <String, dynamic>{
  'neoValueNodeType': _$DartBlockValueTreeNodeTypeEnumMap[instance.nodeType]!,
  'nodeKey': instance.nodeKey,
  'neoValueLogicalNodeType':
      _$DartBlockValueTreeBooleanNodeTypeEnumMap[instance.logicalNodeType]!,
  'neoValueLogicalGenericNodeType':
      _$DartBlockValueTreeBooleanGenericNodeTypeEnumMap[instance
          .logicalGenericNodeType]!,
  'value': instance.value.toJson(),
};

const _$DartBlockValueTreeBooleanGenericNodeTypeEnumMap = {
  DartBlockValueTreeBooleanGenericNodeType.number: 'number',
  DartBlockValueTreeBooleanGenericNodeType.concatenation: 'concatenation',
};

const _$DartBlockValueTreeBooleanNodeTypeEnumMap = {
  DartBlockValueTreeBooleanNodeType.constant: 'constant',
  DartBlockValueTreeBooleanNodeType.dynamic: 'dynamic',
  DartBlockValueTreeBooleanNodeType.generic: 'generic',
  DartBlockValueTreeBooleanNodeType.booleanOperator: 'booleanOperator',
  DartBlockValueTreeBooleanNodeType.equalityOperator: 'equalityOperator',
  DartBlockValueTreeBooleanNodeType.numericComparisonOperator:
      'numericComparisonOperator',
};

DartBlockValueTreeBooleanGenericConcatenationNode
_$DartBlockValueTreeBooleanGenericConcatenationNodeFromJson(
  Map<String, dynamic> json,
) => DartBlockValueTreeBooleanGenericConcatenationNode(
  $enumDecode(
    _$DartBlockValueTreeBooleanGenericNodeTypeEnumMap,
    json['neoValueLogicalGenericNodeType'],
  ),
  DartBlockConcatenationValue.fromJson(json['value'] as Map<String, dynamic>),
  $enumDecode(
    _$DartBlockValueTreeBooleanNodeTypeEnumMap,
    json['neoValueLogicalNodeType'],
  ),
  $enumDecode(_$DartBlockValueTreeNodeTypeEnumMap, json['neoValueNodeType']),
  json['nodeKey'] as String,
);

Map<String, dynamic> _$DartBlockValueTreeBooleanGenericConcatenationNodeToJson(
  DartBlockValueTreeBooleanGenericConcatenationNode instance,
) => <String, dynamic>{
  'neoValueNodeType': _$DartBlockValueTreeNodeTypeEnumMap[instance.nodeType]!,
  'nodeKey': instance.nodeKey,
  'neoValueLogicalNodeType':
      _$DartBlockValueTreeBooleanNodeTypeEnumMap[instance.logicalNodeType]!,
  'neoValueLogicalGenericNodeType':
      _$DartBlockValueTreeBooleanGenericNodeTypeEnumMap[instance
          .logicalGenericNodeType]!,
  'value': instance.value.toJson(),
};

DartBlockValueTreeBooleanConstantNode
_$DartBlockValueTreeBooleanConstantNodeFromJson(Map<String, dynamic> json) =>
    DartBlockValueTreeBooleanConstantNode(
      json['value'] as bool,
      $enumDecode(
        _$DartBlockValueTreeBooleanNodeTypeEnumMap,
        json['neoValueLogicalNodeType'],
      ),
      $enumDecode(
        _$DartBlockValueTreeNodeTypeEnumMap,
        json['neoValueNodeType'],
      ),
      json['nodeKey'] as String,
    );

Map<String, dynamic> _$DartBlockValueTreeBooleanConstantNodeToJson(
  DartBlockValueTreeBooleanConstantNode instance,
) => <String, dynamic>{
  'neoValueNodeType': _$DartBlockValueTreeNodeTypeEnumMap[instance.nodeType]!,
  'nodeKey': instance.nodeKey,
  'neoValueLogicalNodeType':
      _$DartBlockValueTreeBooleanNodeTypeEnumMap[instance.logicalNodeType]!,
  'value': instance.value,
};

DartBlockValueTreeBooleanDynamicNode
_$DartBlockValueTreeBooleanDynamicNodeFromJson(Map<String, dynamic> json) =>
    DartBlockValueTreeBooleanDynamicNode(
      DartBlockDynamicValue.fromJson(json['value'] as Map<String, dynamic>),
      $enumDecode(
        _$DartBlockValueTreeBooleanNodeTypeEnumMap,
        json['neoValueLogicalNodeType'],
      ),
      $enumDecode(
        _$DartBlockValueTreeNodeTypeEnumMap,
        json['neoValueNodeType'],
      ),
      json['nodeKey'] as String,
    );

Map<String, dynamic> _$DartBlockValueTreeBooleanDynamicNodeToJson(
  DartBlockValueTreeBooleanDynamicNode instance,
) => <String, dynamic>{
  'neoValueNodeType': _$DartBlockValueTreeNodeTypeEnumMap[instance.nodeType]!,
  'nodeKey': instance.nodeKey,
  'neoValueLogicalNodeType':
      _$DartBlockValueTreeBooleanNodeTypeEnumMap[instance.logicalNodeType]!,
  'value': instance.value.toJson(),
};

DartBlockValueTreeBooleanOperatorNode
_$DartBlockValueTreeBooleanOperatorNodeFromJson(Map<String, dynamic> json) =>
    DartBlockValueTreeBooleanOperatorNode(
      json['leftChild'] == null
          ? null
          : DartBlockValueTreeBooleanNode.fromJson(
              json['leftChild'] as Map<String, dynamic>,
            ),
      $enumDecodeNullable(_$DartBlockBooleanOperatorEnumMap, json['operator']),
      json['rightChild'] == null
          ? null
          : DartBlockValueTreeBooleanNode.fromJson(
              json['rightChild'] as Map<String, dynamic>,
            ),
      $enumDecode(
        _$DartBlockValueTreeBooleanNodeTypeEnumMap,
        json['neoValueLogicalNodeType'],
      ),
      $enumDecode(
        _$DartBlockValueTreeNodeTypeEnumMap,
        json['neoValueNodeType'],
      ),
      json['nodeKey'] as String,
    );

Map<String, dynamic> _$DartBlockValueTreeBooleanOperatorNodeToJson(
  DartBlockValueTreeBooleanOperatorNode instance,
) => <String, dynamic>{
  'neoValueNodeType': _$DartBlockValueTreeNodeTypeEnumMap[instance.nodeType]!,
  'nodeKey': instance.nodeKey,
  'neoValueLogicalNodeType':
      _$DartBlockValueTreeBooleanNodeTypeEnumMap[instance.logicalNodeType]!,
  'leftChild': instance.leftChild?.toJson(),
  'rightChild': instance.rightChild?.toJson(),
  'operator': _$DartBlockBooleanOperatorEnumMap[instance.operator],
};

const _$DartBlockBooleanOperatorEnumMap = {
  DartBlockBooleanOperator.and: 'and',
  DartBlockBooleanOperator.or: 'or',
};

DartBlockValueTreeBooleanEqualityOperatorNode
_$DartBlockValueTreeBooleanEqualityOperatorNodeFromJson(
  Map<String, dynamic> json,
) => DartBlockValueTreeBooleanEqualityOperatorNode(
  json['leftChild'] == null
      ? null
      : DartBlockValueTreeBooleanNode.fromJson(
          json['leftChild'] as Map<String, dynamic>,
        ),
  $enumDecodeNullable(_$DartBlockEqualityOperatorEnumMap, json['operator']),
  json['rightChild'] == null
      ? null
      : DartBlockValueTreeBooleanNode.fromJson(
          json['rightChild'] as Map<String, dynamic>,
        ),
  $enumDecode(
    _$DartBlockValueTreeBooleanNodeTypeEnumMap,
    json['neoValueLogicalNodeType'],
  ),
  $enumDecode(_$DartBlockValueTreeNodeTypeEnumMap, json['neoValueNodeType']),
  json['nodeKey'] as String,
);

Map<String, dynamic> _$DartBlockValueTreeBooleanEqualityOperatorNodeToJson(
  DartBlockValueTreeBooleanEqualityOperatorNode instance,
) => <String, dynamic>{
  'neoValueNodeType': _$DartBlockValueTreeNodeTypeEnumMap[instance.nodeType]!,
  'nodeKey': instance.nodeKey,
  'neoValueLogicalNodeType':
      _$DartBlockValueTreeBooleanNodeTypeEnumMap[instance.logicalNodeType]!,
  'leftChild': instance.leftChild?.toJson(),
  'rightChild': instance.rightChild?.toJson(),
  'operator': _$DartBlockEqualityOperatorEnumMap[instance.operator],
};

const _$DartBlockEqualityOperatorEnumMap = {
  DartBlockEqualityOperator.equal: 'equal',
  DartBlockEqualityOperator.notEqual: 'notEqual',
};

DartBlockValueTreeBooleanNumberComparisonOperatorNode
_$DartBlockValueTreeBooleanNumberComparisonOperatorNodeFromJson(
  Map<String, dynamic> json,
) => DartBlockValueTreeBooleanNumberComparisonOperatorNode(
  json['leftChild'] == null
      ? null
      : DartBlockValueTreeBooleanGenericNumberNode.fromJson(
          json['leftChild'] as Map<String, dynamic>,
        ),
  $enumDecodeNullable(
    _$DartBlockNumberComparisonOperatorEnumMap,
    json['operator'],
  ),
  json['rightChild'] == null
      ? null
      : DartBlockValueTreeBooleanGenericNumberNode.fromJson(
          json['rightChild'] as Map<String, dynamic>,
        ),
  $enumDecode(
    _$DartBlockValueTreeBooleanNodeTypeEnumMap,
    json['neoValueLogicalNodeType'],
  ),
  $enumDecode(_$DartBlockValueTreeNodeTypeEnumMap, json['neoValueNodeType']),
  json['nodeKey'] as String,
);

Map<String, dynamic>
_$DartBlockValueTreeBooleanNumberComparisonOperatorNodeToJson(
  DartBlockValueTreeBooleanNumberComparisonOperatorNode instance,
) => <String, dynamic>{
  'neoValueNodeType': _$DartBlockValueTreeNodeTypeEnumMap[instance.nodeType]!,
  'nodeKey': instance.nodeKey,
  'neoValueLogicalNodeType':
      _$DartBlockValueTreeBooleanNodeTypeEnumMap[instance.logicalNodeType]!,
  'leftChild': instance.leftChild?.toJson(),
  'rightChild': instance.rightChild?.toJson(),
  'operator': _$DartBlockNumberComparisonOperatorEnumMap[instance.operator],
};

const _$DartBlockNumberComparisonOperatorEnumMap = {
  DartBlockNumberComparisonOperator.greater: 'greater',
  DartBlockNumberComparisonOperator.greaterOrEqual: 'greaterOrEqual',
  DartBlockNumberComparisonOperator.equal: 'equal',
  DartBlockNumberComparisonOperator.notEqual: 'notEqual',
  DartBlockNumberComparisonOperator.less: 'less',
  DartBlockNumberComparisonOperator.lessOrEqual: 'lessOrEqual',
};
