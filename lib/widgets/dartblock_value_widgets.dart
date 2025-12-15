import 'package:collection/collection.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/dartblock_editor_providers.dart';
import 'package:flutter/material.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DartBlockValueWidget extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final Color color;
    final Color textColor;
    if (value == null) {
      color = Theme.of(context).colorScheme.tertiaryContainer;
      textColor = Theme.of(context).colorScheme.onTertiaryContainer;
      return ColoredTitleChip(
        title: value.toString(),
        color: color,
        border: border,
        borderRadius: borderRadius ?? BorderRadius.circular(6),
        textColor: textColor,
      );
    } else {
      switch (value!) {
        case DartBlockStringValue():
          final stringValue = value! as DartBlockStringValue;
          return DartBlockStringValueWidget(
            value: stringValue,
            borderRadius: borderRadius,
          );
        case DartBlockConcatenationValue():
          final concatenationValue = value! as DartBlockConcatenationValue;
          return Wrap(
            spacing: 1,
            children: concatenationValue.values
                .mapIndexed(
                  (i, e) => DartBlockValueWidget(
                    value: e,
                    borderRadius:
                        i == 0 && concatenationValue.values.length == 1
                        ? BorderRadius.circular(8)
                        : i == 0
                        ? BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          )
                        : i == concatenationValue.values.length - 1
                        ? BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          )
                        : null,
                  ),
                )
                .toList(),
          );
        case DartBlockVariable():
          final variable = value! as DartBlockVariable;
          return DartBlockVariableNodeWidget(
            variableName: variable.name,
            borderRadius: borderRadius,
          );
        case DartBlockFunctionCallValue():
          final functionCallValue = value! as DartBlockFunctionCallValue;
          return DartBlockFunctionCallNodeWidget(
            functionCallStatement: functionCallValue.functionCall,
          );
        case DartBlockAlgebraicExpression():
          final algebraicExpression = value! as DartBlockAlgebraicExpression;
          return ValueCompositionNumberNodeWidget(
            node: algebraicExpression.compositionNode,
            selectedNodeKey: null,
            onChangeOperator: null,
            includeBorder: false,
            borderRadius: borderRadius,
            padding: EdgeInsets.zero,
          );
        case DartBlockBooleanExpression():
          final booleanExpression = value! as DartBlockBooleanExpression;
          return ValueCompositionBooleanNodeWidget(
            node: booleanExpression.compositionNode,
            onChangeEqualityOperator: (node, operator) {},
            onChangeLogicalOperator: (node, operator) {},
            onChangeNumberComparisonOperator: (node, operator) {},
            selectedNodeKey: null,
          );
      }
    }
  }
}

///

class DartBlockStringValueWidget extends ConsumerWidget {
  final DartBlockStringValue value;
  final BorderRadius? borderRadius;
  const DartBlockStringValueWidget({
    super.key,
    required this.value,
    this.borderRadius,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Container(
      decoration: BoxDecoration(
        color: settings.colorFamily.string.color,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        value.value,
        style: Theme.of(context).textTheme.bodyMedium?.apply(
          color: settings.colorFamily.string.onColor,
        ),
      ),
    );
  }
}

class ValueCompositionNumberNodeWidget extends StatelessWidget {
  final DartBlockValueTreeAlgebraicNode node;
  final String? selectedNodeKey;
  final Function(DartBlockValueTreeAlgebraicNode)? onTap;
  final Function(
    DartBlockValueTreeAlgebraicOperatorNode,
    DartBlockAlgebraicOperator,
  )?
  onChangeOperator;
  final bool includeBorder;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  const ValueCompositionNumberNodeWidget({
    super.key,
    required this.node,
    required this.selectedNodeKey,
    this.onTap,
    required this.onChangeOperator,
    this.includeBorder = true,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
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
        );
      case DartBlockValueTreeAlgebraicDynamicNode():
        return ValueCompositionNumberDynamicNodeWidget(
          node: node as DartBlockValueTreeAlgebraicDynamicNode,
        );
      case DartBlockValueTreeAlgebraicOperatorNode():
        return ValueCompositionArithmeticOperatorNodeWidget(
          node: node as DartBlockValueTreeAlgebraicOperatorNode,
          selectedNodeKey: selectedNodeKey,
          onTap: onTap,
          onChangeOperator: onChangeOperator,
          includeBorder: includeBorder,
          padding: padding,
        );
    }
  }
}

class ValueCompositionNumberConstantNodeWidget extends ConsumerWidget {
  final DartBlockValueTreeAlgebraicConstantNode node;
  final BorderRadius? borderRadius;
  const ValueCompositionNumberConstantNodeWidget({
    super.key,
    required this.node,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Container(
      decoration: BoxDecoration(
        color: settings.colorFamily.number.color,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        node.toString(),
        style: Theme.of(context).textTheme.bodyMedium?.apply(
          color: settings.colorFamily.number.onColor,
        ),
      ),
    );
  }
}

class ValueCompositionNumberDynamicNodeWidget extends StatelessWidget {
  final DartBlockValueTreeAlgebraicDynamicNode node;
  final BorderRadius? borderRadius;

  const ValueCompositionNumberDynamicNodeWidget({
    super.key,
    required this.node,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final value = node.value;
    return switch (value) {
      DartBlockVariable() => DartBlockVariableNodeWidget(
        variableName: value.name,
        borderRadius: borderRadius,
      ),
      DartBlockFunctionCallValue() => DartBlockFunctionCallNodeWidget(
        functionCallStatement: value.functionCall,
      ),
    };
  }
}

class DartBlockVariableNodeWidget extends ConsumerWidget {
  final String variableName;
  final BorderRadius? borderRadius;
  const DartBlockVariableNodeWidget({
    super.key,
    required this.variableName,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Container(
      decoration: BoxDecoration(
        color: settings.colorFamily.variable.color,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        variableName,
        style: Theme.of(context).textTheme.bodyMedium?.apply(
          color: settings.colorFamily.variable.onColor,
        ),
      ),
    );
  }
}

class DartBlockFunctionCallNodeWidget extends ConsumerWidget {
  final FunctionCallStatement functionCallStatement;
  final BorderRadius? borderRadius;
  const DartBlockFunctionCallNodeWidget({
    super.key,
    required this.functionCallStatement,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: settings.colorFamily.function.color,
            borderRadius:
                borderRadius ??
                (functionCallStatement.arguments.isEmpty
                    ? BorderRadius.circular(8)
                    : BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      )),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            functionCallStatement.functionName +
                (functionCallStatement.arguments.isEmpty ? "()" : "("),
            style: Theme.of(context).textTheme.bodyMedium?.apply(
              color: settings.colorFamily.function.onColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              width: 2,
              color: settings.colorFamily.function.color,
            ),
          ),
          child: Row(
            spacing: 8,
            children: [
              for (int i = 0; i < functionCallStatement.arguments.length; i++)
                IgnorePointer(
                  child: DartBlockValueWidget(
                    value: functionCallStatement.arguments[i],
                    // borderRadius:
                    //     i == 0 && functionCallStatement.arguments.length == 1
                    //     ? BorderRadius.circular(8)
                    //     : i == 0
                    //     ? BorderRadius.only(
                    //         topLeft: Radius.circular(8),
                    //         bottomLeft: Radius.circular(8),
                    //       )
                    //     : i == functionCallStatement.arguments.length - 1
                    //     ? BorderRadius.only(
                    //         topRight: Radius.circular(8),
                    //         bottomRight: Radius.circular(8),
                    //       )
                    //     : null,
                  ),
                ),
            ],
          ),
        ),

        if (functionCallStatement.arguments.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: settings.colorFamily.function.color,
              borderRadius: functionCallStatement.arguments.isEmpty
                  ? BorderRadius.circular(8)
                  : BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              ")",
              style: Theme.of(context).textTheme.bodyMedium?.apply(
                color: settings.colorFamily.function.onColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}

class ArithmericOperatorWidget extends ConsumerWidget {
  final DartBlockAlgebraicOperator arithmeticOperator;
  const ArithmericOperatorWidget({super.key, required this.arithmeticOperator});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Card(
      elevation: 8,
      color: settings.colorFamily.number.color,
      child: Container(
        width: 24,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
  )?
  onChangeOperator;
  final bool includeBorder;
  final EdgeInsetsGeometry? padding;
  const ValueCompositionArithmeticOperatorNodeWidget({
    super.key,
    required this.node,
    required this.selectedNodeKey,
    this.onTap,
    required this.onChangeOperator,
    this.includeBorder = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ??
          const EdgeInsets.only(right: 16, top: 4, bottom: 4, left: 4),
      //margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: includeBorder
            ? Border.all(color: Theme.of(context).colorScheme.outline)
            : null,
      ),
      child: Wrap(
        spacing: 4,
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
            // TODO: turn into vertical list
            IgnorePointer(
              ignoring: onChangeOperator == null,
              child: PopupWidgetButton(
                tooltip: "Change operator...",
                widget: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: node
                      .getSupportedOperators()
                      .map(
                        (e) => InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            onChangeOperator?.call(node, e);
                          },
                          child: Badge(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                            label: Icon(
                              Icons.check,
                              size: 12,
                              color: Theme.of(context).colorScheme.onError,
                            ),
                            isLabelVisible: node.operator == e,
                            child: ArithmericOperatorWidget(
                              arithmeticOperator: e,
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

class ValueCompositionBooleanGenericNodeWidget extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final backgroundColor = switch (node) {
      DartBlockValueTreeBooleanGenericNumberNode() =>
        settings.colorFamily.number.color,
      DartBlockValueTreeBooleanGenericConcatenationNode() =>
        settings.colorFamily.string.color,
    };
    final textColor = switch (node) {
      DartBlockValueTreeBooleanGenericNumberNode() =>
        settings.colorFamily.number.onColor,
      DartBlockValueTreeBooleanGenericConcatenationNode() =>
        settings.colorFamily.string.onColor,
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
          ).textTheme.bodyMedium?.apply(color: textColor),
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

class NumberComparisonOperatorWidget extends ConsumerWidget {
  final DartBlockNumberComparisonOperator operator;
  const NumberComparisonOperatorWidget({super.key, required this.operator});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Card(
      elevation: 2,
      color: settings.colorFamily.number.color,
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
            style: Theme.of(context).textTheme.bodyMedium?.apply(
              color: settings.colorFamily.number.onColor,
            ),
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
