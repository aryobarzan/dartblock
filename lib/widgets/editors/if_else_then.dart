import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartblock/models/function.dart';
import 'package:dartblock/models/dartblock_interaction.dart';
import 'package:dartblock/models/dartblock_notification.dart';
import 'package:dartblock/models/dartblock_value.dart';
import 'package:dartblock/models/statement.dart';
import 'package:dartblock/widgets/editors/composers/boolean_value.dart';
import 'package:dartblock/widgets/dartblock_value_widgets.dart';
import 'package:dartblock/widgets/views/other/dartblock_colors.dart';

class IfElseStatementEditor extends StatefulWidget {
  final IfElseStatement? statement;
  final Function(IfElseStatement) onSaved;

  final List<DartBlockVariableDefinition> existingVariableDefinitions;
  final List<DartBlockFunction> customFunctions;
  const IfElseStatementEditor({
    super.key,
    this.statement,
    required this.onSaved,
    required this.existingVariableDefinitions,
    required this.customFunctions,
  });

  @override
  State<IfElseStatementEditor> createState() => _IfElseStatementEditorState();
}

class _IfElseStatementEditorState extends State<IfElseStatementEditor> {
  DartBlockBooleanExpression? ifCondition;
  late final StatementBlock ifThenStatementBlock;
  late final List<(DartBlockBooleanExpression?, StatementBlock)>
  elseIfStatementBlocks;
  late final StatementBlock elseStatementBlock;
  @override
  void initState() {
    super.initState();
    if (widget.statement != null) {
      ifCondition = widget.statement!.ifCondition;
      ifThenStatementBlock = widget.statement!.ifThenStatementBlock;
      elseIfStatementBlocks = List.from(
        widget.statement!.elseIfStatementBlocks,
      );
      elseStatementBlock = widget.statement!.elseStatementBlock;
    } else {
      ifThenStatementBlock = StatementBlock.init(statements: []);
      elseIfStatementBlocks = [];
      elseStatementBlock = StatementBlock.init(statements: []);
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
                "If-Then-Else",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            FilledButton.icon(
              onPressed:
                  ifCondition != null &&
                      elseIfStatementBlocks
                          .where((element) => element.$1 == null)
                          .isEmpty
                  ? () {
                      if (ifCondition != null &&
                          elseIfStatementBlocks
                              .where((element) => element.$1 == null)
                              .isEmpty) {
                        HapticFeedback.mediumImpact();
                        widget.onSaved(
                          IfElseStatement.init(
                            ifCondition!,
                            ifThenStatementBlock,
                            elseIfStatementBlocks
                                .map((e) => (e.$1!, e.$2))
                                .toList(),
                            elseStatementBlock,
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
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "If-Condition",
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
            _showIfConditionEditorModalBottomSheet();
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: ifCondition != null
                ? DartBlockValueWidget(
                    value: ifCondition,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  )
                : IgnorePointer(
                    child: OutlinedButton(
                      child: const Text("Set if-condition..."),
                      onPressed: () {},
                    ),
                  ),
          ),
        ),
        ReorderableListView.builder(
          buildDefaultDragHandles: false,
          shrinkWrap: true,
          itemBuilder: (context, index) => _buildElseIfWidget(index),
          itemCount: elseIfStatementBlocks.length,
          onReorder: (oldIndex, newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            DartBlockInteraction.create(
              dartBlockInteractionType: DartBlockInteractionType
                  .reorderElseIfBlockOfIfThenElseStatement,
            ).dispatch(context);
            final elseIfStatementBlock = elseIfStatementBlocks.removeAt(
              oldIndex,
            );
            elseIfStatementBlocks.insert(newIndex, elseIfStatementBlock);
          },
        ),
        if (ifCondition != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: OverflowBar(
              alignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    DartBlockInteraction.create(
                      dartBlockInteractionType: DartBlockInteractionType
                          .addElseIfBlockToIfThenElseStatement,
                    ).dispatch(context);
                    setState(() {
                      elseIfStatementBlocks.add((
                        null,
                        StatementBlock.init(statements: []),
                      ));
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Else-If"),
                ),
              ],
            ),
          ),
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
      ],
    );
  }

  Widget _buildElseIfWidget(int index) {
    final elseIfStatementBlock = elseIfStatementBlocks[index];
    return Column(
      key: ValueKey(index),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        ReorderableDragStartListener(
          enabled: elseIfStatementBlocks.length > 1,
          index: index,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Else-If-Condition",
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
              if (elseIfStatementBlocks.length > 1)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.drag_handle),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  _showElseIfConditionEditorModalBottomSheet(index);
                },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: elseIfStatementBlock.$1 != null
                      ? DartBlockValueWidget(
                          value: elseIfStatementBlock.$1,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        )
                      : IgnorePointer(
                          child: OutlinedButton(
                            child: const Text("Set else-if-condition..."),
                            onPressed: () {},
                          ),
                        ),
                ),
              ),
            ),
            IconButton(
              tooltip: "Delete condition",
              onPressed: () {
                DartBlockInteraction.create(
                  dartBlockInteractionType: DartBlockInteractionType
                      .deleteElseIfBlockToIfThenElseStatement,
                ).dispatch(context);
                setState(() {
                  elseIfStatementBlocks.removeAt(index);
                });
              },
              icon: const Icon(Icons.clear),
            ),
          ],
        ),
      ],
    );
  }

  void _showModalBottomSheet(String title, Widget body, {Color? titleColor}) {
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
                          child: Icon(Icons.alt_route),
                          alignment: PlaceholderAlignment.middle,
                        ),
                        TextSpan(
                          text: "If-Then-Else",
                          style: Theme.of(sheetContext).textTheme.titleMedium,
                        ),
                        const WidgetSpan(
                          child: Icon(Icons.keyboard_arrow_right),
                          alignment: PlaceholderAlignment.middle,
                        ),
                        TextSpan(
                          text: title,
                          style: Theme.of(sheetContext).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                        ),
                      ],
                    ),
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

  void _showIfConditionEditorModalBottomSheet() {
    _showModalBottomSheet(
      "If-Condition",
      BooleanValueComposer(
        value: ifCondition?.compositionNode,
        variableDefinitions: widget.existingVariableDefinitions,
        customFunctions: widget.customFunctions,
        onChange: (newValue) {
          setState(() {
            ifCondition = newValue != null
                ? DartBlockBooleanExpression.init(newValue)
                : null;
          });
        },
      ),
      titleColor: DartBlockColors.boolean,
    );
  }

  void _showElseIfConditionEditorModalBottomSheet(int index) {
    _showModalBottomSheet(
      "Else-If-Condition",
      BooleanValueComposer(
        value: elseIfStatementBlocks[index].$1?.compositionNode,
        variableDefinitions: widget.existingVariableDefinitions,
        customFunctions: widget.customFunctions,
        onChange: (newValue) {
          setState(() {
            elseIfStatementBlocks[index] = newValue != null
                ? (
                    DartBlockBooleanExpression.init(newValue),
                    elseIfStatementBlocks[index].$2,
                  )
                : (null, elseIfStatementBlocks[index].$2);
          });
        },
      ),
      titleColor: DartBlockColors.boolean,
    );
  }
}
