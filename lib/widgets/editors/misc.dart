import 'package:dartblock_code/widgets/dartblock_editor_providers.dart';
import 'package:dartblock_code/widgets/editors/composers/components/variable_definition_picker.dart';
import 'package:flutter/material.dart';
import 'package:dartblock_code/models/function.dart';
import 'package:dartblock_code/models/dartblock_notification.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/editors/function_call.dart';
import 'package:dartblock_code/widgets/helpers/provider_aware_modal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FunctionVariableSplitButton extends ConsumerWidget {
  final DartBlockFunctionCallValue? functionCallValue;
  final List<DartBlockVariableDefinition> variableDefinitions;
  final Function(
    DartBlockFunction function,
    FunctionCallStatement functionCallStatement,
  )
  onSavedFunctionCallStatement;
  final Function(DartBlockVariableDefinition) onPickedVariableDefinition;
  final List<DartBlockDataType>? restrictFunctionCallReturnTypes;
  const FunctionVariableSplitButton({
    super.key,
    this.functionCallValue,
    required this.variableDefinitions,
    required this.onSavedFunctionCallStatement,
    required this.onPickedVariableDefinition,
    this.restrictFunctionCallReturnTypes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableFunctions = ref
        .watch(
          availableFunctionsProvider(restrictFunctionCallReturnTypes ?? []),
        )
        .toList();
    final settings = ref.watch(settingsProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: FilledButton(
            onPressed: availableFunctions.isNotEmpty
                ? () {
                    _showFunctionCallComposerModalBottomSheet(context);
                  }
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: settings.colorFamily.function.color,
              padding: const EdgeInsets.only(
                top: 2,
                bottom: 2,
                right: 6,
                left: 12,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
              ),
            ),
            child: Image.asset(
              'assets/icons/neotech_function.png',
              package: 'dartblock_code',
              width: 20,
              height: 20,
              color: availableFunctions.isNotEmpty
                  ? Colors.white
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          child: FilledButton(
            onPressed: variableDefinitions.isNotEmpty
                ? () {
                    _showVariablePickerComposerModalBottomSheet(context);
                  }
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: settings.colorFamily.variable.color,
              padding: const EdgeInsets.only(
                top: 2,
                bottom: 2,
                left: 6,
                right: 12,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
            ),
            child: Image.asset(
              'assets/icons/neotech_variable.png',
              package: 'dartblock_code',
              width: 24,
              height: 24,
              color: variableDefinitions.isNotEmpty
                  ? Colors.white
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  void _showModalBottomSheet(BuildContext context, String title, Widget body) {
    context.showProviderAwareBottomSheet(
      isScrollControlled: true,
      showDragHandle: true,
      clipBehavior: Clip.hardEdge,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      builder: (sheetContext) {
        /// Due to the modal sheet having a separate context and thus no relation
        /// to the main context of the NeoTechWidget, we capture DartBlockNotifications
        /// from the sheet's context and manually re-dispatch them using the parent context.
        /// The parent context may not necessarily be the NeoTechWidget's context,
        /// as certain sheets open additional nested sheets with their own contexts,
        /// hence this process needs to be repeated for every sheet until the NeoTechWidget's
        /// context is reached.
        return NotificationListener<DartBlockNotification>(
          onNotification: (notification) {
            notification.dispatch(context);
            return true;
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 8,
                right: 8,
                top: 8,
                bottom: 16 + MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: Theme.of(sheetContext).textTheme.titleLarge,
                  ),
                  const Divider(),
                  Flexible(child: body),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFunctionCallComposerModalBottomSheet(BuildContext context) {
    _showModalBottomSheet(
      context,
      "Function Call",
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: FunctionCallComposer(
          statement: functionCallValue?.functionCall,
          existingVariableDefinitions: variableDefinitions,
          onSaved: (customFunction, savedFunctionCall) {
            Navigator.of(context).pop();
            onSavedFunctionCallStatement(customFunction, savedFunctionCall);
          },
          restrictToDataTypes: restrictFunctionCallReturnTypes ?? [],
        ),
      ),
    );
  }

  void _showVariablePickerComposerModalBottomSheet(BuildContext context) {
    _showModalBottomSheet(
      context,
      "Variable Picker",
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: VariableDefinitionPicker(
          asPickerButton: false,
          variableDefinitions: variableDefinitions,
          onPick: (pickedVariableDefinition) {
            Navigator.of(context).pop();
            onPickedVariableDefinition(pickedVariableDefinition);
          },
        ),
      ),
    );
  }
}
