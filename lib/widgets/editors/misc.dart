import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartblock/models/function.dart';
import 'package:dartblock/models/dartblock_notification.dart';
import 'package:dartblock/models/dartblock_value.dart';
import 'package:dartblock/models/statement.dart';
import 'package:dartblock/widgets/editors/function_call.dart';
import 'package:dartblock/widgets/helper_widgets.dart';
import 'package:dartblock/widgets/views/other/dartblock_colors.dart';
import 'package:dartblock/widgets/views/variable_definition.dart';

class FunctionVariableSplitButton extends StatelessWidget {
  final DartBlockFunctionCallValue? functionCallValue;
  final List<DartBlockFunction> customFunctions;
  final List<DartBlockVariableDefinition> variableDefinitions;
  final Function(
    DartBlockFunction customFunction,
    FunctionCallStatement functionCallStatement,
  )
  onSavedFunctionCallStatement;
  final Function(DartBlockVariableDefinition) onPickedVariableDefinition;
  final List<DartBlockDataType>? restrictFunctionCallReturnTypes;
  const FunctionVariableSplitButton({
    super.key,
    this.functionCallValue,
    required this.customFunctions,
    required this.variableDefinitions,
    required this.onSavedFunctionCallStatement,
    required this.onPickedVariableDefinition,
    this.restrictFunctionCallReturnTypes,
  });

  @override
  Widget build(BuildContext context) {
    final List<DartBlockFunction> filteredCustomFunctions =
        restrictFunctionCallReturnTypes == null
        ? customFunctions
        : customFunctions
              .where(
                (element) => restrictFunctionCallReturnTypes!.contains(
                  element.returnType,
                ),
              )
              .toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: FilledButton(
            onPressed: filteredCustomFunctions.isNotEmpty
                ? () {
                    _showFunctionCallComposerModalBottomSheet(context);
                  }
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: DartBlockColors.function,
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
              package: 'project_neotech',
              width: 20,
              height: 20,
              color: filteredCustomFunctions.isNotEmpty
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
              backgroundColor: DartBlockColors.variable,
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
              package: 'project_neotech',
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
    showModalBottomSheet(
      isScrollControlled: true,
      showDragHandle: true,
      clipBehavior: Clip.hardEdge,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      context: context,
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
          statement: functionCallValue?.customFunctionCall,
          customFunctions: customFunctions,
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

class VariableDefinitionPicker extends StatelessWidget {
  final List<DartBlockVariableDefinition> variableDefinitions;
  final String? selectedVariableDefinitionName;
  final Function(DartBlockVariableDefinition) onPick;
  final bool asPickerButton;
  final Widget? child;
  const VariableDefinitionPicker({
    super.key,
    required this.variableDefinitions,
    this.selectedVariableDefinitionName,
    required this.onPick,
    this.asPickerButton = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (asPickerButton) {
      return PopupWidgetButton(
        tooltip: "Add a variable...",
        blurBackground: true,
        widget: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 200),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: _buildBody(context),
          ),
        ),
        child: IgnorePointer(
          child:
              child ??
              FilledButton(
                onPressed: variableDefinitions.isNotEmpty ? () {} : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 1,
                  ),
                  backgroundColor: DartBlockColors.variable,
                ),
                child: Text(
                  "(x)",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
        ),
      );
    } else {
      return _buildBody(context);
    }
  }

  Widget _buildBody(BuildContext context) {
    if (variableDefinitions.isEmpty) {
      return Center(
        child: Text(
          "No variables to pick from.",
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    return Wrap(
      spacing: 2,
      runSpacing: 2,
      children: variableDefinitions
          .map(
            (e) => InputChip(
              selected: e.name == selectedVariableDefinitionName,
              showCheckmark: false,
              label: VariableDefinitionWidget(
                variableDefinition: e,
                circularRightSide: true,
                useBodyMedium: true,
              ),
              onPressed: () {
                if (asPickerButton) {
                  Navigator.of(context).pop();
                }
                HapticFeedback.lightImpact();
                onPick(e);
              },
            ),
          )
          .toList(),
    );
  }
}
