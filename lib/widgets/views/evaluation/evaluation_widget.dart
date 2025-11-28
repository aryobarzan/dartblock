import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:dartblock_code/models/evaluator.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:dartblock_code/widgets/dartblock_value_widgets.dart';
import 'package:dartblock_code/widgets/views/function_definition.dart';
import 'package:dartblock_code/widgets/views/other/dartblock_colors.dart';
import 'package:dartblock_code/widgets/views/other/dartblock_exception.dart';
import 'package:dartblock_code/widgets/views/variable_definition.dart';

class _CustomExpansionTile extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Color titleBackgroundColor;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;
  final Color trailingIconColor;
  final List<Widget> children;

  const _CustomExpansionTile({
    required this.title,
    this.subtitle,
    required this.titleBackgroundColor,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.trailingIconColor,
    required this.children,
  });
  @override
  State createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<_CustomExpansionTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      tileColor: widget.titleBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(widget.title, style: widget.titleStyle),
        subtitle: widget.subtitle != null
            ? Text(widget.subtitle!, style: widget.subtitleStyle)
            : null,
        // trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
        shape: Border(),
        iconColor: widget.trailingIconColor,
        collapsedIconColor: widget.trailingIconColor,
        childrenPadding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        children: widget.children,
        onExpansionChanged: (bool expanding) =>
            setState(() => isExpanded = expanding),
      ),
    );
  }
}

class DartBlockEvaluationResultWidget extends StatelessWidget {
  final DartBlockEvaluationResult result;
  const DartBlockEvaluationResultWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final neoTechException = result.evaluations
        .firstWhereOrNull((evaluation) => evaluation.dartBlockException != null)
        ?.dartBlockException;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: _CustomExpansionTile(
        titleBackgroundColor: result.isCorrect()
            ? Colors.green
            : Theme.of(context).colorScheme.errorContainer,
        titleStyle:
            Theme.of(context).textTheme.titleLarge?.apply(
              color: result.isCorrect()
                  ? Colors.white
                  : Theme.of(context).colorScheme.onErrorContainer,
            ) ??
            TextStyle(),
        title: result.isCorrect() ? "Correct!" : "Wrong!",
        subtitle:
            "${result.evaluations.where((elem) => elem.isCorrect).length}/${result.evaluations.length} evaluation${result.evaluations.length == 1 ? '' : 's'} correct${neoTechException != null ? " & exception" : ""}.",
        subtitleStyle:
            Theme.of(context).textTheme.bodyMedium?.apply(
              color: result.isCorrect()
                  ? Colors.white
                  : Theme.of(context).colorScheme.onErrorContainer,
            ) ??
            TextStyle(),
        trailingIconColor: result.isCorrect()
            ? Colors.white
            : Theme.of(context).colorScheme.onErrorContainer,
        children: [
          if (neoTechException != null)
            DartBlockExceptionWidget(dartblockException: neoTechException),
          ..._buildEvaluationChildren(),
        ],
      ),
    );
  }

  List<Widget> _buildEvaluationChildren() {
    List<Widget> children = [];
    for (int i = 0; i < result.evaluations.length; i++) {
      children.add(
        DartBlockEvaluationWidget(
          evaluation: result.evaluations[i],
          index: i + 1,
        ),
      );
      if (i != result.evaluations.length - 1) {
        children.add(Divider());
      }
    }
    return children;
  }
}

class DartBlockEvaluationWidget extends StatelessWidget {
  final DartBlockEvaluation evaluation;
  final int? index;
  const DartBlockEvaluationWidget({
    super.key,
    required this.evaluation,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "${index != null ? "$index. " : ""}${evaluation.evaluationType}",
                style: Theme.of(context).textTheme.titleMedium?.apply(
                  color: evaluation.isCorrect ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
        switch (evaluation) {
          DartBlockFunctionDefinitionEvaluation() =>
            DartBlockFunctionDefinitionEvaluationWidget(
              evaluation: evaluation as DartBlockFunctionDefinitionEvaluation,
            ),
          DartBlockFunctionOutputEvaluation() =>
            DartBlockFunctionOutputEvaluationWidget(
              evaluation: evaluation as DartBlockFunctionOutputEvaluation,
            ),
          DartBlockScriptEvaluation() => DartBlockScriptEvaluationWidget(
            evaluation: evaluation as DartBlockScriptEvaluation,
          ),
          DartBlockVariableCountEvaluation() =>
            DartBlockVariableCountEvaluationWidget(
              evaluation: evaluation as DartBlockVariableCountEvaluation,
            ),
          DartBlockEnvironmentEvaluation() =>
            DartBlockEnvironmentEvaluationWidget(
              evaluation: evaluation as DartBlockEnvironmentEvaluation,
            ),
          DartBlockPrintEvaluation() => DartBlockPrintEvaluationWidget(
            evaluation: evaluation as DartBlockPrintEvaluation,
          ),
        },
      ],
    );
  }
}

class DartBlockVariableCountEvaluationWidget extends StatelessWidget {
  final DartBlockVariableCountEvaluation evaluation;
  const DartBlockVariableCountEvaluationWidget({
    super.key,
    required this.evaluation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(text: "Expected up to "),
              TextSpan(
                text: evaluation.solutionVariableDefinitions.length.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              TextSpan(
                text:
                    ' variable${evaluation.solutionVariableDefinitions.length == 1 ? '' : 's'}.',
              ),
            ],
          ),
        ),
        Row(
          children: [
            Icon(
              evaluation.isCorrect ? Icons.check_circle : Icons.cancel,
              color: evaluation.isCorrect ? Colors.green : Colors.red,
              size: 18,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    TextSpan(text: "Your program contains "),
                    TextSpan(
                      text: evaluation.answerVariableDefinitions.length
                          .toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: evaluation.isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                    TextSpan(
                      text:
                          ' variable${evaluation.answerVariableDefinitions.length == 1 ? '' : 's'}.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DartBlockScriptEvaluationWidget extends StatelessWidget {
  final DartBlockScriptEvaluation evaluation;
  const DartBlockScriptEvaluationWidget({super.key, required this.evaluation});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(text: "Expected a "),
              TextSpan(
                text:
                    "${evaluation.similarityThreshold != 1.0 ? "≥" : ""}${(evaluation.similarityThreshold * 100).toInt()}%",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              TextSpan(text: ' similarity to the sample solution.'),
            ],
          ),
        ),
        Row(
          children: [
            Icon(
              evaluation.isCorrect ? Icons.check_circle : Icons.cancel,
              color: evaluation.isCorrect ? Colors.green : Colors.red,
              size: 18,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    TextSpan(text: "Your program has a "),
                    TextSpan(
                      text: "${(evaluation.matchScore * 100).toInt()}%",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: evaluation.isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                    TextSpan(text: ' similarity.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DartBlockEnvironmentEvaluationWidget extends StatelessWidget {
  final DartBlockEnvironmentEvaluation evaluation;
  const DartBlockEnvironmentEvaluationWidget({
    super.key,
    required this.evaluation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...evaluation.missingVariableDefinitions.mapIndexed(
          (index, elem) => Padding(
            padding: EdgeInsets.only(
              bottom: index != evaluation.missingVariableDefinitions.length - 1
                  ? 4
                  : 0,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.orange,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  "Missing variable: ",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      children: [
                        VariableDefinitionWidget(variableDefinition: elem.$1),
                        Container(
                          width: 12,
                          height: 2,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        Container(
                          alignment: Alignment.center,
                          constraints: const BoxConstraints(minWidth: 24),
                          height: 24,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            elem.$2 ?? "null",
                            style: Theme.of(context).textTheme.bodySmall?.apply(
                              color: Theme.of(
                                context,
                              ).colorScheme.onTertiaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ...evaluation.wrongVariableDefinitionTypes.mapIndexed(
          (index, elem) => Padding(
            padding: EdgeInsets.only(
              top:
                  index == 0 && evaluation.missingVariableDefinitions.isNotEmpty
                  ? 4
                  : 0,
              bottom:
                  index != evaluation.wrongVariableDefinitionTypes.length - 1
                  ? 4
                  : 0,
            ),
            child: Row(
              children: [
                Icon(Icons.cancel, color: Colors.red, size: 18),
                const SizedBox(width: 4),
                Text(
                  "Wrong type: ",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: VariableDefinitionWidget(
                      variableDefinition: DartBlockVariableDefinition(
                        elem.$1.name,
                        elem.$3,
                      ),
                      circularRightSide: true,
                    ),
                  ),
                ),
                Text(
                  "→",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.apply(color: Colors.green),
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: VariableDefinitionWidget(
                        variableDefinition: elem.$1,
                        circularRightSide: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ...evaluation.wrongVariableDefinitionValues.mapIndexed(
          (index, elem) => Padding(
            padding: EdgeInsets.only(
              top:
                  index == 0 &&
                      (evaluation.wrongVariableDefinitionTypes.isNotEmpty ||
                          evaluation.missingVariableDefinitions.isNotEmpty)
                  ? 4
                  : 0,
              bottom:
                  index != evaluation.wrongVariableDefinitionValues.length - 1
                  ? 4
                  : 0,
            ),
            child: Row(
              children: [
                Icon(Icons.cancel, color: Colors.red, size: 18),
                const SizedBox(width: 4),
                Text(
                  "Wrong value: ",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      children: [
                        VariableDefinitionWidget(variableDefinition: elem.$1),
                        Container(
                          width: 12,
                          height: 2,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        Container(
                          alignment: Alignment.center,
                          constraints: const BoxConstraints(minWidth: 24),
                          height: 24,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          child: Text(
                            elem.$3 ?? "null",
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.apply(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  "→",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.apply(color: Colors.green),
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          constraints: const BoxConstraints(minWidth: 24),
                          height: 24,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            elem.$2 ?? "null",
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.apply(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ...evaluation.correctVariableDefinitions.mapIndexed(
          (index, elem) => Padding(
            padding: EdgeInsets.only(
              top:
                  index == 0 &&
                      (evaluation.wrongVariableDefinitionTypes.isNotEmpty ||
                          evaluation.missingVariableDefinitions.isNotEmpty ||
                          evaluation.wrongVariableDefinitionValues.isNotEmpty)
                  ? 4
                  : 0,
              bottom: index != evaluation.missingVariableDefinitions.length - 1
                  ? 4
                  : 0,
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 18),
                const SizedBox(width: 4),
                Text(
                  "Correct variable: ",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      children: [
                        VariableDefinitionWidget(variableDefinition: elem.$1),
                        Container(
                          width: 12,
                          height: 2,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        Container(
                          alignment: Alignment.center,
                          constraints: const BoxConstraints(minWidth: 24),
                          height: 24,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            elem.$2 ?? "null",
                            style: Theme.of(context).textTheme.bodySmall?.apply(
                              color: Theme.of(
                                context,
                              ).colorScheme.onTertiaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DartBlockPrintEvaluationWidget extends StatelessWidget {
  final DartBlockPrintEvaluation evaluation;
  const DartBlockPrintEvaluationWidget({super.key, required this.evaluation});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(text: "Expected "),
              TextSpan(
                text: evaluation.printEvaluations.length.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              TextSpan(text: " lines printed to the console."),
            ],
          ),
        ),
        ...evaluation.printEvaluations.mapIndexed(
          (index, lineEvaluation) => InkWell(
            onTap: () {
              _showLineEvaluationModalBottomSheet(context, index);
            },
            child: _buildLineEvaluationWidget(context, index),
          ),
        ),
      ],
    );
  }

  Widget _buildLineEvaluationWidget(BuildContext context, int index) {
    final lineEvaluation = evaluation.printEvaluations[index];
    switch (lineEvaluation.$3) {
      case DartBlockPrintEvaluationType.correct:
        return Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 18),
            const SizedBox(width: 4),
            Text(
              "${index + 1}. ",
              style: Theme.of(context).textTheme.bodyMedium?.apply(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            Expanded(
              child: Text(
                lineEvaluation.$1,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      case DartBlockPrintEvaluationType.wrong:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.cancel, color: Colors.red, size: 18),
                const SizedBox(width: 4),
                Text(
                  "${index + 1}. ",
                  style: Theme.of(context).textTheme.bodyMedium?.apply(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                Expanded(
                  child: Text(
                    lineEvaluation.$2 ?? 'Missing...',
                    style: Theme.of(context).textTheme.bodyMedium?.apply(
                      fontStyle: lineEvaluation.$2 == null
                          ? FontStyle.italic
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 18),
                Icon(
                  Icons.subdirectory_arrow_right,
                  size: 18,
                  color: Colors.green,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    lineEvaluation.$1,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        );
      case DartBlockPrintEvaluationType.missing:
        return Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.orange, size: 18),
            const SizedBox(width: 4),
            Text(
              "${index + 1}. ",
              style: Theme.of(context).textTheme.bodyMedium?.apply(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            Expanded(
              child: Text(
                lineEvaluation.$1,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
    }
  }

  void _showLineEvaluationModalBottomSheet(BuildContext context, int index) {
    final lineEvaluation = evaluation.printEvaluations[index];
    showModalBottomSheet(
      isScrollControlled: true,
      showDragHandle: true,
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 8,
            right: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                lineEvaluation.$3.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.apply(
                  color: switch (lineEvaluation.$3) {
                    DartBlockPrintEvaluationType.correct => Colors.green,
                    DartBlockPrintEvaluationType.wrong => Colors.red,
                    DartBlockPrintEvaluationType.missing => Colors.orange,
                  },
                ),
              ),
              Text(
                "Expected line #${index + 1}:",
                style: Theme.of(context).textTheme.titleMedium?.apply(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              Text(
                lineEvaluation.$1,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (lineEvaluation.$3 !=
                  DartBlockPrintEvaluationType.missing) ...[
                Divider(),
                Text(
                  "Actual line #${index + 1}:",
                  style: Theme.of(context).textTheme.titleMedium?.apply(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                Text(
                  lineEvaluation.$2 ?? "Missing...",
                  style: Theme.of(context).textTheme.bodyMedium?.apply(
                    fontStyle: lineEvaluation.$2 == null
                        ? FontStyle.italic
                        : null,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class DartBlockFunctionDefinitionEvaluationWidget extends StatelessWidget {
  final DartBlockFunctionDefinitionEvaluation evaluation;
  const DartBlockFunctionDefinitionEvaluationWidget({
    super.key,
    required this.evaluation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              if (evaluation.missingFunctionDefinitions.isNotEmpty) ...[
                TextSpan(
                  text: evaluation.missingFunctionDefinitions.length.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                TextSpan(
                  text:
                      " missing function${evaluation.missingFunctionDefinitions.length == 1 ? '' : 's'}",
                ),
              ],
              if (evaluation.wrongFunctionDefinitions.isNotEmpty) ...[
                if (evaluation.missingFunctionDefinitions.isNotEmpty)
                  TextSpan(text: ", "),
                TextSpan(
                  text: evaluation.wrongFunctionDefinitions.length.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                TextSpan(
                  text:
                      " wrong function${evaluation.wrongFunctionDefinitions.length == 1 ? '' : 's'}",
                ),
              ],
              if (evaluation.correctFunctionDefinitions.isNotEmpty) ...[
                if (evaluation.missingFunctionDefinitions.isNotEmpty ||
                    evaluation.wrongFunctionDefinitions.isNotEmpty)
                  TextSpan(text: ", "),
                TextSpan(
                  text: evaluation.correctFunctionDefinitions.length.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                TextSpan(
                  text:
                      " correct function${evaluation.correctFunctionDefinitions.length == 1 ? '' : 's'}",
                ),
              ],
              TextSpan(text: "."),
            ],
          ),
        ),
        const SizedBox(height: 4),
        ...evaluation.missingFunctionDefinitions.mapIndexed(
          (index, elem) => Padding(
            padding: EdgeInsets.only(
              bottom: index != evaluation.missingFunctionDefinitions.length - 1
                  ? 4
                  : 0,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.orange,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      children: [
                        FunctionDefinitionWidget(functionDefinition: elem),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ...evaluation.wrongFunctionDefinitions.mapIndexed(
          (index, elem) => Padding(
            padding: EdgeInsets.only(
              top: evaluation.missingFunctionDefinitions.isNotEmpty ? 4 : 0,
              bottom: index != evaluation.wrongFunctionDefinitions.length - 1
                  ? 4
                  : 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red, size: 18),
                    const SizedBox(width: 4),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          children: [
                            FunctionDefinitionWidget(
                              functionDefinition: elem.$2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const SizedBox(width: 18),
                    Icon(
                      Icons.subdirectory_arrow_right,
                      size: 18,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          children: [
                            FunctionDefinitionWidget(
                              functionDefinition: elem.$1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        ...evaluation.correctFunctionDefinitions.mapIndexed(
          (index, elem) => Padding(
            padding: EdgeInsets.only(
              top:
                  evaluation.missingFunctionDefinitions.isNotEmpty ||
                      evaluation.wrongFunctionDefinitions.isNotEmpty
                  ? 4
                  : 0,
              bottom: index != evaluation.correctFunctionDefinitions.length - 1
                  ? 4
                  : 0,
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 18),
                const SizedBox(width: 4),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      children: [
                        FunctionDefinitionWidget(functionDefinition: elem),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DartBlockFunctionOutputEvaluationWidget extends StatelessWidget {
  final DartBlockFunctionOutputEvaluation evaluation;
  const DartBlockFunctionOutputEvaluationWidget({
    super.key,
    required this.evaluation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              if (evaluation.wrongFunctionCalls.isNotEmpty) ...[
                TextSpan(
                  text: evaluation.wrongFunctionCalls.length.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                TextSpan(
                  text:
                      " wrong function output${evaluation.wrongFunctionCalls.length == 1 ? '' : 's'}",
                ),
              ],
              if (evaluation.correctFunctionCalls.isNotEmpty) ...[
                if (evaluation.wrongFunctionCalls.isNotEmpty)
                  TextSpan(text: ", "),
                TextSpan(
                  text: evaluation.correctFunctionCalls.length.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                TextSpan(
                  text:
                      " correct function output${evaluation.correctFunctionCalls.length == 1 ? '' : 's'}",
                ),
              ],
              TextSpan(text: "."),
            ],
          ),
        ),
        const SizedBox(height: 4),
        ...evaluation.wrongFunctionCalls.mapIndexed(
          (index, elem) => Padding(
            padding: EdgeInsets.only(
              bottom: index != evaluation.wrongFunctionCalls.length - 1 ? 4 : 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red, size: 18),
                    const SizedBox(width: 4),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: _FunctionCallWidget(
                          functionCallStatement: elem.$1,
                        ),
                      ),
                    ),
                  ],
                ),
                if (elem.$4 != null)
                  Row(
                    children: [
                      const SizedBox(width: 18),
                      Icon(
                        Icons.info,
                        size: 18,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          elem.$4!.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                else ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(width: 18),
                      Icon(
                        Icons.subdirectory_arrow_right,
                        size: 18,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          elem.$3 ?? "N/A",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(width: 18),
                      Icon(
                        Icons.subdirectory_arrow_right,
                        size: 18,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          elem.$2 ?? "N/A",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        ...evaluation.correctFunctionCalls.mapIndexed(
          (index, elem) => Padding(
            padding: EdgeInsets.only(
              top: evaluation.wrongFunctionCalls.isNotEmpty ? 4 : 0,
              bottom: index != evaluation.correctFunctionCalls.length - 1
                  ? 4
                  : 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 18),
                    const SizedBox(width: 4),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: _FunctionCallWidget(
                          functionCallStatement: elem.$1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const SizedBox(width: 18),
                    Icon(
                      Icons.subdirectory_arrow_right,
                      size: 18,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        elem.$2 ?? "N/A",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FunctionCallWidget extends StatelessWidget {
  final FunctionCallStatement functionCallStatement;
  const _FunctionCallWidget({required this.functionCallStatement});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ColoredTitleChip(
          title: functionCallStatement.functionName,
          textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          color: DartBlockColors.function,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
        ),
        if (functionCallStatement.arguments.isNotEmpty) ...[
          Container(
            width: 8,
            height: 2,
            color: Theme.of(context).colorScheme.outline,
          ),
          ...functionCallStatement.arguments.mapIndexed(
            (index, element) => Row(
              children: [
                DartBlockValueWidget(
                  value: element,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                if (index < functionCallStatement.arguments.length - 1)
                  Container(
                    width: 8,
                    height: 1,
                    color: Theme.of(context).colorScheme.outline,
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
