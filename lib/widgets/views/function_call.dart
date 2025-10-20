import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:dartblock/models/function.dart';
import 'package:dartblock/models/statement.dart';
import 'package:dartblock/widgets/helper_widgets.dart';
import 'package:dartblock/widgets/dartblock_value_widgets.dart';
import 'package:dartblock/widgets/views/other/dartblock_colors.dart';
import 'package:dartblock/widgets/views/symbols.dart';

class FunctionCallStatementWidget extends StatelessWidget {
  final FunctionCallStatement statement;

  /// If the custom function being called by this statement cannot be found, this field is null.
  /// A warning should be shown in that case to tell the user to update this statement to fix the issue.
  final DartBlockFunction? customFunction;
  const FunctionCallStatementWidget({
    super.key,
    required this.statement,
    this.customFunction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (customFunction == null && statement.customFunctionName != 'main')
          WarningIconButton(
            title: "Function not found",
            message:
                "The function '${statement.customFunctionName}' does not exist, which may happen when you've changed a function's name.\nEdit this function call to fix the issue!",
          ),
        if (customFunction != null &&
            statement.arguments.length < customFunction!.parameters.length)
          WarningIconButton(
            title: "Missing arguments",
            message:
                "The function '${customFunction!.name}' expects ${customFunction!.parameters.length} argument${customFunction!.parameters.length == 1 ? '' : 's'}, but you have only indicated ${statement.arguments.length}.\nEdit this function call to fix the issue!",
          ),
        ColoredTitleChip(
          title: statement.customFunctionName,
          textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          color: DartBlockColors.function,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
        ),
        if (customFunction != null &&
            customFunction!.parameters.isNotEmpty) ...[
          Container(
            width: 8,
            height: 2,
            color: Theme.of(context).colorScheme.outline,
          ),
          ...customFunction!.parameters.mapIndexed(
            (index, element) => Row(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: DartBlockColors.variable,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Text(
                      element.name,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.apply(color: Colors.white),
                    ),
                  ),
                ),
                index < statement.arguments.length
                    ? DartBlockValueWidget(
                        value: statement.arguments[index],
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Missing argument"),
                              content: Text(
                                "The function '${customFunction!.name}' expects an argument of type ${element.dataType.toString()} at index $index.\nEdit this function call to fix the issue!",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Okay"),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: Text(
                              '???',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.apply(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                if (index < customFunction!.parameters.length - 1)
                  Container(
                    width: 8,
                    height: 1,
                    color: Theme.of(context).colorScheme.outline,
                  ),
              ],
            ),
          ),
        ],
        if (customFunction != null) ...[
          const SizedBox(width: 4),
          const NeoTechReturnSymbol(),
          const SizedBox(width: 4),
          customFunction!.returnType != null
              ? NeoTechDataTypeSymbol(
                  includeLabel: true,
                  dataType: customFunction!.returnType!,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                )
              : const VoidSymbol(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
        ],
      ],
    );
  }
}
