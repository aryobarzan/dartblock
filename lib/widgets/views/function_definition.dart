import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:dartblock_code/models/function.dart';
import 'package:dartblock_code/widgets/views/symbols.dart';
import 'package:dartblock_code/widgets/views/variable_definition.dart';

class FunctionDefinitionWidget extends StatelessWidget {
  final FunctionDefinition functionDefinition;
  final bool showParameters;
  final bool showReturnTypeLabel;
  const FunctionDefinitionWidget({
    super.key,
    required this.functionDefinition,
    this.showParameters = true,
    this.showReturnTypeLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        DartBlockFunctionNameSymbol(name: functionDefinition.name),
        // ColoredTitleChip(
        //   title: functionDefinition.name,
        //   textStyle: Theme.of(context)
        //       .textTheme
        //       .bodySmall
        //       ?.copyWith(fontWeight: FontWeight.w500, color: Colors.white),
        //   color: NeoTechColors.function,
        //   borderRadius: const BorderRadius.only(
        //     topLeft: Radius.circular(12),
        //     bottomLeft: Radius.circular(12),
        //   ),
        // ),
        if (functionDefinition.parameters.isNotEmpty && showParameters) ...[
          Container(
            width: 8,
            height: 2,
            color: Theme.of(context).colorScheme.outline,
          ),
          ...functionDefinition.parameters.mapIndexed(
            (index, element) => Row(
              children: [
                VariableDefinitionWidget(variableDefinition: element),
                if (index < functionDefinition.parameters.length - 1)
                  Container(
                    width: 8,
                    height: 1,
                    color: Theme.of(context).colorScheme.outline,
                  ),
              ],
            ),
          ),
        ],
        ...[
          const Icon(Icons.arrow_right),
          functionDefinition.returnType != null
              ? DartBlockDataTypeSymbol(
                  dataType: functionDefinition.returnType!,
                  includeLabel: showReturnTypeLabel,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                )
              : DartBlockVoidSymbol(
                  includeLabel: showReturnTypeLabel,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
        ],
      ],
    );
  }
}
