import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dartblock_code/widgets/helpers/provider_aware_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartblock_code/models/function.dart';
import 'package:dartblock_code/models/function_builtin.dart';
import 'package:dartblock_code/models/dartblock_notification.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/editors/composers/boolean_value.dart';
import 'package:dartblock_code/widgets/editors/composers/number_value.dart';
import 'package:dartblock_code/widgets/editors/composers/value_concatenation.dart';
import 'package:dartblock_code/widgets/views/symbols.dart';
import 'package:dartblock_code/widgets/views/variable_definition.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FunctionCallComposer extends ConsumerStatefulWidget {
  final List<DartBlockVariableDefinition> existingVariableDefinitions;
  final List<DartBlockCustomFunction> customFunctions;
  final List<DartBlockFunction> availableFunctions;
  final FunctionCallStatement? statement;
  final Function(
    DartBlockFunction function,
    FunctionCallStatement functionCallStatement,
  )?
  onSaved;
  final Function(
    DartBlockFunction function,
    FunctionCallStatement newFunctionCallStatement,
  )?
  onChange;
  final List<DartBlockDataType> restrictToDataTypes;
  final bool showArgumentEditorAsModalBottomSheet;
  final bool autoSelectDefaultFunction;
  FunctionCallComposer({
    super.key,
    required List<DartBlockCustomFunction> customFunctions,
    required this.existingVariableDefinitions,
    this.statement,
    this.onSaved,
    this.onChange,
    required this.restrictToDataTypes,
    this.showArgumentEditorAsModalBottomSheet = false,
    this.autoSelectDefaultFunction = true,
  }) : customFunctions = customFunctions,
       availableFunctions = restrictToDataTypes.isNotEmpty
           ? [
               ...customFunctions.where(
                 (element) => restrictToDataTypes.contains(element.returnType),
               ),
               ...DartBlockBuiltinFunctions.all.where(
                 (element) => restrictToDataTypes.contains(element.returnType),
               ),
             ]
           : [...customFunctions, ...DartBlockBuiltinFunctions.all];

  @override
  ConsumerState<FunctionCallComposer> createState() =>
      _FunctionCallComposerState();
}

class _FunctionCallComposerState extends ConsumerState<FunctionCallComposer> {
  DartBlockFunction? selectedFunction;
  List<DartBlockValue?> indicatedArguments = [];
  int? selectedParameterIndex;

  @override
  void initState() {
    super.initState();
    if (widget.statement != null) {
      selectedFunction = widget.availableFunctions.firstWhereOrNull(
        (element) => element.name == widget.statement!.functionName,
      );
      _updateIndicatedParameters(widget.statement!.arguments);
    } else {
      if (widget.autoSelectDefaultFunction) {
        selectedFunction = widget.availableFunctions.firstOrNull;
      } else {
        selectedFunction = null;
      }
      _updateIndicatedParameters([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedParameter = _getSelectedParameter();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: DropdownButton(
                  isExpanded: true,
                  value: selectedFunction,
                  hint: const Text("Select a function..."),
                  underline: const SizedBox(),
                  items: widget.availableFunctions
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(e.name),
                                  if (e is DartBlockBuiltinFunction) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(width: 4),
                              e.returnType != null
                                  ? NeoTechDataTypeSymbol(
                                      dataType: e.returnType!,
                                    )
                                  : const VoidSymbol(),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != selectedFunction) {
                      setState(() {
                        selectedFunction = value;
                        _updateIndicatedParameters(
                          indicatedArguments.isNotEmpty
                              ? indicatedArguments
                              : widget.statement != null
                              ? widget.statement!.arguments
                              : [],
                        );
                        selectedParameterIndex = null;
                      });
                      _onChange();
                    }
                  },
                ),
              ),
            ),
            if (widget.onSaved != null)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: FilledButton.icon(
                  onPressed: widget.onSaved != null && _validate()
                      ? () {
                          final isValid = _validate();
                          if (isValid) {
                            HapticFeedback.mediumImpact();
                            widget.onSaved!(
                              selectedFunction!,
                              FunctionCallStatement.init(
                                selectedFunction!.name,
                                indicatedArguments.map((e) => e!).toList(),
                              ),
                            );
                          }
                        }
                      : null,
                  label: Text(widget.statement != null ? "Save" : "Add"),
                  icon: Icon(
                    widget.statement != null ? Icons.check : Icons.add,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        if (widget.availableFunctions.isEmpty)
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: "No functions available to call.",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: "\nCreate a custom function by tapping "),
                const WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: NewFunctionSymbol(size: 24),
                ),
                const TextSpan(text: "  in the toolbox."),
              ],
            ),
          ),
        if (selectedFunction != null && selectedFunction!.parameters.isNotEmpty)
          Text(
            "${min(indicatedArguments.where((element) => element != null).length, selectedFunction!.parameters.length)}/${selectedFunction!.parameters.length} arguments provided.",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        if (selectedFunction != null)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 4,
              children: selectedFunction!.parameters
                  .mapIndexed(
                    (parameterIndex, parameter) => Card(
                      color: parameter == selectedParameter
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      elevation: 8,
                      child: InkWell(
                        onTap: () {
                          if (parameterIndex != selectedParameterIndex) {
                            setState(() {
                              selectedParameterIndex = parameterIndex;
                            });
                            if (widget.showArgumentEditorAsModalBottomSheet) {
                              _showArgumentEditorModalBottomSheet();
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            color: selectedParameter == parameter
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              VariableDefinitionWidget(
                                variableDefinition: parameter,
                                circularRightSide: true,
                              ),
                              const SizedBox(width: 2),
                              Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                child: Icon(
                                  indicatedArguments[parameterIndex] != null
                                      ? Icons.check
                                      : Icons.close,
                                  color:
                                      indicatedArguments[parameterIndex] != null
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        if (selectedParameter != null &&
            !widget.showArgumentEditorAsModalBottomSheet)
          _buildParameterEditor(),
      ],
    );
  }

  bool _validate() {
    return selectedFunction != null &&
        indicatedArguments.nonNulls.length ==
            selectedFunction!.parameters.length;
  }

  void _onChange() {
    if (widget.onChange != null) {
      final isValid = _validate();
      if (isValid) {
        widget.onChange!(
          selectedFunction!,
          FunctionCallStatement.init(
            selectedFunction!.name,
            indicatedArguments.map((e) => e!).toList(),
          ),
        );
      }
    }
  }

  void _updateIndicatedParameters(List<DartBlockValue?> values) {
    indicatedArguments.clear();
    if (selectedFunction != null) {
      for (var (parameterIndex, parameter)
          in selectedFunction!.parameters.indexed) {
        if (parameterIndex < values.length) {
          final indicatedValue = values[parameterIndex];
          switch (parameter.dataType) {
            case DartBlockDataType.integerType:
            case DartBlockDataType.doubleType:
              if (indicatedValue is DartBlockAlgebraicExpression) {
                indicatedArguments.add(indicatedValue);
                break;
              } else {
                indicatedArguments[parameterIndex] = null;
              }
            case DartBlockDataType.booleanType:
              if (indicatedValue is DartBlockBooleanExpression) {
                indicatedArguments.add(indicatedValue);
                break;
              } else {
                indicatedArguments[parameterIndex] = null;
              }
            case DartBlockDataType.stringType:
              if (indicatedValue is DartBlockConcatenationValue) {
                indicatedArguments.add(indicatedValue);
                break;
              } else {
                indicatedArguments[parameterIndex] = null;
              }
          }
        } else {
          if (parameterIndex < indicatedArguments.length) {
            indicatedArguments[parameterIndex] = null;
          } else {
            indicatedArguments.add(null);
          }
        }
      }
    }
  }

  DartBlockVariableDefinition? _getSelectedParameter() {
    return selectedFunction != null &&
            selectedParameterIndex != null &&
            selectedParameterIndex! < selectedFunction!.parameters.length
        ? selectedFunction?.parameters[selectedParameterIndex!]
        : null;
  }

  Widget _buildParameterEditor() {
    final selectedParameter = _getSelectedParameter();
    if (selectedParameter != null) {
      final currentValue = selectedParameterIndex! < indicatedArguments.length
          ? indicatedArguments[selectedParameterIndex!]
          : null;
      switch (selectedParameter.dataType) {
        case DartBlockDataType.integerType:
        case DartBlockDataType.doubleType:
          return NumberValueComposer(
            key: ValueKey("Parameter-${selectedParameterIndex!}-Number"),
            value: currentValue is DartBlockAlgebraicExpression
                ? currentValue.compositionNode
                : null,
            variableDefinitions: widget.existingVariableDefinitions,
            customFunctions: widget.customFunctions,
            onChange: (newValue) {
              setState(() {
                indicatedArguments[selectedParameterIndex!] = newValue != null
                    ? DartBlockAlgebraicExpression.init(newValue)
                    : null;
              });
              _onChange();
            },
          );
        case DartBlockDataType.booleanType:
          return BooleanValueComposer(
            key: ValueKey("Parameter-${selectedParameterIndex!}-Boolean"),
            value: currentValue is DartBlockBooleanExpression
                ? currentValue.compositionNode
                : null,
            variableDefinitions: widget.existingVariableDefinitions,
            customFunctions: widget.customFunctions,
            onChange: (newValue) {
              setState(() {
                indicatedArguments[selectedParameterIndex!] = newValue != null
                    ? DartBlockBooleanExpression.init(newValue)
                    : null;
              });
              _onChange();
            },
          );
        case DartBlockDataType.stringType:
          return ConcatenationValueComposer(
            key: ValueKey("Parameter-${selectedParameterIndex!}-String"),
            value: currentValue is DartBlockConcatenationValue
                ? currentValue
                : null,
            variableDefinitions: widget.existingVariableDefinitions,
            customFunctions: widget.customFunctions,
            onInteract: () {},
            onChange: (newValue) {
              setState(() {
                indicatedArguments[selectedParameterIndex!] = newValue;
              });
              _onChange();
            },
          );
      }
    } else {
      return const SizedBox();
    }
  }

  void _showArgumentEditorModalBottomSheet() {
    final selectedParameter = _getSelectedParameter();
    if (selectedParameter != null && selectedFunction != null) {
      context
          .showProviderAwareBottomSheet(
            isScrollControlled: true,
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
                      bottom:
                          16 + MediaQuery.of(sheetContext).viewInsets.bottom,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                child: FunctionNameSymbol(
                                  name: selectedFunction!.name,
                                ),
                                alignment: PlaceholderAlignment.middle,
                              ),
                              const WidgetSpan(
                                child: Icon(Icons.keyboard_arrow_right),
                                alignment: PlaceholderAlignment.middle,
                              ),
                              WidgetSpan(
                                child: VariableDefinitionWidget(
                                  variableDefinition: selectedParameter,
                                  circularRightSide: true,
                                ),
                                alignment: PlaceholderAlignment.middle,
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        Flexible(child: _buildParameterEditor()),
                      ],
                    ),
                  ),
                ),
              );
              // return DraggableScrollableSheet(
              //   initialChildSize: 0.75,
              //   minChildSize: 0.13,
              //   maxChildSize: 0.9,
              //   expand: false,
              //   builder: (context, scrollController) => SingleChildScrollView(
              //     controller: scrollController,
              //     child: Padding(
              //       padding: const EdgeInsets.all(8),
              //       child: this,
              //     ),
              //   ),
              // );
            },
          )
          .then((result) {
            setState(() {
              selectedParameterIndex = null;
            });
          });
    }
  }
}
