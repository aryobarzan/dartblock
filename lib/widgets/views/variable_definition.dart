import 'package:dartblock_code/widgets/dartblock_editor_providers.dart';
import 'package:flutter/material.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/widgets/views/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VariableDefinitionWidget extends ConsumerWidget {
  final DartBlockVariableDefinition variableDefinition;
  final bool circularRightSide;
  final bool useBodyMedium;
  const VariableDefinitionWidget({
    super.key,
    required this.variableDefinition,
    this.circularRightSide = false,
    this.useBodyMedium = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: settings.colorFamily
                .getNeoTechDataTypeColor(variableDefinition.dataType)
                .color,
          ),
          child: DartBlockDataTypeIcon(
            dataType: variableDefinition.dataType,
            color: settings.colorFamily
                .getNeoTechDataTypeColor(variableDefinition.dataType)
                .onColor,
          ),
        ),
        Container(
          height: 28,
          decoration: BoxDecoration(
            borderRadius: circularRightSide
                ? const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  )
                : null,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          alignment: Alignment.center,
          child: Text(
            variableDefinition.name,
            style: Theme.of(context).textTheme.bodyMedium?.apply(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
    // return TwoTonedChip(
    //   left: NeoTechDataTypeIcon(
    //     dataType: variableDefinition.dataType,
    //     color: Colors.white,
    //   ),
    //   right: FittedBox(
    //     fit: BoxFit.scaleDown,
    //     child: Text(
    //       variableDefinition.name,
    //       style:
    //           Theme.of(context).textTheme.bodySmall?.apply(color: Colors.white),
    //     ),
    //   ),
    //   leftColor:
    //       NeoTechColors.getNeoTechDataTypeColor(variableDefinition.dataType),
    //   rightColor: NeoTechColors.variable,
    //   height: 24,
    //   //  width: 80,
    // );
  }
}
