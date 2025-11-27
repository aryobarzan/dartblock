import 'package:dartblock_code/core/dartblock_executor.dart';
import 'package:dartblock_code/models/exception.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:json_annotation/json_annotation.dart';
part 'environment.g.dart';

class VariableDeclarationInfo {
  DartBlockDataType dataType;
  DartBlockValue? value;
  VariableDeclarationInfo(this.dataType, this.value);
}

/// Models the scope of variables by storing the values for each variable name
/// in a simple Map.
@JsonSerializable(explicitToJson: true)
class DartBlockEnvironment {
  /// If indicated, the parent property provides the link to the parent Environment
  /// which contains this Environment. This models for example the nesting of
  /// code blocks, where for example variables declared in a for-loop should not
  /// be accessible after exiting the loop.
  /// The highest-up Environment (scope) has its parent property set to null,
  /// thus indicating it is the "global" scope.
  final int key; // hashCode of StatementBlock
  @JsonKey(includeFromJson: false, includeToJson: false)
  DartBlockEnvironment? _parent;
  final List<DartBlockEnvironment> _children;
  final Map<String, DartBlockValue?> _memory;

  final Map<String, DartBlockDataType> _memoryTypes;

  DartBlockEnvironment(
    this.key, {
    DartBlockEnvironment? parent,
    required List<DartBlockEnvironment> children,
  }) : _parent = parent,
       _children = children,
       _memory = {},
       _memoryTypes = {};

  /// NOTE: The serialized form intentionally omits the upward `parent` link to
  /// avoid infinite recursion (child -> parent -> child ...) during JSON
  /// (de)serialization. We call the generated `_$DartBlockEnvironmentFromJson` to
  /// deserialize children (downward links) and then restore parent references
  /// in-memory via `_rebuildParentReferences()`.
  ///
  /// This keeps the JSON acyclic and prevents stack overflows while preserving
  /// parent pointers after deserialization.
  factory DartBlockEnvironment.fromJson(Map<String, dynamic> json) =>
      // Use generated deserializer then re-establish parent links for children
      (() {
        final env = _$DartBlockEnvironmentFromJson(json);
        env._rebuildParentReferences();
        return env;
      })();

  /// NOTE: `parent` is excluded from JSON output on purpose to prevent cyclic
  /// traversal of the object graph (parent -> child -> parent -> ...), which
  /// causes stack overflows. Only downward links (`children`) are serialized.
  /// Parent links are restored after `fromJson` runs `_rebuildParentReferences()`.
  ///
  /// See: `@JsonKey(includeFromJson: false, includeToJson: false)` on `parent` (including its getter) and `DartBlockEnvironment.fromJson`.
  Map<String, dynamic> toJson() => _$DartBlockEnvironmentToJson(this);

  void addChild(DartBlockEnvironment child) {
    child.setParent(this);
    _children.add(child);
  }

  void setParent(DartBlockEnvironment? parent) {
    if (parent != this) {
      _parent = parent;
    }
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  DartBlockEnvironment? get parent => _parent;

  List<DartBlockEnvironment> get children => _children;

  /// Search for the Environment which stores the value mapped to the given
  /// variable name (key).
  /// If a given key is not found in the current Environment, it may still be
  /// found in a higher up (parent) Environment, hence this function recursively
  /// searches for the parent Environment which contains this key.
  DartBlockEnvironment? getContainingEnvironment(String variableName) {
    if (_memory.containsKey(variableName)) {
      return this;
    } else {
      if (_parent != null) {
        return _parent!.getContainingEnvironment(variableName);
      } else {
        return null;
      }
    }
  }

  /// Declare a variable using the given name and optionally the initial value.
  void declareVariable(
    DartBlockArbiter arbiter,
    String variableName,
    DartBlockDataType dataType,
    DartBlockValue? value,
  ) {
    /// If a variable with the same name is already declared, throw an Error.
    if (getContainingEnvironment(variableName) != null) {
      throw VariableAlreadyDeclaredException(variableName);
    } else {
      _memoryTypes[variableName] = dataType;
      // if (value != null) {
      _assignValue(arbiter, this, variableName, value);
      // }
    }
  }

  /// Assign a value to an existing variable based on its name.
  void assignValueToVariable(
    DartBlockArbiter arbiter,
    String variableName,
    DartBlockValue? value,
  ) {
    var containingEnvironment = getContainingEnvironment(variableName);
    if (containingEnvironment != null) {
      containingEnvironment._assignValue(
        arbiter,
        containingEnvironment,
        variableName,
        value,
      );
    } else {
      /// If the variable with the given name is not yet declared, throw an Error.
      throw VariableNotDeclaredException(variableName);
    }
  }

  void _assignValue(
    DartBlockArbiter arbiter,
    DartBlockEnvironment environment,
    String variableName,
    DartBlockValue? value,
  ) {
    if (value != null) {
      _checkTypeMatch(arbiter, environment, variableName, value);
    }

    /// CRITICAL: Do not assign a Variable as a value for the given variable
    /// name. This causes a stack overflow issue as Variables, including Expressions,
    /// cause an infinite computation of the value as they have to rely on the
    /// appropriate Environment object to find the stored value.
    /// Solution: Always store the value as a constant in the Map.
    switch (value) {
      case DartBlockConcatenationValue():
        environment._memory[variableName] =
            DartBlockConcatenationValue.fromConstant(value.getValue(arbiter));
        break;
      // case ConstantValue<T>():
      //   break;
      // case Variable<T>():
      //   break;
      // case VoidValue():
      //   break;
      case DartBlockAlgebraicExpression():
        environment._memory[variableName] =
            DartBlockAlgebraicExpression.fromConstant(value.getValue(arbiter));
        break;
      case DartBlockBooleanExpression():
        environment._memory[variableName] =
            DartBlockBooleanExpression.fromConstant(value.getValue(arbiter));
        break;
      // environment._memory[name] = ConstantValue<T>(value.getValue(arbiter));
      default:
        environment._memory[variableName] = value;
    }
  }

  void _checkTypeMatch(
    DartBlockArbiter arbiter,
    DartBlockEnvironment environment,
    String variableName,
    DartBlockValue value,
  ) {
    final concreteValue = value.getValue(arbiter);
    bool isMatching = true;
    switch (_memoryTypes[variableName]!) {
      case DartBlockDataType.integerType:
        if (concreteValue is! int) {
          isMatching = false;
        }
        break;
      case DartBlockDataType.doubleType:
        if (concreteValue is! num) {
          isMatching = false;
        }
        break;
      case DartBlockDataType.booleanType:
        if (concreteValue is! bool) {
          isMatching = false;
        }
        break;
      case DartBlockDataType.stringType:
        if (concreteValue is! String) {
          isMatching = false;
        }
        break;
    }
    if (!isMatching) {
      throw VariableValueTypeMismatchException(
        variableName,
        _memoryTypes[variableName]!,
        concreteValue.runtimeType,
      );
    }
  }

  /// Get the current value associated with the given variable name.
  DartBlockValue? get(String variableName) {
    var containingEnvironment = getContainingEnvironment(variableName);
    if (containingEnvironment != null) {
      return containingEnvironment._memory[variableName];
    } else {
      throw VariableNotDeclaredException(variableName);
    }
  }

  Map<DartBlockVariableDefinition, String?> getAllValues(
    DartBlockArbiter arbiter,
  ) {
    Map<DartBlockVariableDefinition, String?> memory = {};
    for (final entry in _memoryTypes.entries) {
      final value = _memory.containsKey(entry.key)
          ? _memory[entry.key]?.getValue(arbiter)?.toString()
          : null;
      memory[DartBlockVariableDefinition(entry.key, entry.value)] = value;
    }
    for (var child in children) {
      memory.addAll(child.getAllValues(arbiter));
    }

    return memory;
  }

  void clearChildren() {
    children.clear();
  }

  void clearMemory() {
    _memory.clear();
  }

  void copyFrom(DartBlockEnvironment environment) {
    _memory.clear();
    _memory.addAll(environment._memory);
    _memoryTypes.clear();
    _memoryTypes.addAll(environment._memoryTypes);
    children.clear();
    children.addAll(
      environment.children.map(
        (c) => DartBlockEnvironment.fromJson(c.toJson()),
      ),
    );

    // Ensure parent references are correct after copying children
    _rebuildParentReferences();
  }

  /// Create a deep copy of this environment (including children and memory).
  DartBlockEnvironment clone() {
    // toJson omits parent pointers (acyclic); fromJson rebuilds parents.
    final json = toJson();
    return DartBlockEnvironment.fromJson(json);
  }

  /// After deserialization or copying, ensure every child points back to this
  /// environment as its parent. This prevents cycles during JSON (de)serialization
  /// while preserving the parent links at runtime.
  void _rebuildParentReferences() {
    for (var child in _children) {
      child.setParent(this);
      child._rebuildParentReferences();
    }
  }

  @override
  String toString() {
    return "$DartBlockEnvironment $key:\n$_memory\nIs root: ${parent == null}";
  }
}
