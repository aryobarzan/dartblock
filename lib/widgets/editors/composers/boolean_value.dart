import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartblock/models/function.dart';
import 'package:dartblock/models/dartblock_interaction.dart';
import 'package:dartblock/models/dartblock_value.dart';
import 'package:dartblock/widgets/editors/composers/number_value.dart';
import 'package:dartblock/widgets/editors/composers/string_value.dart';
import 'package:dartblock/widgets/editors/misc.dart';
import 'package:dartblock/widgets/dartblock_value_widgets.dart';
import 'package:dartblock/widgets/views/other/dartblock_colors.dart';

class BooleanValueComposer extends StatefulWidget {
  final DartBlockValueTreeBooleanNode? value;
  final List<DartBlockVariableDefinition> variableDefinitions;
  final List<DartBlockFunction> customFunctions;
  final Function(DartBlockValueTreeBooleanNode?) onChange;
  const BooleanValueComposer({
    super.key,
    this.value,
    required this.variableDefinitions,
    required this.customFunctions,
    required this.onChange,
  });

  @override
  State<BooleanValueComposer> createState() => _BooleanValueComposerState();
}

class _BooleanValueComposerState extends State<BooleanValueComposer> {
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
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 50,
                  maxHeight: 200,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: value != null
                      ? ValueCompositionBooleanNodeWidget(
                          node: value!,
                          selectedNodeKey: selectedNodeKey,
                          onTap: (tappedNode) {
                            setState(() {
                              if (selectedNodeKey == tappedNode.nodeKey) {
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
                                selectedNodeKey = tappedNode.nodeKey;
                              }
                            });
                          },
                          onChangeLogicalOperator:
                              (logicalOperatorNode, newOperator) {
                                if (newOperator !=
                                    logicalOperatorNode.operator) {
                                  DartBlockInteraction.create(
                                    dartBlockInteractionType:
                                        DartBlockInteractionType
                                            .changeBooleanComposerLogicalOperatorThroughNode,
                                  ).dispatch(context);
                                  undoHistory.add(value?.copy());
                                  setState(() {
                                    logicalOperatorNode.operator = newOperator;
                                    _updateValue(value);
                                  });
                                }
                              },
                          onChangeEqualityOperator:
                              (equalityOperatorNode, newOperator) {
                                if (newOperator !=
                                    equalityOperatorNode.operator) {
                                  DartBlockInteraction.create(
                                    dartBlockInteractionType:
                                        DartBlockInteractionType
                                            .changeBooleanComposerEqualityOperatorThroughNode,
                                  ).dispatch(context);
                                  undoHistory.add(value?.copy());
                                  setState(() {
                                    equalityOperatorNode.operator = newOperator;
                                    _updateValue(value);
                                  });
                                }
                              },
                          onChangeNumberComparisonOperator:
                              (numberComparisonOperatorNode, newOperator) {
                                if (newOperator !=
                                    numberComparisonOperatorNode.operator) {
                                  DartBlockInteraction.create(
                                    dartBlockInteractionType:
                                        DartBlockInteractionType
                                            .changeBooleanComposerNumberComparisonOperatorThroughNode,
                                  ).dispatch(context);
                                  undoHistory.add(value?.copy());
                                  setState(() {
                                    numberComparisonOperatorNode.operator =
                                        newOperator;
                                    _updateValue(value);
                                  });
                                }
                              },
                        )
                      : Text(
                          'No value (null)',
                          style: Theme.of(context).textTheme.bodyMedium?.apply(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        GridView.count(
          shrinkWrap: true,
          primary: false,
          padding: EdgeInsets.zero,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          crossAxisCount: 4,
          childAspectRatio: 2 / 1,
          children: [
            _buildFunctionVariableButton(),
            _buildUndoRedoButton(),
            _buildBackspaceButton(),
            _buildLogicalOperatorButton(DartBlockBooleanOperator.and),
            _buildConstantButton(true),
            _buildConstantButton(false),
            _buildEqualityOperatorSplitButton(),
            _buildLogicalOperatorButton(DartBlockBooleanOperator.or),
            _buildStringValueComposerButton(),
            _buildNumberComposerButton(),
            _buildNumberComparisonOperatorSplitButton(
              DartBlockNumberComparisonOperator.greater,
              DartBlockNumberComparisonOperator.greaterOrEqual,
            ),
            _buildNumberComparisonOperatorSplitButton(
              DartBlockNumberComparisonOperator.lessOrEqual,
              DartBlockNumberComparisonOperator.less,
            ),
          ],
        ),
        _buildActiveComposer(),
      ],
    );
  }

  Widget _buildActiveComposer() {
    return switch (_booleanComposerActiveComposerType) {
      null => const SizedBox(height: 16),
      _BooleanComposerActiveComposerType.number => Container(
        decoration: BoxDecoration(
          border: Border.all(color: DartBlockColors.number, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(4),
        child: NumberValueComposer(
          key: ValueKey(
            "NumberValueComposer-${_getCurrentAlgebraicNode().hashCode}",
          ),
          value: _getCurrentAlgebraicNode(),
          variableDefinitions: widget.variableDefinitions,
          customFunctions: widget.customFunctions,
          showValue: false,
          showBackspaceButton: false,
          showFunctionVariableButton: false,
          showUndoRedoButton: false,
          onChange: (neoValueAlgebraicNode) {
            _onReceiveNeoValueAlgebraicNode(neoValueAlgebraicNode);
          },
        ),
      ),
      _BooleanComposerActiveComposerType.text => Container(
        decoration: BoxDecoration(
          border: Border.all(color: DartBlockColors.string, width: 2),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: StringValueComposer(
          value: _getCurrentStringValue(),
          onChange: (stringValue) {
            _onReceiveStringValue(stringValue);
          },
        ),
      ),
    };
  }

  DartBlockValueTreeBooleanNode? getSelectedNode() {
    return selectedNodeKey != null
        ? value?.findNodeByKey(selectedNodeKey!)
        : null;
  }

  Widget _buildNumberComparisonOperatorSplitButton(
    DartBlockNumberComparisonOperator leftOperator,
    DartBlockNumberComparisonOperator rightOperator,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Tooltip(
            message: leftOperator.describeVerbal(),
            child: FilledButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _onTapNumberComparisonOperator(leftOperator);
              },
              style: FilledButton.styleFrom(
                backgroundColor: DartBlockColors.number,
                padding: const EdgeInsets.only(left: 2),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                  ),
                ),
              ),
              child: Text(
                leftOperator.toScript(),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.apply(color: Colors.white),
              ),
            ),
          ),
        ),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: Theme.of(context).colorScheme.outline,
        ),
        Expanded(
          child: Tooltip(
            message: rightOperator.describeVerbal(),
            child: FilledButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _onTapNumberComparisonOperator(rightOperator);
              },
              style: FilledButton.styleFrom(
                backgroundColor: DartBlockColors.number,
                padding: const EdgeInsets.only(right: 2),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
              ),
              child: Text(
                rightOperator.toScript(),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.apply(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
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

  Widget _buildFunctionVariableButton() {
    final selectedNode = getSelectedNode();

    final rightLeaf = (selectedNode ?? value)?.getRightLeaf();
    DartBlockFunctionCallValue? currentFunctionCallValue;
    if (rightLeaf is DartBlockValueTreeBooleanDynamicNode &&
        rightLeaf.value is DartBlockFunctionCallValue) {
      currentFunctionCallValue = rightLeaf.value as DartBlockFunctionCallValue;
    }

    return FunctionVariableSplitButton(
      functionCallValue: currentFunctionCallValue,
      customFunctions: widget.customFunctions,
      variableDefinitions: widget.variableDefinitions,
      // .where((element) => element.dataType == NeoTechDataType.booleanType)
      // .toList(),
      /// Allow all custom function return types, except for void
      restrictFunctionCallReturnTypes: DartBlockDataType.values,
      onSavedFunctionCallStatement: (customFunction, savedFunctionCall) {
        _onReceiveFunctionCall(
          customFunction,
          DartBlockFunctionCallValue.init(savedFunctionCall),
        );
      },
      onPickedVariableDefinition: (pickedVariableDefinition) {
        _onReceiveVariableDefinition(pickedVariableDefinition);
        // _onReceiveDynamicValue(NeoVariable.init(pickedVariableDefinition.name));
      },
    );
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
    DartBlockFunction customFunction,
    DartBlockFunctionCallValue functionCallValue,
  ) {
    // Do not accept function calls with a 'void' return type
    if (customFunction.returnType != null) {
      DartBlockInteraction.create(
        dartBlockInteractionType:
            DartBlockInteractionType.saveBooleanComposerFunctionCall,
        content: 'FunctionName-${customFunction.name}',
      ).dispatch(context);
      switch (customFunction.returnType!) {
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

  // Widget _buildClearSelectionButton() {
  //   return OutlinedButton(
  //     style: OutlinedButton.styleFrom(
  //       padding: const EdgeInsets.symmetric(
  //         vertical: 4,
  //         horizontal: 1,
  //       ),
  //     ),
  //     onPressed: selectedNodeKey != null
  //         ? () {
  //             setState(() {
  //               selectedNodeKey = null;
  //             });
  //           }
  //         : null,
  //     child: const Icon(Icons.deselect),
  //   );
  // }

  Widget _buildUndoRedoButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Tooltip(
            message: "Undo",
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: InkWell(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
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
                child: Icon(
                  Icons.undo,
                  color: undoHistory.isNotEmpty
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Tooltip(
            message: "Redo",
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: InkWell(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
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
                child: Icon(
                  Icons.redo,
                  color: redoHistory.isNotEmpty
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackspaceButton() {
    return Tooltip(
      message: "Delete",
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 1),
        ),
        onPressed: () {
          DartBlockInteraction.create(
            dartBlockInteractionType:
                DartBlockInteractionType.tapBooleanComposerBackspace,
          ).dispatch(context);
          HapticFeedback.lightImpact();
          _onBackSpace();
        },
        child: const Icon(Icons.backspace),
      ),
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

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 1),
      ),
      onPressed: () {
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
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildEqualityOperatorSplitButton() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Tooltip(
            message: DartBlockEqualityOperator.equal.describeVerbal(),
            child: FilledButton(
              onPressed: () {
                DartBlockInteraction.create(
                  dartBlockInteractionType: DartBlockInteractionType
                      .tapBooleanComposerEqualityOperator,
                  content: 'Operator-${DartBlockEqualityOperator.equal.name}',
                ).dispatch(context);
                HapticFeedback.lightImpact();
                _onReceiveEqualityOperator(DartBlockEqualityOperator.equal);
              },
              style: FilledButton.styleFrom(
                // backgroundColor: NeoTechColors.number,
                padding: const EdgeInsets.only(left: 2),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                  ),
                ),
              ),
              child: Text(
                "==",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        Expanded(
          child: Tooltip(
            message: DartBlockEqualityOperator.notEqual.describeVerbal(),
            child: FilledButton(
              onPressed: () {
                DartBlockInteraction.create(
                  dartBlockInteractionType: DartBlockInteractionType
                      .tapBooleanComposerEqualityOperator,
                  content:
                      'Operator-${DartBlockEqualityOperator.notEqual.name}',
                ).dispatch(context);
                HapticFeedback.lightImpact();
                _onReceiveEqualityOperator(DartBlockEqualityOperator.notEqual);
              },
              style: FilledButton.styleFrom(
                // backgroundColor: NeoTechColors.number,
                padding: const EdgeInsets.only(right: 2),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
              ),
              child: Text(
                "!=",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogicalOperatorButton(DartBlockBooleanOperator operator) {
    final selectedNode = getSelectedNode();

    return Tooltip(
      message: operator.describeVerbal(),
      child: FilledButton(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 1),
        ),
        onPressed: () {
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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
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

  Widget _buildStringValueComposerButton() {
    final bool isActive =
        _booleanComposerActiveComposerType ==
        _BooleanComposerActiveComposerType.text;

    return InkWell(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          if (_booleanComposerActiveComposerType ==
              _BooleanComposerActiveComposerType.text) {
            DartBlockInteraction.create(
              dartBlockInteractionType:
                  DartBlockInteractionType.tapBooleanComposerTextToggleToHide,
            ).dispatch(context);
            _booleanComposerActiveComposerType = null;
          } else {
            DartBlockInteraction.create(
              dartBlockInteractionType:
                  DartBlockInteractionType.tapBooleanComposerTextToggleToShow,
            ).dispatch(context);
            _booleanComposerActiveComposerType =
                _BooleanComposerActiveComposerType.text;
          }
        });
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? DartBlockColors.string : null,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: isActive
              ? Border(
                  top: BorderSide(color: Theme.of(context).colorScheme.outline),
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  right: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                )
              : Border.all(color: DartBlockColors.string, width: 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          // mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Text",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isActive
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Icon(
                isActive ? Icons.expand_less : Icons.expand_more,
                size: 18,
                color: isActive
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildNumberComposerButton() {
    final bool isActive =
        _booleanComposerActiveComposerType ==
        _BooleanComposerActiveComposerType.number;

    return InkWell(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          if (_booleanComposerActiveComposerType ==
              _BooleanComposerActiveComposerType.number) {
            DartBlockInteraction.create(
              dartBlockInteractionType:
                  DartBlockInteractionType.tapBooleanComposerNumberToggleToHide,
            ).dispatch(context);
            _booleanComposerActiveComposerType = null;
          } else {
            DartBlockInteraction.create(
              dartBlockInteractionType:
                  DartBlockInteractionType.tapBooleanComposerNumberToggleToShow,
            ).dispatch(context);
            _booleanComposerActiveComposerType =
                _BooleanComposerActiveComposerType.number;
          }
        });
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? DartBlockColors.number : null,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: isActive
              ? Border(
                  top: BorderSide(color: Theme.of(context).colorScheme.outline),
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  right: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                )
              : Border.all(color: DartBlockColors.number, width: 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          // mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "123",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isActive
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Icon(
                isActive ? Icons.expand_less : Icons.expand_more,
                size: 18,
                color: isActive
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
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

enum _BooleanComposerActiveComposerType { number, text }
