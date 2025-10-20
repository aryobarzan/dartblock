import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartblock_code/models/function.dart';
import 'package:dartblock_code/models/dartblock_interaction.dart';
import 'package:dartblock_code/models/dartblock_notification.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/editors/composers/boolean_value.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:dartblock_code/widgets/dartblock_value_widgets.dart';
import 'package:dartblock_code/widgets/views/other/dartblock_colors.dart';

class WhileLoopStatementEditor extends StatefulWidget {
  final WhileLoopStatement? statement;
  final Function(WhileLoopStatement) onSaved;

  final List<DartBlockVariableDefinition> existingVariableDefinitions;
  final List<DartBlockFunction> customFunctions;
  const WhileLoopStatementEditor({
    super.key,
    this.statement,
    required this.onSaved,
    required this.existingVariableDefinitions,
    required this.customFunctions,
  });

  @override
  State<WhileLoopStatementEditor> createState() =>
      _WhileLoopStatementEditorState();
}

class _WhileLoopStatementEditorState extends State<WhileLoopStatementEditor> {
  bool isDoWhile = false;
  DartBlockBooleanExpression? condition;
  @override
  void initState() {
    super.initState();
    if (widget.statement != null) {
      isDoWhile = widget.statement!.isDoWhile;
      condition = widget.statement!.condition;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "While-Loop",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            FilledButton.icon(
              onPressed: condition != null
                  ? () {
                      if (condition != null) {
                        HapticFeedback.mediumImpact();
                        widget.onSaved(
                          WhileLoopStatement.init(
                            isDoWhile,
                            condition!,
                            widget.statement?.bodyStatements ?? [],
                          ),
                        );
                      }
                    }
                  : null,
              label: Text(widget.statement != null ? "Save" : "Add"),
              icon: Icon(widget.statement != null ? Icons.check : Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            SegmentedButton(
              showSelectedIcon: false,
              onSelectionChanged: (value) {
                if (value.first != isDoWhile) {
                  DartBlockInteraction.create(
                    dartBlockInteractionType:
                        DartBlockInteractionType.changeWhileLoopType,
                  ).dispatch(context);
                  setState(() {
                    isDoWhile = value.first;
                  });
                }
              },
              segments: const [
                ButtonSegment(value: false, label: Text("While")),
                ButtonSegment(value: true, label: Text("Do-While")),
              ],
              selected: {isDoWhile},
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (isDoWhile)
          ..._buildBodyExplainerTexts() + [const SizedBox(height: 16)],
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Condition",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextSpan(
                text: "*",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () {
            _showConditionEditorModalBottomSheet();
          },
          child: condition != null
              ? ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: DartBlockValueWidget(
                    value: condition!,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                )
              : IgnorePointer(
                  child: OutlinedButton(
                    child: const Text("Set condition..."),
                    onPressed: () {},
                  ),
                ),
        ),
        if (!isDoWhile)
          ...<Widget>[const SizedBox(height: 16)] + _buildBodyExplainerTexts(),
        const Divider(),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodySmall,
            children: [
              TextSpan(
                text: "*",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              TextSpan(
                text: " required",
                style: Theme.of(context).textTheme.bodySmall?.apply(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodySmall,
            children: [
              WidgetSpan(
                child: Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                alignment: PlaceholderAlignment.middle,
              ),
              TextSpan(
                text:
                    "The ${isDoWhile ? "Do-While-Loop" : "While-Loop"} is executed in the following order:",
                style: Theme.of(context).textTheme.bodySmall?.apply(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        if (isDoWhile)
          _buildDoWhileLoopExplainerWidget()
        else
          _buildWhileLoopExplainerWidget(),
      ],
    );
  }

  List<Widget> _buildBodyExplainerTexts() {
    return [
      Text("Body", style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 4),
      Text(
        "The body of the while-loop cannot be edited here.",
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ];
  }

  void _showConditionEditorModalBottomSheet() {
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
                  RichText(
                    text: TextSpan(
                      children: [
                        const WidgetSpan(
                          child: Icon(Icons.loop),
                          alignment: PlaceholderAlignment.middle,
                        ),
                        TextSpan(
                          text: "While-Loop",
                          style: Theme.of(sheetContext).textTheme.titleMedium,
                        ),
                        const WidgetSpan(
                          child: Icon(Icons.keyboard_arrow_right),
                          alignment: PlaceholderAlignment.middle,
                        ),
                        TextSpan(
                          text: 'Condition',
                          style: Theme.of(sheetContext).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: DartBlockColors.boolean,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Flexible(
                    child: BooleanValueComposer(
                      value: condition?.compositionNode,
                      variableDefinitions: widget.existingVariableDefinitions,
                      customFunctions: widget.customFunctions,
                      onChange: (newValue) {
                        setState(() {
                          condition = newValue != null
                              ? DartBlockBooleanExpression.init(newValue)
                              : null;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWhileLoopExplainerWidget() {
    return Column(
      children: [
        IntrinsicWidth(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 38 + 23, right: 23),
                child: Container(
                  height: 2,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              Row(
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.outline,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          Container(
                            height: 2,
                            width: 7,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          ArrowHeadWidget(
                            direction: AxisDirection.right,
                            size: const Size(4, 8),
                            strokeColor: Theme.of(context).colorScheme.outline,
                          ),
                        ],
                      ),
                      Text("", style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        height: 28,
                        width: 2,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      ArrowHeadWidget(
                        direction: AxisDirection.down,
                        size: const Size(8, 4),
                        strokeColor: Theme.of(context).colorScheme.outline,
                      ),
                      _buildExplainerNode("Condition"),
                      Badge(
                        backgroundColor: Colors.transparent,
                        offset: const Offset(16, -8),
                        alignment: Alignment.centerRight,
                        label: Text(
                          "false",
                          style: Theme.of(context).textTheme.bodySmall?.apply(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        child: Container(
                          height: 28,
                          width: 2,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      ArrowHeadWidget(
                        direction: AxisDirection.down,
                        size: const Size(8, 4),
                        strokeColor: Theme.of(context).colorScheme.error,
                      ),
                      Text(
                        "Stop",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "true",
                        style: Theme.of(context).textTheme.bodySmall?.apply(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Container(
                        height: 2,
                        width: 28,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Text(
                        '',
                        style: Theme.of(context).textTheme.bodySmall?.apply(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text('', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  Column(
                    children: [
                      ArrowHeadWidget(
                        direction: AxisDirection.right,
                        size: const Size(4, 8),
                        strokeColor: Theme.of(context).colorScheme.primary,
                      ),
                      Text('', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        height: 32,
                        width: 2,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      _buildExplainerNode("Body"),
                      const SizedBox(height: 32),
                      Text('', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDoWhileLoopExplainerWidget() {
    return Column(
      children: [
        IntrinsicWidth(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 23 + 23, right: 38),
                child: Badge(
                  backgroundColor: Colors.transparent,
                  offset: const Offset(-8, 4),
                  alignment: Alignment.bottomCenter,
                  label: Text(
                    "true",
                    style: Theme.of(context).textTheme.bodySmall?.apply(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: Container(
                    height: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Row(
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.outline,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          Container(
                            height: 2,
                            width: 7,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          ArrowHeadWidget(
                            direction: AxisDirection.right,
                            size: const Size(4, 8),
                            strokeColor: Theme.of(context).colorScheme.outline,
                          ),
                        ],
                      ),
                      Text("", style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        height: 28,
                        width: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      ArrowHeadWidget(
                        direction: AxisDirection.down,
                        size: const Size(8, 4),
                        strokeColor: Theme.of(context).colorScheme.primary,
                      ),
                      _buildExplainerNode("Body"),
                      const SizedBox(height: 32),
                      Text('', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        height: 2,
                        width: 28,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      Text('', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  Column(
                    children: [
                      ArrowHeadWidget(
                        direction: AxisDirection.right,
                        size: const Size(4, 8),
                        strokeColor: Theme.of(context).colorScheme.outline,
                      ),
                      Text('', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        height: 32,
                        width: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      _buildExplainerNode("Condition"),
                      Badge(
                        backgroundColor: Colors.transparent,
                        offset: const Offset(16, -8),
                        alignment: Alignment.centerRight,
                        label: Text(
                          "false",
                          style: Theme.of(context).textTheme.bodySmall?.apply(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        child: Container(
                          height: 28,
                          width: 2,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      ArrowHeadWidget(
                        direction: AxisDirection.down,
                        size: const Size(8, 4),
                        strokeColor: Theme.of(context).colorScheme.error,
                      ),
                      Text(
                        "Stop",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExplainerNode(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.apply(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
