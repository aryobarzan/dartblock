import 'package:dartblock_code/models/dartblock_notification.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/widgets/dartblock_editor_providers.dart';
import 'package:dartblock_code/widgets/editors/composers/components/variable_definition_picker.dart';
import 'package:dartblock_code/widgets/helpers/provider_aware_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VariablePickerButton extends ConsumerWidget {
  final List<DartBlockVariableDefinition> variableDefinitions;
  final Function(DartBlockVariableDefinition) onPickedVariableDefinition;
  const VariablePickerButton({
    super.key,
    required this.variableDefinitions,
    required this.onPickedVariableDefinition,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Tooltip(
      message: "Variable",
      child: FilledButton(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 1),
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: variableDefinitions.isNotEmpty
            ? () {
                _showVariablePickerComposerModalBottomSheet(context);
              }
            : null,
        child: Text(
          "(x)",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: settings.colorFamily.variable.color,
          ),
        ),
      ),
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
