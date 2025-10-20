import 'package:flutter/material.dart';
import 'package:dartblock/models/dartblock_value.dart';
import 'package:dartblock/widgets/views/other/dartblock_colors.dart';
import 'package:dartblock/widgets/views/symbols.dart';

class VariableDefinitionWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            color: DartBlockColors.getNeoTechDataTypeColor(
              variableDefinition.dataType,
            ),
          ),
          child: NeoTechDataTypeIcon(
            dataType: variableDefinition.dataType,
            color: Colors.white,
          ),
        ),
        Container(
          height: 24,
          decoration: BoxDecoration(
            borderRadius: circularRightSide
                ? const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  )
                : null,
            color: DartBlockColors.variable,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          alignment: Alignment.center,
          child: Text(
            variableDefinition.name,
            style: useBodyMedium
                ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  )
                : Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
