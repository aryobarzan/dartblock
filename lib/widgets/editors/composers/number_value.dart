import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartblock_code/models/dartblock_interaction.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/editors/composers/components/algebraic_digit_button.dart';
import 'package:dartblock_code/widgets/editors/composers/components/algebraic_dot_button.dart';
import 'package:dartblock_code/widgets/editors/composers/components/algebraic_operator_button.dart';
import 'package:dartblock_code/widgets/editors/misc.dart';
import 'package:dartblock_code/widgets/dartblock_value_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NumberValueComposer extends ConsumerStatefulWidget {
  final DartBlockValueTreeAlgebraicNode? value;
  final List<DartBlockVariableDefinition> variableDefinitions;
  final Function(DartBlockValueTreeAlgebraicNode?) onChange;
  final bool showFunctionVariableButton;
  final bool showUndoRedoButton;
  final bool showBackspaceButton;
  final bool showValue;
  NumberValueComposer({
    super.key,
    this.value,
    required List<DartBlockVariableDefinition> variableDefinitions,
    required this.onChange,
    this.showFunctionVariableButton = true,
    this.showUndoRedoButton = true,
    this.showBackspaceButton = true,
    this.showValue = true,
  }) : variableDefinitions = variableDefinitions
           .where(
             (element) =>
                 element.dataType == DartBlockDataType.integerType ||
                 element.dataType == DartBlockDataType.doubleType,
           )
           .toList();

  @override
  ConsumerState<NumberValueComposer> createState() =>
      _NumberValueComposerState();
}

class _NumberValueComposerState extends ConsumerState<NumberValueComposer> {
  DartBlockValueTreeAlgebraicNode? value;
  final List<DartBlockValueTreeAlgebraicNode?> undoHistory = [];
  final List<DartBlockValueTreeAlgebraicNode?> redoHistory = [];
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
        if (widget.showValue)
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity != 0) {
                DartBlockInteraction.create(
                  dartBlockInteractionType: DartBlockInteractionType
                      .swipeNumberComposerValueToBackspace,
                ).dispatch(context);
                _onBackSpace();
                // if (details.primaryVelocity! < 0) {
                //   print('left');
                //   // _onBackSpace();
                // } else if (details.primaryVelocity! > 0) {
                //   print('right');
                //   // User swiped Right
                // }
              }
            },
            child: InkWell(
              onTap: selectedNodeKey != null
                  ? () {
                      DartBlockInteraction.create(
                        dartBlockInteractionType: DartBlockInteractionType
                            .deselectNumberComposerValueNode,
                        content: 'TappedOutsideValue',
                      ).dispatch(context);
                      setState(() {
                        selectedNodeKey = null;
                      });
                    }
                  : () {},
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 42,
                    maxHeight: 100,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: (value != null)
                        ? ValueCompositionNumberNodeWidget(
                            node: value!,
                            selectedNodeKey: selectedNodeKey,
                            onTap: (tappedNode) {
                              setState(() {
                                if (selectedNodeKey == tappedNode.nodeKey) {
                                  DartBlockInteraction.create(
                                    dartBlockInteractionType:
                                        DartBlockInteractionType
                                            .deselectNumberComposerValueNode,
                                  ).dispatch(context);
                                  selectedNodeKey = null;
                                } else {
                                  DartBlockInteraction.create(
                                    dartBlockInteractionType:
                                        DartBlockInteractionType
                                            .selectNumberComposerValueNode,
                                  ).dispatch(context);
                                  selectedNodeKey = tappedNode.nodeKey;
                                }
                              });
                            },
                            onChangeOperator:
                                (arithmeticOperatorNode, newOperator) {
                                  if (arithmeticOperatorNode.operator !=
                                      newOperator) {
                                    undoHistory.add(value?.copy());
                                    setState(() {
                                      DartBlockInteraction.create(
                                        dartBlockInteractionType:
                                            DartBlockInteractionType
                                                .changeNumberComposerOperatorThroughNode,
                                      ).dispatch(context);
                                      arithmeticOperatorNode.operator =
                                          newOperator;
                                      _updateValue(value);
                                    });
                                  }
                                },
                          )
                        : Text(
                            'No value (null)',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.apply(fontStyle: FontStyle.italic),
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
          childAspectRatio: 2 / 1, // 70 / 35.0,
          children: [
            widget.showFunctionVariableButton
                ? _buildFunctionVariableButton()
                : const SizedBox(),
            widget.showUndoRedoButton
                ? _buildUndoRedoButton()
                : const SizedBox(),
            _buildNegationButton(),
            _buildOperatorButton(DartBlockAlgebraicOperator.modulo),
            _buildDigitButton(7),
            _buildDigitButton(8),
            _buildDigitButton(9),
            _buildOperatorButton(DartBlockAlgebraicOperator.divide),
            _buildDigitButton(4),
            _buildDigitButton(5),
            _buildDigitButton(6),
            _buildOperatorButton(DartBlockAlgebraicOperator.multiply),
            _buildDigitButton(1),
            _buildDigitButton(2),
            _buildDigitButton(3),
            _buildOperatorButton(DartBlockAlgebraicOperator.subtract),
            _buildDigitButton(0),
            _buildDotButton(),
            widget.showBackspaceButton
                ? _buildBackspaceButton()
                : const SizedBox(),
            _buildOperatorButton(DartBlockAlgebraicOperator.add),
          ],
        ),
      ],
    );
  }

  DartBlockValueTreeAlgebraicNode? getSelectedNode() {
    return selectedNodeKey != null
        ? value?.findNodeByKey(selectedNodeKey!)
        : null;
  }

  Widget _buildDotButton() {
    return Tooltip(
      message: "Decimal point",
      child: AlgebraicDotButton(
        onTap: () {
          _onTapDot();
        },
      ),
    );
  }

  void _onTapDot() {
    DartBlockInteraction.create(
      dartBlockInteractionType:
          DartBlockInteractionType.tapNumberComposerDecimalPoint,
    ).dispatch(context);
    HapticFeedback.mediumImpact();
    undoHistory.add(value?.copy());
    final selectedNode = getSelectedNode();
    setState(() {
      final DartBlockValueTreeAlgebraicNode? resultingNode;
      if (selectedNode != null) {
        resultingNode = selectedNode.receiveDot();
      } else if (value != null) {
        resultingNode = value!.receiveDot();
      } else {
        resultingNode = value = DartBlockValueTreeAlgebraicConstantNode.init(
          0,
          true,
          null,
        );
      }

      /// Important: if it is the root node that is being changed, update
      /// the pointer to the root in this widget so as to point to the new
      /// root. Otherwise, the changes are not reflected.
      _updateValue(resultingNode);
    });
  }

  Widget _buildFunctionVariableButton() {
    final rightLeaf = (getSelectedNode() ?? value)?.getRightLeaf();
    DartBlockFunctionCallValue? currentFunctionCallValue;
    if (rightLeaf is DartBlockValueTreeAlgebraicDynamicNode &&
        rightLeaf.value is DartBlockFunctionCallValue) {
      currentFunctionCallValue = rightLeaf.value as DartBlockFunctionCallValue;
    }

    return FunctionVariableSplitButton(
      functionCallValue: currentFunctionCallValue,
      variableDefinitions: widget.variableDefinitions,
      restrictFunctionCallReturnTypes: const [
        DartBlockDataType.integerType,
        DartBlockDataType.doubleType,
      ],
      onSavedFunctionCallStatement: (customFunction, savedFunctionCall) {
        _onAddFunctionCall(savedFunctionCall);
      },
      onPickedVariableDefinition: (pickedVariableDefinition) {
        _onAddVariableDefinition(pickedVariableDefinition);
      },
    );
  }

  Widget _buildUndoRedoButton() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Tooltip(
              message: "Undo",
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
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
                              dartBlockInteractionType: DartBlockInteractionType
                                  .tapNumberComposerUndo,
                            ).dispatch(context);
                            HapticFeedback.mediumImpact();
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
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
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
                              dartBlockInteractionType: DartBlockInteractionType
                                  .tapNumberComposerRedo,
                            ).dispatch(context);
                            HapticFeedback.mediumImpact();
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
      ),
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
                DartBlockInteractionType.tapNumberComposerBackspace,
          ).dispatch(context);
          _onBackSpace();
        },
        child: const Icon(Icons.backspace),
      ),
    );
  }

  void _onBackSpace() {
    HapticFeedback.mediumImpact();
    undoHistory.add(value?.copy());
    final selectedNode = getSelectedNode();
    setState(() {
      final DartBlockValueTreeAlgebraicNode? resultingNode;
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

  Widget _buildNegationButton() {
    final selectedNode = getSelectedNode();

    return Tooltip(
      message: "Negate",
      child: FilledButton(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 1),
        ),
        onPressed: () {
          DartBlockInteraction.create(
            dartBlockInteractionType:
                DartBlockInteractionType.tapNumberComposerNegate,
          ).dispatch(context);
          HapticFeedback.mediumImpact();
          undoHistory.add(value?.copy());
          setState(() {
            final DartBlockValueTreeAlgebraicNode? resultingNode;
            if (selectedNode != null) {
              resultingNode = selectedNode.receiveNegation();
            } else if (value != null) {
              resultingNode = value!.receiveNegation();
            } else {
              resultingNode = DartBlockValueTreeAlgebraicOperatorNode.init(
                DartBlockAlgebraicOperator.subtract,
                null,
                null,
                null,
              );
            }
            _updateValue(resultingNode);
          });
        },
        child: Text(
          "+/-",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ), // ±
      ),
    );
  }

  Widget _buildDigitButton(int digit) {
    final selectedNode = getSelectedNode();

    return AlgebraicDigitButton(
      digit: digit,
      onTap: (digit) {
        // new approach - disabled for now
        // ref.broadcastInteraction(
        //   DartBlockInteraction.create(
        //     dartBlockInteractionType:
        //         DartBlockInteractionType.tapNumberComposerConstant,
        //     content: 'Digit-$digit',
        //   ),
        // );
        DartBlockInteraction.create(
          dartBlockInteractionType:
              DartBlockInteractionType.tapNumberComposerConstant,
          content: 'Digit-$digit',
        ).dispatch(context);
        HapticFeedback.mediumImpact();
        undoHistory.add(value?.copy());
        setState(() {
          final DartBlockValueTreeAlgebraicNode? resultingNode;
          if (selectedNode != null) {
            resultingNode = selectedNode.receiveDigit(digit);
          } else if (value != null) {
            resultingNode = value!.receiveDigit(digit);
          } else {
            resultingNode = value =
                DartBlockValueTreeAlgebraicConstantNode.init(
                  digit,
                  false,
                  null,
                );
          }

          /// Important: if it is the root node that is being changed, update
          /// the pointer to the root in this widget so as to point to the new
          /// root. Otherwise, the changes are not reflected.
          /// Reason: when the existing root is a ValueCompositionNumberDynamicNode,
          /// it will be replaced by a ValueCompositionNumberConstantNode.
          /// Hence, the root object itself is replaced and the existing pointer
          /// to the root is no longer correct.
          _updateValue(resultingNode);
        });
      },
    );
  }

  void _onAddFunctionCall(FunctionCallStatement functionCallStatement) {
    DartBlockInteraction.create(
      dartBlockInteractionType:
          DartBlockInteractionType.saveNumberComposerFunctionCall,
      content: "FunctionName-${functionCallStatement.functionName}",
    ).dispatch(context);
    final selectedNode = getSelectedNode();
    setState(() {
      undoHistory.add(value?.copy());
      final DartBlockValueTreeAlgebraicNode? resultingNode;
      if (selectedNode != null) {
        resultingNode = selectedNode.receiveDynamicValue(
          DartBlockFunctionCallValue.init(functionCallStatement),
        );
      } else if (value != null) {
        resultingNode = value!.receiveDynamicValue(
          DartBlockFunctionCallValue.init(functionCallStatement),
        );
      } else {
        resultingNode = DartBlockValueTreeAlgebraicDynamicNode.init(
          DartBlockFunctionCallValue.init(functionCallStatement),
          null,
        );
      }
      _updateValue(resultingNode);
    });
  }

  void _onAddVariableDefinition(
    DartBlockVariableDefinition variableDefinition,
  ) {
    DartBlockInteraction.create(
      dartBlockInteractionType:
          DartBlockInteractionType.pickNumberComposerVariable,
      content:
          "Name-${variableDefinition.name}-Type-${variableDefinition.dataType}",
    ).dispatch(context);
    final selectedNode = getSelectedNode();
    setState(() {
      undoHistory.add(value?.copy());
      final DartBlockValueTreeAlgebraicNode? resultingNode;
      if (selectedNode != null) {
        resultingNode = selectedNode.receiveDynamicValue(
          DartBlockVariable.init(variableDefinition.name),
        );
      } else if (value != null) {
        resultingNode = value!.receiveDynamicValue(
          DartBlockVariable.init(variableDefinition.name),
        );
      } else {
        resultingNode = value = DartBlockValueTreeAlgebraicDynamicNode.init(
          DartBlockVariable.init(variableDefinition.name),
          null,
        );
      }

      /// Important: if it is the root node that is being changed, update
      /// the pointer to the root in this widget so as to point to the new
      /// root. Otherwise, the changes are not reflected.
      /// Reason: when the existing root is a ValueCompositionNumberConstantNode,
      /// it will be replaced by a ValueCompositionNumberDynamicNode.
      /// Hence, the root object itself is replaced and the existing pointer
      /// to the root is no longer correct.
      _updateValue(resultingNode);
    });
  }

  Widget _buildOperatorButton(DartBlockAlgebraicOperator operator) {
    final selectedNode = getSelectedNode();

    return Tooltip(
      message: operator.describeVerbal(),
      child: AlgebraicOperatorButton(
        algebraicOperator: operator,
        onTap: (operator) {
          DartBlockInteraction.create(
            dartBlockInteractionType:
                DartBlockInteractionType.tapNumberComposerOperator,
            content: 'Operator-${operator.name}',
          ).dispatch(context);
          HapticFeedback.mediumImpact();
          undoHistory.add(value?.copy());
          setState(() {
            final DartBlockValueTreeAlgebraicNode? resultingNode;
            if (selectedNode != null) {
              resultingNode = selectedNode.receiveOperator(operator);
            } else if (value != null) {
              resultingNode = value?.receiveOperator(operator);
            } else if (operator == DartBlockAlgebraicOperator.subtract) {
              resultingNode = DartBlockValueTreeAlgebraicOperatorNode.init(
                operator,
                null,
                null,
                null,
              );
            } else {
              resultingNode = null;
            }

            /// Move the selection pointer to the newly created
            /// ValueCompositionArithmeticOperatorNode so the user can continue building that expression
            selectedNodeKey = resultingNode?.nodeKey;

            _updateValue(resultingNode);
          });
        },
      ),
    );
  }

  void _updateValue(DartBlockValueTreeAlgebraicNode? newValue) {
    /// Important: if it is the root node that is being changed, update
    /// the pointer to the root in this widget so as to point to the new
    /// root. Otherwise, the changes are not reflected.
    value = newValue?.getRoot();
    widget.onChange(value);
  }
}
