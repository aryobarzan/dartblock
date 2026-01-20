import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dartblock_code/widgets/dartblock_editor_providers.dart';
import 'package:dartblock_code/widgets/editors/composers/components/composer_common_button.dart';
import 'package:dartblock_code/widgets/editors/composers/components/variable_definition_picker.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:dartblock_code/models/dartblock_interaction.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/widgets/editors/composers/boolean_value.dart';
import 'package:dartblock_code/widgets/editors/composers/number_value.dart';
import 'package:dartblock_code/widgets/editors/composers/string_value.dart';
import 'package:dartblock_code/widgets/editors/function_call.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConcatenationValueComposer extends ConsumerStatefulWidget {
  final DartBlockConcatenationValue? value;
  final List<DartBlockVariableDefinition> variableDefinitions;
  final Function(DartBlockConcatenationValue?) onChange;
  final Function() onInteract;
  final String? valueLabel;
  const ConcatenationValueComposer({
    super.key,
    this.value,
    required this.variableDefinitions,
    required this.onChange,
    required this.onInteract,
    this.valueLabel,
  });

  @override
  ConsumerState<ConcatenationValueComposer> createState() =>
      _ConcatenationValueComposerState();
}

class _ConcatenationValueComposerState
    extends ConsumerState<ConcatenationValueComposer>
    with SingleTickerProviderStateMixin {
  late DartBlockConcatenationValue value;
  final List<DartBlockConcatenationValue> undoHistory = [];
  final List<DartBlockConcatenationValue> redoHistory = [];

  _ConcatenationValueType? _concatenationValueType;
  int? _selectedIndex;
  bool _isEditingLastDeletedIndex = false;
  // Track if we're adding a new value or rather editing an existing one.
  bool _isAddingNewValue = false;
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
    final fullRadius = 24.0;
    final halfRadius = 12.0;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).viewInsets.bottom == 0 ? 480 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildItems(),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            primary: false,
            padding: EdgeInsets.zero,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            crossAxisCount: 4,
            childAspectRatio: 4 / 2.25,
            children: [
              if (_concatenationValueType != null)
                ComposerCommonButton(
                  onTap: () {
                    DartBlockInteraction.create(
                      dartBlockInteractionType: DartBlockInteractionType
                          .deselectConcatenationValueComposerValueNode,
                      content: 'TappedButton',
                    ).dispatch(context);
                    widget.onInteract();
                    setState(() {
                      _selectedIndex = null;
                      _concatenationValueType = null;
                      _isAddingNewValue = false;
                    });
                  },
                  tooltipMessage: "Deselect",
                  child: Icon(Icons.deselect),
                )
              else
                SizedBox(),
              ComposerCommonButton(
                onTap: undoHistory.isNotEmpty
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
                tooltipMessage: "Undo",
                child: Icon(Icons.undo),
              ),
              ComposerCommonButton(
                onTap: redoHistory.isNotEmpty
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
                tooltipMessage: "Redo",
                child: Icon(Icons.redo),
              ),
              ComposerCommonButton(
                onTap: value.values.isNotEmpty
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
                tooltipMessage: "Delete",
                child: Icon(Icons.backspace_outlined),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                        borderRadius: _concatenationValueType == elem
                            ? BorderRadius.circular(fullRadius)
                            : idx == 0
                            ? BorderRadius.only(
                                topLeft: Radius.circular(fullRadius),
                                bottomLeft: Radius.circular(fullRadius),
                                topRight: Radius.circular(halfRadius),
                                bottomRight: Radius.circular(halfRadius),
                              )
                            : idx ==
                                      _ConcatenationValueType.values.length -
                                          1 &&
                                  _ConcatenationValueType.values.length > 1
                            ? BorderRadius.only(
                                topRight: Radius.circular(fullRadius),
                                bottomRight: Radius.circular(fullRadius),
                                topLeft: Radius.circular(halfRadius),
                                bottomLeft: Radius.circular(halfRadius),
                              )
                            : BorderRadius.circular(halfRadius),
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
                              _isAddingNewValue =
                                  false; // Reset when hiding editor
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
                              _isAddingNewValue =
                                  false; // Reset when switching types
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
                        color: _getTypeColor(ref, _concatenationValueType!),
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
    Widget child;
    if (value.values.isNotEmpty) {
      List<Widget> children = [];
      for (int index = 0; index < value.values.length; index++) {
        if (_selectedIndex != null &&
            _isEditingLastDeletedIndex &&
            _selectedIndex == index) {
          children.add(
            AbsorbPointer(
              key: ValueKey("cursor_$index"),
              child: IgnorePointer(
                child: GestureDetector(
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

      child = ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 42, maxHeight: 60),
        child: Padding(
          padding: EdgeInsetsGeometry.only(
            bottom: 12,
            top: widget.valueLabel != null ? 20 : 12,
            left: 12,
            right: 12,
          ),
          child: ReorderableListView(
            buildDefaultDragHandles: false,
            scrollDirection: Axis.horizontal,
            children: children,
            onReorder: (oldIndex, newIndex) {
              // If the user is trying to reorder the 'cursor' tile, ignore.
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
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }

                  // If the 'cursor' tile is visible, adjust the indices accordingly.
                  if (_selectedIndex != null && _isEditingLastDeletedIndex) {
                    final adjustedOldIndex = oldIndex > _selectedIndex!
                        ? oldIndex - 1
                        : oldIndex;
                    final adjustedNewIndex = newIndex > _selectedIndex!
                        ? newIndex - 1
                        : newIndex;

                    final item = value.values.removeAt(adjustedOldIndex);
                    value.values.insert(adjustedNewIndex, item);
                  }
                  // 'Cursor' tile is not visible, no index adjustment required.
                  else {
                    final item = value.values.removeAt(oldIndex);
                    value.values.insert(newIndex, item);

                    // If the user has reordered the element that was previously selected,
                    // or reordered other elements around it, adjust the selected index.
                    if (_selectedIndex != null) {
                      if (_selectedIndex == oldIndex) {
                        _selectedIndex = newIndex;
                      } else if (oldIndex < _selectedIndex! &&
                          newIndex >= _selectedIndex!) {
                        _selectedIndex = _selectedIndex! - 1;
                      } else if (oldIndex > _selectedIndex! &&
                          newIndex <= _selectedIndex!) {
                        _selectedIndex = _selectedIndex! + 1;
                      }
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
          ),
        ),
      );
    } else {
      // ConstrainedBox ensures the UI does not shift downwards/upwards when the user adds a value.
      child = ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 42, maxHeight: 60),
        child: Padding(
          padding: EdgeInsetsGeometry.only(
            bottom: 12,
            top: widget.valueLabel != null ? 20 : 12,
            left: 12,
            right: 12,
          ),
          child: Center(
            child: Text(
              "null",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.apply(fontStyle: FontStyle.italic),
            ),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          child,
          if (widget.valueLabel != null)
            Positioned(
              top: 2,
              left: 4,
              child: Text(
                widget.valueLabel!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
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
    final settings = ref.watch(settingsProvider);
    switch (item) {
      case DartBlockVariable():
        concatenationValueType = _ConcatenationValueType.variable;
        child = _buildChip(
          item.name,
          settings.colorFamily.variable.color,
          settings.colorFamily.variable.onColor,
          index,
        );
        break;
      case DartBlockFunctionCallValue():
        concatenationValueType = _ConcatenationValueType.functionCall;
        child = _buildChip(
          item.toString(),
          settings.colorFamily.function.color,
          settings.colorFamily.function.onColor,
          index,
        );
        break;
      case DartBlockStringValue():
        concatenationValueType = _ConcatenationValueType.constantString;
        child = _buildChip(
          "\"${item.value}\"",
          settings.colorFamily.string.color,
          settings.colorFamily.string.onColor,
          index,
        );
        break;
      case DartBlockAlgebraicExpression():
        concatenationValueType = _ConcatenationValueType.numericExpression;
        child = _buildChip(
          item.toString(),
          settings.colorFamily.number.color,
          settings.colorFamily.number.onColor,
          index,
        );
        break;
      case DartBlockBooleanExpression():
        concatenationValueType = _ConcatenationValueType.booleanExpression;
        child = _buildChip(
          item.toString(),
          settings.colorFamily.boolean.color,
          settings.colorFamily.boolean.onColor,
          index,
        );
        break;
      case DartBlockConcatenationValue():
        // This case should never actually come up, but it is covered for exhaustiveness purposes.
        concatenationValueType = _ConcatenationValueType.constantString;
        child = const SizedBox();
        break;
    }
    // We use the delayed variant to avoid interfering with the horizontal scrolling nature
    // of the parent ReorderableListView.
    return ReorderableDelayedDragStartListener(
      index: index,
      key: ValueKey("item_$index"),
      child: Padding(
        padding: EdgeInsetsGeometry.only(
          right: index == value.values.length - 1 ? 0 : 2,
        ),
        child: InkWell(
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
              _isAddingNewValue = false; // Reset when switching selection
            });
          },
          child: child,
        ),
      ),
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

    final child = Container(
      // Necessary, as otherwise it will not take up the full available height in the ReorderableListView (32 based on the ConstrainedBox), when placed inside a Stack.
      height: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
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

    if ((itemIndex == _selectedIndex && !_isEditingLastDeletedIndex) ||
        (_isAddingNewValue && itemIndex == value.values.length - 1)) {
      // Arrow indicator for the selected item
      // Badge is not used, as it interferes with the height of the item.
      return Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          child,
          Transform.translate(
            offset: const Offset(0, 12),
            child: ArrowHeadWidget(
              strokeColor: Theme.of(context).colorScheme.primary,
              direction: AxisDirection.up,
              size: const Size(12, 12),
            ),
          ),
        ],
      );
    }

    return child;
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
            existingVariableDefinitions: widget.variableDefinitions,
            onChange: (customFunction, newFunctionCallStatement) {
              _onChangeValue(
                DartBlockFunctionCallValue.init(newFunctionCallStatement),
              );
            },
            showArgumentEditorAsModalBottomSheet: false,
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
          return LayoutBuilder(
            builder: (context, constraints) {
              return FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                  child: NumberValueComposer(
                    ///  (*) See explanation above.
                    key: _selectedIndex != null
                        ? ValueKey("NumberValueComposer-$_selectedIndex")
                        : null,
                    value: selectedValue is DartBlockAlgebraicExpression
                        ? selectedValue.compositionNode
                        : null,
                    variableDefinitions: widget.variableDefinitions,
                    onChange: (newAlgebraicNode) {
                      _onChangeValue(
                        newAlgebraicNode != null
                            ? DartBlockAlgebraicExpression.init(
                                newAlgebraicNode,
                              )
                            : null,
                      );
                    },
                  ),
                ),
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
        // User is adding a new value and no index is currently selected.
        if (_isAddingNewValue) {
          undoHistory.add(value.copy());
          if (value.values.isNotEmpty) {
            // Update the last added value instead of adding another
            value.values[value.values.length - 1] = newValue.copy();
          } else {
            value.values.add(newValue.copy());
          }
        } else {
          // This case corresponds to the user adding a new value for the first time.
          // Here, we add the new value and set the _isAddingNewValue flag to true.
          // The latter ensures that subsequent edits to this new value update it instead of adding more values.
          // Specifically, if for example the function call tab is active because the first added value is a function call,
          // then if the user continues modifying the function call, i.e., they do not actively select a specific index (value) or a specific editor tab (variable, number, ...),
          // we want to update the existing value instead of adding more function calls.
          // This flag is used to ensure the current editor does not close after adding the very first value,
          // as we avoid setting the _selectedIndex which would cause a reset of the editor.
          // Example: if the user adds the function call "triple(5)" as the first value, but they continue adding the digit 5, i.e., to make it "triple(55)",
          // we would instead of end up with two function calls "triple(5)" and "triple(55)", in the case of the flag not being used and instead the selected index being set automatically.
          // This flag instead ensures that the existing value is updated to "triple(55)".
          undoHistory.add(value.copy());
          value.values.add(newValue.copy());
          _isAddingNewValue = true;
        }
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

class _ConcatenationValueTypeButton extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          borderRadius: borderRadius ?? BorderRadius.circular(24),
          color: isEnabled
              ? isSelected
                    ? _getTypeColorContainer(context, ref)
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
              ),
              width: 80,
              height: 48,
              child: _buildTypeLabel(
                context,
                _getTypeOnColorContainer(context, ref),
              ),
            ),
          ),
        ),
        if (isSelected) ...[
          Container(
            width: 2,
            height: 8,
            color: _getTypeColor(ref, concatenationValueType),
          ),
          Text(
            concatenationValueType.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.apply(
              color: _getTypeColor(ref, concatenationValueType),
            ),
          ),
          Container(
            width: 2,
            height: 8,
            color: _getTypeColor(ref, concatenationValueType),
          ),
        ],
      ],
    );
  }

  Widget _buildTypeLabel(BuildContext context, Color textColor) {
    return switch (concatenationValueType) {
      _ConcatenationValueType.constantString => Text(
        "Text",
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isEnabled
              ? isSelected
                    ? textColor
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
                  ? textColor
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
                  ? textColor
                  : Theme.of(context).colorScheme.onPrimaryContainer
            : Colors.black,
      ),
      _ConcatenationValueType.numericExpression => Text(
        "123",
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isEnabled
              ? isSelected
                    ? textColor
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
                    ? textColor
                    : Theme.of(context).colorScheme.onPrimaryContainer
              : Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    };
  }

  Color _getTypeColorContainer(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    if (!isEnabled) {
      return Colors.white24;
    }
    return switch (concatenationValueType) {
      _ConcatenationValueType.constantString =>
        settings.colorFamily.string.colorContainer,
      _ConcatenationValueType.functionCall =>
        settings.colorFamily.function.colorContainer,
      _ConcatenationValueType.variable =>
        settings.colorFamily.variable.colorContainer,
      _ConcatenationValueType.numericExpression =>
        settings.colorFamily.number.colorContainer,
      _ConcatenationValueType.booleanExpression =>
        settings.colorFamily.boolean.colorContainer,
    };
  }

  Color _getTypeOnColorContainer(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    if (!isEnabled) {
      return Colors.white24;
    }
    return switch (concatenationValueType) {
      _ConcatenationValueType.constantString =>
        settings.colorFamily.string.onColorContainer,
      _ConcatenationValueType.functionCall =>
        settings.colorFamily.function.onColorContainer,
      _ConcatenationValueType.variable =>
        settings.colorFamily.variable.onColorContainer,
      _ConcatenationValueType.numericExpression =>
        settings.colorFamily.number.onColorContainer,
      _ConcatenationValueType.booleanExpression =>
        settings.colorFamily.boolean.onColorContainer,
    };
  }
}

Color _getTypeColor(
  WidgetRef ref,
  _ConcatenationValueType concatenationValueType,
) {
  final settings = ref.watch(settingsProvider);
  return switch (concatenationValueType) {
    _ConcatenationValueType.constantString => settings.colorFamily.string.color,
    _ConcatenationValueType.functionCall => settings.colorFamily.function.color,
    _ConcatenationValueType.variable => settings.colorFamily.variable.color,
    _ConcatenationValueType.numericExpression =>
      settings.colorFamily.number.color,
    _ConcatenationValueType.booleanExpression =>
      settings.colorFamily.boolean.color,
  };
}
