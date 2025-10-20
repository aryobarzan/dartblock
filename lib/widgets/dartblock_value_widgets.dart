import 'package:flutter/material.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:dartblock_code/widgets/views/other/dartblock_colors.dart';

class DartBlockValueWidget extends StatelessWidget {
  final DartBlockValue? value;
  final BorderRadius? borderRadius;
  final Border? border;
  const DartBlockValueWidget({
    super.key,
    required this.value,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (value == null) {
      color = Theme.of(context).colorScheme.tertiaryContainer;
    } else {
      switch (value!) {
        case DartBlockStringValue():
          color = DartBlockColors.string;
          break;
        case DartBlockConcatenationValue():
          return Wrap(
            spacing: 1,
            children: (value! as DartBlockConcatenationValue).values
                .map((e) => DartBlockValueWidget(value: e))
                .toList(),
          );
        case DartBlockVariable():
          color = DartBlockColors.variable;
          break;
        case DartBlockFunctionCallValue():
          // return FunctionCallWidget(
          //     statement: (value! as FunctionCallValue).customFunctionCall);
          color = DartBlockColors.function;
          break;
        case DartBlockAlgebraicExpression():
          color = DartBlockColors.number;
          break;
        case DartBlockBooleanExpression():
          color = DartBlockColors.boolean;
          break;
      }
    }

    return ColoredTitleChip(
      title: value.toString(),
      color: color,
      border: border,
      borderRadius: borderRadius ?? BorderRadius.circular(6),
      textColor: value == null
          ? Theme.of(context).colorScheme.onTertiaryContainer
          : Colors.white,
    );
  }
}

///

class ValueCompositionNumberNodeWidget extends StatelessWidget {
  final DartBlockValueTreeAlgebraicNode node;
  final String? selectedNodeKey;
  final Function(DartBlockValueTreeAlgebraicNode)? onTap;
  final Function(
    DartBlockValueTreeAlgebraicOperatorNode,
    DartBlockAlgebraicOperator,
  )
  onChangeOperator;
  const ValueCompositionNumberNodeWidget({
    super.key,
    required this.node,
    required this.selectedNodeKey,
    this.onTap,
    required this.onChangeOperator,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap != null
          ? () {
              onTap!(node);
            }
          : null,
      child: Badge(
        backgroundColor: Theme.of(context).colorScheme.error,
        label: Icon(
          Icons.check,
          size: 12,
          color: Theme.of(context).colorScheme.onError,
        ),
        isLabelVisible: selectedNodeKey == node.nodeKey,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (node) {
      case DartBlockValueTreeAlgebraicConstantNode():
        return ValueCompositionNumberConstantNodeWidget(
          node: node as DartBlockValueTreeAlgebraicConstantNode,
          selectedNodeKey: selectedNodeKey,
          onTap: onTap,
        );
      case DartBlockValueTreeAlgebraicDynamicNode():
        return ValueCompositionNumberDynamicNodeWidget(
          node: node as DartBlockValueTreeAlgebraicDynamicNode,
          selectedNodeKey: selectedNodeKey,
          onTap: onTap,
        );
      case DartBlockValueTreeAlgebraicOperatorNode():
        return ValueCompositionArithmeticOperatorNodeWidget(
          node: node as DartBlockValueTreeAlgebraicOperatorNode,
          selectedNodeKey: selectedNodeKey,
          onTap: onTap,
          onChangeOperator: onChangeOperator,
        );
    }
  }
}

class ValueCompositionNumberConstantNodeWidget extends StatelessWidget {
  final DartBlockValueTreeAlgebraicConstantNode node;
  final String? selectedNodeKey;
  final Function(DartBlockValueTreeAlgebraicNode)? onTap;
  const ValueCompositionNumberConstantNodeWidget({
    super.key,
    required this.node,
    required this.selectedNodeKey,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Text(
        node.toString(),
        style: Theme.of(context).textTheme.bodyMedium?.apply(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class ValueCompositionNumberDynamicNodeWidget extends StatelessWidget {
  final DartBlockValueTreeAlgebraicDynamicNode node;
  final String? selectedNodeKey;
  final Function(DartBlockValueTreeAlgebraicNode)? onTap;
  const ValueCompositionNumberDynamicNodeWidget({
    super.key,
    required this.node,
    required this.selectedNodeKey,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color;
    switch (node.value) {
      case DartBlockVariable():
        color = DartBlockColors.variable;
        break;
      case DartBlockFunctionCallValue():
        color = DartBlockColors.function;
        break;
    }
    return Card(
      color: color,
      elevation: 6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          node.toString(),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.apply(color: Colors.white),
        ),
      ),
    );
  }
}

class ArithmericOperatorWidget extends StatelessWidget {
  final DartBlockAlgebraicOperator arithmeticOperator;
  const ArithmericOperatorWidget({super.key, required this.arithmeticOperator});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: Theme.of(context).colorScheme.surfaceTint,
      child: Container(
        width: 24,
        //  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(
            arithmeticOperator.text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.apply(
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class ValueCompositionArithmeticOperatorNodeWidget extends StatelessWidget {
  final DartBlockValueTreeAlgebraicOperatorNode node;
  final String? selectedNodeKey;
  final Function(DartBlockValueTreeAlgebraicNode)? onTap;
  final Function(
    DartBlockValueTreeAlgebraicOperatorNode,
    DartBlockAlgebraicOperator,
  )
  onChangeOperator;
  const ValueCompositionArithmeticOperatorNodeWidget({
    super.key,
    required this.node,
    required this.selectedNodeKey,
    this.onTap,
    required this.onChangeOperator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 16, top: 4, bottom: 4, left: 4),
      //margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (node.leftChild != null)
            ValueCompositionNumberNodeWidget(
              node: node.leftChild!,
              selectedNodeKey: selectedNodeKey,
              onTap: onTap,
              onChangeOperator: onChangeOperator,
            ),
          if (node.operator != null)
            PopupWidgetButton(
              tooltip: "Change operator...",
              widget: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: node
                    .getSupportedOperators()
                    .map(
                      (e) => InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          onChangeOperator(node, e);
                        },
                        child: Badge(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          label: Icon(
                            Icons.check,
                            size: 12,
                            color: Theme.of(context).colorScheme.onError,
                          ),
                          isLabelVisible: node.operator == e,
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: ArithmericOperatorWidget(
                              arithmeticOperator: e,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              child: ArithmericOperatorWidget(
                arithmeticOperator: node.operator!,
              ),
            ),
          if (node.rightChild != null)
            ValueCompositionNumberNodeWidget(
              node: node.rightChild!,
              selectedNodeKey: selectedNodeKey,
              onTap: onTap,
              onChangeOperator: onChangeOperator,
            ),
        ],
      ),
    );
  }
}

/// Boolean widgets

class ValueCompositionBooleanNodeWidget extends StatelessWidget {
  final DartBlockValueTreeBooleanNode node;
  final String? selectedNodeKey;
  final Function(DartBlockValueTreeBooleanNode)? onTap;
  final Function(
    DartBlockValueTreeBooleanOperatorNode,
    DartBlockBooleanOperator,
  )
  onChangeLogicalOperator;
  final Function(
    DartBlockValueTreeBooleanEqualityOperatorNode,
    DartBlockEqualityOperator,
  )
  onChangeEqualityOperator;
  final Function(
    DartBlockValueTreeBooleanNumberComparisonOperatorNode,
    DartBlockNumberComparisonOperator,
  )
  onChangeNumberComparisonOperator;
  const ValueCompositionBooleanNodeWidget({
    super.key,
    required this.node,
    required this.selectedNodeKey,
    this.onTap,
    required this.onChangeLogicalOperator,
    required this.onChangeEqualityOperator,
    required this.onChangeNumberComparisonOperator,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap != null
          ? () {
              onTap!(node);
            }
          : null,
      child: Badge(
        backgroundColor: Theme.of(context).colorScheme.error,
        label: Icon(
          Icons.check,
          size: 12,
          color: Theme.of(context).colorScheme.onError,
        ),
        isLabelVisible: selectedNodeKey == node.nodeKey,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (node) {
      case DartBlockValueTreeBooleanConstantNode():
        return ValueCompositionBooleanConstantNodeWidget(
          node: node as DartBlockValueTreeBooleanConstantNode,
          selectedNodeKey: selectedNodeKey,
          onTap: onTap,
        );
      case DartBlockValueTreeBooleanDynamicNode():
        return ValueCompositionBooleanDynamicNodeWidget(
          node: node as DartBlockValueTreeBooleanDynamicNode,
          selectedNodeKey: selectedNodeKey,
          onTap: onTap,
        );
      case DartBlockValueTreeBooleanGenericNode():
        return ValueCompositionBooleanGenericNodeWidget(
          node: node as DartBlockValueTreeBooleanGenericNode,
          selectedNodeKey: selectedNodeKey,
          onTap: onTap,
        );
      case DartBlockValueTreeBooleanOperatorNode():
        return ValueCompositionLogicalOperatorNodeWidget(
          node: node as DartBlockValueTreeBooleanOperatorNode,
          selectedNodeKey: selectedNodeKey,
          onTap: onTap,
          onChangeLogicalOperator: onChangeLogicalOperator,
          onChangeEqualityOperator: onChangeEqualityOperator,
          onChangeNumberComparisonOperator: onChangeNumberComparisonOperator,
        );
      case DartBlockValueTreeBooleanEqualityOperatorNode():
        return ValueCompositionEqualityOperatorNodeWidget(
          node: node as DartBlockValueTreeBooleanEqualityOperatorNode,
          selectedNodeKey: selectedNodeKey,
          onTap: onTap,
          onChangeLogicalOperator: onChangeLogicalOperator,
          onChangeEqualityOperator: onChangeEqualityOperator,
          onChangeNumberComparisonOperator: onChangeNumberComparisonOperator,
        );
      case DartBlockValueTreeBooleanNumberComparisonOperatorNode():
        return ValueCompositionNumberComparisonOperatorNodeWidget(
          node: node as DartBlockValueTreeBooleanNumberComparisonOperatorNode,
          selectedNodeKey: selectedNodeKey,
          onTap: onTap,
          onChangeLogicalOperator: onChangeLogicalOperator,
          onChangeEqualityOperator: onChangeEqualityOperator,
          onChangeNumberComparisonOperator: onChangeNumberComparisonOperator,
        );
    }
  }
}

class ValueCompositionBooleanConstantNodeWidget extends StatelessWidget {
  final DartBlockValueTreeBooleanConstantNode node;
  final String? selectedNodeKey;
  final Function(DartBlockValueTreeBooleanNode)? onTap;
  const ValueCompositionBooleanConstantNodeWidget({
    super.key,
    required this.node,
    required this.selectedNodeKey,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          node.toString(),
          style: Theme.of(context).textTheme.bodyMedium?.apply(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

class ValueCompositionBooleanDynamicNodeWidget extends StatelessWidget {
  final DartBlockValueTreeBooleanDynamicNode node;
  final String? selectedNodeKey;
  final Function(DartBlockValueTreeBooleanNode)? onTap;
  const ValueCompositionBooleanDynamicNodeWidget({
    super.key,
    required this.node,
    required this.selectedNodeKey,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          node.toString(),
          style: Theme.of(context).textTheme.bodyMedium?.apply(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

class ValueCompositionBooleanGenericNodeWidget extends StatelessWidget {
  final DartBlockValueTreeBooleanGenericNode node;
  final String? selectedNodeKey;
  final Function(DartBlockValueTreeBooleanNode)? onTap;
  const ValueCompositionBooleanGenericNodeWidget({
    super.key,
    required this.node,
    required this.selectedNodeKey,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = switch (node) {
      DartBlockValueTreeBooleanGenericNumberNode() => DartBlockColors.number,
      DartBlockValueTreeBooleanGenericConcatenationNode() =>
        DartBlockColors.string,
    };
    return Card(
      color: backgroundColor,
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          node.value.toString(),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.apply(color: Colors.white),
        ),
      ),
    );
  }
}

class LogicalOperatorWidget extends StatelessWidget {
  final DartBlockBooleanOperator logicalOperator;
  const LogicalOperatorWidget({super.key, required this.logicalOperator});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.surfaceTint,
      child: Container(
        width: 36,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(
            logicalOperator.text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.apply(
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class ValueCompositionLogicalOperatorNodeWidget extends StatelessWidget {
  final DartBlockValueTreeBooleanOperatorNode node;
  final String? selectedNodeKey;
  final Function(DartBlockValueTreeBooleanNode)? onTap;
  final Function(
    DartBlockValueTreeBooleanOperatorNode,
    DartBlockBooleanOperator,
  )
  onChangeLogicalOperator;
  final Function(
    DartBlockValueTreeBooleanEqualityOperatorNode,
    DartBlockEqualityOperator,
  )
  onChangeEqualityOperator;
  final Function(
    DartBlockValueTreeBooleanNumberComparisonOperatorNode,
    DartBlockNumberComparisonOperator,
  )
  onChangeNumberComparisonOperator;
  const ValueCompositionLogicalOperatorNodeWidget({
    super.key,
    required this.node,
    required this.selectedNodeKey,
    this.onTap,
    required this.onChangeLogicalOperator,
    required this.onChangeEqualityOperator,
    required this.onChangeNumberComparisonOperator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 16, top: 4, bottom: 4, left: 4),
      //margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Wrap(
        spacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (node.leftChild != null)
            ValueCompositionBooleanNodeWidget(
              node: node.leftChild!,
              selectedNodeKey: selectedNodeKey,
              onTap: onTap,
              onChangeLogicalOperator: onChangeLogicalOperator,
              onChangeEqualityOperator: onChangeEqualityOperator,
              onChangeNumberComparisonOperator:
                  onChangeNumberComparisonOperator,
            ),
          if (node.operator != null)
            PopupWidgetButton(
              tooltip: "Change operator...",
              widget: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: DartBlockBooleanOperator.values
                    .map(
                      (e) => InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          onChangeLogicalOperator(node, e);
                        },
                        child: Badge(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          label: Icon(
                            Icons.check,
                            size: 12,
                            color: Theme.of(context).colorScheme.onError,
                          ),
                          isLabelVisible: node.operator == e,
                          child: LogicalOperatorWidget(logicalOperator: e),
                        ),
                      ),
                    )
                    .toList(),
              ),
              child: LogicalOperatorWidget(logicalOperator: node.operator!),
            ),
          if (node.rightChild != null)
            ValueCompositionBooleanNodeWidget(
              node: node.rightChild!,
              selectedNodeKey: selectedNodeKey,
              onTap: onTap,
              onChangeLogicalOperator: onChangeLogicalOperator,
              onChangeEqualityOperator: onChangeEqualityOperator,
              onChangeNumberComparisonOperator:
                  onChangeNumberComparisonOperator,
            ),
        ],
      ),
    );
  }
}

class EqualityOperatorWidget extends StatelessWidget {
  final DartBlockEqualityOperator equalityOperator;
  const EqualityOperatorWidget({super.key, required this.equalityOperator});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.surfaceTint,
      child: Container(
        width: 36,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          //
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            equalityOperator.text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.apply(
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class ValueCompositionEqualityOperatorNodeWidget extends StatelessWidget {
  final DartBlockValueTreeBooleanEqualityOperatorNode node;
  final String? selectedNodeKey;
  final Function(DartBlockValueTreeBooleanNode)? onTap;
  final Function(
    DartBlockValueTreeBooleanOperatorNode,
    DartBlockBooleanOperator,
  )
  onChangeLogicalOperator;
  final Function(
    DartBlockValueTreeBooleanEqualityOperatorNode,
    DartBlockEqualityOperator,
  )
  onChangeEqualityOperator;
  final Function(
    DartBlockValueTreeBooleanNumberComparisonOperatorNode,
    DartBlockNumberComparisonOperator,
  )
  onChangeNumberComparisonOperator;
  const ValueCompositionEqualityOperatorNodeWidget({
    super.key,
    required this.node,
    required this.selectedNodeKey,
    this.onTap,
    required this.onChangeLogicalOperator,
    required this.onChangeEqualityOperator,
    required this.onChangeNumberComparisonOperator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 16, top: 4, bottom: 4, left: 4),
      //margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Wrap(
        spacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (node.leftChild != null)
            ValueCompositionBooleanNodeWidget(
              node: node.leftChild!,
              selectedNodeKey: selectedNodeKey,
              onTap: onTap,
              onChangeLogicalOperator: onChangeLogicalOperator,
              onChangeEqualityOperator: onChangeEqualityOperator,
              onChangeNumberComparisonOperator:
                  onChangeNumberComparisonOperator,
            ),
          if (node.operator != null)
            PopupWidgetButton(
              tooltip: "Change operator...",
              widget: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: DartBlockEqualityOperator.values
                    .map(
                      (e) => InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          onChangeEqualityOperator(node, e);
                        },
                        child: Badge(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          label: Icon(
                            Icons.check,
                            size: 12,
                            color: Theme.of(context).colorScheme.onError,
                          ),
                          isLabelVisible: node.operator == e,
                          child: EqualityOperatorWidget(equalityOperator: e),
                        ),
                      ),
                    )
                    .toList(),
              ),
              child: EqualityOperatorWidget(equalityOperator: node.operator!),
            ),
          if (node.rightChild != null)
            ValueCompositionBooleanNodeWidget(
              node: node.rightChild!,
              selectedNodeKey: selectedNodeKey,
              onTap: onTap,
              onChangeLogicalOperator: onChangeLogicalOperator,
              onChangeEqualityOperator: onChangeEqualityOperator,
              onChangeNumberComparisonOperator:
                  onChangeNumberComparisonOperator,
            ),
        ],
      ),
    );
  }
}

class NumberComparisonOperatorWidget extends StatelessWidget {
  final DartBlockNumberComparisonOperator operator;
  const NumberComparisonOperatorWidget({super.key, required this.operator});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: DartBlockColors.number,
      child: Container(
        width: 36,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          //
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            operator.toScript(),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.apply(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class ValueCompositionNumberComparisonOperatorNodeWidget
    extends StatelessWidget {
  final DartBlockValueTreeBooleanNumberComparisonOperatorNode node;
  final String? selectedNodeKey;
  final Function(DartBlockValueTreeBooleanNode)? onTap;
  final Function(
    DartBlockValueTreeBooleanOperatorNode,
    DartBlockBooleanOperator,
  )
  onChangeLogicalOperator;
  final Function(
    DartBlockValueTreeBooleanEqualityOperatorNode,
    DartBlockEqualityOperator,
  )
  onChangeEqualityOperator;
  final Function(
    DartBlockValueTreeBooleanNumberComparisonOperatorNode,
    DartBlockNumberComparisonOperator,
  )
  onChangeNumberComparisonOperator;
  const ValueCompositionNumberComparisonOperatorNodeWidget({
    super.key,
    required this.node,
    required this.selectedNodeKey,
    this.onTap,
    required this.onChangeLogicalOperator,
    required this.onChangeEqualityOperator,
    required this.onChangeNumberComparisonOperator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 16, top: 4, bottom: 4, left: 4),
      //margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Wrap(
        spacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (node.leftChild != null)
            ValueCompositionBooleanNodeWidget(
              node: node.leftChild!,
              selectedNodeKey: selectedNodeKey,
              onTap: onTap,
              onChangeLogicalOperator: onChangeLogicalOperator,
              onChangeEqualityOperator: onChangeEqualityOperator,
              onChangeNumberComparisonOperator:
                  onChangeNumberComparisonOperator,
            ),
          if (node.operator != null)
            PopupWidgetButton(
              tooltip: "Change operator...",
              widget: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: DartBlockNumberComparisonOperator.values
                    .map(
                      (e) => InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          onChangeNumberComparisonOperator(node, e);
                        },
                        child: Badge(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          label: Icon(
                            Icons.check,
                            size: 12,
                            color: Theme.of(context).colorScheme.onError,
                          ),
                          isLabelVisible: node.operator == e,
                          child: NumberComparisonOperatorWidget(operator: e),
                        ),
                      ),
                    )
                    .toList(),
              ),
              child: NumberComparisonOperatorWidget(operator: node.operator!),
            ),
          if (node.rightChild != null)
            ValueCompositionBooleanNodeWidget(
              node: node.rightChild!,
              selectedNodeKey: selectedNodeKey,
              onTap: onTap,
              onChangeLogicalOperator: onChangeLogicalOperator,
              onChangeEqualityOperator: onChangeEqualityOperator,
              onChangeNumberComparisonOperator:
                  onChangeNumberComparisonOperator,
            ),
        ],
      ),
    );
  }
}
