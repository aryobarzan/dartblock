import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartblock/core/dartblock_program.dart';
import 'package:dartblock/models/function.dart';
import 'package:dartblock/models/dartblock_value.dart';
import 'package:dartblock/models/dartblock_validator.dart';
import 'package:dartblock/widgets/views/symbols.dart';

class VariableDefinitionEditor extends StatefulWidget {
  /// If the VariableDefinitionEditor is being used in the context of a custom function's
  /// parameters, include the function's definition such that its name is highlighted for clarity.
  final FunctionDefinition? functionDefinition;
  final DartBlockVariableDefinition? variableDefinition;
  final List<DartBlockVariableDefinition> existingVariableDefinitions;
  final Function() onDelete;
  final Function(DartBlockVariableDefinition) onSaved;
  final bool canChange;
  final bool canDelete;
  const VariableDefinitionEditor({
    super.key,
    this.functionDefinition,
    this.variableDefinition,
    required this.existingVariableDefinitions,
    required this.onDelete,
    required this.onSaved,
    required this.canChange,
    required this.canDelete,
  });

  @override
  State<VariableDefinitionEditor> createState() =>
      _VariableDefinitionEditorState();
}

class _VariableDefinitionEditorState extends State<VariableDefinitionEditor> {
  DartBlockDataType dataType = DartBlockDataType.integerType;
  TextEditingController nameTEC = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.variableDefinition != null) {
      dataType = widget.variableDefinition!.dataType;
      nameTEC.text = widget.variableDefinition!.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const NeoTechFunctionSymbol(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.variableDefinition == null
                      ? "New Parameter"
                      : "Edit Parameter",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.variableDefinition != null && widget.canDelete)
                    IconButton(
                      tooltip: "Delete Parameter",
                      onPressed: widget.canDelete
                          ? () {
                              widget.onDelete();
                            }
                          : null,
                      color: Theme.of(context).colorScheme.error,
                      icon: const Icon(Icons.delete),
                    ),
                  FilledButton.icon(
                    onPressed: widget.canChange
                        ? () {
                            final isValid =
                                formKey.currentState?.validate() ?? false;
                            if (isValid) {
                              widget.onSaved(
                                DartBlockVariableDefinition(
                                  nameTEC.text,
                                  dataType,
                                ),
                              );
                            }
                          }
                        : null,
                    label: Text(
                      widget.variableDefinition == null ? "Add" : "Save",
                    ),
                    icon: Icon(
                      widget.variableDefinition == null
                          ? Icons.add
                          : Icons.check,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.functionDefinition != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FunctionNameSymbol(name: widget.functionDefinition!.name),
            ),
          TextFormField(
            autofocus: widget.variableDefinition == null,
            // Use "LengthLimitingTextInputFormatter" through "inputFormatters" parameter instead,
            // in order to not show the counter under the textfield.
            // maxLength: NeoTechConstantSettings.variableNameLength,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            enabled: widget.canChange,
            inputFormatters: [
              LengthLimitingTextInputFormatter(
                NeoTechConstantSettings.variableNameLength,
              ),
              FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z\$_]")),
            ],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Parameter name',
            ),
            controller: nameTEC,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Name must not be empty.';
              }
              if (widget.existingVariableDefinitions.any(
                (element) => element.name == value,
              )) {
                return 'A variable with that name already exists.';
              }

              final nameValidation = DartBlockValidator.validateVariableName(
                value,
              );

              return nameValidation;
            },
          ),
          const SizedBox(height: 4),
          Text("Type", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: DartBlockDataType.values
                .map(
                  (element) => ChoiceChip(
                    showCheckmark: false,
                    labelPadding: const EdgeInsets.only(left: 8),
                    avatar: NeoTechDataTypeIcon(dataType: element),
                    label: Text(element.toScript()),
                    selected: element == dataType,
                    onSelected: widget.canChange
                        ? (selected) {
                            if (element != dataType) {
                              setState(() {
                                dataType = element;
                              });
                            }
                          }
                        : null,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
