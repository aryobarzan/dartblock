import 'package:dartblock_code/widgets/editors/composers/components/button_group.dart';
import 'package:dartblock_code/widgets/editors/composers/components/composer_common_button.dart';
import 'package:dartblock_code/widgets/editors/composers/components/function_composer_button.dart';
import 'package:dartblock_code/widgets/editors/composers/components/variable_picker_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartblock_code/models/function.dart';
import 'package:dartblock_code/models/dartblock_interaction.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/widgets/editors/composers/number_value.dart';
import 'package:dartblock_code/widgets/editors/composers/string_value.dart';
import 'package:dartblock_code/widgets/dartblock_value_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BooleanValueComposer extends ConsumerStatefulWidget {
  final DartBlockValueTreeBooleanNode? value;
  final List<DartBlockVariableDefinition> variableDefinitions;
  final Function(DartBlockValueTreeBooleanNode?) onChange;
  final String? valueLabel;
  const BooleanValueComposer({
    super.key,
    this.value,
    required this.variableDefinitions,
    required this.onChange,
    this.valueLabel,
  });

  @override
  ConsumerState<BooleanValueComposer> createState() =>
      _BooleanValueComposerState();
}

class _BooleanValueComposerState extends ConsumerState<BooleanValueComposer> {
  DartBlockValueTreeBooleanNode? value;
  final List<DartBlockValueTreeBooleanNode?> undoHistory = [];
  final List<DartBlockValueTreeBooleanNode?> redoHistory = [];

  _BooleanComposerActiveComposerType? _booleanComposerActiveComposerType;
  @override
  void initState() {
    super.initState();
    value = widget.value?.copy();
  }

  String? selectedNodeKey;
  @override
  Widget build(BuildContext context) {
    final selectedNode = getSelectedNode();
    if (selectedNode == null) {
      selectedNodeKey = null;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const crossAxisCount = 4;
        const crossAxisSpacing = 2.0;
        const childAspectRatio = 2 / 1;

        final availableWidth = constraints.maxWidth;
        final itemWidth =
            (availableWidth - (crossAxisCount - 1) * crossAxisSpacing) /
            crossAxisCount;
        // Used to match the height of the button group with that of the GridView
        final itemHeight = itemWidth / childAspectRatio;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null &&
                    details.primaryVelocity != 0) {
                  DartBlockInteraction.create(
                    dartBlockInteractionType: DartBlockInteractionType
                        .swipeBooleanComposerValueToBackspace,
                  ).dispatch(context);
                  _onBackSpace();
                }
              },
              child: InkWell(
                onTap: selectedNodeKey != null
                    ? () {
                        DartBlockInteraction.create(
                          dartBlockInteractionType: DartBlockInteractionType
                              .deselectBooleanComposerValueNode,
                          content: 'TappedOutsideValue',
                        ).dispatch(context);
                        setState(() {
                          selectedNodeKey = null;
                        });
                      }
                    : null,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: 42,
                            maxHeight: 60,
                          ),
                          child: Center(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: value != null
                                  ? Padding(
                                      padding: EdgeInsetsGeometry.only(
                                        bottom: 12,
                                        top: widget.valueLabel != null
                                            ? 20
                                            : 12,
                                        left: 12,
                                        right: 12,
                                      ),
                                      child: ValueCompositionBooleanNodeWidget(
                                        node: value!,
                                        selectedNodeKey: selectedNodeKey,
                                        onTap: (tappedNode) {
                                          setState(() {
                                            if (selectedNodeKey ==
                                                tappedNode.nodeKey) {
                                              DartBlockInteraction.create(
                                                dartBlockInteractionType:
                                                    DartBlockInteractionType
                                                        .deselectBooleanComposerValueNode,
                                              ).dispatch(context);
                                              selectedNodeKey = null;
                                            } else {
                                              DartBlockInteraction.create(
                                                dartBlockInteractionType:
                                                    DartBlockInteractionType
                                                        .selectBooleanComposerValueNode,
                                              ).dispatch(context);
                                              selectedNodeKey =
                                                  tappedNode.nodeKey;
                                            }
                                          });
                                        },
                                        onChangeLogicalOperator:
                                            (logicalOperatorNode, newOperator) {
                                              if (newOperator !=
                                                  logicalOperatorNode
                                                      .operator) {
                                                DartBlockInteraction.create(
                                                  dartBlockInteractionType:
                                                      DartBlockInteractionType
                                                          .changeBooleanComposerLogicalOperatorThroughNode,
                                                ).dispatch(context);
                                                undoHistory.add(value?.copy());
                                                setState(() {
                                                  logicalOperatorNode.operator =
                                                      newOperator;
                                                  _updateValue(value);
                                                });
                                              }
                                            },
                                        onChangeEqualityOperator:
                                            (
                                              equalityOperatorNode,
                                              newOperator,
                                            ) {
                                              if (newOperator !=
                                                  equalityOperatorNode
                                                      .operator) {
                                                DartBlockInteraction.create(
                                                  dartBlockInteractionType:
                                                      DartBlockInteractionType
                                                          .changeBooleanComposerEqualityOperatorThroughNode,
                                                ).dispatch(context);
                                                undoHistory.add(value?.copy());
                                                setState(() {
                                                  equalityOperatorNode
                                                          .operator =
                                                      newOperator;
                                                  _updateValue(value);
                                                });
                                              }
                                            },
                                        onChangeNumberComparisonOperator:
                                            (
                                              numberComparisonOperatorNode,
                                              newOperator,
                                            ) {
                                              if (newOperator !=
                                                  numberComparisonOperatorNode
                                                      .operator) {
                                                DartBlockInteraction.create(
                                                  dartBlockInteractionType:
                                                      DartBlockInteractionType
                                                          .changeBooleanComposerNumberComparisonOperatorThroughNode,
                                                ).dispatch(context);
                                                undoHistory.add(value?.copy());
                                                setState(() {
                                                  numberComparisonOperatorNode
                                                          .operator =
                                                      newOperator;
                                                  _updateValue(value);
                                                });
                                              }
                                            },
                                      ),
                                    )
                                  : Text(
                                      'null',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.apply(fontStyle: FontStyle.italic),
                                    ),
                            ),
                          ),
                        ),
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
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              primary: false,
              padding: EdgeInsets.zero,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              crossAxisCount: 5,
              childAspectRatio: 2 / 1.4,
              children: [
                _buildFunctionComposerButton(),
                _buildVariablePickerButton(),
                _buildUndoButton(),
                _buildRedoButton(),
                _buildBackspaceButton(),
              ],
            ),
            const SizedBox(height: 4),
            GridView.count(
              shrinkWrap: true,
              primary: false,
              padding: EdgeInsets.zero,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              crossAxisCount: 4,
              childAspectRatio: 4 / 2.25,
              children: [
                _buildLogicalOperatorButton(DartBlockBooleanOperator.and),
                _buildLogicalOperatorButton(DartBlockBooleanOperator.or),
                _buildEqualityOperatorButton(DartBlockEqualityOperator.equal),
                _buildEqualityOperatorButton(
                  DartBlockEqualityOperator.notEqual,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Divider(),
            SizedBox(
              height: itemHeight,
              child: ButtonGroup<_BooleanComposerActiveComposerType?>(
                emptySelectionAllowed: true,
                items: [
                  ButtonGroupItem(
                    value: _BooleanComposerActiveComposerType.logic,
                    label: "Logic",
                  ),
                  ButtonGroupItem(
                    value: _BooleanComposerActiveComposerType.math,
                    label: "Math",
                  ),
                  ButtonGroupItem(
                    value: _BooleanComposerActiveComposerType.text,
                    label: "Text",
                  ),
                ],
                selected: _booleanComposerActiveComposerType != null
                    ? {_booleanComposerActiveComposerType}
                    : {},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    if (newSelection.isEmpty) {
                      _booleanComposerActiveComposerType = null;
                    } else {
                      _booleanComposerActiveComposerType = newSelection.first;
                    }
                  });
                },
              ),
            ),
            if (_booleanComposerActiveComposerType != null) SizedBox(height: 8),
            _buildActiveComposer(),
          ],
        );
      },
    );
  }

  Widget _buildFunctionComposerButton() {
    final selectedNode = getSelectedNode();

    final rightLeaf = (selectedNode ?? value)?.getRightLeaf();
    DartBlockFunctionCallValue? currentFunctionCallValue;
    if (rightLeaf is DartBlockValueTreeBooleanDynamicNode &&
        rightLeaf.value is DartBlockFunctionCallValue) {
      currentFunctionCallValue = rightLeaf.value as DartBlockFunctionCallValue;
    }

    return FunctionComposerButton(
      functionCallValue: currentFunctionCallValue,
      variableDefinitions: widget.variableDefinitions,
      restrictFunctionCallReturnTypes: const [
        DartBlockDataType.integerType,
        DartBlockDataType.doubleType,
      ],
      onSavedFunctionCallStatement: (customFunction, savedFunctionCall) {
        _onReceiveFunctionCall(
          customFunction,
          DartBlockFunctionCallValue.init(savedFunctionCall),
        );
      },
    );
  }

  Widget _buildVariablePickerButton() {
    return VariablePickerButton(
      variableDefinitions: widget.variableDefinitions,
      onPickedVariableDefinition: (pickedVariableDefinition) {
        _onReceiveVariableDefinition(pickedVariableDefinition);
      },
    );
  }

  Widget _buildActiveComposer() {
    return switch (_booleanComposerActiveComposerType) {
      null => const SizedBox(height: 16),
      _BooleanComposerActiveComposerType.logic => GridView.count(
        shrinkWrap: true,
        primary: false,
        padding: EdgeInsets.zero,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        crossAxisCount: 2,
        childAspectRatio: 4 / 1,
        children: [_buildConstantButton(true), _buildConstantButton(false)],
      ),
      _BooleanComposerActiveComposerType.math => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GridView.count(
            shrinkWrap: true,
            primary: false,
            padding: EdgeInsets.zero,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            crossAxisCount: 4,
            childAspectRatio: 4 / 2.25,
            children: [
              _buildNumberComparisonOperatorButton(
                DartBlockNumberComparisonOperator.greater,
              ),
              _buildNumberComparisonOperatorButton(
                DartBlockNumberComparisonOperator.greaterOrEqual,
              ),
              _buildNumberComparisonOperatorButton(
                DartBlockNumberComparisonOperator.lessOrEqual,
              ),
              _buildNumberComparisonOperatorButton(
                DartBlockNumberComparisonOperator.less,
              ),
            ],
          ),
          const SizedBox(height: 4),
          NumberValueComposer(
            key: ValueKey(
              "NumberValueComposer-${_getCurrentAlgebraicNode().hashCode}",
            ),
            value: _getCurrentAlgebraicNode(),
            variableDefinitions: widget.variableDefinitions,
            showValue: false,
            showBackspaceButton: false,
            showFunctionVariableButton: false,
            showUndoRedoButton: false,
            onChange: (neoValueAlgebraicNode) {
              _onReceiveNeoValueAlgebraicNode(neoValueAlgebraicNode);
            },
          ),
        ],
      ),
      _BooleanComposerActiveComposerType.text => StringValueComposer(
        value: _getCurrentStringValue(),
        onChange: (stringValue) {
          _onReceiveStringValue(stringValue);
        },
      ),
    };
  }

  DartBlockValueTreeBooleanNode? getSelectedNode() {
    return selectedNodeKey != null
        ? value?.findNodeByKey(selectedNodeKey!)
        : null;
  }

  void _onTapNumberComparisonOperator(
    DartBlockNumberComparisonOperator numberComparisonOperator,
  ) {
    DartBlockInteraction.create(
      dartBlockInteractionType:
          DartBlockInteractionType.tapBooleanComposerNumberComparisonOperator,
      content: 'Operator-${numberComparisonOperator.name}',
    ).dispatch(context);
    final selectedNode = getSelectedNode();
    undoHistory.add(value?.copy());
    setState(() {
      final DartBlockValueTreeBooleanNode? resultingNode;
      if (selectedNode != null) {
        resultingNode = selectedNode.receiveNumberComparisonOperator(
          numberComparisonOperator,
        );
      } else if (value != null) {
        resultingNode = value?.receiveNumberComparisonOperator(
          numberComparisonOperator,
        );
      } else {
        resultingNode =
            DartBlockValueTreeBooleanNumberComparisonOperatorNode.init(
              numberComparisonOperator,
              null,
              null,
              null,
            );
      }

      selectedNodeKey = resultingNode?.nodeKey;
      _updateValue(resultingNode);
    });
  }

  void _onReceiveDynamicValue(DartBlockDynamicValue dynamicValue) {
    final selectedNode = getSelectedNode();
    undoHistory.add(value?.copy());
    setState(() {
      final DartBlockValueTreeBooleanNode? resultingNode;
      if (selectedNode != null) {
        resultingNode = selectedNode.receiveDynamicValue(dynamicValue);
      } else if (value != null) {
        resultingNode = value!.receiveDynamicValue(dynamicValue);
      } else {
        resultingNode = DartBlockValueTreeBooleanDynamicNode.init(
          dynamicValue,
          null,
        );
      }
      _updateValue(resultingNode);
    });
  }

  void _onReceiveFunctionCall(
    DartBlockFunction function,
    DartBlockFunctionCallValue functionCallValue,
  ) {
    // Do not accept function calls with a 'void' return type
    if (function.returnType != null) {
      DartBlockInteraction.create(
        dartBlockInteractionType:
            DartBlockInteractionType.saveBooleanComposerFunctionCall,
        content: 'FunctionName-${function.name}',
      ).dispatch(context);
      switch (function.returnType!) {
        /// If the function call has a numeric return type, automatically
        /// wrap it in an AlgebraicExpression such that the user can use
        /// the number comparison operators such as >, == and <=.
        case DartBlockDataType.integerType:
        case DartBlockDataType.doubleType:
          setState(() {
            undoHistory.add(value?.copy());
            final selectedNode = getSelectedNode();
            final DartBlockValueTreeBooleanNode? resultingNode;
            final newNumberNode = DartBlockAlgebraicExpression.init(
              DartBlockValueTreeAlgebraicDynamicNode.init(
                functionCallValue,
                null,
              ),
            );

            if (selectedNode != null) {
              resultingNode = selectedNode.receiveNumberComposedValue(
                newNumberNode,
              );
            } else if (value != null) {
              resultingNode = value!.receiveNumberComposedValue(newNumberNode);
            } else {
              resultingNode = DartBlockValueTreeBooleanGenericNumberNode.init(
                newNumberNode,
                null,
              );
            }
            _updateValue(resultingNode);
          });
          break;

        /// For all other types, perform the generic behaviour of accepting
        /// a dynamic value.
        case DartBlockDataType.booleanType:
        case DartBlockDataType.stringType:
          _onReceiveDynamicValue(functionCallValue);
          return;
      }
    }
  }

  void _onReceiveVariableDefinition(
    DartBlockVariableDefinition variableDefinition,
  ) {
    DartBlockInteraction.create(
      dartBlockInteractionType:
          DartBlockInteractionType.pickBooleanComposerVariable,
      content:
          'Name-${variableDefinition.name}-Type-${variableDefinition.dataType}',
    ).dispatch(context);
    switch (variableDefinition.dataType) {
      /// If the variable has a numeric type, automatically
      /// wrap it in an AlgebraicExpression such that the user can use
      /// the number comparison operators such as >, == and <=.
      case DartBlockDataType.integerType:
      case DartBlockDataType.doubleType:
        setState(() {
          final selectedNode = getSelectedNode();
          undoHistory.add(value?.copy());
          final DartBlockValueTreeBooleanNode? resultingNode;
          final newNumberNode = DartBlockAlgebraicExpression.init(
            DartBlockValueTreeAlgebraicDynamicNode.init(
              DartBlockVariable.init(variableDefinition.name),
              null,
            ),
          );

          if (selectedNode != null) {
            resultingNode = selectedNode.receiveNumberComposedValue(
              newNumberNode,
            );
          } else if (value != null) {
            resultingNode = value!.receiveNumberComposedValue(newNumberNode);
          } else {
            resultingNode = DartBlockValueTreeBooleanGenericNumberNode.init(
              newNumberNode,
              null,
            );
          }
          _updateValue(resultingNode);
        });
        break;

      /// For all other types, perform the generic behaviour of accepting
      /// a dynamic value.
      case DartBlockDataType.booleanType:
      case DartBlockDataType.stringType:
        _onReceiveDynamicValue(DartBlockVariable.init(variableDefinition.name));
        return;
    }
  }

  Widget _buildUndoButton() {
    return ComposerCommonButton(
      onTap: undoHistory.isNotEmpty
          ? () {
              if (undoHistory.isNotEmpty) {
                DartBlockInteraction.create(
                  dartBlockInteractionType:
                      DartBlockInteractionType.tapBooleanComposerUndo,
                ).dispatch(context);
                HapticFeedback.lightImpact();
                setState(() {
                  redoHistory.add(value?.copy());
                  _updateValue(undoHistory.removeLast());
                });
              }
            }
          : null,
      tooltipMessage: "Undo",
      child: Icon(Icons.undo),
    );
  }

  Widget _buildRedoButton() {
    return ComposerCommonButton(
      onTap: redoHistory.isNotEmpty
          ? () {
              if (redoHistory.isNotEmpty) {
                DartBlockInteraction.create(
                  dartBlockInteractionType:
                      DartBlockInteractionType.tapBooleanComposerRedo,
                ).dispatch(context);
                HapticFeedback.lightImpact();
                setState(() {
                  undoHistory.add(value?.copy());
                  _updateValue(redoHistory.removeLast());
                });
              }
            }
          : null,
      tooltipMessage: "Redo",
      child: Icon(Icons.redo),
    );
  }

  Widget _buildBackspaceButton() {
    return ComposerCommonButton(
      tooltipMessage: "Delete",
      onTap: () {
        DartBlockInteraction.create(
          dartBlockInteractionType:
              DartBlockInteractionType.tapBooleanComposerBackspace,
        ).dispatch(context);
        HapticFeedback.lightImpact();
        _onBackSpace();
      },
      child: const Icon(Icons.backspace_outlined),
    );
  }

  void _onBackSpace() {
    final selectedNode = getSelectedNode();
    if (selectedNode != null || value != null) {
      undoHistory.add(value?.copy());

      setState(() {
        final DartBlockValueTreeBooleanNode? resultingNode;
        if (selectedNode != null) {
          resultingNode = selectedNode.backspace();
        } else if (value != null) {
          resultingNode = value!.backspace();
        } else {
          resultingNode = null;
        }

        /// Move selection outwards after node is deleted
        if (selectedNodeKey != null) {
          selectedNodeKey = resultingNode?.nodeKey;
        }

        /// Important: always update the root node, as it may even have
        /// been deleted.
        _updateValue(resultingNode);
        if (value == null) {
          selectedNodeKey = null;
        }
      });
    }
  }

  Widget _buildConstantButton(bool constant) {
    final selectedNode = getSelectedNode();

    return ComposerCommonButton(
      tooltipMessage: constant.toString(),
      onTap: () {
        DartBlockInteraction.create(
          dartBlockInteractionType:
              DartBlockInteractionType.tapBooleanComposerConstant,
          content: 'Constant-$constant',
        ).dispatch(context);
        HapticFeedback.lightImpact();
        undoHistory.add(value?.copy());
        setState(() {
          final DartBlockValueTreeBooleanNode? resultingNode;
          if (selectedNode != null) {
            resultingNode = selectedNode.receiveConstant(constant);
          } else if (value != null) {
            resultingNode = value!.receiveConstant(constant);
          } else {
            resultingNode = DartBlockValueTreeBooleanConstantNode.init(
              constant,
              null,
            );
          }
          _updateValue(resultingNode);
        });
      },
      child: Text(
        constant.toString(),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildNumberComparisonOperatorButton(
    DartBlockNumberComparisonOperator operator,
  ) {
    return ComposerCommonButton(
      tooltipMessage: operator.describeVerbal(),
      backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
      onTap: () {
        DartBlockInteraction.create(
          dartBlockInteractionType: DartBlockInteractionType
              .tapBooleanComposerNumberComparisonOperator,
          content: 'Operator-${operator.name}',
        ).dispatch(context);
        HapticFeedback.lightImpact();
        _onTapNumberComparisonOperator(operator);
      },
      child: Text(
        operator.toScript(),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }

  Widget _buildEqualityOperatorButton(DartBlockEqualityOperator operator) {
    return ComposerCommonButton(
      tooltipMessage: operator.describeVerbal(),
      backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
      onTap: () {
        DartBlockInteraction.create(
          dartBlockInteractionType:
              DartBlockInteractionType.tapBooleanComposerEqualityOperator,
          content: 'Operator-${operator.name}',
        ).dispatch(context);
        HapticFeedback.lightImpact();
        _onReceiveEqualityOperator(operator);
      },
      child: Text(
        operator.text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }

  Widget _buildLogicalOperatorButton(DartBlockBooleanOperator operator) {
    final selectedNode = getSelectedNode();

    return ComposerCommonButton(
      tooltipMessage: operator.describeVerbal(),
      backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
      onTap: () {
        if (selectedNode != null || value != null) {
          DartBlockInteraction.create(
            dartBlockInteractionType:
                DartBlockInteractionType.tapBooleanComposerLogicalOperator,
            content: 'Operator-${operator.name}',
          ).dispatch(context);
          HapticFeedback.lightImpact();
          undoHistory.add(value?.copy());
          setState(() {
            final DartBlockValueTreeBooleanNode? resultingNode;
            if (selectedNode != null) {
              resultingNode = selectedNode.receiveLogicalOperator(operator);
            } else if (value != null) {
              resultingNode = value?.receiveLogicalOperator(operator);
            } else {
              // Do not do anything if the current value is null, as it does not make sense to add a logical boolean operator in that case.
              resultingNode = null;
              // Previously, if the current value was null, the result would be "null &&", which does not make sense and is syntactically incorrect.
              // resultingNode = NeoValueBooleanOperatorNode.init(
              //   operator,
              //   null,
              //   null,
              //   null,
              // );
            }
            if (resultingNode != null) {
              selectedNodeKey = resultingNode.nodeKey;
              _updateValue(resultingNode);
            }
          });
        }
      },
      child: Text(
        operator.text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }

  void _onReceiveEqualityOperator(DartBlockEqualityOperator operator) {
    final selectedNode = getSelectedNode();
    undoHistory.add(value?.copy());
    setState(() {
      final DartBlockValueTreeBooleanNode? resultingNode;
      if (selectedNode != null) {
        resultingNode = selectedNode.receiveEqualityOperator(operator);
      } else if (value != null) {
        resultingNode = value?.receiveEqualityOperator(operator);
      } else {
        resultingNode = DartBlockValueTreeBooleanEqualityOperatorNode.init(
          operator,
          null,
          null,
          null,
        );
      }

      selectedNodeKey = resultingNode?.nodeKey;
      _updateValue(resultingNode);
    });
  }

  void _updateValue(DartBlockValueTreeBooleanNode? newValue) {
    /// Important: if it is the root node that is being changed, update
    /// the pointer to the root in this widget so as to point to the new
    /// root. Otherwise, the changes are not reflected.
    value = newValue?.getRoot();
    widget.onChange(value);
  }

  void _onReceiveStringValue(DartBlockStringValue? stringValue) {
    final selectedNode = getSelectedNode();
    undoHistory.add(value?.copy());
    if (stringValue != null) {
      final newValueConcatenation = DartBlockConcatenationValue.fromConstant(
        stringValue.value,
      );
      setState(() {
        final DartBlockValueTreeBooleanNode? resultingNode;
        if (selectedNode != null) {
          resultingNode = selectedNode.receiveValueConcatenation(
            newValueConcatenation,
          );
        } else if (value != null) {
          resultingNode = value!.receiveValueConcatenation(
            newValueConcatenation,
          );
        } else {
          resultingNode =
              DartBlockValueTreeBooleanGenericConcatenationNode.init(
                newValueConcatenation,
                null,
              );
        }
        _updateValue(resultingNode);
      });
    } else {
      // Delete the value concatenation from the boolean expression
      setState(() {
        if (selectedNode != null) {
          _updateValue(selectedNode.deleteRightLeaf());
        } else {
          _updateValue(value?.deleteRightLeaf());
        }
      });
    }
  }

  DartBlockStringValue? _getCurrentStringValue() {
    final selectedNode = getSelectedNode();
    final rightLeaf = (selectedNode ?? value)?.getRightLeaf();
    DartBlockConcatenationValue? currentValueConcatenation;
    if (rightLeaf is DartBlockValueTreeBooleanGenericConcatenationNode) {
      currentValueConcatenation = rightLeaf.value;
    }
    final lastValueInConcatenationValue =
        currentValueConcatenation?.values.lastOrNull;
    if (lastValueInConcatenationValue != null &&
        lastValueInConcatenationValue is DartBlockStringValue) {
      return lastValueInConcatenationValue;
    }
    return null;
  }

  DartBlockValueTreeAlgebraicNode? _getCurrentAlgebraicNode() {
    final selectedNode = getSelectedNode();
    final rightLeaf = (selectedNode ?? value)?.getRightLeaf();
    DartBlockValueTreeAlgebraicNode? currentNumber;
    if (rightLeaf is DartBlockValueTreeBooleanGenericNumberNode) {
      currentNumber = rightLeaf.value.compositionNode;
    }
    return currentNumber;
  }

  void _onReceiveNeoValueAlgebraicNode(
    DartBlockValueTreeAlgebraicNode? newNumber,
  ) {
    final selectedNode = getSelectedNode();

    //
    undoHistory.add(value?.copy());
    if (newNumber != null) {
      final newNumberNode = DartBlockAlgebraicExpression.init(newNumber);
      setState(() {
        final DartBlockValueTreeBooleanNode? resultingNode;
        if (selectedNode != null) {
          resultingNode = selectedNode.receiveNumberComposedValue(
            newNumberNode,
          );
        } else if (value != null) {
          resultingNode = value!.receiveNumberComposedValue(newNumberNode);
        } else {
          resultingNode = DartBlockValueTreeBooleanGenericNumberNode.init(
            newNumberNode,
            null,
          );
        }
        _updateValue(resultingNode);
      });
    } else {
      // Delete the number from the boolean expression
      setState(() {
        if (selectedNode != null) {
          _updateValue(selectedNode.deleteRightLeaf());
        } else {
          _updateValue(value?.deleteRightLeaf());
        }
      });
    }
  }
}

enum _BooleanComposerActiveComposerType { logic, math, text }
