import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartblock/core/dartblock_program.dart';
import 'package:dartblock/models/dartblock_interaction.dart';
import 'package:dartblock/models/dartblock_value.dart';
import 'package:dartblock/models/dartblock_validator.dart';
import 'package:dartblock/widgets/views/symbols.dart';

class CustomFunctionBasicEditor extends StatefulWidget {
  final String? customFunctionName;
  final DartBlockDataType? returnType;
  final List<String> existingCustomFunctionNames;
  final bool canDelete;
  final bool canChange;
  final Function() onDelete;
  final Function(String, DartBlockDataType?) onSaved;
  const CustomFunctionBasicEditor({
    super.key,
    this.customFunctionName,
    this.returnType,
    required this.existingCustomFunctionNames,
    required this.canDelete,
    required this.canChange,
    required this.onDelete,
    required this.onSaved,
  });

  @override
  State<CustomFunctionBasicEditor> createState() =>
      _CustomFunctionBasicEditorState();
}

class _CustomFunctionBasicEditorState extends State<CustomFunctionBasicEditor> {
  DartBlockDataType? returnType;
  TextEditingController nameTEC = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    returnType = widget.returnType;
    nameTEC.text = widget.customFunctionName ?? "";
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
              const NewFunctionSymbol(),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.customFunctionName == null
                      ? "New Function"
                      : "Edit Function",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.customFunctionName != null && widget.canDelete)
                    IconButton(
                      tooltip: "Delete function",
                      onPressed: widget.canDelete
                          ? () {
                              DartBlockInteraction.create(
                                dartBlockInteractionType:
                                    DartBlockInteractionType.deletedFunction,
                              ).dispatch(context);
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
                              DartBlockInteraction.create(
                                dartBlockInteractionType:
                                    widget.customFunctionName != null
                                    ? DartBlockInteractionType.editedFunction
                                    : DartBlockInteractionType.createdFunction,
                                content: "FunctionName-${nameTEC.text}",
                              ).dispatch(context);
                              HapticFeedback.mediumImpact();
                              widget.onSaved(nameTEC.text, returnType);
                            }
                          }
                        : null,
                    label: Text(
                      widget.customFunctionName == null ? "Create" : "Save",
                    ),
                    icon: Icon(
                      widget.customFunctionName == null
                          ? Icons.add
                          : Icons.check,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            autofocus: widget.customFunctionName == null,
            autocorrect: false,
            // Use "LengthLimitingTextInputFormatter" through "inputFormatters" parameter instead,
            // in order to not show the counter under the textfield.
            // maxLength: NeoTechConstantSettings.functionNameLength,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            enabled: widget.canChange,
            inputFormatters: [
              LengthLimitingTextInputFormatter(
                NeoTechConstantSettings.functionNameLength,
              ),
              FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z\$_]")),
            ],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Name',
            ),
            controller: nameTEC,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Name must not be empty.';
              }
              if (widget.existingCustomFunctionNames.any(
                (element) => element == value,
              )) {
                return 'A function with that name already exists.';
              }

              final nameValidation = DartBlockValidator.validateFunctionName(
                value,
              );

              return nameValidation;
            },
          ),
          const SizedBox(height: 4),
          Text("Return Type", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children:
                <Widget>[
                  ChoiceChip(
                    showCheckmark: false,
                    labelPadding: const EdgeInsets.only(left: 8),
                    avatar: const Icon(Icons.adjust),
                    label: const Text('void'),
                    selected: returnType == null,
                    onSelected: widget.canChange
                        ? (selected) {
                            setState(() {
                              returnType = null;
                            });
                          }
                        : null,
                  ),
                ] +
                DartBlockDataType.values
                    .map(
                      (dataType) => ChoiceChip(
                        showCheckmark: false,
                        labelPadding: const EdgeInsets.only(left: 8),
                        avatar: NeoTechDataTypeIcon(dataType: dataType),
                        label: Text(dataType.toScript()),
                        selected: dataType == returnType,
                        onSelected: widget.canChange
                            ? (selected) {
                                setState(() {
                                  returnType = dataType;
                                });
                              }
                            : null,
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
