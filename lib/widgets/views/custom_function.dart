import 'package:collection/collection.dart';
import 'package:dartblock_code/core/dartblock_program.dart';
import 'package:dartblock_code/widgets/dartblock_editor_providers.dart';
import 'package:dartblock_code/widgets/helpers/adaptive_display.dart';
import 'package:flutter/material.dart';
import 'package:dartblock_code/models/function.dart';
import 'package:dartblock_code/models/dartblock_interaction.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/editors/custom_function_basic.dart';
import 'package:dartblock_code/widgets/editors/variable_definition.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:dartblock_code/widgets/views/statement_listview.dart';
import 'package:dartblock_code/widgets/views/symbols.dart';
import 'package:dartblock_code/widgets/views/variable_definition.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomFunctionWidget extends ConsumerWidget {
  final DartBlockCustomFunction customFunction;
  final bool isMainFunction;

  final Function(DartBlockCustomFunction) onChanged;
  final Function()? onDelete;
  final Function(Statement statement, bool cut) onCopiedStatement;
  final Function() onPastedStatement;
  const CustomFunctionWidget({
    super.key,
    required this.customFunction,
    required this.onChanged,
    this.onDelete,
    required this.onCopiedStatement,
    required this.onPastedStatement,
    required this.isMainFunction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final program = ref.watch(programProvider);
    final settings = ref.watch(settingsProvider);

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          isMainFunction
              ? const MainFunctionHeader()
              : CustomFunctionHeaderWidget(
                  customFunction: customFunction,
                  onTap: () {
                    DartBlockInteraction.create(
                      dartBlockInteractionType:
                          DartBlockInteractionType.editFunction,
                      content: 'FunctionName-${customFunction.name}',
                    ).dispatch(context);
                    _showCustomFunctionBasicEditorBottomSheet(
                      context,
                      ref,
                      settings,
                      program,
                    );
                  },
                ),
          if (!isMainFunction)
            Container(
              decoration: BoxDecoration(
                color: settings.colorFamily.function.colorContainer.withValues(
                  alpha: 0.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 4, right: 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ...customFunction.parameters.mapIndexed(
                      (index, e) => InkWell(
                        onTap: settings.canDelete || settings.canChange
                            ? () {
                                _showCustomFunctionParameterEditorBottomSheet(
                                  context,
                                  settings,
                                  program,
                                  parameterIndex: index,
                                );
                              }
                            : null,
                        child: SizedBox(
                          height: 36,
                          child: VariableDefinitionWidget(
                            variableDefinition: e,
                            circularRightSide: true,
                          ),
                        ),
                      ),
                    ),
                    if (settings.canChange)
                      customFunction.parameters.isEmpty
                          ? TextButton.icon(
                              onPressed: () {
                                _showCustomFunctionParameterEditorBottomSheet(
                                  context,
                                  settings,
                                  program,
                                );
                              },
                              icon: Icon(
                                Icons.add,
                                color: settings.colorFamily.function.color,
                              ),
                              label: Text(
                                'Parameter',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.apply(
                                      color:
                                          settings.colorFamily.function.color,
                                    ),
                              ),
                            )
                          : IconButton(
                              color: settings.colorFamily.function.color,
                              onPressed: () {
                                _showCustomFunctionParameterEditorBottomSheet(
                                  context,
                                  settings,
                                  program,
                                );
                              },
                              tooltip: "Add new parameter...",
                              icon: const Icon(Icons.add),
                            ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 2, right: 2, bottom: 4),
            child: StatementListView(
              neoTechCoreNodeKey: customFunction.statements.isNotEmpty
                  ? customFunction.statements.last.hashCode
                  : customFunction.hashCode,
              statements: customFunction.statements,
              canDelete: settings.canDelete,
              canReorder: settings.canReorder,
              onChanged: (newStatements) {
                customFunction.statements = newStatements;
                onChanged(customFunction);
              },
              onDuplicate: (index) {
                final duplicatedStatement = customFunction.statements[index]
                    .copy();
                if (index < customFunction.statements.length - 1) {
                  customFunction.statements.insert(
                    index + 1,
                    duplicatedStatement,
                  );
                } else {
                  customFunction.statements.add(duplicatedStatement);
                }
                onChanged(customFunction);
              },
              onCopiedStatement: onCopiedStatement,
              onPastedStatement: onPastedStatement,
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomFunctionBasicEditorBottomSheet(
    BuildContext context,
    WidgetRef ref,
    DartBlockSettings settings,
    DartBlockProgram program,
  ) {
    final availableFunctions = ref.watch(availableFunctionsProvider([]));
    showAdaptiveBottomSheetOrDialog(
      context,
      sheetPadding: EdgeInsets.all(8),
      dialogPadding: EdgeInsets.all(16),
      useProviderAwareModal: true,
      child: CustomFunctionBasicEditor(
        customFunctionName: customFunction.name,
        returnType: customFunction.returnType,
        existingCustomFunctionNames: availableFunctions
            .map((e) => e.name)
            .whereNot((element) => element == customFunction.name)
            .toList(),
        canDelete: settings.canDelete,
        canChange: settings.canChange,
        onDelete: () {
          if (onDelete != null) {
            Navigator.of(context).pop();
            onDelete!();
          }
        },
        onSaved: (newName, newReturnType) {
          Navigator.of(context).pop();
          customFunction.name = newName;
          customFunction.returnType = newReturnType;
          ScaffoldMessenger.of(context).showSnackBar(
            createDartBlockInfoSnackBar(
              context,
              iconData: Icons.check,
              message: "Saved custom function: $newName",
            ),
          );
          onChanged(customFunction);
        },
      ),
    );
  }

  bool isParameterIndexValid(int? index) {
    return index != null &&
        index >= 0 &&
        index < customFunction.parameters.length;
  }

  void _showCustomFunctionParameterEditorBottomSheet(
    BuildContext context,
    DartBlockSettings settings,
    DartBlockProgram program, {
    int? parameterIndex,
  }) {
    final neoTechCoreTree = program.buildTree();
    final variableDefinition = isParameterIndexValid(parameterIndex)
        ? customFunction.parameters[parameterIndex!]
        : null;
    DartBlockInteraction.create(
      dartBlockInteractionType: variableDefinition != null
          ? DartBlockInteractionType.editFunctionParameter
          : DartBlockInteractionType.createFunctionParameter,
      content: variableDefinition != null
          ? 'ParameterName-${variableDefinition.name}'
          : '',
    ).dispatch(context);

    showAdaptiveBottomSheetOrDialog(
      context,
      dialogPadding: EdgeInsets.all(16),
      useProviderAwareModal: true,
      child: VariableDefinitionEditor(
        functionDefinition: customFunction.getAsFunctionDefinition(),
        variableDefinition: variableDefinition,
        existingVariableDefinitions: variableDefinition != null
            ? neoTechCoreTree
                  .findVariableDefinitions(
                    customFunction.hashCode,
                    includeNode: true,
                  )
                  .whereNot((element) => element == variableDefinition)
                  .toList()
            : neoTechCoreTree.findVariableDefinitions(
                customFunction.hashCode,
                includeNode: true,
              ),
        canChange: settings.canChange,
        canDelete: settings.canDelete,
        onSaved: (value) {
          Navigator.of(context).pop();
          if (isParameterIndexValid(parameterIndex)) {
            DartBlockInteraction.create(
              dartBlockInteractionType:
                  DartBlockInteractionType.editedFunctionParameter,
            ).dispatch(context);
            customFunction.parameters[parameterIndex!] = value;
          } else {
            DartBlockInteraction.create(
              dartBlockInteractionType:
                  DartBlockInteractionType.createdFunctionParameter,
            ).dispatch(context);
            customFunction.parameters.add(value);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            createDartBlockInfoSnackBar(
              context,
              iconData: Icons.check,
              message:
                  "${isParameterIndexValid(parameterIndex) ? 'Saved' : 'Added'} function parameter: ${value.name}",
            ),
          );
          onChanged(customFunction);
        },
        onDelete: () {
          Navigator.of(context).pop();
          if (isParameterIndexValid(parameterIndex)) {
            DartBlockInteraction.create(
              dartBlockInteractionType:
                  DartBlockInteractionType.deletedFunctionParameter,
            ).dispatch(context);
            customFunction.parameters.removeAt(parameterIndex!);
            onChanged(customFunction);
          }
        },
      ),
    );
  }
}

class CustomFunctionHeaderWidget extends ConsumerWidget {
  final DartBlockCustomFunction customFunction;
  final Function onTap;
  const CustomFunctionHeaderWidget({
    super.key,
    required this.customFunction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Container(
      decoration: BoxDecoration(
        color: settings.colorFamily.function.colorContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          onTap: () {
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const DartBlockFunctionSymbol(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    customFunction.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.apply(
                      color: settings.colorFamily.function.onColorContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                customFunction.returnType != null
                    ? DartBlockDataTypeSymbol(
                        dataType: customFunction.returnType!,
                        includeLabel: true,
                      )
                    : const DartBlockVoidSymbol(includeLabel: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainFunctionHeader extends ConsumerWidget {
  const MainFunctionHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Container(
      decoration: BoxDecoration(
        color: settings.colorFamily.function.colorContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          onTap: () {
            DartBlockInteraction.create(
              dartBlockInteractionType:
                  DartBlockInteractionType.tapMainFunctionHeader,
            ).dispatch(context);
            _showMainFunctionExplainerDialog(context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                const DartBlockFunctionSymbol(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Main Function",
                    maxLines: 1,
                    style: Theme.of(context).textTheme.titleMedium?.apply(
                      color: settings.colorFamily.function.onColorContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: settings.colorFamily.function.onColorContainer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMainFunctionExplainerDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.info),
          iconColor: Theme.of(context).colorScheme.primary,
          title: const Text('Main Function'),
          content: const Text(
            "'Main Function' is the entry point of your DartBlock program, "
            "which is executed when tapping 'Run'.\n"
            "The name of this special function cannot be changed, and it has no return type.",
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
