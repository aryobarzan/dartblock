import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:dartblock/core/dartblock_program.dart';
import 'package:dartblock/models/function.dart';
import 'package:dartblock/models/evaluator.dart';
import 'package:dartblock/widgets/editors/function_call.dart';
import 'package:dartblock/widgets/helper_widgets.dart';
import 'package:dartblock/widgets/views/function_call.dart';
import 'package:dartblock/widgets/views/function_definition.dart';

class DartBlockEvaluatorEditor extends StatefulWidget {
  final DartBlockEvaluator? evaluator;
  final DartBlockProgram sampleSolution;
  final Function(DartBlockEvaluator evaluator) onChange;
  const DartBlockEvaluatorEditor({
    super.key,
    this.evaluator,
    required this.sampleSolution,
    required this.onChange,
  });

  @override
  State<DartBlockEvaluatorEditor> createState() =>
      _DartBlockEvaluatorEditorState();
}

class _DartBlockEvaluatorEditorState extends State<DartBlockEvaluatorEditor> {
  List<DartBlockEvaluationSchema> schemas = [];
  @override
  void initState() {
    super.initState();
    if (widget.evaluator != null) {
      schemas = List.from(widget.evaluator!.schemas);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PopupMenuButton(
              borderRadius: BorderRadius.circular(24),
              tooltip: "Add an evaluation schema...",
              onSelected: (value) {
                setState(() {
                  switch (value) {
                    case DartBlockEvaluationSchemaType.functionDefinition:
                      schemas.add(
                        DartBlockFunctionDefinitionEvaluationSchema(true, []),
                      );
                      break;
                    case DartBlockEvaluationSchemaType.functionOutput:
                      schemas.add(
                        DartBlockFunctionOutputEvaluationSchema(true, []),
                      );
                      break;
                    case DartBlockEvaluationSchemaType.script:
                      schemas.add(DartBlockScriptEvaluationSchema(true, 1.0));
                      break;
                    case DartBlockEvaluationSchemaType.variableCount:
                      schemas.add(
                        DartBlockVariableCountEvaluationSchema(true, true),
                      );
                      break;
                    case DartBlockEvaluationSchemaType.environment:
                      schemas.add(
                        DartBlockEnvironmentEvaluationSchema(true, true),
                      );
                      break;
                    case DartBlockEvaluationSchemaType.print:
                      schemas.add(DartBlockPrintEvaluationSchema(true, 1.0));
                      break;
                  }
                });
                widget.onChange(DartBlockEvaluator(schemas));
              },
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              itemBuilder: (context) => DartBlockEvaluationSchemaType.values
                  .map(
                    (e) => PopupMenuItem(
                      enabled:
                          schemas.firstWhereOrNull(
                            (element) => element.schemaType == e,
                          ) ==
                          null,
                      value: e,
                      child: ListTile(
                        title: Text(
                          e.toString(),
                          maxLines: 1,
                          style: Theme.of(context).textTheme.titleMedium?.apply(
                            color: Theme.of(context).colorScheme.onSurface
                                .withValues(
                                  alpha:
                                      schemas.firstWhereOrNull(
                                            (element) =>
                                                element.schemaType == e,
                                          ) ==
                                          null
                                      ? 1.0
                                      : 0.5,
                                ),
                          ),
                        ),
                        leading: _buildInfoButton(e),
                      ),
                    ),
                  )
                  .toList(),
              child: IgnorePointer(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text("Schema"),
                ),
              ),
            ),
          ],
        ),
        ...schemas.mapIndexed(
          (index, element) => Dismissible(
            key: ValueKey("EvaluationSchema-${element.schemaType}-$index"),
            onDismissed: (direction) {
              setState(() {
                schemas.removeAt(index);
              });
              widget.onChange(DartBlockEvaluator(schemas));
            },
            confirmDismiss: (direction) async {
              return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Delete"),
                  content: const Text("Delete the evaluation schema?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: const Text("Delete"),
                    ),
                  ],
                ),
              );
            },
            child: Card(
              elevation: element.isEnabled ? 8 : 1,
              child: ListTile(
                leading: _buildInfoButton(element.schemaType),
                // trailing: Tooltip(
                //   message: "Enabled",
                //   child: Checkbox(
                //     value: element.isEnabled,
                //     onChanged: (value) {
                //       if (value != null) {
                //         setState(() {
                //           schemas[index].isEnabled = value;
                //         });
                //       }
                //     },
                //   ),
                // ),
                title: Text(element.schemaType.toString()),
                subtitle: NeoTechEvaluationSchemaEditor(
                  evaluationSchema: element,
                  neoTechCore: widget.sampleSolution,
                  onChange: (newSchema) {
                    setState(() {
                      schemas[index] = newSchema;
                    });
                    widget.onChange(DartBlockEvaluator(schemas));
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoButton(DartBlockEvaluationSchemaType schemaType) {
    return IconButton(
      tooltip: schemaType.describe(extended: true),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(schemaType.toString()),
            content: Text(schemaType.describe(extended: true)),
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
      icon: const Icon(Icons.info_outline),
    );
  }
}

class NeoTechEvaluationSchemaEditor extends StatelessWidget {
  final DartBlockEvaluationSchema evaluationSchema;
  final DartBlockProgram neoTechCore;
  final Function(DartBlockEvaluationSchema) onChange;
  const NeoTechEvaluationSchemaEditor({
    super.key,
    required this.evaluationSchema,
    required this.neoTechCore,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    switch (evaluationSchema) {
      case DartBlockFunctionDefinitionEvaluationSchema():
        return NeoTechFunctionDefinitionEvaluationSchemaEditor(
          neoTechCore: neoTechCore,
          evaluationSchema:
              evaluationSchema as DartBlockFunctionDefinitionEvaluationSchema,
          onChange: onChange,
        );
      case DartBlockFunctionOutputEvaluationSchema():
        return NeoTechFunctionOutputEvaluationSchemaEditor(
          neoTechCore: neoTechCore,
          evaluationSchema:
              evaluationSchema as DartBlockFunctionOutputEvaluationSchema,
          onChange: onChange,
        );
      case DartBlockScriptEvaluationSchema():
        return NeoTechScriptEvaluationSchemaEditor(
          neoTechCore: neoTechCore,
          evaluationSchema: evaluationSchema as DartBlockScriptEvaluationSchema,
          onChange: onChange,
        );
      case DartBlockVariableCountEvaluationSchema():
        return NeoTechVariableCountEvaluationSchemaEditor(
          neoTechCore: neoTechCore,
          evaluationSchema:
              evaluationSchema as DartBlockVariableCountEvaluationSchema,
          onChange: onChange,
        );
      case DartBlockEnvironmentEvaluationSchema():
        return NeoTechEnvironmentEvaluationSchemaEditor(
          neoTechCore: neoTechCore,
          evaluationSchema:
              evaluationSchema as DartBlockEnvironmentEvaluationSchema,
          onChange: onChange,
        );
      case DartBlockPrintEvaluationSchema():
        return NeoTechPrintEvaluationSchemaEditor(
          neoTechCore: neoTechCore,
          evaluationSchema: evaluationSchema as DartBlockPrintEvaluationSchema,
          onChange: onChange,
        );
    }
  }
}

class NeoTechFunctionDefinitionEvaluationSchemaEditor extends StatelessWidget {
  final DartBlockFunctionDefinitionEvaluationSchema evaluationSchema;
  final DartBlockProgram neoTechCore;
  final Function(DartBlockFunctionDefinitionEvaluationSchema) onChange;
  const NeoTechFunctionDefinitionEvaluationSchemaEditor({
    super.key,
    required this.evaluationSchema,
    required this.neoTechCore,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final List<FunctionDefinition> availableFunctionDefinitions = neoTechCore
        .customFunctions
        .map((e) => e.getAsFunctionDefinition())
        .whereNot(
          (element) => evaluationSchema.functionDefinitions.contains(element),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (evaluationSchema.functionDefinitions.isEmpty)
          const Text("Add at least one sample function definition."),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: evaluationSchema.functionDefinitions
              .mapIndexed(
                (index, element) => Card(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: "Delete",
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          evaluationSchema.functionDefinitions.removeAt(index);
                          onChange(evaluationSchema);
                        },
                      ),
                      FunctionDefinitionWidget(functionDefinition: element),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PopupWidgetButton(
              isFullWidth: true,
              tooltip: "Add a sample function definition",
              widget: Padding(
                padding: const EdgeInsets.all(4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableFunctionDefinitions
                      .map(
                        (e) => ActionChip(
                          label: FunctionDefinitionWidget(
                            functionDefinition: e,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            evaluationSchema.functionDefinitions.add(e);
                            onChange(evaluationSchema);
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
              child: IgnorePointer(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text("Function Definition"),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class NeoTechFunctionOutputEvaluationSchemaEditor extends StatelessWidget {
  final DartBlockFunctionOutputEvaluationSchema evaluationSchema;
  final DartBlockProgram neoTechCore;
  final Function(DartBlockFunctionOutputEvaluationSchema) onChange;
  const NeoTechFunctionOutputEvaluationSchemaEditor({
    super.key,
    required this.evaluationSchema,
    required this.neoTechCore,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (evaluationSchema.sampleFunctionCalls.isEmpty)
          const Text("Add at least one sample function call."),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: evaluationSchema.sampleFunctionCalls
              .mapIndexed(
                (index, element) => Card(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: "Delete",
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          evaluationSchema.sampleFunctionCalls.removeAt(index);
                          onChange(evaluationSchema);
                        },
                      ),
                      PopupWidgetButton(
                        isFullWidth: true,
                        tooltip: "Edit sample function call",
                        widget: Padding(
                          padding: const EdgeInsets.all(4),
                          child: FunctionCallComposer(
                            statement: element,
                            customFunctions: neoTechCore.customFunctions,
                            existingVariableDefinitions: const [],
                            onSaved: (customFunction, savedFunctionCall) {
                              Navigator.of(context).pop();
                              evaluationSchema.sampleFunctionCalls[index] =
                                  savedFunctionCall;
                              onChange(evaluationSchema);
                            },
                            restrictToDataTypes: const [],
                          ),
                        ),
                        child: FunctionCallStatementWidget(
                          statement: element,
                          customFunction: neoTechCore.customFunctions
                              .firstWhereOrNull(
                                (customFunction) =>
                                    customFunction.name ==
                                    element.customFunctionName,
                              ),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PopupWidgetButton(
              isFullWidth: true,
              tooltip: "Add a sample function call",
              widget: Padding(
                padding: const EdgeInsets.all(4),
                child: FunctionCallComposer(
                  customFunctions: neoTechCore.customFunctions,
                  existingVariableDefinitions: const [],
                  onSaved: (customFunction, savedFunctionCall) {
                    Navigator.of(context).pop();
                    evaluationSchema.sampleFunctionCalls.add(savedFunctionCall);
                    onChange(evaluationSchema);
                  },
                  restrictToDataTypes: const [],
                ),
              ),
              child: IgnorePointer(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text("Function Call"),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class NeoTechScriptEvaluationSchemaEditor extends StatelessWidget {
  final DartBlockScriptEvaluationSchema evaluationSchema;
  final DartBlockProgram neoTechCore;
  final Function(DartBlockScriptEvaluationSchema) onChange;
  const NeoTechScriptEvaluationSchemaEditor({
    super.key,
    required this.evaluationSchema,
    required this.neoTechCore,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Threshold: ${(evaluationSchema.similarityThreshold * 100).round()}%",
          textAlign: TextAlign.start,
        ),
        Slider(
          divisions: 4,
          min: 0.8,
          max: 1.0,
          value: evaluationSchema.similarityThreshold,
          onChanged: (value) {
            onChange(
              DartBlockScriptEvaluationSchema(
                evaluationSchema.isEnabled,
                value,
              ),
            );
          },
        ),
      ],
    );
  }
}

class NeoTechVariableCountEvaluationSchemaEditor extends StatelessWidget {
  final DartBlockVariableCountEvaluationSchema evaluationSchema;
  final DartBlockProgram neoTechCore;
  final Function(DartBlockVariableCountEvaluationSchema) onChange;
  const NeoTechVariableCountEvaluationSchemaEditor({
    super.key,
    required this.evaluationSchema,
    required this.neoTechCore,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Maximum: ${getMaximumVariableCount()} variable(s)'),
        Row(
          children: [
            Checkbox(
              value: evaluationSchema.ignoreVariablesStartingWithUnderscore,
              onChanged: (value) {
                if (value != null) {
                  onChange(
                    DartBlockVariableCountEvaluationSchema(
                      evaluationSchema.isEnabled,
                      value,
                    ),
                  );
                }
              },
            ),
            const Flexible(child: Text("Ignore variables starting with '_'")),
          ],
        ),
      ],
    );
  }

  int getMaximumVariableCount() {
    var variableDefinitions = neoTechCore
        .buildTree()
        .findAllVariableDefinitions();
    if (evaluationSchema.ignoreVariablesStartingWithUnderscore) {
      return variableDefinitions
          .where((element) => !element.name.startsWith('_'))
          .length;
    } else {
      return variableDefinitions.length;
    }
  }
}

class NeoTechEnvironmentEvaluationSchemaEditor extends StatelessWidget {
  final DartBlockEnvironmentEvaluationSchema evaluationSchema;
  final DartBlockProgram neoTechCore;
  final Function(DartBlockEnvironmentEvaluationSchema) onChange;
  const NeoTechEnvironmentEvaluationSchemaEditor({
    super.key,
    required this.evaluationSchema,
    required this.neoTechCore,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Checkbox(
              value: evaluationSchema.ignoreVariablesStartingWithUnderscore,
              onChanged: (value) {
                if (value != null) {
                  onChange(
                    DartBlockEnvironmentEvaluationSchema(
                      evaluationSchema.isEnabled,
                      value,
                    ),
                  );
                }
              },
            ),
            const Flexible(child: Text("Ignore variables starting with '_'")),
          ],
        ),
      ],
    );
  }
}

class NeoTechPrintEvaluationSchemaEditor extends StatelessWidget {
  final DartBlockPrintEvaluationSchema evaluationSchema;
  final DartBlockProgram neoTechCore;
  final Function(DartBlockPrintEvaluationSchema) onChange;
  const NeoTechPrintEvaluationSchemaEditor({
    super.key,
    required this.evaluationSchema,
    required this.neoTechCore,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Threshold: ${(evaluationSchema.similarityThreshold * 100).round()}%",
          textAlign: TextAlign.start,
        ),
        Slider(
          divisions: 4,
          min: 0.8,
          max: 1.0,
          value: evaluationSchema.similarityThreshold,
          onChanged: (value) {
            onChange(
              DartBlockPrintEvaluationSchema(evaluationSchema.isEnabled, value),
            );
          },
        ),
      ],
    );
  }
}
