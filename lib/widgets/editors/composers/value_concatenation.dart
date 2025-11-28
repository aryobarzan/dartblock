import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:dartblock_code/models/function.dart';
import 'package:dartblock_code/models/dartblock_interaction.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/widgets/editors/composers/boolean_value.dart';
import 'package:dartblock_code/widgets/editors/composers/number_value.dart';
import 'package:dartblock_code/widgets/editors/composers/string_value.dart';
import 'package:dartblock_code/widgets/editors/function_call.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:dartblock_code/widgets/editors/misc.dart';
import 'package:dartblock_code/widgets/views/other/dartblock_colors.dart';
import 'package:reorderables/reorderables.dart';

class ConcatenationValueComposer extends StatefulWidget {
  final DartBlockConcatenationValue? value;
  final List<DartBlockVariableDefinition> variableDefinitions;
  final List<DartBlockCustomFunction> customFunctions;
  final Function(DartBlockConcatenationValue?) onChange;
  final Function() onInteract;
  const ConcatenationValueComposer({
    super.key,
    this.value,
    required this.variableDefinitions,
    required this.customFunctions,
    required this.onChange,
    required this.onInteract,
  });

  @override
  State<ConcatenationValueComposer> createState() =>
      _ConcatenationValueComposerState();
}

class _ConcatenationValueComposerState extends State<ConcatenationValueComposer>
    with SingleTickerProviderStateMixin {
  late DartBlockConcatenationValue value;
  final List<DartBlockConcatenationValue> undoHistory = [];
  final List<DartBlockConcatenationValue> redoHistory = [];

  _ConcatenationValueType? _concatenationValueType;
  int? _selectedIndex;
  bool _isEditingLastDeletedIndex = false;
  late AnimationController _animationController;
  late Animation _colorTween;

  DartBlockValue? getSelectedValue() =>
      _selectedIndex != null &&
          _selectedIndex! >= 0 &&
          _selectedIndex! < value.values.length
      ? value.values[_selectedIndex!]
      : null;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1, milliseconds: 500),
    )..repeat(reverse: true);
    _colorTween = ColorTween(
      begin: Colors.transparent,
      end: Colors.blue,
    ).animate(_animationController);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _colorTween = ColorTween(
        begin: Theme.of(context).colorScheme.primary,
        end: Theme.of(context).colorScheme.primaryContainer,
      ).animate(_animationController);
    });
    value = widget.value?.copy() ?? DartBlockConcatenationValue.init([]);
    if (value.values.isEmpty) {
      _concatenationValueType = _ConcatenationValueType.constantString;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).viewInsets.bottom == 0 ? 480 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildItems(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_selectedIndex != null)
                TextButton.icon(
                  onPressed: () {
                    DartBlockInteraction.create(
                      dartBlockInteractionType: DartBlockInteractionType
                          .deselectConcatenationValueComposerValueNode,
                      content: 'TappedButton',
                    ).dispatch(context);
                    widget.onInteract();
                    setState(() {
                      _selectedIndex = null;
                      _concatenationValueType = null;
                    });
                  },
                  label: const Text("Deselect"),
                  icon: const Icon(Icons.deselect),
                ),
              IconButton(
                tooltip: "Undo",
                color: Theme.of(context).colorScheme.primary,
                onPressed: undoHistory.isNotEmpty
                    ? () {
                        DartBlockInteraction.create(
                          dartBlockInteractionType: DartBlockInteractionType
                              .tapConcatenationValueComposerUndo,
                        ).dispatch(context);
                        widget.onInteract();
                        HapticFeedback.lightImpact();
                        _undo();
                      }
                    : null,
                icon: const Icon(Icons.undo),
              ),
              IconButton(
                tooltip: "Redo",
                color: Theme.of(context).colorScheme.primary,
                onPressed: redoHistory.isNotEmpty
                    ? () {
                        DartBlockInteraction.create(
                          dartBlockInteractionType: DartBlockInteractionType
                              .tapConcatenationValueComposerRedo,
                        ).dispatch(context);
                        widget.onInteract();
                        HapticFeedback.lightImpact();
                        _redo();
                      }
                    : null,
                icon: const Icon(Icons.redo),
              ),
              IconButton(
                tooltip: "Delete",
                color: Theme.of(context).colorScheme.primary,
                onPressed: value.values.isNotEmpty
                    ? () {
                        DartBlockInteraction.create(
                          dartBlockInteractionType: DartBlockInteractionType
                              .tapConcatenationValueComposerBackspace,
                        ).dispatch(context);
                        widget.onInteract();
                        HapticFeedback.lightImpact();
                        setState(() {
                          undoHistory.add(value.copy());
                          if (_selectedIndex != null &&
                              _isEditingLastDeletedIndex &&
                              _selectedIndex! >= 1 &&
                              _selectedIndex! <= value.values.length &&
                              value.values.isNotEmpty) {
                            value.values.removeAt(_selectedIndex! - 1);
                            _selectedIndex = max(0, _selectedIndex! - 1);
                          } else if (_selectedIndex != null &&
                              getSelectedValue() != null) {
                            value.values.removeAt(_selectedIndex!);
                            if (value.values.isNotEmpty &&
                                _selectedIndex! <= value.values.length) {
                              _isEditingLastDeletedIndex = true;
                              if (_selectedIndex! == value.values.length) {
                                _selectedIndex = _selectedIndex! + 1;
                              }
                            } else {
                              _selectedIndex = max(0, _selectedIndex! - 1);
                            }
                          } else {
                            value.values.removeLast();
                          }

                          if (_selectedIndex != null) {
                            if (_selectedIndex! >= value.values.length) {
                              _selectedIndex = _selectedIndex! - 1;
                            }
                            if (value.values.isEmpty) {
                              _selectedIndex = null;
                              _isEditingLastDeletedIndex = false;
                            }
                            _updateActiveConcatenationValueType();
                          }
                        });
                        _updateValue();
                      }
                    : null,
                icon: const Icon(Icons.backspace),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Wrap(
              spacing: 2,
              children: _ConcatenationValueType.values
                  .mapIndexed(
                    (idx, elem) => Tooltip(
                      message: elem.describeVerbal(),
                      child: _ConcatenationValueTypeButton(
                        concatenationValueType: elem,
                        isSelected: _concatenationValueType == elem,
                        isEnabled: true,
                        borderRadius: idx == 0
                            ? const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                bottomLeft: Radius.circular(24),
                              )
                            : idx == _ConcatenationValueType.values.length - 1
                            ? const BorderRadius.only(
                                topRight: Radius.circular(24),
                                bottomRight: Radius.circular(24),
                              )
                            : const BorderRadius.all(Radius.zero),
                        onTap: () {
                          widget.onInteract();
                          HapticFeedback.lightImpact();
                          setState(() {
                            final DartBlockInteractionType
                            dartBlockInteractionType;
                            if (_concatenationValueType == elem) {
                              dartBlockInteractionType = switch (elem) {
                                _ConcatenationValueType.constantString =>
                                  DartBlockInteractionType
                                      .tapConcatenationValueComposerTextToggleToHide,
                                _ConcatenationValueType.functionCall =>
                                  DartBlockInteractionType
                                      .tapConcatenationValueComposerFunctionCallToggleToHide,
                                _ConcatenationValueType.variable =>
                                  DartBlockInteractionType
                                      .tapConcatenationValueComposerVariablePickerToggleToHide,
                                _ConcatenationValueType.numericExpression =>
                                  DartBlockInteractionType
                                      .tapConcatenationValueComposerNumberToggleToHide,
                                _ConcatenationValueType.booleanExpression =>
                                  DartBlockInteractionType
                                      .tapConcatenationValueComposerBooleanToggleToHide,
                              };
                              _concatenationValueType = null;
                              if (!_isEditingLastDeletedIndex) {
                                _selectedIndex = null;
                              }
                            } else {
                              dartBlockInteractionType = switch (elem) {
                                _ConcatenationValueType.constantString =>
                                  DartBlockInteractionType
                                      .tapConcatenationValueComposerTextToggleToShow,
                                _ConcatenationValueType.functionCall =>
                                  DartBlockInteractionType
                                      .tapConcatenationValueComposerFunctionCallToggleToShow,
                                _ConcatenationValueType.variable =>
                                  DartBlockInteractionType
                                      .tapConcatenationValueComposerVariablePickerToggleToShow,
                                _ConcatenationValueType.numericExpression =>
                                  DartBlockInteractionType
                                      .tapConcatenationValueComposerNumberToggleToShow,
                                _ConcatenationValueType.booleanExpression =>
                                  DartBlockInteractionType
                                      .tapConcatenationValueComposerBooleanToggleToShow,
                              };
                              _concatenationValueType = elem;
                            }
                            DartBlockInteraction.create(
                              dartBlockInteractionType:
                                  dartBlockInteractionType,
                            ).dispatch(context);
                          });
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 2,
              right: 2,
              bottom: 2,
              top: 6,
            ),
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              border: _concatenationValueType != null
                  ? Border(
                      top: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : null,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: _buildEditor(),
          ),
        ],
      ),
    );
  }

  void _updateValue() {
    widget.onChange(value.values.isEmpty ? null : value);
  }

  void _undo() {
    if (undoHistory.isNotEmpty) {
      final previousLength = value.values.length;
      setState(() {
        redoHistory.add(value.copy());
        value = undoHistory.removeLast();
      });
      if (value.values.length != previousLength) {
        _selectedIndex = null;
      }
      _updateValue();
    }
  }

  void _redo() {
    if (redoHistory.isNotEmpty) {
      final previousLength = value.values.length;
      setState(() {
        undoHistory.add(value.copy());
        value = redoHistory.removeLast();
      });
      if (value.values.length != previousLength) {
        _selectedIndex = null;
      }
      _updateValue();
    }
  }

  Widget _buildItems() {
    if (value.values.isNotEmpty) {
      List<Widget> children = [];
      for (int index = 0; index < value.values.length; index++) {
        if (_selectedIndex != null &&
            _isEditingLastDeletedIndex &&
            _selectedIndex == index) {
          children.add(
            AbsorbPointer(
              child: IgnorePointer(
                child: GestureDetector(
                  onLongPress: () {},
                  child: AnimatedBuilder(
                    animation: _colorTween,
                    builder: (context, child) => Container(
                      width: 40,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _colorTween.value,
                        border: Border.all(
                          width: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: _selectedIndex! == 0
                              ? const Radius.circular(12)
                              : Radius.zero,
                          bottomLeft: _selectedIndex! == 0
                              ? const Radius.circular(12)
                              : Radius.zero,
                          topRight: _selectedIndex! < value.values.length - 1
                              ? const Radius.circular(12)
                              : Radius.zero,
                          bottomRight: _selectedIndex! < value.values.length - 1
                              ? const Radius.circular(12)
                              : Radius.zero,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        children.add(_buildItem(index, value.values[index]));
      }
      return ReorderableWrap(
        needsLongPressDraggable: false,
        onReorder: (oldIndex, newIndex) {
          // If the user is trying to reorderf the 'cursor' tile, ignore.
          if (_selectedIndex != null &&
              _isEditingLastDeletedIndex &&
              oldIndex == _selectedIndex) {
            // Do nothing
          } else {
            DartBlockInteraction.create(
              dartBlockInteractionType: DartBlockInteractionType
                  .reorderConcatenationValueComposerValueNode,
            ).dispatch(context);
            setState(() {
              // If the 'cursor' tile is visible, adjust the indices accordingly.
              if (_selectedIndex != null && _isEditingLastDeletedIndex) {
                final adjustedOldIndex = oldIndex >= _selectedIndex!
                    ? oldIndex - 1
                    : oldIndex;
                final int adjustedNewIndex;
                // User is moving an element backwards
                if (newIndex < oldIndex) {
                  adjustedNewIndex = newIndex > _selectedIndex!
                      ? newIndex - 1
                      : newIndex;
                }
                // User is moving an element forwards
                else {
                  adjustedNewIndex = newIndex >= _selectedIndex!
                      ? newIndex - 1
                      : newIndex;
                }

                final item = value.values.removeAt(adjustedOldIndex);
                value.values.insert(adjustedNewIndex, item);
              }
              // 'Cursor' tile is not visible, no index adjustment required.
              else {
                final item = value.values.removeAt(oldIndex);
                value.values.insert(newIndex, item);
              }
              // If the user has reordered the element that was previously selected,
              // adjust the selected index such that the same element is still selected.
              if (!_isEditingLastDeletedIndex && _selectedIndex != null) {
                if (_selectedIndex == oldIndex) {
                  _selectedIndex = newIndex;
                }
              }
              // Hide the 'cursor' tile.
              _isEditingLastDeletedIndex = false;
              // If the selected index is no longer valid, void it.
              if (_selectedIndex != null &&
                  _selectedIndex! >= value.values.length) {
                _selectedIndex = null;
              }
            });
          }
        },
        alignment: WrapAlignment.center,
        spacing: 1,
        runSpacing: 1,
        children: children,
        // children: value.values
        //     .mapIndexed((index, item) => _buildItem(index, item))
        //     .toList(),
      );
    } else {
      // ConstrainedBox ensures the UI does not shift downwards/upwards when the user adds a value.
      return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 32),
        child: Center(
          child: Text(
            "No value (null)",
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.apply(fontStyle: FontStyle.italic),
          ),
        ),
      );
    }
  }

  void _updateActiveConcatenationValueType() {
    if (_selectedIndex != null) {
      if (_isEditingLastDeletedIndex) {
        _concatenationValueType = null;
        return;
      }
      final selectedValue = getSelectedValue();
      if (selectedValue != null) {
        final _ConcatenationValueType newConcatenationValueType;
        switch (selectedValue) {
          case DartBlockVariable():
            newConcatenationValueType = _ConcatenationValueType.variable;

            break;
          case DartBlockFunctionCallValue():
            newConcatenationValueType = _ConcatenationValueType.functionCall;

            break;
          case DartBlockStringValue():
            newConcatenationValueType = _ConcatenationValueType.constantString;

            break;
          case DartBlockAlgebraicExpression():
            newConcatenationValueType =
                _ConcatenationValueType.numericExpression;

            break;
          case DartBlockBooleanExpression():
            newConcatenationValueType =
                _ConcatenationValueType.booleanExpression;

            break;
          case DartBlockConcatenationValue():
            // This case should never actually come up, but it is covered for exhaustiveness purposes.
            newConcatenationValueType = _ConcatenationValueType.constantString;

            break;
        }
        if (newConcatenationValueType != _concatenationValueType) {
          _concatenationValueType = newConcatenationValueType;
        }
      }
    }
  }

  Widget _buildItem(int index, DartBlockValue item) {
    final _ConcatenationValueType concatenationValueType;
    final Widget child;
    switch (item) {
      case DartBlockVariable():
        concatenationValueType = _ConcatenationValueType.variable;
        child = _buildChip(
          item.name,
          DartBlockColors.variable,
          Colors.white,
          index,
        );
        break;
      case DartBlockFunctionCallValue():
        concatenationValueType = _ConcatenationValueType.functionCall;
        child = _buildChip(
          item.toString(),
          DartBlockColors.function,
          Colors.white,
          index,
        );
        break;
      case DartBlockStringValue():
        concatenationValueType = _ConcatenationValueType.constantString;
        child = _buildChip(
          item.value,
          DartBlockColors.string,
          Colors.white,
          index,
        );
        break;
      case DartBlockAlgebraicExpression():
        concatenationValueType = _ConcatenationValueType.numericExpression;
        child = _buildChip(
          item.toString(),
          DartBlockColors.number,
          Colors.white,
          index,
        );
        break;
      case DartBlockBooleanExpression():
        concatenationValueType = _ConcatenationValueType.booleanExpression;
        child = _buildChip(
          item.toString(),
          DartBlockColors.boolean,
          Colors.white,
          index,
        );
        break;
      case DartBlockConcatenationValue():
        // This case should never actually come up, but it is covered for exhaustiveness purposes.
        concatenationValueType = _ConcatenationValueType.constantString;
        child = const SizedBox();
        break;
    }
    return InkWell(
      onTap: () {
        setState(() {
          widget.onInteract();
          if (getSelectedValue() == item) {
            DartBlockInteraction.create(
              dartBlockInteractionType: DartBlockInteractionType
                  .deselectConcatenationValueComposerValueNode,
            ).dispatch(context);
            _selectedIndex = null;
            _concatenationValueType = null;
          } else {
            DartBlockInteraction.create(
              dartBlockInteractionType: DartBlockInteractionType
                  .selectConcatenationValueComposerValueNode,
            ).dispatch(context);
            _selectedIndex = index;
            _concatenationValueType = concatenationValueType;
          }
          _isEditingLastDeletedIndex = false;
        });
      },
      child: child,
    );
  }

  Widget _buildChip(
    String text,
    Color backgroundColor,
    Color textColor,
    int itemIndex,
  ) {
    final isLeftCircular = value.values.length == 1 || itemIndex == 0;
    final isRightCircular =
        value.values.length == 1 || itemIndex == value.values.length - 1;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          width: 2,
          color: itemIndex == _selectedIndex && !_isEditingLastDeletedIndex
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
        ),
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(isLeftCircular ? 12 : 0),
          right: Radius.circular(isRightCircular ? 12 : 0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.apply(color: textColor),
        ),
      ),
    );
  }

  Widget _buildEditor() {
    if (_concatenationValueType != null) {
      final selectedValue = getSelectedValue();
      switch (_concatenationValueType!) {
        case _ConcatenationValueType.constantString:
          return StringValueComposer(
            /// Important to specify key: if the user has currently selected another StringValue
            /// and they change their selection to a different StringValue, the editor's value will not update.
            /// By giving the StringValueComposer stateful widget a unique key depending on the selected index,
            /// the value being edited will appropriately appear when the editor is refreshed.
            /// This process (*) needs to be repeated for each type of editor.
            key: _selectedIndex != null
                ? ValueKey("StringValueComposer-$_selectedIndex")
                : null,
            value: selectedValue is DartBlockStringValue ? selectedValue : null,
            onChange: (newValue) {
              _onChangeValue(newValue);
            },
            onSubmitted: (submittedValue) {
              setState(() {
                if (_selectedIndex != null) {
                  if (_isEditingLastDeletedIndex) {
                    _isEditingLastDeletedIndex = false;
                    if (_selectedIndex! >= value.values.length) {
                      _selectedIndex = null;
                    }
                  } else {
                    _selectedIndex = null;
                  }
                } else {}
                _concatenationValueType = null;
              });
            },
          );
        case _ConcatenationValueType.functionCall:
          return FunctionCallComposer(
            key: _selectedIndex != null
                ? ValueKey("FunctionCallComposer-$_selectedIndex")
                : null,
            statement: selectedValue is DartBlockFunctionCallValue
                ? selectedValue.functionCall
                : null,
            autoSelectDefaultFunction: false,
            customFunctions: widget.customFunctions,
            existingVariableDefinitions: widget.variableDefinitions,
            onChange: (customFunction, newFunctionCallStatement) {
              _onChangeValue(
                DartBlockFunctionCallValue.init(newFunctionCallStatement),
              );
            },
            showArgumentEditorAsModalBottomSheet: true,
            // Allow all function return types, except for void!
            restrictToDataTypes: DartBlockDataType.values,
          );
        case _ConcatenationValueType.variable:
          return VariableDefinitionPicker(
            ///  (*) See explanation above.
            key: _selectedIndex != null
                ? ValueKey("VariablePicker-$_selectedIndex")
                : null,
            variableDefinitions: widget.variableDefinitions,
            selectedVariableDefinitionName: selectedValue is DartBlockVariable
                ? selectedValue.name
                : null,
            onPick: (pickedVariableDefinition) {
              _onChangeValue(
                DartBlockVariable.init(pickedVariableDefinition.name),
              );
            },
          );
        case _ConcatenationValueType.numericExpression:
          return NumberValueComposer(
            ///  (*) See explanation above.
            key: _selectedIndex != null
                ? ValueKey("NumberValueComposer-$_selectedIndex")
                : null,
            value: selectedValue is DartBlockAlgebraicExpression
                ? selectedValue.compositionNode
                : null,
            variableDefinitions: widget.variableDefinitions,
            customFunctions: widget.customFunctions,
            onChange: (newAlgebraicNode) {
              _onChangeValue(
                newAlgebraicNode != null
                    ? DartBlockAlgebraicExpression.init(newAlgebraicNode)
                    : null,
              );
            },
          );
        case _ConcatenationValueType.booleanExpression:
          return BooleanValueComposer(
            ///  (*) See explanation above.
            key: _selectedIndex != null
                ? ValueKey("BooleanValueComposer-$_selectedIndex")
                : null,
            value: selectedValue is DartBlockBooleanExpression
                ? selectedValue.compositionNode
                : null,
            variableDefinitions: widget.variableDefinitions,
            customFunctions: widget.customFunctions,
            onChange: (newBooleanNode) {
              _onChangeValue(
                newBooleanNode != null
                    ? DartBlockBooleanExpression.init(newBooleanNode)
                    : null,
              );
            },
          );
      }
    } else {
      return const SizedBox();
    }
  }

  void _onChangeValue(DartBlockValue? newValue) {
    setState(() {
      if (_isEditingLastDeletedIndex) {
        final currentIndex = max(
          0,
          min(_selectedIndex ?? 0, value.values.length),
        );
        if (newValue == null) {
          // do nothing
        } else {
          undoHistory.add(value.copy());
          if (currentIndex >= value.values.length) {
            value.values.add(newValue.copy());
          } else {
            value.values.insert(currentIndex, newValue.copy());
          }
          _isEditingLastDeletedIndex = false;
          _updateValue();
        }
      } else if (_selectedIndex != null) {
        if (newValue == null) {
          undoHistory.add(value.copy());
          value.values.removeAt(_selectedIndex!);
          if (_selectedIndex! < value.values.length) {
            _isEditingLastDeletedIndex = true;
          } else {
            // If the selected element had been the last one, just clear the selection.
            _selectedIndex = null;
          }
          _updateValue();
        } else {
          undoHistory.add(value.copy());
          if (_selectedIndex! >= 0 && _selectedIndex! < value.values.length) {
            value.values[_selectedIndex!] = newValue.copy();
          } else {
            value.values.add(newValue);
          }
          _updateValue();
        }
      } else if (newValue != null) {
        undoHistory.add(value.copy());
        value.values.add(newValue.copy());
        _selectedIndex = value.values.length - 1;
        _updateValue();
      }
    });
  }
}

enum _ConcatenationValueType {
  constantString,
  functionCall,
  variable,
  numericExpression,
  booleanExpression;

  @override
  String toString() {
    return switch (this) {
      _ConcatenationValueType.constantString => 'Constant',
      _ConcatenationValueType.functionCall => 'Function',
      _ConcatenationValueType.variable => 'Variable',
      _ConcatenationValueType.numericExpression => 'Number',
      _ConcatenationValueType.booleanExpression => 'Boolean',
    };
  }

  /// Describe the concatenation value type in spoken English (short).
  String describeVerbal() {
    switch (this) {
      case _ConcatenationValueType.constantString:
        return "Text";
      case _ConcatenationValueType.functionCall:
        return "Function call";
      case _ConcatenationValueType.variable:
        return "Variable";
      case _ConcatenationValueType.numericExpression:
        return "Numeric expression";
      case _ConcatenationValueType.booleanExpression:
        return "Boolean expression";
    }
  }
}

class _ConcatenationValueTypeButton extends StatelessWidget {
  final _ConcatenationValueType concatenationValueType;
  final bool isSelected;
  final bool isEnabled;
  final Function onTap;
  final BorderRadius? borderRadius;
  const _ConcatenationValueTypeButton({
    required this.concatenationValueType,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          borderRadius: borderRadius ?? BorderRadius.circular(24),
          color: isEnabled
              ? isSelected
                    ? _getTypeColor(context)
                    : Theme.of(context).colorScheme.primaryContainer
              : Colors.grey,
          child: InkWell(
            borderRadius: borderRadius ?? BorderRadius.circular(24),
            onTap: isEnabled
                ? () {
                    onTap();
                  }
                : null,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: borderRadius ?? BorderRadius.circular(24),
                border: isSelected
                    ? Border.all(
                        strokeAlign: BorderSide.strokeAlignOutside,
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      )
                    : null,
              ),
              width: 80,
              height: 40,
              child: _buildTypeLabel(context),
            ),
          ),
        ),
        if (isSelected) ...[
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: ArrowHeadWidget(
              direction: AxisDirection.up,
              strokeColor: Theme.of(context).colorScheme.primary,
              size: const Size(12, 8),
            ),
          ),
          Text(
            concatenationValueType.toString(),
            style: Theme.of(context).textTheme.bodySmall?.apply(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Container(
            width: 1,
            height: 8,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ],
    );
  }

  Widget _buildTypeLabel(BuildContext context) {
    return switch (concatenationValueType) {
      _ConcatenationValueType.constantString => Text(
        "Text",
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isEnabled
              ? isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onPrimaryContainer
              : Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      _ConcatenationValueType.functionCall => Image.asset(
        'assets/icons/neotech_function.png',
        package: 'dartblock_code',
        width: 20,
        height: 20,
        color: isEnabled
            ? isSelected
                  ? Colors.white.withValues(alpha: isEnabled ? 1.0 : 0.5)
                  : Theme.of(context).colorScheme.onPrimaryContainer
            : Colors.black,
      ),
      _ConcatenationValueType.variable => Image.asset(
        'assets/icons/neotech_variable.png',
        package: 'dartblock_code',
        width: 20,
        height: 20,
        color: isEnabled
            ? isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onPrimaryContainer
            : Colors.black,
      ),
      _ConcatenationValueType.numericExpression => Text(
        "123",
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isEnabled
              ? isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onPrimaryContainer
              : Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      _ConcatenationValueType.booleanExpression => Text(
        "&&",
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isEnabled
              ? isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onPrimaryContainer
              : Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    };
  }

  Color _getTypeColor(BuildContext context) {
    if (!isEnabled) {
      return Colors.white24;
    }
    return switch (concatenationValueType) {
      _ConcatenationValueType.constantString => DartBlockColors.string,
      _ConcatenationValueType.functionCall => DartBlockColors.function,
      _ConcatenationValueType.variable => DartBlockColors.variable,
      _ConcatenationValueType.numericExpression => DartBlockColors.number,
      _ConcatenationValueType.booleanExpression => DartBlockColors.boolean,
    };
  }
}
