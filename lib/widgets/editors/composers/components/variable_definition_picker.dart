import 'package:collection/collection.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/widgets/dartblock_editor_providers.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VariableDefinitionPicker extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    if (asPickerButton) {
      return PopupWidgetButton(
        tooltip: "Add a variable...",
        blurBackground: true,
        widget: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 200),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: _buildBody(context, ref),
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
                  backgroundColor: settings.colorFamily.variable.color,
                ),
                child: Text(
                  "(x)",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: settings.colorFamily.variable.onColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
        ),
      );
    } else {
      return _buildBody(context, ref);
    }
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    if (variableDefinitions.isEmpty) {
      return Center(
        child: Text(
          "No variables to pick from.",
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.apply(fontStyle: FontStyle.italic),
        ),
      );
    }

    final variablesByType =
        groupBy<DartBlockVariableDefinition, DartBlockDataType>(
          variableDefinitions,
          (e) => e.dataType,
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        ...variablesByType.entries.map(
          (elem) => Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                Text(
                  elem.key.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: settings.colorFamily
                        .getDartBlockDataTypeColorFamily(elem.key)
                        .color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: elem.value
                      .map(
                        (variable) => InputChip(
                          selected:
                              variable.name == selectedVariableDefinitionName,
                          showCheckmark: false,
                          label: Text(variable.name),
                          onPressed: () {
                            if (asPickerButton) {
                              Navigator.of(context).pop();
                            }
                            HapticFeedback.lightImpact();
                            onPick(variable);
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
