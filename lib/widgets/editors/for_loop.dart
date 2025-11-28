import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartblock_code/models/function.dart';
import 'package:dartblock_code/models/dartblock_notification.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/editors/composers/boolean_value.dart';
import 'package:dartblock_code/widgets/editors/variable_assignment.dart';
import 'package:dartblock_code/widgets/editors/variable_declaration.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:dartblock_code/widgets/dartblock_value_widgets.dart';
import 'package:dartblock_code/widgets/views/other/dartblock_colors.dart';
import 'package:dartblock_code/widgets/views/variable_assignment.dart';
import 'package:dartblock_code/widgets/views/variable_declaration.dart';

class ForLoopStatementEditor extends StatefulWidget {
  final ForLoopStatement? statement;
  final Function(ForLoopStatement) onSaved;

  final List<DartBlockVariableDefinition> existingVariableDefinitions;
  final List<DartBlockCustomFunction> customFunctions;
  const ForLoopStatementEditor({
    super.key,
    this.statement,
    required this.onSaved,
    required this.existingVariableDefinitions,
    required this.customFunctions,
  });

  @override
  State<ForLoopStatementEditor> createState() => _ForLoopStatementEditorState();
}

class _ForLoopStatementEditorState extends State<ForLoopStatementEditor> {
  Statement? initStatement;
  DartBlockBooleanExpression? condition;
  Statement? postStatement;
  @override
  void initState() {
    super.initState();
    if (widget.statement != null) {
      initStatement = widget.statement!.initStatement;
      condition = widget.statement!.condition;
      postStatement = widget.statement!.postStatement;
    } else {
      // Create a default for-loop:
      // int i = 0
      initStatement = VariableDeclarationStatement.init(
        "i",
        DartBlockDataType.integerType,
        DartBlockAlgebraicExpression.fromConstant(0),
      );
      // i < 10
      condition = DartBlockBooleanExpression.init(
        DartBlockValueTreeBooleanNumberComparisonOperatorNode.init(
          DartBlockNumberComparisonOperator.less,
          DartBlockValueTreeBooleanGenericNumberNode.init(
            DartBlockAlgebraicExpression.init(
              DartBlockValueTreeAlgebraicDynamicNode.init(
                DartBlockVariable.init("i"),
                null,
              ),
            ),
            null,
          ),
          DartBlockValueTreeBooleanGenericNumberNode.init(
            DartBlockAlgebraicExpression.fromConstant(10),
            null,
          ),
          null,
        ),
      );
      // i=i+1
      postStatement = VariableAssignmentStatement.init(
        "i",
        DartBlockAlgebraicExpression.init(
          DartBlockValueTreeAlgebraicOperatorNode.init(
            DartBlockAlgebraicOperator.add,
            DartBlockValueTreeAlgebraicDynamicNode.init(
              DartBlockVariable.init("i"),
              null,
            ),
            DartBlockValueTreeAlgebraicConstantNode.init(1, false, null),
            null,
          ),
        ),
      );
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
                "For-Loop",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            FilledButton.icon(
              onPressed: condition != null
                  ? () {
                      if (condition != null) {
                        HapticFeedback.mediumImpact();
                        widget.onSaved(
                          ForLoopStatement.init(
                            initStatement,
                            condition!,
                            postStatement,
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
        _buildHeader('Pre-Step', 1),
        Text(
          'Variable initialization',
          style: Theme.of(context).textTheme.bodySmall?.apply(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () {
            _showPreStepEditorModalBottomSheet();
          },
          child:
              initStatement != null &&
                  initStatement is VariableDeclarationStatement
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: VariableDeclarationStatementWidget(
                          statement:
                              initStatement as VariableDeclarationStatement,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            initStatement = null;
                          });
                        },
                        icon: const Icon(Icons.clear),
                      ),
                    ],
                  ),
                )
              : IgnorePointer(
                  child: OutlinedButton(
                    child: const Text("Set pre-step..."),
                    onPressed: () {},
                  ),
                ),
        ),
        const SizedBox(height: 16),
        _buildHeader('Condition', 2, isRequired: true),
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
        const SizedBox(height: 16),
        _buildHeader('Body', 3),
        const SizedBox(height: 4),
        Text(
          "The body of the for-loop cannot be edited here.",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        _buildHeader('Post-Step', 4),
        Text(
          'Variable update',
          style: Theme.of(context).textTheme.bodySmall?.apply(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () {
            _showPostStepEditorModalBottomSheet();
          },
          child:
              postStatement != null &&
                  postStatement is VariableAssignmentStatement
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: VariableAssignmentStatementWidget(
                          statement:
                              postStatement as VariableAssignmentStatement,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            postStatement = null;
                          });
                        },
                        icon: const Icon(Icons.clear),
                      ),
                    ],
                  ),
                )
              : IgnorePointer(
                  child: OutlinedButton(
                    child: const Text("Set post-step..."),
                    onPressed: () {},
                  ),
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
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
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
                text: "The steps are executed in the following order:",
                style: Theme.of(context).textTheme.bodySmall?.apply(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Center(child: _buildSequenceVisualizer()),
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
                          child: Icon(Icons.loop),
                          alignment: PlaceholderAlignment.middle,
                        ),
                        TextSpan(
                          text: "For-Loop",
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

  void _showConditionEditorModalBottomSheet() {
    List<DartBlockVariableDefinition> conditionAvailableVariableDefinitions =
        List.from(widget.existingVariableDefinitions);
    if (initStatement != null &&
        initStatement is VariableDeclarationStatement) {
      final initStatementVariableDefinition = DartBlockVariableDefinition(
        (initStatement as VariableDeclarationStatement).name,
        (initStatement as VariableDeclarationStatement).dataType,
      );

      conditionAvailableVariableDefinitions.add(
        initStatementVariableDefinition,
      );
      conditionAvailableVariableDefinitions =
          conditionAvailableVariableDefinitions.toSet().toList();
    }
    _showModalBottomSheet(
      "Condition",
      BooleanValueComposer(
        value: condition?.compositionNode,
        variableDefinitions: conditionAvailableVariableDefinitions,
        customFunctions: widget.customFunctions,
        onChange: (newValue) {
          setState(() {
            condition = newValue != null
                ? DartBlockBooleanExpression.init(newValue)
                : null;
          });
        },
      ),
      titleColor: DartBlockColors.boolean,
    );
  }

  void _showPreStepEditorModalBottomSheet() {
    _showModalBottomSheet(
      "Pre-Step",
      VariableDeclarationEditor(
        statement: initStatement is VariableDeclarationStatement
            ? initStatement as VariableDeclarationStatement
            : null,
        existingVariableDefinitions: widget.existingVariableDefinitions,
        customFunctions: widget.customFunctions,
        onSaved: (newValue) {
          Navigator.of(context).pop();
          setState(() {
            initStatement = newValue;
          });
        },
      ),
    );
  }

  void _showPostStepEditorModalBottomSheet() {
    List<DartBlockVariableDefinition>
    postStatementAvailableVariableDefinitions = List.from(
      widget.existingVariableDefinitions,
    );
    if (initStatement != null &&
        initStatement is VariableDeclarationStatement) {
      final initStatementVariableDefinition = DartBlockVariableDefinition(
        (initStatement as VariableDeclarationStatement).name,
        (initStatement as VariableDeclarationStatement).dataType,
      );

      postStatementAvailableVariableDefinitions.add(
        initStatementVariableDefinition,
      );
      postStatementAvailableVariableDefinitions =
          postStatementAvailableVariableDefinitions.toSet().toList();
    }
    _showModalBottomSheet(
      "Post-Step",
      VariableAssignmentEditor(
        statement: postStatement is VariableAssignmentStatement
            ? postStatement as VariableAssignmentStatement
            : null,
        existingVariableDefinitions: postStatementAvailableVariableDefinitions,
        customFunctions: widget.customFunctions,
        onSaved: (newValue) {
          Navigator.of(context).pop();
          setState(() {
            postStatement = newValue;
          });
        },
      ),
    );
  }

  Widget _buildHeader(String title, int counter, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                counter.toString(),
                style: Theme.of(context).textTheme.titleSmall?.apply(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          TextSpan(text: title, style: Theme.of(context).textTheme.titleMedium),
          if (isRequired)
            TextSpan(
              text: "*",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSequenceVisualizer() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildSequenceVisualizerNode('title', 1),
        Container(
          width: 28,
          height: 2,
          color: Theme.of(context).colorScheme.outline,
        ),
        ArrowHeadWidget(
          direction: AxisDirection.right,
          size: const Size(4, 8),
          strokeColor: Theme.of(context).colorScheme.outline,
        ),
        IntrinsicWidth(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 12, right: 12, top: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                height: 2,
              ),
              Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 2,
                        height: 20,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      ArrowHeadWidget(
                        direction: AxisDirection.down,
                        size: const Size(8, 4),
                        strokeColor: Theme.of(context).colorScheme.outline,
                      ),
                      _buildSequenceVisualizerNode('title', 2),
                      Row(
                        children: [
                          Badge(
                            textColor: Theme.of(context).colorScheme.error,
                            backgroundColor: Colors.transparent,
                            offset: const Offset(16, -10),
                            label: Text(
                              'false',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.apply(
                                    fontStyle: FontStyle.italic,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                            alignment: Alignment.centerRight,
                            child: Column(
                              children: [
                                Container(
                                  width: 2,
                                  height: 12,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                ArrowHeadWidget(
                                  direction: AxisDirection.down,
                                  size: const Size(8, 4),
                                  strokeColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Stop',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              Text(
                                'true',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontStyle: FontStyle.italic,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                              Container(
                                width: 28,
                                height: 2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              Text(
                                '',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          ArrowHeadWidget(
                            direction: AxisDirection.right,
                            size: const Size(4, 8),
                            strokeColor: Theme.of(context).colorScheme.primary,
                          ),
                          _buildSequenceVisualizerNode('title', 3),
                          Container(
                            width: 28,
                            height: 2,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          ArrowHeadWidget(
                            direction: AxisDirection.right,
                            size: const Size(4, 8),
                            strokeColor: Theme.of(context).colorScheme.outline,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 2,
                                height: 24,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              _buildSequenceVisualizerNode('title', 4),
                              const SizedBox(width: 2, height: 24),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
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

  Widget _buildSequenceVisualizerNode(String title, int counter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        counter.toString(),
        style: Theme.of(context).textTheme.titleSmall?.apply(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
