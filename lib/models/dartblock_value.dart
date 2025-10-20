import 'package:json_annotation/json_annotation.dart';
import 'package:dartblock/core/dartblock_executor.dart';
import 'package:dartblock/models/statement.dart';
import 'package:uuid/uuid.dart';

import 'exception.dart';
part 'dartblock_value.g.dart';

@JsonEnum()
enum DartBlockDataType {
  @JsonValue('integerType')
  integerType('integerType'),
  @JsonValue('doubleType')
  doubleType('doubleType'),
  @JsonValue('booleanType')
  booleanType('booleanType'),
  @JsonValue('stringType')
  stringType('stringType');

  final String jsonValue;
  const DartBlockDataType(this.jsonValue);
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    switch (this) {
      case DartBlockDataType.integerType:
        switch (language) {
          case DartBlockTypedLanguage.java:
            return "int";
        }
      case DartBlockDataType.doubleType:
        switch (language) {
          case DartBlockTypedLanguage.java:
            return "double";
        }
      case DartBlockDataType.stringType:
        switch (language) {
          case DartBlockTypedLanguage.java:
            return "String";
        }
      case DartBlockDataType.booleanType:
        switch (language) {
          case DartBlockTypedLanguage.java:
            return "boolean";
        }
    }
  }

  @override
  String toString() {
    return toScript();
  }
}

@JsonSerializable()
class DartBlockVariableDefinition {
  final String name;
  final DartBlockDataType dataType;
  DartBlockVariableDefinition(this.name, this.dataType);

  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    return "${dataType.toScript(language: language)} $name";
  }

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) {
    return other is DartBlockVariableDefinition && name == other.name;
  }

  @override
  String toString() {
    return "${dataType.toString()} $name";
  }

  factory DartBlockVariableDefinition.fromJson(Map<String, dynamic> json) =>
      _$VariableDefinitionFromJson(json);

  Map<String, dynamic> toJson() => _$VariableDefinitionToJson(this);

  DartBlockVariableDefinition copy() {
    return DartBlockVariableDefinition(name, dataType);
  }
}
//

@JsonEnum()
enum DartBlockValueType {
  @JsonValue('dynamicValue')
  dynamicValue('dynamicValue'),
  @JsonValue('stringValue')
  stringValue('stringValue'),
  @JsonValue('concatenationValue')
  concatenationValue('concatenationValue'),
  @JsonValue('expressionValue')
  expressionValue('expressionValue');

  final String jsonValue;
  const DartBlockValueType(this.jsonValue);
}

sealed class DartBlockValue<T> {
  @JsonKey(name: "neoValueType")
  final DartBlockValueType valueType;
  DartBlockValue(this.valueType);
  T getValue(DartBlockArbiter arbiter);
  DartBlockValue copy();

  factory DartBlockValue.fromJson(Map<String, dynamic> json) {
    var kind = DartBlockValueType.dynamicValue;
    for (var neoValueType in DartBlockValueType.values) {
      if (json["neoValueType"] == neoValueType.jsonValue) {
        kind = neoValueType;
        break;
      }
    }
    switch (kind) {
      case DartBlockValueType.dynamicValue:
        return DartBlockDynamicValue.fromJson(json) as DartBlockValue<T>;
      case DartBlockValueType.stringValue:
        return DartBlockStringValue.fromJson(json) as DartBlockValue<T>;
      case DartBlockValueType.concatenationValue:
        return DartBlockConcatenationValue.fromJson(json) as DartBlockValue<T>;
      case DartBlockValueType.expressionValue:
        return DartBlockExpressionValue.fromJson(json) as DartBlockValue<T>;
    }
  }
  Map<String, dynamic> toJson();

  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  });
}

@JsonEnum()
enum DartBlockDynamicValueType {
  @JsonValue('variable')
  variable('variable'),
  @JsonValue('functionCall')
  functionCall('functionCall');

  final String jsonValue;
  const DartBlockDynamicValueType(this.jsonValue);
}

sealed class DartBlockDynamicValue extends DartBlockValue {
  final DartBlockDynamicValueType dynamicValueType;
  DartBlockDynamicValue.init(this.dynamicValueType)
    : super(DartBlockValueType.dynamicValue);
  DartBlockDynamicValue(this.dynamicValueType, super.valueType);

  @override
  DartBlockDynamicValue copy();

  factory DartBlockDynamicValue.fromJson(Map<String, dynamic> json) {
    var kind = DartBlockDynamicValueType.variable;
    for (var dynamicValueType in DartBlockDynamicValueType.values) {
      if (json["dynamicValueType"] == dynamicValueType.jsonValue) {
        kind = dynamicValueType;
        break;
      }
    }
    switch (kind) {
      case DartBlockDynamicValueType.variable:
        return DartBlockVariable.fromJson(json);
      case DartBlockDynamicValueType.functionCall:
        return DartBlockFunctionCallValue.fromJson(json);
    }
  }
  @override
  Map<String, dynamic> toJson();
}

@JsonSerializable()
class DartBlockVariable extends DartBlockDynamicValue {
  String name;
  DartBlockVariable.init(this.name)
    : super.init(DartBlockDynamicValueType.variable);
  DartBlockVariable(this.name, super.dynamicValueType, super.neoValueType);

  /// Retrieves the value associated with this variably by lookup in the indicated
  /// Environment.
  @override
  getValue(DartBlockArbiter arbiter) {
    return arbiter.getVariableValue(name)?.getValue(arbiter);
  }

  @override
  String toString() {
    return name;
  }

  @override
  DartBlockVariable copy() {
    return DartBlockVariable.init(name);
  }

  factory DartBlockVariable.fromJson(Map<String, dynamic> json) =>
      _$NeoVariableFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$NeoVariableToJson(this);

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    return name;
  }
}

@JsonSerializable()
class DartBlockFunctionCallValue extends DartBlockDynamicValue {
  final FunctionCallStatement customFunctionCall;
  DartBlockFunctionCallValue.init(this.customFunctionCall)
    : super.init(DartBlockDynamicValueType.functionCall);
  DartBlockFunctionCallValue(
    this.customFunctionCall,
    super.dynamicValueType,
    super.neoValueType,
  );

  @override
  getValue(DartBlockArbiter arbiter) {
    var result = customFunctionCall.run(arbiter);
    if (result == null || result.returnValue == null) {
      // An error should be thrown here.
    } else {
      return result.returnValue;
    }
  }

  @override
  DartBlockFunctionCallValue copy() {
    /// WARNING: DO NOT CALL customFunctionCall.copy().
    /// This would cause an infinite recursion!
    return DartBlockFunctionCallValue.init(
      FunctionCallStatement.init(
        customFunctionCall.customFunctionName,
        List.from(customFunctionCall.arguments.map((e) => e.copy())),
      ),
    );
  }

  factory DartBlockFunctionCallValue.fromJson(Map<String, dynamic> json) =>
      _$FunctionCallValueFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$FunctionCallValueToJson(this);

  @override
  String toString() {
    return customFunctionCall.toString();
  }

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    String script = customFunctionCall.toScript(language: language);
    if (script.endsWith(";") && script.length > 1) {
      script = script.substring(0, script.length - 1);
    }
    return script;
  }
}

@JsonSerializable()
class DartBlockStringValue extends DartBlockValue<String> {
  String value;
  DartBlockStringValue.init(this.value) : super(DartBlockValueType.stringValue);
  DartBlockStringValue(this.value, super.valueType);
  @override
  String getValue(DartBlockArbiter arbiter) {
    return value;
  }

  @override
  String toString() {
    return "\"$value\"";
  }

  @override
  DartBlockStringValue copy() {
    return DartBlockStringValue.init(value);
  }

  factory DartBlockStringValue.fromJson(Map<String, dynamic> json) =>
      _$StringValueFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$StringValueToJson(this);

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    return "\"${value.replaceAll('"', '\\"')}\"";
  }
}

@JsonSerializable()
class DartBlockConcatenationValue extends DartBlockValue<String> {
  List<DartBlockValue> values;

  DartBlockConcatenationValue.init(this.values)
    : super(DartBlockValueType.concatenationValue);
  DartBlockConcatenationValue(this.values, super.valueType);
  DartBlockConcatenationValue.fromConstant(String constant)
    : values = [DartBlockStringValue.init(constant)],
      super(DartBlockValueType.concatenationValue);

  @override
  String getValue(DartBlockArbiter arbiter) {
    String test = "";
    for (var v in values) {
      final concrete = v.getValue(arbiter);
      //print("concrete: $concrete / toString: ${concrete.toString()}");
      test += (concrete.toString());
    }
    return test;
  }

  @override
  String toString() {
    return values.map((e) => e.toString()).join("+");
  }

  @override
  DartBlockConcatenationValue copy() {
    return DartBlockConcatenationValue.init(
      List.from(values.map((value) => value.copy())),
    );
  }

  factory DartBlockConcatenationValue.fromJson(Map<String, dynamic> json) =>
      _$ConcatenationValueFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ConcatenationValueToJson(this);

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    return values.map((e) => e.toScript(language: language)).join("+");
  }
}

@JsonEnum()
enum DartBlockExpressionValueType {
  @JsonValue('algebraic')
  algebraic('algebraic'),
  @JsonValue('boolean')
  boolean('boolean');

  final String jsonValue;
  const DartBlockExpressionValueType(this.jsonValue);
}

sealed class DartBlockExpressionValue<T, U extends DartBlockValueTreeNode>
    extends DartBlockValue<T> {
  final DartBlockExpressionValueType expressionValueType;
  U compositionNode;
  DartBlockExpressionValue.init(
    this.compositionNode, {
    required this.expressionValueType,
  }) : super(DartBlockValueType.expressionValue);
  DartBlockExpressionValue(
    this.compositionNode,
    super.valueType,
    this.expressionValueType,
  );

  @override
  T getValue(DartBlockArbiter arbiter) {
    final concreteValue = compositionNode.getValue(arbiter);
    if (concreteValue == null || concreteValue is! T) {
      throw ExpressionValueTypeMismatchException(
        this,
        concreteValue,
        T,
        concreteValue.runtimeType,
      );
    }
    return concreteValue;
  }

  @override
  String toString() {
    final text = compositionNode.toString();
    // Remove outer parentheses for clarity and because they're unnnecessary.
    if (text.startsWith("(") && text.endsWith(")") && text.length > 2) {
      return text.substring(1, text.length - 1);
    } else {
      return text;
    }
  }

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    final text = compositionNode.toScript(language: language);
    // Remove outer parentheses for clarity and because they're unnnecessary.
    if (text.startsWith("(") && text.endsWith(")") && text.length > 2) {
      return text.substring(1, text.length - 1);
    } else {
      return text;
    }
  }

  factory DartBlockExpressionValue.fromJson(Map<String, dynamic> json) {
    var kind = DartBlockExpressionValueType.algebraic;
    for (var expressionValueType in DartBlockExpressionValueType.values) {
      if (json["expressionValueType"] == expressionValueType.jsonValue) {
        kind = expressionValueType;
        break;
      }
    }
    switch (kind) {
      case DartBlockExpressionValueType.algebraic:
        return DartBlockAlgebraicExpression.fromJson(json)
            as DartBlockExpressionValue<T, U>;
      case DartBlockExpressionValueType.boolean:
        return DartBlockBooleanExpression.fromJson(json)
            as DartBlockExpressionValue<T, U>;
    }
  }
  @override
  Map<String, dynamic> toJson();
}

@JsonSerializable()
class DartBlockAlgebraicExpression
    extends DartBlockExpressionValue<num, DartBlockValueTreeAlgebraicNode> {
  DartBlockAlgebraicExpression.init(super.compositionNode)
    : super.init(expressionValueType: DartBlockExpressionValueType.algebraic);
  DartBlockAlgebraicExpression(
    super.compositionNode,
    super.neoValueType,
    super.expressionValueType,
  );

  DartBlockAlgebraicExpression.fromConstant(num constant)
    : super.init(
        DartBlockValueTreeAlgebraicConstantNode.init(constant, false, null),
        expressionValueType: DartBlockExpressionValueType.algebraic,
      );

  @override
  DartBlockAlgebraicExpression copy() {
    return DartBlockAlgebraicExpression.init(compositionNode.copy());
  }

  factory DartBlockAlgebraicExpression.fromJson(Map<String, dynamic> json) =>
      _$AlgebraicExpressionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$AlgebraicExpressionToJson(this);
}

@JsonSerializable()
class DartBlockBooleanExpression
    extends DartBlockExpressionValue<bool, DartBlockValueTreeBooleanNode> {
  DartBlockBooleanExpression.init(super.compositionNode)
    : super.init(expressionValueType: DartBlockExpressionValueType.boolean);
  DartBlockBooleanExpression(
    super.compositionNode,
    super.neoValueType,
    super.expressionValueType,
  );

  DartBlockBooleanExpression.fromConstant(bool constant)
    : super.init(
        DartBlockValueTreeBooleanConstantNode.init(constant, null),
        expressionValueType: DartBlockExpressionValueType.boolean,
      );

  @override
  DartBlockBooleanExpression copy() {
    return DartBlockBooleanExpression.init(compositionNode.copy());
  }

  factory DartBlockBooleanExpression.fromJson(Map<String, dynamic> json) =>
      _$BooleanExpressionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$BooleanExpressionToJson(this);
}

///
@JsonEnum()
enum DartBlockValueTreeNodeType {
  @JsonValue('algebraic')
  algebraic('algebraic'),
  @JsonValue('boolean')
  boolean('boolean');

  final String jsonValue;
  const DartBlockValueTreeNodeType(this.jsonValue);
}

sealed class DartBlockValueTreeNode<T> {
  final DartBlockValueTreeNodeType neoValueNodeType;
  String nodeKey;
  DartBlockValueTreeNode.init({
    String? specificNodeKey,
    required this.neoValueNodeType,
  }) : nodeKey = specificNodeKey ?? const Uuid().v4();
  DartBlockValueTreeNode(this.neoValueNodeType, this.nodeKey);
  T getValue(DartBlockArbiter arbiter);

  @override
  bool operator ==(Object other) =>
      other is DartBlockValueTreeNode && other.nodeKey == nodeKey;
  @override
  int get hashCode => nodeKey.hashCode;

  /// Find a specific by its key. Note that non-leaf nodes need to override this
  /// implementation such that they properly call the same findNodeByKey
  /// function on their child nodes.
  DartBlockValueTreeNode? findNodeByKey(String key) {
    return key == nodeKey ? this : null;
  }

  /// Traverse the tree upwards and retrieve the root.
  /// The root is defined as the node which has no parent.
  DartBlockValueTreeNode getRoot();

  /// Return a deep copy of the node.
  DartBlockValueTreeNode copy();

  factory DartBlockValueTreeNode.fromJson(Map<String, dynamic> json) {
    var kind = DartBlockValueTreeNodeType.algebraic;
    for (var neoValueNodeType in DartBlockValueTreeNodeType.values) {
      if (json["neoValueNodeType"] == neoValueNodeType.jsonValue) {
        kind = neoValueNodeType;
        break;
      }
    }
    switch (kind) {
      case DartBlockValueTreeNodeType.algebraic:
        return DartBlockValueTreeAlgebraicNode.fromJson(json)
            as DartBlockValueTreeNode<T>;
      case DartBlockValueTreeNodeType.boolean:
        return DartBlockValueTreeBooleanNode.fromJson(json)
            as DartBlockValueTreeNode<T>;
    }
  }

  Map<String, dynamic> toJson();

  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  });
}

@JsonEnum()
enum DartBlockValueTreeAlgebraicNodeType {
  @JsonValue('constant')
  constant('constant'),
  @JsonValue('dynamic')
  dynamic('dynamic'),
  @JsonValue('algebraicOperator')
  algebraicOperator('algebraicOperator');

  final String jsonValue;
  const DartBlockValueTreeAlgebraicNodeType(this.jsonValue);
}

sealed class DartBlockValueTreeAlgebraicNode
    extends DartBlockValueTreeNode<num> {
  final DartBlockValueTreeAlgebraicNodeType neoValueNumericNodeType;
  @JsonKey(includeToJson: false, includeFromJson: false)
  DartBlockValueTreeAlgebraicNode? parent;
  DartBlockValueTreeAlgebraicNode.init(
    this.parent, {
    super.specificNodeKey,
    required this.neoValueNumericNodeType,
  }) : super.init(neoValueNodeType: DartBlockValueTreeNodeType.algebraic);
  DartBlockValueTreeAlgebraicNode(
    this.neoValueNumericNodeType,
    super.neoValueNodeType,
    super.nodeKey,
  );

  factory DartBlockValueTreeAlgebraicNode.fromJson(Map<String, dynamic> json) {
    var kind = DartBlockValueTreeAlgebraicNodeType.constant;
    for (var neoValueNumericNodeType
        in DartBlockValueTreeAlgebraicNodeType.values) {
      if (json["neoValueNumericNodeType"] ==
          neoValueNumericNodeType.jsonValue) {
        kind = neoValueNumericNodeType;
        break;
      }
    }
    switch (kind) {
      case DartBlockValueTreeAlgebraicNodeType.constant:
        return DartBlockValueTreeAlgebraicConstantNode.fromJson(json);
      case DartBlockValueTreeAlgebraicNodeType.dynamic:
        return DartBlockValueTreeAlgebraicDynamicNode.fromJson(json);
      case DartBlockValueTreeAlgebraicNodeType.algebraicOperator:
        return DartBlockValueTreeAlgebraicOperatorNode.fromJson(json);
    }
  }
  @override
  Map<String, dynamic> toJson();

  /// Only implemented by ArithmeticOperatorNode which features two child (left, right)
  /// properties. All other subclasses have empty implementations.
  DartBlockValueTreeAlgebraicNode? replaceChild(
    DartBlockValueTreeAlgebraicNode oldChild,
    DartBlockValueTreeAlgebraicNode? newChild,
  );

  /// Traverse the tree upwards and retrieve the root.
  /// The root is defined as the node which has no parent.
  @override
  DartBlockValueTreeAlgebraicNode getRoot() {
    if (parent == null) {
      return this;
    } else {
      return parent!.getRoot();
    }
  }

  /// Receive an operator (+, -, *, /)
  DartBlockValueTreeAlgebraicNode receiveOperator(
    DartBlockAlgebraicOperator operator,
  ) {
    final originalParent = parent;

    /// The constructor of ValueCompositionArithmeticOperatorNode automatically sets
    /// its childrens' parent property to itself. This is why we first retain the
    /// original parent with originalParent, such that we retain the reference.
    final newNode = DartBlockValueTreeAlgebraicOperatorNode.init(
      operator,
      this,
      null,
      originalParent,
    );
    originalParent?.replaceChild(this, newNode);

    return newNode;
  }

  /// Receive a digit 0-9.
  DartBlockValueTreeAlgebraicNode receiveDigit(num digit);

  /// Receive a dynamic value, which may be a variable or a function call.
  DartBlockValueTreeAlgebraicNode receiveDynamicValue(
    DartBlockDynamicValue dynamicValue,
  );

  /// Receive a delete (backspace) request, which should delete the right-most
  /// component (digit of a constant, variable, operator).
  DartBlockValueTreeAlgebraicNode? backspace();

  /// Receive a dot, indicating the user wants to compose a decimal constant value.
  DartBlockValueTreeAlgebraicNode receiveDot();

  DartBlockValueTreeAlgebraicNode receiveNegation();

  /// Used to retrieve current function call value. (See NumberValueComposer)
  DartBlockValueTreeAlgebraicNode getRightLeaf() => this;

  /// findNodeByKey returns the subtype ValueCompositionNumberNode for ValueCompositionNumberNode and its concrete subclasses.
  @override
  DartBlockValueTreeAlgebraicNode? findNodeByKey(String key);

  @override
  DartBlockValueTreeAlgebraicNode copy();
}

@JsonSerializable()
class DartBlockValueTreeAlgebraicConstantNode
    extends DartBlockValueTreeAlgebraicNode {
  num value;
  bool hasPendingDot;
  DartBlockValueTreeAlgebraicConstantNode.init(
    this.value,
    this.hasPendingDot,
    super.parent, {
    super.specificNodeKey,
  }) : super.init(
         neoValueNumericNodeType: DartBlockValueTreeAlgebraicNodeType.constant,
       );
  DartBlockValueTreeAlgebraicConstantNode(
    this.value,
    this.hasPendingDot,
    super.neoValueNumericNodeType,
    super.neoValueNodeType,
    super.nodeKey,
  );

  factory DartBlockValueTreeAlgebraicConstantNode.fromJson(
    Map<String, dynamic> json,
  ) => _$NeoValueAlgebraicConstantNodeFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$NeoValueAlgebraicConstantNodeToJson(this);

  @override
  num getValue(DartBlockArbiter arbiter) {
    return value;
  }

  @override
  DartBlockValueTreeAlgebraicNode? replaceChild(
    DartBlockValueTreeAlgebraicNode oldChild,
    DartBlockValueTreeAlgebraicNode? newChild,
  ) => this;

  @override
  DartBlockValueTreeAlgebraicNode receiveDigit(num digit) {
    var valueString = value.toString();
    if (hasPendingDot && !valueString.contains(".")) {
      valueString += ".";
      hasPendingDot = false;
    }
    valueString += digit.toString();

    /// Parse a double
    if (valueString.contains(".")) {
      try {
        final newValue = double.parse(valueString);
        if (newValue.toString() == valueString) {
          value = newValue;
        }
        /// Overflow
        else {
          if (valueString.contains(".")) {
            hasPendingDot = true;
          }
        }
      } on FormatException catch (_) {
        ///
      }
    } else {
      try {
        value = int.parse(valueString);
      } on FormatException catch (_) {
        /// Overflow
      }
    }

    return this;
  }

  @override
  DartBlockValueTreeAlgebraicNode receiveDynamicValue(
    DartBlockDynamicValue dynamicValue,
  ) {
    if (parent != null) {
      parent!.replaceChild(
        this,
        DartBlockValueTreeAlgebraicDynamicNode.init(
          dynamicValue,
          parent,
          specificNodeKey: nodeKey,
        ),
      );

      return this;
    } else {
      return DartBlockValueTreeAlgebraicDynamicNode.init(
        dynamicValue,
        null,
        specificNodeKey: nodeKey,
      );
    }
  }

  @override
  DartBlockValueTreeAlgebraicNode? backspace() {
    var valueString = value.toString();
    if (hasPendingDot) {
      hasPendingDot = false;
    } else if (valueString.length > 1) {
      valueString = valueString.substring(0, valueString.length - 1);
      if (valueString.endsWith(".")) {
        hasPendingDot = true;
        if (valueString.length > 1) {
          valueString = valueString.substring(0, valueString.length - 1);
        } else {
          valueString = "";
        }
      } else {
        /// unnecessary?
        hasPendingDot = false;
      }
    } else {
      valueString = "";
    }
    if (valueString.isNotEmpty) {
      value = num.parse(valueString);

      return this;
    } else {
      return parent?.replaceChild(this, null);
    }
  }

  @override
  DartBlockValueTreeAlgebraicNode receiveDot() {
    if (!hasPendingDot && (value is int || value == value.roundToDouble())) {
      hasPendingDot = true;
    }

    return this;
  }

  @override
  DartBlockValueTreeAlgebraicNode receiveNegation() {
    if (parent != null) {
      parent!.replaceChild(
        this,
        DartBlockValueTreeAlgebraicOperatorNode.init(
          DartBlockAlgebraicOperator.subtract,
          null,
          DartBlockValueTreeAlgebraicConstantNode.init(
            value,
            hasPendingDot,
            null,
          ),
          parent,
          specificNodeKey: nodeKey,
        ),
      );

      return this;
    } else {
      return DartBlockValueTreeAlgebraicOperatorNode.init(
        DartBlockAlgebraicOperator.subtract,
        null,
        DartBlockValueTreeAlgebraicConstantNode.init(
          value,
          hasPendingDot,
          null,
        ),
        null,
        specificNodeKey: nodeKey,
      );
    }
  }

  @override
  String toString() {
    return "${value.toString()}${hasPendingDot ? "." : ""}";
  }

  @override
  DartBlockValueTreeAlgebraicNode? findNodeByKey(String key) {
    return key == nodeKey ? this : null;
  }

  @override
  DartBlockValueTreeAlgebraicConstantNode copy() {
    return DartBlockValueTreeAlgebraicConstantNode.init(
      value,
      hasPendingDot,
      parent,
      specificNodeKey: nodeKey,
    );
  }

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    return toString();
  }
}

@JsonSerializable()
class DartBlockValueTreeAlgebraicDynamicNode
    extends DartBlockValueTreeAlgebraicNode {
  DartBlockDynamicValue value;
  DartBlockValueTreeAlgebraicDynamicNode.init(
    this.value,
    super.parent, {
    super.specificNodeKey,
  }) : super.init(
         neoValueNumericNodeType: DartBlockValueTreeAlgebraicNodeType.dynamic,
       );
  DartBlockValueTreeAlgebraicDynamicNode(
    this.value,
    super.neoValueNumericNodeType,
    super.neoValueNodeType,
    super.nodeKey,
  );

  factory DartBlockValueTreeAlgebraicDynamicNode.fromJson(
    Map<String, dynamic> json,
  ) => _$NeoValueAlgebraicDynamicNodeFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$NeoValueAlgebraicDynamicNodeToJson(this);

  @override
  num getValue(DartBlockArbiter arbiter) {
    final numericValue = value.getValue(arbiter);
    if (numericValue == null || numericValue is! num) {
      throw DynamicValueTypeMismatchException(
        value,
        numericValue,
        num,
        numericValue.runtimeType,
      );
    }
    return numericValue;
  }

  @override
  DartBlockValueTreeAlgebraicNode? replaceChild(
    DartBlockValueTreeAlgebraicNode oldChild,
    DartBlockValueTreeAlgebraicNode? newChild,
  ) {
    return this;
  }

  @override
  DartBlockValueTreeAlgebraicNode receiveDigit(num digit) {
    if (parent != null) {
      final newConstantNode = DartBlockValueTreeAlgebraicConstantNode.init(
        digit,
        false,
        parent,
        specificNodeKey: nodeKey,
      );
      parent!.replaceChild(this, newConstantNode);

      return newConstantNode;
    } else {
      return DartBlockValueTreeAlgebraicConstantNode.init(
        digit,
        false,
        null,
        specificNodeKey: nodeKey,
      );
    }
  }

  @override
  DartBlockValueTreeAlgebraicNode receiveDynamicValue(
    DartBlockDynamicValue dynamicValue,
  ) {
    value = dynamicValue;

    return this;
  }

  @override
  DartBlockValueTreeAlgebraicNode? backspace() {
    return parent?.replaceChild(this, null);
  }

  @override
  DartBlockValueTreeAlgebraicNode receiveDot() {
    if (parent != null) {
      /// Convert to constant node 0., with a pending dot.
      final newConstantNode = DartBlockValueTreeAlgebraicConstantNode.init(
        0,
        true,
        parent,
        specificNodeKey: nodeKey,
      );
      parent!.replaceChild(this, newConstantNode);

      return newConstantNode;
    } else {
      return DartBlockValueTreeAlgebraicConstantNode.init(0, true, null);
    }
  }

  @override
  DartBlockValueTreeAlgebraicNode receiveNegation() {
    if (parent != null) {
      parent!.replaceChild(
        this,
        DartBlockValueTreeAlgebraicOperatorNode.init(
          DartBlockAlgebraicOperator.subtract,
          null,
          DartBlockValueTreeAlgebraicDynamicNode.init(value, null),
          parent,
          specificNodeKey: nodeKey,
        ),
      );

      return this;
    } else {
      return DartBlockValueTreeAlgebraicOperatorNode.init(
        DartBlockAlgebraicOperator.subtract,
        null,
        DartBlockValueTreeAlgebraicDynamicNode.init(value, null),
        null,
        specificNodeKey: nodeKey,
      );
    }
  }

  @override
  String toString() {
    return value.toString();
  }

  @override
  DartBlockValueTreeAlgebraicNode? findNodeByKey(String key) {
    return key == nodeKey ? this : null;
  }

  @override
  DartBlockValueTreeAlgebraicDynamicNode copy() {
    return DartBlockValueTreeAlgebraicDynamicNode.init(
      value.copy(),
      parent,
      specificNodeKey: nodeKey,
    );
  }

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    return toString();
  }
}

@JsonSerializable()
class DartBlockValueTreeAlgebraicOperatorNode
    extends DartBlockValueTreeAlgebraicNode {
  DartBlockValueTreeAlgebraicNode? leftChild;
  DartBlockValueTreeAlgebraicNode? rightChild;
  DartBlockAlgebraicOperator? operator;
  DartBlockValueTreeAlgebraicOperatorNode.init(
    this.operator,
    this.leftChild,
    this.rightChild,
    super.parent, {
    super.specificNodeKey,
  }) : super.init(
         neoValueNumericNodeType:
             DartBlockValueTreeAlgebraicNodeType.algebraicOperator,
       ) {
    leftChild?.parent = this;
    rightChild?.parent = this;
  }
  DartBlockValueTreeAlgebraicOperatorNode(
    this.leftChild,
    this.operator,
    this.rightChild,
    super.neoValueNumericNodeType,
    super.neoValueNodeType,
    super.nodeKey,
  ) {
    leftChild?.parent = this;
    rightChild?.parent = this;
  }

  factory DartBlockValueTreeAlgebraicOperatorNode.fromJson(
    Map<String, dynamic> json,
  ) => _$NeoValueAlgebraicOperatorNodeFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$NeoValueAlgebraicOperatorNodeToJson(this);

  void setLeftChild(DartBlockValueTreeAlgebraicNode? child) {
    leftChild = child;
    child?.parent = this;
  }

  void setRightChild(DartBlockValueTreeAlgebraicNode? child) {
    rightChild = child;
    child?.parent = this;
  }

  @override
  DartBlockValueTreeAlgebraicNode? replaceChild(
    DartBlockValueTreeAlgebraicNode oldChild,
    DartBlockValueTreeAlgebraicNode? newChild,
  ) {
    if (leftChild == oldChild) {
      leftChild = newChild;
      leftChild?.parent = this;
    } else if (rightChild == oldChild) {
      rightChild = newChild;
      rightChild?.parent = this;
    }
    if (leftChild == null) {
      if (operator != DartBlockAlgebraicOperator.subtract &&
          operator != DartBlockAlgebraicOperator.add) {
        operator = null;
        if (parent == null) {
          rightChild?.parent = null;

          return rightChild;
        } else {
          return parent?.replaceChild(this, rightChild);
        }
      }
    }
    if (rightChild == null && operator == null) {
      if (parent == null) {
        leftChild?.parent = null;

        return leftChild;
      } else {
        return parent?.replaceChild(this, leftChild);
      }
    }

    return this;
  }

  @override
  DartBlockValueTreeAlgebraicNode receiveOperator(
    DartBlockAlgebraicOperator operator,
  ) {
    /// If it has no right child, add or replace its operator and return the same
    /// node.
    if (rightChild == null) {
      this.operator = operator;

      return this;
    } else {
      /// Otherwise, use the normal behavior, i.e. wrap it in a new
      /// ArithmeticOperatorNode.
      return super.receiveOperator(operator);
    }
  }

  @override
  DartBlockValueTreeAlgebraicNode receiveDigit(num digit) {
    if (rightChild == null) {
      if (operator != null) {
        rightChild = DartBlockValueTreeAlgebraicConstantNode.init(
          digit,
          false,
          this,
        );
      } else {
        leftChild?.receiveDigit(digit);
      }

      return this;
    } else {
      return rightChild!.receiveDigit(digit);
    }
  }

  @override
  DartBlockValueTreeAlgebraicNode receiveDynamicValue(
    DartBlockDynamicValue dynamicValue,
  ) {
    if (rightChild == null) {
      if (operator != null) {
        rightChild = DartBlockValueTreeAlgebraicDynamicNode.init(
          dynamicValue,
          this,
        );
      } else {
        leftChild?.receiveDynamicValue(dynamicValue);
      }

      return this;
    } else {
      return rightChild!.receiveDynamicValue(dynamicValue);
    }
  }

  @override
  DartBlockValueTreeAlgebraicNode? backspace() {
    if (rightChild != null) {
      rightChild?.backspace();
    } else if (operator != null) {
      operator = null;
      if (parent != null) {
        return parent?.replaceChild(this, leftChild);
      } else {
        leftChild?.parent = null;

        return leftChild;
      }
    } else {
      leftChild?.backspace();
    }
    if (rightChild == null && operator == null) {
      if (leftChild == null) {
        return parent?.replaceChild(this, leftChild);
      } else {
        if (parent != null) {
          return parent?.replaceChild(this, leftChild);
        } else {
          return leftChild;
        }
      }
    } else {
      /// Return 'this' instead to not have selection change.
      return this;

      /// Previously returned 'result', which change user selection to the right child
      /// when it was previously the parent arithmetic node.
    }
  }

  @override
  DartBlockValueTreeAlgebraicNode receiveDot() {
    if (rightChild == null) {
      if (operator != null) {
        rightChild = DartBlockValueTreeAlgebraicConstantNode.init(
          0,
          true,
          this,
        );
      } else {
        leftChild?.receiveDot();
      }

      return this;
    } else {
      return rightChild!.receiveDot();
    }
  }

  @override
  DartBlockValueTreeAlgebraicNode receiveNegation() {
    if (rightChild != null &&
        leftChild == null &&
        operator == DartBlockAlgebraicOperator.subtract) {
      if (parent != null) {
        parent!.replaceChild(this, rightChild);
        return rightChild!;
      } else {
        rightChild!.parent = null;

        return rightChild!;
      }
    } else {
      return receiveOperator(DartBlockAlgebraicOperator.subtract);
    }
  }

  @override
  DartBlockValueTreeAlgebraicNode getRightLeaf() {
    if (rightChild != null) {
      return rightChild!.getRightLeaf();
    } else if (operator == null && leftChild != null) {
      return leftChild!.getRightLeaf();
    } else {
      return this;
    }
  }

  List<DartBlockAlgebraicOperator> getSupportedOperators() {
    List<DartBlockAlgebraicOperator> supportedOperators = [];
    if (leftChild != null) {
      supportedOperators = DartBlockAlgebraicOperator.values;
    } else {
      supportedOperators = [
        DartBlockAlgebraicOperator.add,
        DartBlockAlgebraicOperator.subtract,
      ];
    }

    return supportedOperators;
  }

  @override
  num getValue(DartBlockArbiter arbiter) {
    if (leftChild != null && operator != null && rightChild != null) {
      switch (operator!) {
        case DartBlockAlgebraicOperator.add:
          return leftChild!.getValue(arbiter) + rightChild!.getValue(arbiter);
        case DartBlockAlgebraicOperator.subtract:
          return leftChild!.getValue(arbiter) - rightChild!.getValue(arbiter);
        case DartBlockAlgebraicOperator.multiply:
          return leftChild!.getValue(arbiter) * rightChild!.getValue(arbiter);
        case DartBlockAlgebraicOperator.divide:
          final rightValue = rightChild!.getValue(arbiter);
          if (rightValue == 0) {
            throw MalformedAlgebraicExpressionException(
              null,
              rightValue,
              operator,
              "Division by zero is not allowed. ('${toString()}')",
            );
          }
          final leftValue = leftChild!.getValue(arbiter);
          // CRITICAL: mimic truncating integer division of Java.
          // Note that 9 / 2 results in 4.5 in Dart, but 4 in Java!
          if (leftValue is int && rightValue is int) {
            return leftValue ~/ rightValue;
          } else {
            return leftValue / rightValue;
          }
        case DartBlockAlgebraicOperator.modulo:
          final leftValue = leftChild!.getValue(arbiter);
          final rightValue = rightChild!.getValue(arbiter);
          if (leftValue < 0 || rightValue < 0) {
            throw MalformedAlgebraicExpressionException(
              leftValue,
              rightValue,
              operator,
              "The modulo '%' operator can only be applied to positive operands. ('${toString()}')",
            );
          } else if (rightValue == 0) {
            throw MalformedAlgebraicExpressionException(
              leftValue,
              rightValue,
              operator,
              "The right operand of the modulo '%' operator must be greater than zero. ('${toString()}')",
            );
          }
          return leftValue % rightValue;
      }
    } else if (leftChild != null && operator == null && rightChild != null) {
      throw MalformedAlgebraicExpressionException(
        null,
        null,
        operator,
        "Missing operator between the two operands. ('${toString()}')",
      );
    } else if (leftChild != null && operator != null && rightChild == null) {
      return leftChild!.getValue(arbiter);
    } else if (leftChild == null && operator != null && rightChild != null) {
      switch (operator!) {
        case DartBlockAlgebraicOperator.add:
          return rightChild!.getValue(arbiter);
        case DartBlockAlgebraicOperator.subtract:
          return -rightChild!.getValue(arbiter);
        case DartBlockAlgebraicOperator.multiply:
          throw MalformedAlgebraicExpressionException(
            null,
            null,
            operator,
            "Algebraic expressions cannot start with the multiplication '*' operator. ('${toString()}')",
          );
        case DartBlockAlgebraicOperator.divide:
          throw MalformedAlgebraicExpressionException(
            null,
            null,
            operator,
            "Algebraic expressions cannot start with the division '/' operator. ('${toString()}')",
          );
        case DartBlockAlgebraicOperator.modulo:
          throw MalformedAlgebraicExpressionException(
            null,
            null,
            operator,
            "Algebraic expressions cannot start with the modulo '%' operator. ('${toString()}')",
          );
      }
    } else if (leftChild == null && operator == null && rightChild != null) {
      return rightChild!.getValue(arbiter);
    } else if (leftChild != null && operator == null && rightChild == null) {
      return leftChild!.getValue(arbiter);
    } else if (leftChild == null && operator != null && rightChild == null) {
      throw MalformedAlgebraicExpressionException(
        null,
        null,
        operator,
        "Missing operand(s). ('${toString()}')",
      );
    }
    // all null
    else {
      throw MalformedAlgebraicExpressionException(
        null,
        null,
        null,
        "Missing operand(s) and operator. ('${toString()}')",
      );
    }
  }

  @override
  String toString() {
    return "(${leftChild != null ? leftChild!.toString() : ""}${operator != null ? " ${operator!.text}" : ""}${rightChild != null ? " ${rightChild!.toString()}" : ""})";
  }

  @override
  DartBlockValueTreeAlgebraicNode? findNodeByKey(String key) {
    if (key == nodeKey) {
      return this;
    } else {
      return leftChild?.findNodeByKey(key) ?? rightChild?.findNodeByKey(key);
    }
  }

  @override
  DartBlockValueTreeAlgebraicOperatorNode copy() {
    /// WARNING: do not do parent?.copy().
    /// Reason: This will cause a stackoverflow, as this node already calls its
    /// children's (left & right) copy() methods. If its children call their parent's
    /// (this node)'s copy() again, it will cause an infinite loop.
    /// The correct usage of copy() is to always call it on the root node of the tree,
    /// which will create the deep copy top-down.
    return DartBlockValueTreeAlgebraicOperatorNode.init(
      operator,
      leftChild?.copy(),
      rightChild?.copy(),
      parent,
      specificNodeKey: nodeKey,
    );
  }

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    return "(${leftChild != null ? leftChild!.toScript(language: language) : ""}${operator != null ? operator!.toScript(language: language) : ""}${rightChild != null ? rightChild!.toScript(language: language) : ""})";
  }
}

/// The possible operators which can be applied as part of an ArithmeticExpression.
@JsonEnum()
enum DartBlockAlgebraicOperator {
  @JsonValue('add')
  add('add', '+'),
  @JsonValue('subtract')
  subtract('subtract', '-'),
  @JsonValue('multiply')
  multiply('multiply', '*'), // Symbol changed from "x" to "*" as of 0.2.0
  @JsonValue('divide')
  divide('divide', '/'), // Symbol changed from "÷" to "/" as of 0.2.0
  @JsonValue('modulo')
  modulo('modulo', '%');

  final String jsonValue;
  final String text;
  const DartBlockAlgebraicOperator(this.jsonValue, this.text);

  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    switch (language) {
      case DartBlockTypedLanguage.java:
        switch (this) {
          case DartBlockAlgebraicOperator.add:
            return '+';
          case DartBlockAlgebraicOperator.subtract:
            return '-';
          case DartBlockAlgebraicOperator.multiply:
            return '*';
          case DartBlockAlgebraicOperator.divide:
            return '/';
          case DartBlockAlgebraicOperator.modulo:
            return '%';
        }
    }
  }

  /// Describe the operator in spoken English (short).
  ///
  /// Example: '%' is described as 'modulo'
  String describeVerbal() {
    switch (this) {
      case DartBlockAlgebraicOperator.add:
        return 'add';
      case DartBlockAlgebraicOperator.subtract:
        return 'subtract';
      case DartBlockAlgebraicOperator.multiply:
        return 'multiply';
      case DartBlockAlgebraicOperator.divide:
        return 'divide';
      case DartBlockAlgebraicOperator.modulo:
        return 'modulo';
    }
  }
}

@JsonEnum()
enum DartBlockValueTreeBooleanNodeType {
  @JsonValue('constant')
  constant('constant'),
  @JsonValue('dynamic')
  dynamic('dynamic'),
  @JsonValue('generic')
  generic('generic'),
  @JsonValue('booleanOperator')
  booleanOperator('booleanOperator'),
  @JsonValue('equalityOperator')
  equalityOperator('equalityOperator'),
  @JsonValue('numericComparisonOperator')
  numericComparisonOperator('numericComparisonOperator');

  final String jsonValue;
  const DartBlockValueTreeBooleanNodeType(this.jsonValue);
}

/// Logical expression
sealed class DartBlockValueTreeBooleanNode
    extends DartBlockValueTreeNode<bool> {
  final DartBlockValueTreeBooleanNodeType neoValueLogicalNodeType;
  @JsonKey(includeToJson: false, includeFromJson: false)
  DartBlockValueTreeBooleanNode? parent;
  DartBlockValueTreeBooleanNode.init(
    this.parent, {
    super.specificNodeKey,
    required this.neoValueLogicalNodeType,
  }) : super.init(neoValueNodeType: DartBlockValueTreeNodeType.boolean);
  DartBlockValueTreeBooleanNode(
    this.neoValueLogicalNodeType,
    super.neoValueNodeType,
    super.nodeKey,
  );

  factory DartBlockValueTreeBooleanNode.fromJson(Map<String, dynamic> json) {
    var kind = DartBlockValueTreeBooleanNodeType.constant;
    for (var neoValueLogicalNodeType
        in DartBlockValueTreeBooleanNodeType.values) {
      if (json["neoValueLogicalNodeType"] ==
          neoValueLogicalNodeType.jsonValue) {
        kind = neoValueLogicalNodeType;
        break;
      }
    }
    switch (kind) {
      case DartBlockValueTreeBooleanNodeType.constant:
        return DartBlockValueTreeBooleanConstantNode.fromJson(json);
      case DartBlockValueTreeBooleanNodeType.dynamic:
        return DartBlockValueTreeBooleanDynamicNode.fromJson(json);
      case DartBlockValueTreeBooleanNodeType.generic:
        return DartBlockValueTreeBooleanDynamicNode.fromJson(json);
      case DartBlockValueTreeBooleanNodeType.booleanOperator:
        return DartBlockValueTreeBooleanOperatorNode.fromJson(json);
      case DartBlockValueTreeBooleanNodeType.equalityOperator:
        return DartBlockValueTreeBooleanEqualityOperatorNode.fromJson(json);
      case DartBlockValueTreeBooleanNodeType.numericComparisonOperator:
        return DartBlockValueTreeBooleanNumberComparisonOperatorNode.fromJson(
          json,
        );
    }
  }
  @override
  Map<String, dynamic> toJson();

  DartBlockValueTreeBooleanNode? replaceChild(
    covariant DartBlockValueTreeNode oldChild,
    covariant DartBlockValueTreeNode? newChild,
  );

  DartBlockValueTreeBooleanNode? deleteRightLeaf();

  DartBlockValueTreeBooleanNode receiveLogicalOperator(
    DartBlockBooleanOperator operator,
  ) {
    final originalParent = parent;

    final newNode = DartBlockValueTreeBooleanOperatorNode.init(
      operator,
      this,
      null,
      originalParent,
    );
    originalParent?.replaceChild(this, newNode);

    return newNode;
  }

  DartBlockValueTreeBooleanNode receiveEqualityOperator(
    DartBlockEqualityOperator operator,
  ) {
    final originalParent = parent;

    final newNode = DartBlockValueTreeBooleanEqualityOperatorNode.init(
      operator,
      this,
      null,
      originalParent,
    );
    originalParent?.replaceChild(this, newNode);

    return newNode;
  }

  DartBlockValueTreeBooleanNode receiveNumberComparisonOperator(
    DartBlockNumberComparisonOperator operator,
  ) {
    final originalParent = parent;

    final newNode = DartBlockValueTreeBooleanNumberComparisonOperatorNode.init(
      operator,
      null,
      null,
      originalParent,
    );
    originalParent?.replaceChild(this, newNode);

    return newNode;
  }

  DartBlockValueTreeBooleanNode receiveConstant(bool constant);
  DartBlockValueTreeBooleanNode receiveDynamicValue(
    DartBlockDynamicValue dynamicValue,
  );
  DartBlockValueTreeBooleanNode receiveNumberComposedValue(
    DartBlockAlgebraicExpression numberComposedValue,
  );
  DartBlockValueTreeBooleanNode receiveValueConcatenation(
    DartBlockConcatenationValue valueConcatenation,
  );

  /// Receive a delete (backspace) request, which should delete the right-most
  /// component (constant, dynamic value, etc.).
  DartBlockValueTreeBooleanNode? backspace();

  /// Must be overriden by composed types. (See example implementation: ValueCompositionLogicalOperatorNode)
  @override
  DartBlockValueTreeBooleanNode? findNodeByKey(String key) {
    return key == nodeKey ? this : null;
  }

  /// Traverse the tree upwards and retrieve the root.
  /// The root is defined as the node which has no parent.
  @override
  DartBlockValueTreeBooleanNode getRoot() {
    if (parent == null) {
      return this;
    } else {
      return parent!.getRoot();
    }
  }

  DartBlockValueTreeBooleanNode getRightLeaf() => this;

  @override
  DartBlockValueTreeBooleanNode copy();
}

@JsonEnum()
enum DartBlockValueTreeBooleanGenericNodeType {
  @JsonValue('number')
  number('number'),
  @JsonValue('concatenation')
  concatenation('concatenation');

  final String jsonValue;
  const DartBlockValueTreeBooleanGenericNodeType(this.jsonValue);
}

sealed class DartBlockValueTreeBooleanGenericNode<T extends DartBlockValue>
    extends DartBlockValueTreeBooleanNode {
  final DartBlockValueTreeBooleanGenericNodeType neoValueLogicalGenericNodeType;
  T value;
  DartBlockValueTreeBooleanGenericNode.init(
    this.value,
    super.parent, {
    super.specificNodeKey,
    required this.neoValueLogicalGenericNodeType,
  }) : super.init(
         neoValueLogicalNodeType: DartBlockValueTreeBooleanNodeType.generic,
       );
  DartBlockValueTreeBooleanGenericNode(
    this.neoValueLogicalGenericNodeType,
    this.value,
    super.neoValueLogicalNodeType,
    super.neoValueNodeType,
    super.nodeKey,
  );

  factory DartBlockValueTreeBooleanGenericNode.fromJson(
    Map<String, dynamic> json,
  ) {
    var kind = DartBlockValueTreeBooleanGenericNodeType.number;
    for (var neoValueLogicalGenericNodeType
        in DartBlockValueTreeBooleanGenericNodeType.values) {
      if (json["neoValueLogicalGenericNodeType"] ==
          neoValueLogicalGenericNodeType.jsonValue) {
        kind = neoValueLogicalGenericNodeType;
        break;
      }
    }
    switch (kind) {
      case DartBlockValueTreeBooleanGenericNodeType.number:
        return DartBlockValueTreeBooleanGenericNumberNode.fromJson(json)
            as DartBlockValueTreeBooleanGenericNode<T>;
      case DartBlockValueTreeBooleanGenericNodeType.concatenation:
        return DartBlockValueTreeBooleanGenericConcatenationNode.fromJson(json)
            as DartBlockValueTreeBooleanGenericNode<T>;
    }
  }
  @override
  Map<String, dynamic> toJson();

  @override
  bool getValue(DartBlockArbiter arbiter) => true;

  @override
  DartBlockValueTreeBooleanGenericNode copy();

  @override
  DartBlockValueTreeBooleanNode receiveConstant(bool constant) {
    if (parent != null) {
      final newConstantNode = DartBlockValueTreeBooleanConstantNode.init(
        constant,
        parent,
        specificNodeKey: nodeKey,
      );
      parent!.replaceChild(this, newConstantNode);

      return newConstantNode;
    } else {
      return DartBlockValueTreeBooleanConstantNode.init(
        constant,
        null,
        specificNodeKey: nodeKey,
      );
    }
  }

  @override
  DartBlockValueTreeBooleanNode receiveDynamicValue(
    DartBlockDynamicValue dynamicValue,
  ) {
    if (parent != null) {
      final newDynamicNode = DartBlockValueTreeBooleanDynamicNode.init(
        dynamicValue,
        parent,
        specificNodeKey: nodeKey,
      );
      parent!.replaceChild(this, newDynamicNode);

      return newDynamicNode;
    } else {
      return DartBlockValueTreeBooleanDynamicNode.init(
        dynamicValue,
        null,
        specificNodeKey: nodeKey,
      );
    }
  }

  @override
  DartBlockValueTreeBooleanNode receiveNumberComposedValue(
    DartBlockAlgebraicExpression numberComposedValue,
  ) {
    if (parent != null) {
      final newNumbeNode = DartBlockValueTreeBooleanGenericNumberNode.init(
        numberComposedValue,
        parent,
        specificNodeKey: nodeKey,
      );
      parent!.replaceChild(this, newNumbeNode);

      return newNumbeNode;
    } else {
      return DartBlockValueTreeBooleanGenericNumberNode.init(
        numberComposedValue,
        null,
        specificNodeKey: nodeKey,
      );
    }
  }

  @override
  DartBlockValueTreeBooleanNode receiveValueConcatenation(
    DartBlockConcatenationValue valueConcatenation,
  ) {
    if (parent != null) {
      final newValueConcatenationNode =
          DartBlockValueTreeBooleanGenericConcatenationNode.init(
            valueConcatenation,
            parent,
            specificNodeKey: nodeKey,
          );
      parent!.replaceChild(this, newValueConcatenationNode);

      return newValueConcatenationNode;
    } else {
      return DartBlockValueTreeBooleanGenericConcatenationNode.init(
        valueConcatenation,
        null,
        specificNodeKey: nodeKey,
      );
    }
  }

  @override
  DartBlockValueTreeBooleanNode? backspace() {
    return parent?.replaceChild(this, null);
  }

  @override
  DartBlockValueTreeBooleanNode? replaceChild(
    covariant DartBlockValueTreeNode oldChild,
    covariant DartBlockValueTreeNode? newChild,
  ) {
    return this;
  }

  @override
  DartBlockValueTreeBooleanNode? deleteRightLeaf() {
    return parent?.replaceChild(this, null);
  }

  @override
  String toString() {
    return value.toString();
  }
}

@JsonSerializable()
class DartBlockValueTreeBooleanGenericNumberNode
    extends DartBlockValueTreeBooleanGenericNode<DartBlockAlgebraicExpression> {
  DartBlockValueTreeBooleanGenericNumberNode.init(
    super.value,
    super.parent, {
    super.specificNodeKey,
  }) : super.init(
         neoValueLogicalGenericNodeType:
             DartBlockValueTreeBooleanGenericNodeType.number,
       );
  DartBlockValueTreeBooleanGenericNumberNode(
    super.neoValueLogicalGenericNodeType,
    super.value,
    super.neoValueLogicalNodeType,
    super.neoValueNodeType,
    super.nodeKey,
  );

  factory DartBlockValueTreeBooleanGenericNumberNode.fromJson(
    Map<String, dynamic> json,
  ) => _$NeoValueBooleanGenericNumberNodeFromJson(json);
  @override
  Map<String, dynamic> toJson() =>
      _$NeoValueBooleanGenericNumberNodeToJson(this);

  @override
  DartBlockValueTreeBooleanNode receiveNumberComposedValue(
    DartBlockAlgebraicExpression numberComposedValue,
  ) {
    value = numberComposedValue;

    return this;
  }

  @override
  DartBlockValueTreeBooleanNode receiveNumberComparisonOperator(
    DartBlockNumberComparisonOperator operator,
  ) {
    final originalParent = parent;

    final newNode = DartBlockValueTreeBooleanNumberComparisonOperatorNode.init(
      operator,
      this,
      null,
      originalParent,
    );
    originalParent?.replaceChild(this, newNode);

    return newNode;
  }

  @override
  DartBlockValueTreeBooleanNode receiveEqualityOperator(
    DartBlockEqualityOperator operator,
  ) {
    /// If a numeric node of a boolean expression receives an EqualityOperator (==, !=),
    /// view it instead as receiving the corresponding equality operator from NumberComparisonOperator.
    ///
    /// Why: this will allow the user to tap the operator and choose from all available NumberComparisonOperators,
    /// including less than and greater than operators.
    return receiveNumberComparisonOperator(
      operator == DartBlockEqualityOperator.equal
          ? DartBlockNumberComparisonOperator.equal
          : DartBlockNumberComparisonOperator.notEqual,
    );
  }

  @override
  DartBlockValueTreeBooleanGenericNumberNode copy() {
    return DartBlockValueTreeBooleanGenericNumberNode.init(
      value.copy(),
      parent,
      specificNodeKey: nodeKey,
    );
  }

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    return value.toScript();
  }
}

@JsonSerializable()
class DartBlockValueTreeBooleanGenericConcatenationNode
    extends DartBlockValueTreeBooleanGenericNode<DartBlockConcatenationValue> {
  DartBlockValueTreeBooleanGenericConcatenationNode.init(
    super.value,
    super.parent, {
    super.specificNodeKey,
  }) : super.init(
         neoValueLogicalGenericNodeType:
             DartBlockValueTreeBooleanGenericNodeType.concatenation,
       );
  DartBlockValueTreeBooleanGenericConcatenationNode(
    super.neoValueLogicalGenericNodeType,
    super.value,
    super.neoValueLogicalNodeType,
    super.neoValueNodeType,
    super.nodeKey,
  );

  factory DartBlockValueTreeBooleanGenericConcatenationNode.fromJson(
    Map<String, dynamic> json,
  ) => _$NeoValueBooleanGenericConcatenationNodeFromJson(json);
  @override
  Map<String, dynamic> toJson() =>
      _$NeoValueBooleanGenericConcatenationNodeToJson(this);

  @override
  DartBlockValueTreeBooleanGenericConcatenationNode copy() {
    return DartBlockValueTreeBooleanGenericConcatenationNode.init(
      value.copy(),
      parent,
      specificNodeKey: nodeKey,
    );
  }

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    return value.toScript();
  }
}

@JsonSerializable()
class DartBlockValueTreeBooleanConstantNode
    extends DartBlockValueTreeBooleanNode {
  bool value;
  DartBlockValueTreeBooleanConstantNode.init(
    this.value,
    super.parent, {
    super.specificNodeKey,
  }) : super.init(
         neoValueLogicalNodeType: DartBlockValueTreeBooleanNodeType.constant,
       );
  DartBlockValueTreeBooleanConstantNode(
    this.value,
    super.neoValueLogicalNodeType,
    super.neoValueNodeType,
    super.nodeKey,
  );

  factory DartBlockValueTreeBooleanConstantNode.fromJson(
    Map<String, dynamic> json,
  ) => _$NeoValueBooleanConstantNodeFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$NeoValueBooleanConstantNodeToJson(this);

  @override
  bool getValue(DartBlockArbiter arbiter) {
    return value;
  }

  @override
  DartBlockValueTreeBooleanNode? replaceChild(
    DartBlockValueTreeBooleanNode oldChild,
    DartBlockValueTreeBooleanNode? newChild,
  ) => this;

  @override
  DartBlockValueTreeBooleanNode? deleteRightLeaf() {
    return parent?.replaceChild(this, null);
  }

  @override
  DartBlockValueTreeBooleanNode receiveConstant(bool constant) {
    value = constant;

    return this;
  }

  @override
  DartBlockValueTreeBooleanNode receiveDynamicValue(
    DartBlockDynamicValue dynamicValue,
  ) {
    if (parent != null) {
      final newDynamicNode = DartBlockValueTreeBooleanDynamicNode.init(
        dynamicValue,
        parent,
        specificNodeKey: nodeKey,
      );
      parent!.replaceChild(this, newDynamicNode);

      return newDynamicNode;
    } else {
      return DartBlockValueTreeBooleanDynamicNode.init(
        dynamicValue,
        null,
        specificNodeKey: nodeKey,
      );
    }
  }

  @override
  DartBlockValueTreeBooleanNode receiveNumberComposedValue(
    DartBlockAlgebraicExpression numberComposedValue,
  ) {
    if (parent != null) {
      final newDynamicNode = DartBlockValueTreeBooleanGenericNumberNode.init(
        numberComposedValue,
        parent,
        specificNodeKey: nodeKey,
      );
      parent!.replaceChild(this, newDynamicNode);

      return newDynamicNode;
    } else {
      return DartBlockValueTreeBooleanGenericNumberNode.init(
        numberComposedValue,
        null,
        specificNodeKey: nodeKey,
      );
    }
  }

  @override
  DartBlockValueTreeBooleanNode receiveValueConcatenation(
    DartBlockConcatenationValue valueConcatenation,
  ) {
    if (parent != null) {
      final newValueConcatenationNode =
          DartBlockValueTreeBooleanGenericConcatenationNode.init(
            valueConcatenation,
            parent,
            specificNodeKey: nodeKey,
          );
      parent!.replaceChild(this, newValueConcatenationNode);

      return newValueConcatenationNode;
    } else {
      return DartBlockValueTreeBooleanGenericConcatenationNode.init(
        valueConcatenation,
        null,
        specificNodeKey: nodeKey,
      );
    }
  }

  @override
  DartBlockValueTreeBooleanNode? backspace() {
    return parent?.replaceChild(this, null);
  }

  @override
  String toString() {
    return value.toString();
  }

  @override
  DartBlockValueTreeBooleanConstantNode copy() {
    return DartBlockValueTreeBooleanConstantNode.init(
      value,
      parent,
      specificNodeKey: nodeKey,
    );
  }

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    return toString();
  }
}

@JsonSerializable()
class DartBlockValueTreeBooleanDynamicNode
    extends DartBlockValueTreeBooleanNode {
  DartBlockDynamicValue value;
  DartBlockValueTreeBooleanDynamicNode.init(
    this.value,
    super.parent, {
    super.specificNodeKey,
  }) : super.init(
         neoValueLogicalNodeType: DartBlockValueTreeBooleanNodeType.dynamic,
       );
  DartBlockValueTreeBooleanDynamicNode(
    this.value,
    super.neoValueLogicalNodeType,
    super.neoValueNodeType,
    super.nodeKey,
  );

  factory DartBlockValueTreeBooleanDynamicNode.fromJson(
    Map<String, dynamic> json,
  ) => _$NeoValueBooleanDynamicNodeFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$NeoValueBooleanDynamicNodeToJson(this);

  @override
  bool getValue(DartBlockArbiter arbiter) {
    final booleanValue = value.getValue(arbiter);
    if (booleanValue == null || booleanValue is! bool) {
      throw DynamicValueTypeMismatchException(
        value,
        booleanValue,
        bool,
        booleanValue.runtimeType,
      );
    }
    return booleanValue;
  }

  @override
  DartBlockValueTreeBooleanNode? replaceChild(
    DartBlockValueTreeBooleanNode oldChild,
    DartBlockValueTreeBooleanNode? newChild,
  ) => this;

  @override
  DartBlockValueTreeBooleanNode? deleteRightLeaf() {
    return parent?.replaceChild(this, null);
  }

  @override
  DartBlockValueTreeBooleanNode receiveConstant(bool constant) {
    if (parent != null) {
      final newConstantNode = DartBlockValueTreeBooleanConstantNode.init(
        constant,
        parent,
        specificNodeKey: nodeKey,
      );
      parent!.replaceChild(this, newConstantNode);

      return newConstantNode;
    } else {
      return DartBlockValueTreeBooleanConstantNode.init(
        constant,
        null,
        specificNodeKey: nodeKey,
      );
    }
  }

  @override
  DartBlockValueTreeBooleanNode receiveDynamicValue(
    DartBlockDynamicValue dynamicValue,
  ) {
    value = dynamicValue;

    return this;
  }

  @override
  DartBlockValueTreeBooleanNode receiveNumberComposedValue(
    DartBlockAlgebraicExpression numberComposedValue,
  ) {
    if (parent != null) {
      final newDynamicNode = DartBlockValueTreeBooleanGenericNumberNode.init(
        numberComposedValue,
        parent,
        specificNodeKey: nodeKey,
      );
      parent!.replaceChild(this, newDynamicNode);

      return newDynamicNode;
    } else {
      return DartBlockValueTreeBooleanGenericNumberNode.init(
        numberComposedValue,
        null,
        specificNodeKey: nodeKey,
      );
    }
  }

  @override
  DartBlockValueTreeBooleanNode receiveValueConcatenation(
    DartBlockConcatenationValue valueConcatenation,
  ) {
    if (parent != null) {
      final newValueConcatenationNode =
          DartBlockValueTreeBooleanGenericConcatenationNode.init(
            valueConcatenation,
            parent,
            specificNodeKey: nodeKey,
          );
      parent!.replaceChild(this, newValueConcatenationNode);

      return newValueConcatenationNode;
    } else {
      return DartBlockValueTreeBooleanGenericConcatenationNode.init(
        valueConcatenation,
        null,
        specificNodeKey: nodeKey,
      );
    }
  }

  @override
  DartBlockValueTreeBooleanNode? backspace() {
    return parent?.replaceChild(this, null);
  }

  @override
  String toString() {
    return value.toString();
  }

  @override
  DartBlockValueTreeBooleanDynamicNode copy() {
    return DartBlockValueTreeBooleanDynamicNode.init(
      value.copy(),
      parent,
      specificNodeKey: nodeKey,
    );
  }

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    return value.toString();
  }
}

@JsonSerializable()
class DartBlockValueTreeBooleanOperatorNode
    extends DartBlockValueTreeBooleanNode {
  DartBlockValueTreeBooleanNode? leftChild;
  DartBlockValueTreeBooleanNode? rightChild;
  DartBlockBooleanOperator? operator;
  DartBlockValueTreeBooleanOperatorNode.init(
    this.operator,
    this.leftChild,
    this.rightChild,
    super.parent, {
    super.specificNodeKey,
  }) : super.init(
         neoValueLogicalNodeType:
             DartBlockValueTreeBooleanNodeType.booleanOperator,
       ) {
    leftChild?.parent = this;
    rightChild?.parent = this;
  }
  DartBlockValueTreeBooleanOperatorNode(
    this.leftChild,
    this.operator,
    this.rightChild,
    super.neoValueLogicalNodeType,
    super.neoValueNodeType,
    super.nodeKey,
  ) {
    leftChild?.parent = this;
    rightChild?.parent = this;
  }

  factory DartBlockValueTreeBooleanOperatorNode.fromJson(
    Map<String, dynamic> json,
  ) => _$NeoValueBooleanOperatorNodeFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$NeoValueBooleanOperatorNodeToJson(this);

  @override
  bool getValue(DartBlockArbiter arbiter) {
    if (leftChild != null && operator != null && rightChild != null) {
      switch (operator!) {
        case DartBlockBooleanOperator.and:
          return leftChild!.getValue(arbiter) && rightChild!.getValue(arbiter);
        case DartBlockBooleanOperator.or:
          return leftChild!.getValue(arbiter) || rightChild!.getValue(arbiter);
      }
    } else if (leftChild == null && operator != null && rightChild != null) {
      return rightChild!.getValue(arbiter);
    } else if (leftChild != null && operator != null && rightChild == null) {
      return leftChild!.getValue(arbiter);
    } else if (leftChild != null && operator == null && rightChild != null) {
      throw MalformedBooleanLogicalExpressionException(
        null,
        null,
        null,
        "Missing operator (&&, ||). ('${toString()}')",
      );
    } else if (leftChild == null && operator == null && rightChild != null) {
      return rightChild!.getValue(arbiter);
    } else if (leftChild == null && operator != null && rightChild == null) {
      throw MalformedBooleanLogicalExpressionException(
        null,
        null,
        null,
        "Missing operands. ('${toString()}')",
      );
    } else if (leftChild != null && operator == null && rightChild == null) {
      return leftChild!.getValue(arbiter);
    } else {
      // All null
      throw MalformedBooleanLogicalExpressionException(
        null,
        null,
        null,
        "Missing operands and operator (&&, ||). ('${toString()}')",
      );
    }
  }

  @override
  DartBlockValueTreeBooleanNode? replaceChild(
    DartBlockValueTreeBooleanNode oldChild,
    DartBlockValueTreeBooleanNode? newChild,
  ) {
    if (leftChild == oldChild) {
      leftChild = newChild;
      leftChild?.parent = this;
    } else if (rightChild == oldChild) {
      rightChild = newChild;
      rightChild?.parent = this;
    }
    if (leftChild == null) {
      operator = null;
      if (parent == null) {
        rightChild?.parent = null;

        return rightChild;
      } else {
        return parent?.replaceChild(this, rightChild);
      }
    }
    if (rightChild == null && operator == null) {
      if (parent == null) {
        leftChild?.parent = null;

        return leftChild;
      } else {
        return parent?.replaceChild(this, leftChild);
      }
    }

    return this;
  }

  @override
  DartBlockValueTreeBooleanNode? deleteRightLeaf() {
    if (rightChild != null) {
      return rightChild?.deleteRightLeaf();
    } else if (operator == null && leftChild != null) {
      return leftChild!.deleteRightLeaf();
    } else {
      return parent?.replaceChild(this, null);
    }
  }

  @override
  DartBlockValueTreeBooleanNode receiveLogicalOperator(
    DartBlockBooleanOperator operator,
  ) {
    /// If it has no right child, add or replace its operator and return the same
    /// node.
    if (rightChild == null) {
      this.operator = operator;

      return this;
    } else {
      /// Up until (and including) DartBlock 0.0.37, the enabled approach was 1.
      /// Subsequently, the new approach is 2 as it is more natural and what the user would expect to happen.
      ///
      /// 1. The following would wrap the right child in a new NeoValueBooleanOperatorNode.
      /// Example: Given "true && false" and the incoming operator "||", the result is "true && (false ||)"
      // return rightChild!.receiveLogicalOperator(operator);

      ///
      /// 2. The following wraps the current NeoValueBooleanOperatorNode as a whole in a new NeoValueBooleanOperatorNode.
      /// Example: Given "true && false" and the incoming operator "||", the result is "(true && false) ||"
      return super.receiveLogicalOperator(operator);
    }
  }

  @override
  DartBlockValueTreeBooleanNode receiveEqualityOperator(
    DartBlockEqualityOperator operator,
  ) {
    if (rightChild == null) {
      final originalParent = parent;

      final newNode = DartBlockValueTreeBooleanEqualityOperatorNode.init(
        operator,
        leftChild,
        null,
        originalParent,
      );
      originalParent?.replaceChild(this, newNode);

      return newNode;
    } else {
      return rightChild!.receiveEqualityOperator(operator);
      // return super.receiveEqualityOperator(operator);
    }
  }

  @override
  DartBlockValueTreeBooleanNode receiveNumberComparisonOperator(
    DartBlockNumberComparisonOperator operator,
  ) {
    if (rightChild == null) {
      final originalParent = parent;

      final newNode =
          DartBlockValueTreeBooleanNumberComparisonOperatorNode.init(
            operator,
            leftChild != null &&
                    leftChild is DartBlockValueTreeBooleanGenericNumberNode
                ? leftChild as DartBlockValueTreeBooleanGenericNumberNode
                : null,
            null,
            originalParent,
          );
      originalParent?.replaceChild(this, newNode);

      return newNode;
    } else {
      return rightChild!.receiveNumberComparisonOperator(operator);
      // return super.receiveEqualityOperator(operator);
    }
  }

  @override
  DartBlockValueTreeBooleanNode receiveConstant(bool constant) {
    if (rightChild == null) {
      if (operator != null) {
        rightChild = DartBlockValueTreeBooleanConstantNode.init(constant, this);
      } else {
        leftChild?.receiveConstant(constant);
      }

      return this;
    } else {
      return rightChild!.receiveConstant(constant);
    }
  }

  @override
  DartBlockValueTreeBooleanNode receiveDynamicValue(
    DartBlockDynamicValue dynamicValue,
  ) {
    if (rightChild == null) {
      if (operator != null) {
        rightChild = DartBlockValueTreeBooleanDynamicNode.init(
          dynamicValue,
          this,
        );
      } else {
        leftChild?.receiveDynamicValue(dynamicValue);
      }

      return this;
    } else {
      return rightChild!.receiveDynamicValue(dynamicValue);
    }
  }

  @override
  DartBlockValueTreeBooleanNode receiveNumberComposedValue(
    DartBlockAlgebraicExpression numberComposedValue,
  ) {
    if (rightChild == null) {
      if (operator != null) {
        rightChild = DartBlockValueTreeBooleanGenericNumberNode.init(
          numberComposedValue,
          this,
        );
      } else {
        leftChild?.receiveNumberComposedValue(numberComposedValue);
      }

      return this;
    } else {
      return rightChild!.receiveNumberComposedValue(numberComposedValue);
    }
  }

  @override
  DartBlockValueTreeBooleanNode receiveValueConcatenation(
    DartBlockConcatenationValue valueConcatenation,
  ) {
    if (rightChild == null) {
      if (operator != null) {
        rightChild = DartBlockValueTreeBooleanGenericConcatenationNode.init(
          valueConcatenation,
          this,
        );
      } else {
        leftChild?.receiveValueConcatenation(valueConcatenation);
      }

      return this;
    } else {
      return rightChild!.receiveValueConcatenation(valueConcatenation);
    }
  }

  @override
  DartBlockValueTreeBooleanNode? backspace() {
    if (rightChild != null) {
      /// Perform backspace on its right child
      rightChild!.backspace();
      if (operator == null && rightChild == null) {
        /// If the right child becomes null and there is no operator, replace this
        /// composed node with its left child (which can be null)
        return parent?.replaceChild(this, leftChild) ?? leftChild;
      } else {
        /// If it still has an operator, return the composed node.
        return this;
      }
    } else {
      /// If the right child is already null, disregard if there is an operator
      /// and simply replace this composed node with its left child (which can be null).
      /// Important: set the left child's parent to the composed node's parent before
      /// performing this replacement. This step should probably be integrated into the
      /// replaceChild method.
      leftChild?.parent = parent;

      return parent?.replaceChild(this, leftChild) ?? leftChild;
    }
  }

  @override
  DartBlockValueTreeBooleanNode getRightLeaf() {
    if (rightChild != null) {
      return rightChild!.getRightLeaf();
    } else if (operator == null && leftChild != null) {
      return leftChild!.getRightLeaf();
    } else {
      return this;
    }
  }

  @override
  String toString() {
    return "(${leftChild != null ? leftChild.toString() : ""} ${operator != null ? operator!.text : ""} ${rightChild != null ? rightChild.toString() : ""})";
  }

  @override
  DartBlockValueTreeBooleanNode? findNodeByKey(String key) {
    if (key == nodeKey) {
      return this;
    } else {
      return leftChild?.findNodeByKey(key) ?? rightChild?.findNodeByKey(key);
    }
  }

  @override
  DartBlockValueTreeBooleanOperatorNode copy() {
    /// WARNING: do not do parent?.copy().
    /// Reason: This will cause a stackoverflow, as this node already calls its
    /// children's (left & right) copy() methods. If its children call their parent's
    /// (this node)'s copy() again, it will cause an infinite loop.
    /// The correct usage of copy() is to always call it on the root node of the tree,
    /// which will create the deep copy top-down.
    return DartBlockValueTreeBooleanOperatorNode.init(
      operator,
      leftChild?.copy(),
      rightChild?.copy(),
      parent,
      specificNodeKey: nodeKey,
    );
  }

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    return "(${leftChild != null ? leftChild!.toScript(language: language) : ""} ${operator != null ? operator!.toScript(language: language) : ""} ${rightChild != null ? rightChild!.toScript(language: language) : ""})";
  }
}

@JsonSerializable()
class DartBlockValueTreeBooleanEqualityOperatorNode
    extends DartBlockValueTreeBooleanNode {
  DartBlockValueTreeBooleanNode? leftChild;
  DartBlockValueTreeBooleanNode? rightChild;
  DartBlockEqualityOperator? operator;
  DartBlockValueTreeBooleanEqualityOperatorNode.init(
    this.operator,
    this.leftChild,
    this.rightChild,
    super.parent, {
    super.specificNodeKey,
  }) : super.init(
         neoValueLogicalNodeType:
             DartBlockValueTreeBooleanNodeType.equalityOperator,
       ) {
    leftChild?.parent = this;
    rightChild?.parent = this;
  }
  DartBlockValueTreeBooleanEqualityOperatorNode(
    this.leftChild,
    this.operator,
    this.rightChild,
    super.neoValueLogicalNodeType,
    super.neoValueNodeType,
    super.nodeKey,
  ) {
    leftChild?.parent = this;
    rightChild?.parent = this;
  }

  factory DartBlockValueTreeBooleanEqualityOperatorNode.fromJson(
    Map<String, dynamic> json,
  ) => _$NeoValueBooleanEqualityOperatorNodeFromJson(json);
  @override
  Map<String, dynamic> toJson() =>
      _$NeoValueBooleanEqualityOperatorNodeToJson(this);

  @override
  bool getValue(DartBlockArbiter arbiter) {
    if (operator != null) {
      switch (operator!) {
        case DartBlockEqualityOperator.equal:
          if (leftChild == null && rightChild == null) {
            return true;
          } else if (leftChild == null && rightChild != null) {
            return false;
          } else if (leftChild != null && rightChild == null) {
            return false;
          } else {
            DartBlockValueTreeBooleanGenericNode? leftGeneric;
            DartBlockValueTreeBooleanGenericNode? rightGeneric;
            if (leftChild! is DartBlockValueTreeBooleanGenericNode) {
              leftGeneric = leftChild as DartBlockValueTreeBooleanGenericNode;
            }
            if (rightChild! is DartBlockValueTreeBooleanGenericNode) {
              rightGeneric = rightChild as DartBlockValueTreeBooleanGenericNode;
            }
            return (leftGeneric?.value.getValue(arbiter) ??
                    leftChild?.getValue(arbiter)) ==
                (rightGeneric?.value.getValue(arbiter) ??
                    rightChild?.getValue(arbiter));
          }
        case DartBlockEqualityOperator.notEqual:
          if (leftChild == null && rightChild == null) {
            return false;
          } else if (leftChild == null && rightChild != null) {
            return true;
          } else if (leftChild != null && rightChild == null) {
            return true;
          } else {
            DartBlockValueTreeBooleanGenericNode? leftGeneric;
            DartBlockValueTreeBooleanGenericNode? rightGeneric;
            if (leftChild! is DartBlockValueTreeBooleanGenericNode) {
              leftGeneric = leftChild as DartBlockValueTreeBooleanGenericNode;
            }
            if (rightChild! is DartBlockValueTreeBooleanGenericNode) {
              rightGeneric = rightChild as DartBlockValueTreeBooleanGenericNode;
            }
            return (leftGeneric?.value.getValue(arbiter) ??
                    leftChild?.getValue(arbiter)) !=
                (rightGeneric?.value.getValue(arbiter) ??
                    rightChild?.getValue(arbiter));
          }
        // return leftChild?.getValue(arbiter) != rightChild?.getValue(arbiter);
      }
    } else {
      throw MalformedBooleanEqualityExpressionException(
        null,
        null,
        null,
        "Missing operator (==, !=). ('${toString()}')",
      );
    }
  }

  @override
  DartBlockValueTreeBooleanNode? replaceChild(
    DartBlockValueTreeBooleanNode oldChild,
    DartBlockValueTreeBooleanNode? newChild,
  ) {
    if (leftChild == oldChild) {
      leftChild = newChild;
      leftChild?.parent = this;
    } else if (rightChild == oldChild) {
      rightChild = newChild;
      rightChild?.parent = this;
    }
    if (leftChild == null) {
      operator = null;
      if (parent == null) {
        rightChild?.parent = null;

        return rightChild;
      } else {
        return parent?.replaceChild(this, rightChild);
      }
    }
    if (rightChild == null && operator == null) {
      if (parent == null) {
        leftChild?.parent = null;

        return leftChild;
      } else {
        return parent?.replaceChild(this, leftChild);
      }
    }

    return this;
  }

  @override
  DartBlockValueTreeBooleanNode? deleteRightLeaf() {
    if (rightChild != null) {
      return rightChild?.deleteRightLeaf();
    } else if (operator == null && leftChild != null) {
      return leftChild!.deleteRightLeaf();
    } else {
      return parent?.replaceChild(this, null);
    }
  }

  @override
  DartBlockValueTreeBooleanNode receiveLogicalOperator(
    DartBlockBooleanOperator operator,
  ) {
    if (rightChild == null) {
      final originalParent = parent;

      final newNode = DartBlockValueTreeBooleanOperatorNode.init(
        operator,
        leftChild,
        null,
        originalParent,
      );
      originalParent?.replaceChild(this, newNode);

      return newNode;
    } else {
      return super.receiveLogicalOperator(operator);
    }
  }

  @override
  DartBlockValueTreeBooleanNode receiveConstant(bool constant) {
    if (leftChild == null) {
      leftChild = DartBlockValueTreeBooleanConstantNode.init(constant, this);
    } else if (rightChild == null && operator != null) {
      rightChild = DartBlockValueTreeBooleanConstantNode.init(constant, this);
    } else if (rightChild != null) {
      rightChild!.receiveConstant(constant);
    } else {
      leftChild!.receiveConstant(constant);
    }

    return this;
  }

  @override
  DartBlockValueTreeBooleanNode receiveDynamicValue(
    DartBlockDynamicValue dynamicValue,
  ) {
    if (leftChild == null) {
      leftChild = DartBlockValueTreeBooleanDynamicNode.init(dynamicValue, this);
    } else if (rightChild == null && operator != null) {
      rightChild = DartBlockValueTreeBooleanDynamicNode.init(
        dynamicValue,
        this,
      );
    } else if (rightChild != null) {
      rightChild!.receiveDynamicValue(dynamicValue);
    } else {
      leftChild!.receiveDynamicValue(dynamicValue);
    }

    return this;
  }

  @override
  DartBlockValueTreeBooleanNode receiveNumberComposedValue(
    DartBlockAlgebraicExpression numberComposedValue,
  ) {
    if (leftChild == null) {
      leftChild = DartBlockValueTreeBooleanGenericNumberNode.init(
        numberComposedValue,
        this,
      );
    } else if (rightChild == null && operator != null) {
      rightChild = DartBlockValueTreeBooleanGenericNumberNode.init(
        numberComposedValue,
        this,
      );
    } else if (rightChild != null) {
      rightChild!.receiveNumberComposedValue(numberComposedValue);
    } else {
      leftChild!.receiveNumberComposedValue(numberComposedValue);
    }

    return this;
  }

  @override
  DartBlockValueTreeBooleanNode receiveNumberComparisonOperator(
    DartBlockNumberComparisonOperator operator,
  ) {
    /// If the left child is a numeric node (constant, variable, function call),
    /// and the right child is null, convert this NeoValueBooleanEqualityOperatorNode
    /// to a NeoValueBooleanNumberComparisonOperatorNode.
    if (rightChild == null &&
        leftChild is DartBlockValueTreeBooleanGenericNumberNode) {
      final originalParent = parent;

      final newNode =
          DartBlockValueTreeBooleanNumberComparisonOperatorNode.init(
            operator,
            leftChild as DartBlockValueTreeBooleanGenericNumberNode,
            null,
            originalParent,
          );
      originalParent?.replaceChild(this, newNode);

      return newNode;
    } else {
      return super.receiveNumberComparisonOperator(operator);
    }
  }

  @override
  DartBlockValueTreeBooleanNode receiveValueConcatenation(
    DartBlockConcatenationValue valueConcatenation,
  ) {
    if (leftChild == null) {
      leftChild = DartBlockValueTreeBooleanGenericConcatenationNode.init(
        valueConcatenation,
        this,
      );
    } else if (rightChild == null && operator != null) {
      rightChild = DartBlockValueTreeBooleanGenericConcatenationNode.init(
        valueConcatenation,
        this,
      );
    } else if (rightChild != null) {
      rightChild!.receiveValueConcatenation(valueConcatenation);
    } else {
      leftChild!.receiveValueConcatenation(valueConcatenation);
    }

    return this;
  }

  @override
  DartBlockValueTreeBooleanNode? backspace() {
    if (rightChild != null) {
      /// Perform backspace on its right child
      rightChild!.backspace();
      if (operator == null && rightChild == null) {
        /// If the right child becomes null and there is no operator, replace this
        /// composed node with its left child (which can be null)
        return parent?.replaceChild(this, leftChild) ?? leftChild;
      } else {
        /// If it still has an operator, return the composed node.
        return this;
      }
    } else {
      /// If the right child is already null, disregard if there is an operator
      /// and simply replace this composed node with its left child (which can be null).
      /// Important: set the left child's parent to the composed node's parent before
      /// performing this replacement. This step should probably be integrated into the
      /// replaceChild method.
      leftChild?.parent = parent;

      return parent?.replaceChild(this, leftChild) ?? leftChild;
    }
  }

  @override
  DartBlockValueTreeBooleanNode getRightLeaf() {
    if (rightChild != null) {
      return rightChild!.getRightLeaf();
    } else if (operator == null && leftChild != null) {
      return leftChild!.getRightLeaf();
    } else {
      return this;
    }
  }

  @override
  DartBlockValueTreeBooleanNode? findNodeByKey(String key) {
    if (key == nodeKey) {
      return this;
    } else {
      return leftChild?.findNodeByKey(key) ?? rightChild?.findNodeByKey(key);
    }
  }

  @override
  String toString() {
    return "(${leftChild.toString()} ${operator != null ? operator!.text : "??"} ${rightChild.toString()})";
  }

  @override
  DartBlockValueTreeBooleanEqualityOperatorNode copy() {
    /// WARNING: do not do parent?.copy().
    /// Reason: This will cause a stackoverflow, as this node already calls its
    /// children's (left & right) copy() methods. If its children call their parent's
    /// (this node)'s copy() again, it will cause an infinite loop.
    /// The correct usage of copy() is to always call it on the root node of the tree,
    /// which will create the deep copy top-down.
    return DartBlockValueTreeBooleanEqualityOperatorNode.init(
      operator,
      leftChild?.copy(),
      rightChild?.copy(),
      parent,
      specificNodeKey: nodeKey,
    );
  }

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    return "(${leftChild?.toScript(language: language)} ${operator != null ? operator!.toScript(language: language) : "??"} ${rightChild?.toScript(language: language)})";
  }
}

@JsonSerializable()
class DartBlockValueTreeBooleanNumberComparisonOperatorNode
    extends DartBlockValueTreeBooleanNode {
  DartBlockValueTreeBooleanGenericNumberNode? leftChild;
  DartBlockValueTreeBooleanGenericNumberNode? rightChild;
  DartBlockNumberComparisonOperator? operator;
  DartBlockValueTreeBooleanNumberComparisonOperatorNode.init(
    this.operator,
    this.leftChild,
    this.rightChild,
    super.parent, {
    super.specificNodeKey,
  }) : super.init(
         neoValueLogicalNodeType:
             DartBlockValueTreeBooleanNodeType.numericComparisonOperator,
       ) {
    leftChild?.parent = this;
    rightChild?.parent = this;
  }
  DartBlockValueTreeBooleanNumberComparisonOperatorNode(
    this.leftChild,
    this.operator,
    this.rightChild,
    super.neoValueLogicalNodeType,
    super.neoValueNodeType,
    super.nodeKey,
  ) {
    leftChild?.parent = this;
    rightChild?.parent = this;
  }

  factory DartBlockValueTreeBooleanNumberComparisonOperatorNode.fromJson(
    Map<String, dynamic> json,
  ) => _$NeoValueBooleanNumberComparisonOperatorNodeFromJson(json);
  @override
  Map<String, dynamic> toJson() =>
      _$NeoValueBooleanNumberComparisonOperatorNodeToJson(this);

  @override
  bool getValue(DartBlockArbiter arbiter) {
    if (operator != null && leftChild != null && rightChild != null) {
      switch (operator!) {
        case DartBlockNumberComparisonOperator.equal:
          return leftChild!.value.getValue(arbiter) ==
              rightChild!.value.getValue(arbiter);
        case DartBlockNumberComparisonOperator.notEqual:
          return leftChild!.value.getValue(arbiter) !=
              rightChild!.value.getValue(arbiter);
        case DartBlockNumberComparisonOperator.greater:
          return leftChild!.value.getValue(arbiter) >
              rightChild!.value.getValue(arbiter);
        case DartBlockNumberComparisonOperator.greaterOrEqual:
          return leftChild!.value.getValue(arbiter) >=
              rightChild!.value.getValue(arbiter);
        case DartBlockNumberComparisonOperator.less:
          return leftChild!.value.getValue(arbiter) <
              rightChild!.value.getValue(arbiter);
        case DartBlockNumberComparisonOperator.lessOrEqual:
          return leftChild!.value.getValue(arbiter) <=
              rightChild!.value.getValue(arbiter);
      }
    } else {
      if (operator == null && leftChild == null && rightChild == null) {
        throw MalformedBooleanNumberComparisonExpressionException(
          null,
          null,
          null,
          "An operator (>, >=, ==, !=, <=, <) and two operands are required. ('${toString()}')",
        );
      } else if (operator == null && leftChild != null && rightChild != null) {
        throw MalformedBooleanNumberComparisonExpressionException(
          null,
          null,
          null,
          "An operator (>, >=, ==, !=, <=, <) is required. ('${toString()}')",
        );
      } else if (operator == null && leftChild == null && rightChild != null) {
        throw MalformedBooleanNumberComparisonExpressionException(
          null,
          null,
          null,
          "An operator (>, >=, ==, !=, <=, <) and a left operand are required. ('${toString()}')",
        );
      } else if (operator == null && leftChild != null && rightChild == null) {
        throw MalformedBooleanNumberComparisonExpressionException(
          null,
          null,
          null,
          "An operator (>, >=, ==, !=, <=, <) and a right operand are required. ('${toString()}')",
        );
      } else if (operator != null && leftChild == null && rightChild == null) {
        throw MalformedBooleanNumberComparisonExpressionException(
          null,
          null,
          null,
          "Two operands are required. ('${toString()}')",
        );
      } else if (operator != null && leftChild == null && rightChild != null) {
        throw MalformedBooleanNumberComparisonExpressionException(
          null,
          null,
          null,
          "A left operand is required. ('${toString()}')",
        );
      }
      // No right operand
      else {
        throw MalformedBooleanNumberComparisonExpressionException(
          null,
          null,
          null,
          "A right operand is required. ('${toString()}')",
        );
      }
    }
  }

  @override
  DartBlockValueTreeBooleanNode? replaceChild(
    DartBlockValueTreeBooleanNode oldChild,
    DartBlockValueTreeBooleanNode? newChild,
  ) {
    if (newChild != null &&
        newChild is! DartBlockValueTreeBooleanGenericNumberNode) {
      if (parent == null) {
        newChild.parent = null;

        return newChild;
      } else {
        return parent?.replaceChild(this, newChild);
      }
    }
    if (leftChild == oldChild) {
      leftChild = newChild as DartBlockValueTreeBooleanGenericNumberNode?;
      leftChild?.parent = this;
    } else if (rightChild == oldChild) {
      rightChild = newChild as DartBlockValueTreeBooleanGenericNumberNode?;
      rightChild?.parent = this;
    }
    if (leftChild == null) {
      operator = null;
      if (parent == null) {
        rightChild?.parent = null;

        return rightChild;
      } else {
        return parent?.replaceChild(this, rightChild);
      }
    }
    if (rightChild == null && operator == null) {
      if (parent == null) {
        leftChild?.parent = null;

        return leftChild;
      } else {
        return parent?.replaceChild(this, leftChild);
      }
    }

    return this;
  }

  @override
  DartBlockValueTreeBooleanNode? deleteRightLeaf() {
    if (rightChild != null) {
      return rightChild?.deleteRightLeaf();
    } else if (operator == null && leftChild != null) {
      return leftChild!.deleteRightLeaf();
    } else {
      return parent?.replaceChild(this, null);
    }
  }

  @override
  DartBlockValueTreeBooleanNode receiveLogicalOperator(
    DartBlockBooleanOperator operator,
  ) {
    if (rightChild == null) {
      final originalParent = parent;

      final newNode = DartBlockValueTreeBooleanOperatorNode.init(
        operator,
        leftChild,
        null,
        originalParent,
      );
      originalParent?.replaceChild(this, newNode);

      return newNode;
    } else {
      return super.receiveLogicalOperator(operator);
    }
  }

  @override
  DartBlockValueTreeBooleanNode receiveConstant(bool constant) {
    if (parent != null) {
      final newConstantNode = DartBlockValueTreeBooleanConstantNode.init(
        constant,
        parent,
        specificNodeKey: nodeKey,
      );
      parent!.replaceChild(this, newConstantNode);

      return newConstantNode;
    } else {
      return DartBlockValueTreeBooleanConstantNode.init(
        constant,
        null,
        specificNodeKey: nodeKey,
      );
    }
  }

  @override
  DartBlockValueTreeBooleanNode receiveDynamicValue(
    DartBlockDynamicValue dynamicValue,
  ) {
    if (parent != null) {
      final newDynamicNode = DartBlockValueTreeBooleanDynamicNode.init(
        dynamicValue,
        parent,
        specificNodeKey: nodeKey,
      );
      parent!.replaceChild(this, newDynamicNode);

      return newDynamicNode;
    } else {
      return DartBlockValueTreeBooleanDynamicNode.init(
        dynamicValue,
        null,
        specificNodeKey: nodeKey,
      );
    }
  }

  @override
  DartBlockValueTreeBooleanNode receiveNumberComposedValue(
    DartBlockAlgebraicExpression numberComposedValue,
  ) {
    if (leftChild == null) {
      leftChild = DartBlockValueTreeBooleanGenericNumberNode.init(
        numberComposedValue,
        this,
      );
    } else if (rightChild == null && operator != null) {
      rightChild = DartBlockValueTreeBooleanGenericNumberNode.init(
        numberComposedValue,
        this,
      );
    } else if (rightChild != null) {
      rightChild!.receiveNumberComposedValue(numberComposedValue);
    } else {
      leftChild!.receiveNumberComposedValue(numberComposedValue);
    }

    return this;
  }

  @override
  DartBlockValueTreeBooleanNode receiveValueConcatenation(
    DartBlockConcatenationValue valueConcatenation,
  ) {
    if (parent != null) {
      final newValueConcatenationNode =
          DartBlockValueTreeBooleanGenericConcatenationNode.init(
            valueConcatenation,
            parent,
            specificNodeKey: nodeKey,
          );
      parent!.replaceChild(this, newValueConcatenationNode);

      return newValueConcatenationNode;
    } else {
      return DartBlockValueTreeBooleanGenericConcatenationNode.init(
        valueConcatenation,
        null,
        specificNodeKey: nodeKey,
      );
    }
  }

  @override
  DartBlockValueTreeBooleanNode receiveNumberComparisonOperator(
    DartBlockNumberComparisonOperator operator,
  ) {
    /// If the right child is null and the left child is not, add or replace
    /// the current operator with the incoming operator.
    if (rightChild == null && leftChild != null) {
      this.operator = operator;
      return this;
    } else {
      return super.receiveNumberComparisonOperator(operator);
    }
  }

  @override
  DartBlockValueTreeBooleanNode receiveEqualityOperator(
    DartBlockEqualityOperator operator,
  ) {
    /// If the right child is null, treat the incoming EqualityOperator as the
    /// corresponding NumberComparisonOperator instead.
    ///
    /// This allows the user to later change the operator to any of the NumberComparisonOperator
    /// values, including greater than and less than, rather than just the two possible values
    /// of EqualityOperator.
    if (rightChild == null) {
      return receiveNumberComparisonOperator(
        operator == DartBlockEqualityOperator.equal
            ? DartBlockNumberComparisonOperator.equal
            : DartBlockNumberComparisonOperator.notEqual,
      );
    } else {
      return super.receiveEqualityOperator(operator);
    }
  }

  @override
  DartBlockValueTreeBooleanNode? backspace() {
    if (rightChild != null) {
      /// Perform backspace on its right child
      rightChild!.backspace();
      if (operator == null && rightChild == null) {
        /// If the right child becomes null and there is no operator, replace this
        /// composed node with its left child (which can be null)
        return parent?.replaceChild(this, leftChild) ?? leftChild;
      } else {
        /// If it still has an operator, return the composed node.
        return this;
      }
    } else {
      /// If the right child is already null, disregard if there is an operator
      /// and simply replace this composed node with its left child (which can be null).
      /// Important: set the left child's parent to the composed node's parent before
      /// performing this replacement. This step should probably be integrated into the
      /// replaceChild method.
      leftChild?.parent = parent;

      return parent?.replaceChild(this, leftChild) ?? leftChild;
    }
  }

  @override
  DartBlockValueTreeBooleanNode getRightLeaf() {
    if (rightChild != null) {
      return rightChild!.getRightLeaf();
    } else if (operator == null && leftChild != null) {
      return leftChild!.getRightLeaf();
    } else {
      return this;
    }
  }

  @override
  DartBlockValueTreeBooleanNode? findNodeByKey(String key) {
    if (key == nodeKey) {
      return this;
    } else {
      return leftChild?.findNodeByKey(key) ?? rightChild?.findNodeByKey(key);
    }
  }

  @override
  String toString() {
    return "(${leftChild != null ? leftChild.toString() : ""} ${operator != null ? operator!.text : ""} ${rightChild != null ? rightChild.toString() : ""})";
  }

  @override
  DartBlockValueTreeBooleanNumberComparisonOperatorNode copy() {
    return DartBlockValueTreeBooleanNumberComparisonOperatorNode.init(
      operator,
      leftChild?.copy(),
      rightChild?.copy(),
      parent,
      specificNodeKey: nodeKey,
    );
  }

  @override
  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    return "(${leftChild != null ? leftChild!.toScript(language: language) : ""} ${operator != null ? operator!.toScript(language: language) : ""} ${rightChild != null ? rightChild!.toScript(language: language) : ""})";
  }
}

@JsonEnum()
enum DartBlockEqualityOperator {
  @JsonValue('equal')
  equal('equal', "=="),
  @JsonValue('notEqual')
  notEqual('notEqual', "!=");

  final String jsonValue;
  final String text;
  const DartBlockEqualityOperator(this.jsonValue, this.text);

  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    switch (language) {
      case DartBlockTypedLanguage.java:
        switch (this) {
          case DartBlockEqualityOperator.equal:
            return '==';
          case DartBlockEqualityOperator.notEqual:
            return '!=';
        }
    }
  }

  /// Describe the operator in spoken English (short).
  ///
  /// Example: '==' is described as 'equal to'
  String describeVerbal() {
    switch (this) {
      case DartBlockEqualityOperator.equal:
        return 'equal to';
      case DartBlockEqualityOperator.notEqual:
        return 'not equal to';
    }
  }
}

@JsonEnum()
enum DartBlockBooleanOperator {
  @JsonValue('and')
  and('and', "&&"),
  @JsonValue('or')
  or('or', "||");

  final String jsonValue;
  final String text;
  const DartBlockBooleanOperator(this.jsonValue, this.text);

  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    switch (language) {
      case DartBlockTypedLanguage.java:
        switch (this) {
          case DartBlockBooleanOperator.and:
            return '&&';
          case DartBlockBooleanOperator.or:
            return '||';
        }
    }
  }

  /// Describe the operator in spoken English (short).
  ///
  /// Example: '&&' is described as 'and'
  String describeVerbal() {
    switch (this) {
      case DartBlockBooleanOperator.and:
        return 'and';
      case DartBlockBooleanOperator.or:
        return 'or';
    }
  }
}

@JsonEnum()
enum DartBlockNumberComparisonOperator {
  @JsonValue('greater')
  greater('greater', ">"),
  @JsonValue('greaterOrEqual')
  greaterOrEqual('greaterOrEqual', "≥"),
  @JsonValue('equal')
  equal('equal', "=="),
  @JsonValue('notEqual')
  notEqual('notEqual', "≠"),
  @JsonValue('less')
  less('less', "<"),
  @JsonValue('lessOrEqual')
  lessOrEqual('lessOrEqual', "≤");

  final String jsonValue;
  final String text;
  const DartBlockNumberComparisonOperator(this.jsonValue, this.text);

  String toScript({
    DartBlockTypedLanguage language = DartBlockTypedLanguage.java,
  }) {
    switch (language) {
      case DartBlockTypedLanguage.java:
        switch (this) {
          case DartBlockNumberComparisonOperator.greater:
            return '>';
          case DartBlockNumberComparisonOperator.greaterOrEqual:
            return '>=';
          case DartBlockNumberComparisonOperator.equal:
            return '==';
          case DartBlockNumberComparisonOperator.notEqual:
            return '!=';
          case DartBlockNumberComparisonOperator.less:
            return '<';
          case DartBlockNumberComparisonOperator.lessOrEqual:
            return '<=';
        }
    }
  }

  /// Describe the operator in spoken English (short).
  ///
  /// Example: '>' is described as 'greater than'
  String describeVerbal() {
    switch (this) {
      case DartBlockNumberComparisonOperator.greater:
        return 'greater than';
      case DartBlockNumberComparisonOperator.greaterOrEqual:
        return 'greater than or equal to';
      case DartBlockNumberComparisonOperator.equal:
        return 'equal to';
      case DartBlockNumberComparisonOperator.notEqual:
        return 'not equal to';
      case DartBlockNumberComparisonOperator.less:
        return 'less than';
      case DartBlockNumberComparisonOperator.lessOrEqual:
        return 'less than or equal to';
    }
  }
}
