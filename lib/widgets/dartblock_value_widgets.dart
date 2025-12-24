import 'package:collection/collection.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/dartblock_editor_providers.dart';
import 'package:dartblock_code/widgets/views/dartblock_base_value_widget.dart';
import 'package:flutter/material.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DartBlockValueWidget extends ConsumerWidget {
  final DartBlockValue? value;
  final BorderRadius? borderRadius;
  final Border? border;
  final bool isInteractive;
  const DartBlockValueWidget({
    super.key,
    required this.value,
    this.borderRadius,
    this.border,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget child;
    if (value == null) {
      child = DartblockBaseValueWidget(
        color: Theme.of(context).colorScheme.secondary,
        label: "null",
        borderRadius: borderRadius,
      );
    } else {
      switch (value!) {
        case DartBlockStringValue():
          final stringValue = value! as DartBlockStringValue;
          child = DartBlockStringValueWidget(
            value: stringValue,
            borderRadius: borderRadius,
          );
        case DartBlockConcatenationValue():
          final concatenationValue = value! as DartBlockConcatenationValue;
          child = Wrap(
            spacing: 1,
            children: concatenationValue.values
                .mapIndexed((i, e) => DartBlockValueWidget(value: e))
                .toList(),
          );
        case DartBlockVariable():
          final variable = value! as DartBlockVariable;
          child = DartBlockVariableNodeWidget(
            variableName: variable.name,
            borderRadius: borderRadius,
          );
        case DartBlockFunctionCallValue():
          final functionCallValue = value! as DartBlockFunctionCallValue;
          child = DartBlockFunctionCallNodeWidget(
            functionCallStatement: functionCallValue.functionCall,
          );
        case DartBlockAlgebraicExpression():
          final algebraicExpression = value! as DartBlockAlgebraicExpression;
          child = ValueCompositionNumberNodeWidget(
            node: algebraicExpression.compositionNode,
            selectedNodeKey: null,
            onChangeOperator: null,
            includeBorder: false,
            borderRadius: borderRadius,
            padding: EdgeInsets.zero,
          );
        case DartBlockBooleanExpression():
          final booleanExpression = value! as DartBlockBooleanExpression;
          child = ValueCompositionBooleanNodeWidget(
            node: booleanExpression.compositionNode,
            onChangeEqualityOperator: (node, operator) {},
            onChangeLogicalOperator: (node, operator) {},
            onChangeNumberComparisonOperator: (node, operator) {},
            selectedNodeKey: null,
          );
      }
    }
    return isInteractive ? child : IgnorePointer(child: child);
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
    return DartblockBaseValueWidget(
      color: settings.colorFamily.string.color,
      label: "\"${value.value}\"",
      borderRadius: borderRadius,
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
    return DartblockBaseValueWidget(
      color: settings.colorFamily.number.color,
      label: node.toString(),
      borderRadius: borderRadius,
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
    return DartblockBaseValueWidget(
      color: settings.colorFamily.variable.color,
      label: variableName,
      borderRadius: borderRadius,
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
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border(
              left: BorderSide(
                color: settings.colorFamily.function.color,
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            functionCallStatement.functionName +
                (functionCallStatement.arguments.isEmpty ? "()" : "("),
            style: Theme.of(context).textTheme.bodyMedium?.apply(
              color: Theme.of(context).colorScheme.onSurface,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(4),
            border: Border.all(
              width: 1,
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
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              // borderRadius: functionCallStatement.arguments.isEmpty
              //     ? BorderRadius.circular(8)
              //     : BorderRadius.only(
              //         topRight: Radius.circular(8),
              //         bottomRight: Radius.circular(8),
              //       ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              ")",
              style: Theme.of(context).textTheme.bodyMedium?.apply(
                color: Theme.of(context).colorScheme.onSurface,
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
    return Container(
      width: 28,
      height: 28,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: settings.colorFamily.number.color, width: 1),
      ),
      child: Center(
        child: Text(
          arithmeticOperator.text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.apply(
            color: settings.colorFamily.number.color,
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
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: includeBorder
            ? Border(
                left: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 2,
                ),
                right: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 2,
                ),
              )
            : null,
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
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
                  spacing: 12,
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

class ValueCompositionBooleanConstantNodeWidget extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return DartblockBaseValueWidget(
      color: settings.colorFamily.boolean.color,
      label: node.toString(),
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
    return DartBlockValueWidget(value: node.value);
  }
}

class LogicalOperatorWidget extends StatelessWidget {
  final DartBlockBooleanOperator logicalOperator;
  const LogicalOperatorWidget({super.key, required this.logicalOperator});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceTint,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          logicalOperator.text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.apply(
            color: Theme.of(context).colorScheme.surfaceTint,
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 2,
          ),
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 2,
          ),
        ),
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
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
                spacing: 12,
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
    return Container(
      width: 28,
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceTint,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          equalityOperator.text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.apply(
            color: Theme.of(context).colorScheme.surfaceTint,
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 2,
          ),
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 2,
          ),
        ),
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
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
                spacing: 12,
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
    return Container(
      width: 28,
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: settings.colorFamily.number.color, width: 1),
      ),
      child: Center(
        child: Text(
          operator.toScript(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.apply(
            color: settings.colorFamily.number.color,
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 2,
          ),
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 2,
          ),
        ),
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
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
                spacing: 12,
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
