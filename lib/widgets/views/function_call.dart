import 'package:collection/collection.dart';
import 'package:dartblock_code/widgets/dartblock_editor_providers.dart';
import 'package:flutter/material.dart';
import 'package:dartblock_code/models/function.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:dartblock_code/widgets/dartblock_value_widgets.dart';
import 'package:dartblock_code/widgets/views/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FunctionCallStatementWidget extends ConsumerWidget {
  final FunctionCallStatement statement;

  /// If the DartBlockFunction being called by this statement cannot be found, this field is null.
  /// A warning should be shown in that case to tell the user to update this statement to fix the issue.
  final DartBlockFunction? dartBlockFunction;
  const FunctionCallStatementWidget({
    super.key,
    required this.statement,
    this.dartBlockFunction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dartBlockFunction == null && statement.functionName != 'main')
          WarningIconButton(
            title: "Function not found",
            message:
                "The function '${statement.functionName}' does not exist, which may happen when you've changed a function's name.\nEdit this function call to fix the issue!",
          ),
        if (dartBlockFunction != null &&
            statement.arguments.length < dartBlockFunction!.parameters.length)
          WarningIconButton(
            title: "Missing arguments",
            message:
                "The function '${dartBlockFunction!.name}' expects ${dartBlockFunction!.parameters.length} argument${dartBlockFunction!.parameters.length == 1 ? '' : 's'}, but you have only indicated ${statement.arguments.length}.\nEdit this function call to fix the issue!",
          ),
        ColoredTitleChip(
          title: statement.functionName,
          textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          color: settings.colorFamily.function.color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
        ),
        if (dartBlockFunction != null &&
            dartBlockFunction!.parameters.isNotEmpty) ...[
          Container(
            width: 8,
            height: 2,
            color: Theme.of(context).colorScheme.outline,
          ),
          ...dartBlockFunction!.parameters.mapIndexed(
            (index, element) => Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: settings.colorFamily.variable.color,
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
                                "The function '${dartBlockFunction!.name}' expects an argument of type ${element.dataType.toString()} at index $index.\nEdit this function call to fix the issue!",
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
                if (index < dartBlockFunction!.parameters.length - 1)
                  Container(
                    width: 8,
                    height: 1,
                    color: Theme.of(context).colorScheme.outline,
                  ),
              ],
            ),
          ),
        ],
        if (dartBlockFunction != null) ...[
          const SizedBox(width: 4),
          const NeoTechReturnSymbol(),
          const SizedBox(width: 4),
          dartBlockFunction!.returnType != null
              ? NeoTechDataTypeSymbol(
                  includeLabel: true,
                  dataType: dartBlockFunction!.returnType!,
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
