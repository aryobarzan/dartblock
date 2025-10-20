import 'package:flutter/material.dart';
import 'package:dartblock/models/function.dart';

import 'package:dartblock/models/statement.dart';
import 'package:dartblock/widgets/editors/statement.dart';
import 'package:dartblock/widgets/helper_widgets.dart';
import 'package:dartblock/widgets/dartblock_value_widgets.dart';
import 'package:dartblock/widgets/dartblock_editor.dart';
import 'package:dartblock/widgets/views/other/dartblock_colors.dart';
import 'package:dartblock/widgets/views/statement.dart';
import 'package:dartblock/widgets/views/statement_listview.dart';

class ForLoopStatementWidget extends StatelessWidget {
  final ForLoopStatement statement;
  final bool canDelete;
  final bool canChange;
  final bool canReorder;
  final Function(ForLoopStatement) onChanged;
  final Function(Statement statement, bool cut) onCopiedStatement;
  final Function() onPastedStatement;
  final List<DartBlockFunction> customFunctions;
  final bool displayToolboxItemDragTarget;
  const ForLoopStatementWidget({
    super.key,
    required this.statement,
    required this.canDelete,
    required this.canChange,
    required this.canReorder,
    required this.onChanged,
    required this.onCopiedStatement,
    required this.onPastedStatement,
    required this.customFunctions,
    required this.displayToolboxItemDragTarget,
  });

  @override
  Widget build(BuildContext context) {
    /// ERROR: do not call the inherited widget here.
    /// Reason: when re-ordering statements, the inherited widget does not appear
    /// to be retrievable during the drag, causing a null error to be thrown.
    /// Solution: only access the inherited widget in parent widgets which cannot be re-ordered,e.g.,
    /// the CustomFunctionWidget.
    // final neoTechCoreInheritedWidget = NeoTechCoreInheritedWidget.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        statement.initStatement != null
            ? StatementWidget(
                statement: statement.initStatement!,
                includeBottomPadding: false,
                showLabel: false,
                canChange: canChange,
                canDelete: canDelete,
                canReorder: canReorder,
                canDuplicate: false,
                onChanged: (value) {
                  statement.initStatement = value;
                  onChanged(statement);
                },
                onDelete: (statementToDelete) {
                  statement.initStatement = null;
                  onChanged(statement);
                },
                onCopyStatement: (statementToCopy, cut) {
                  onCopiedStatement(statementToCopy, cut);
                  if (cut) {
                    statement.initStatement = null;
                    onChanged(statement);
                  }
                },
                onCopiedStatement: onCopiedStatement,
                onPastedStatement: onPastedStatement,
                onPasteStatement: (statementToPaste) {
                  if (statementToPaste.statementType ==
                      StatementType.variableDeclarationStatement) {
                    statement.initStatement = statementToPaste.copy();
                    onPastedStatement();
                    onChanged(statement);
                  } else {
                    // Special case: the for-loop's init ('pre-step') can only be a 'Declare Variable' type statement.
                    ScaffoldMessenger.of(context).showSnackBar(
                      createDartBlockInfoSnackBar(
                        context,
                        iconData: Icons.error,
                        message:
                            "Can only use 'Declare Variable' statement for a For-Loop's pre-step.",
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.errorContainer,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    );
                  }
                },
                onDuplicate: (statementToDuplicate) {
                  /// Cannot duplicate this statement.
                },
                onAppendNewStatement: null,
                customFunctions: customFunctions,
              )
            : TextButton.icon(
                onPressed: canChange
                    ? () {
                        final neoTechCoreInheritedWidget =
                            DartBlockEditorInheritedWidget.of(context);
                        final neoTechCoreTree = neoTechCoreInheritedWidget
                            .program
                            .buildTree();
                        final existingVariableDefinitions = neoTechCoreTree
                            .findVariableDefinitions(
                              statement.hashCode,
                              includeNode: false,
                            );
                        StatementEditor.create(
                          statementType:
                              StatementType.variableDeclarationStatement,
                          existingVariableDefinitions:
                              existingVariableDefinitions,
                          customFunctions: neoTechCoreInheritedWidget
                              .program
                              .customFunctions,
                          onSaved: (value) {
                            Navigator.of(context).pop();
                            statement.initStatement = value;
                            onChanged(statement);
                          },
                        ).showAsModalBottomSheet(context);
                      }
                    : null,
                icon: const Icon(Icons.add),
                label: const Text("Add initialization step (optional)"),
              ),
        Container(
          margin: const EdgeInsets.only(left: 16),
          height: 18,
          width: 1,
          color: Theme.of(context).colorScheme.outline,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: ArrowHeadWidget(
            direction: AxisDirection.down,
            size: const Size(8, 4),
            strokeColor: Theme.of(context).colorScheme.outline,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 32),
            child: DartBlockValueWidget(
              value: statement.condition,
              border: Border.all(color: DartBlockColors.boolean),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0.5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      ArrowHeadWidget(
                        direction: AxisDirection.up,
                        size: const Size(8, 4),
                        strokeColor: Theme.of(context).colorScheme.outline,
                      ),
                      Container(
                        height: 36,
                        width: 1,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ],
                  ),
                  const SizedBox(width: 18),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            height: 36,
                            width: 1,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Badge(
                                  alignment: Alignment.topCenter,
                                  offset: const Offset(-10, -14),
                                  backgroundColor: Colors.transparent,
                                  label: Text(
                                    'false',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.apply(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                          fontStyle: FontStyle.italic,
                                        ),
                                  ),
                                  child: Container(
                                    height: 1,
                                    width: 48,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                ArrowHeadWidget(
                                  direction: AxisDirection.right,
                                  size: const Size(4, 8),
                                  strokeColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                    horizontal: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "Exit loop",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ArrowHeadWidget(
                        direction: AxisDirection.down,
                        size: const Size(8, 4),
                        strokeColor: Theme.of(context).colorScheme.outline,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          width: 1,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: StatementListView(
                        neoTechCoreNodeKey: statement.bodyStatements.isNotEmpty
                            ? statement.bodyStatements.last.hashCode
                            : (statement.initStatement?.hashCode ??
                                  statement.hashCode),
                        statements: statement.bodyStatements,
                        canDelete: canDelete,
                        canChange: canChange,
                        canReorder: canReorder,
                        onCopiedStatement: onCopiedStatement,
                        onChanged: (newStatements) {
                          statement.bodyStatements = newStatements;
                          onChanged(statement);
                        },
                        onDuplicate: (index) {
                          final duplicatedStatement = statement
                              .bodyStatements[index]
                              .copy();
                          if (index < statement.bodyStatements.length - 1) {
                            statement.bodyStatements.insert(
                              index + 1,
                              duplicatedStatement,
                            );
                          } else {
                            statement.bodyStatements.add(duplicatedStatement);
                          }
                          onChanged(statement);
                        },
                        onPastedStatement: onPastedStatement,
                        customFunctions: customFunctions,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              const SizedBox(width: 24, height: 18),
                              Positioned(
                                top: 0,
                                left: 6,
                                width: 1,
                                height: 18,
                                child: Container(
                                  height: 18,
                                  width: 1,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 2,
                                child: ArrowHeadWidget(
                                  direction: AxisDirection.down,
                                  size: const Size(8, 4),
                                  strokeColor: Theme.of(
                                    context,
                                  ).colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: statement.postStatement != null
                              ? StatementWidget(
                                  statement: statement.postStatement!,
                                  includeBottomPadding: false,
                                  showLabel: false,
                                  canChange: canChange,
                                  canDelete: canDelete,
                                  canReorder: canReorder,
                                  canDuplicate: false,
                                  onChanged: (value) {
                                    statement.postStatement = value;
                                    onChanged(statement);
                                  },
                                  onDelete: (statementToDelete) {
                                    statement.postStatement = null;
                                    onChanged(statement);
                                  },
                                  onCopyStatement: (statementToCopy, cut) {
                                    onCopiedStatement(statementToCopy, cut);
                                    if (cut) {
                                      statement.postStatement = null;
                                      onChanged(statement);
                                    }
                                  },
                                  onCopiedStatement: onCopiedStatement,
                                  onDuplicate: (statementToDuplicate) {
                                    /// Cannot duplicate this statement.
                                  },
                                  onPastedStatement: onPastedStatement,
                                  onPasteStatement: (statementToPaste) {
                                    if (statementToPaste.statementType ==
                                        StatementType
                                            .variableAssignmentStatement) {
                                      statement.postStatement = statementToPaste
                                          .copy();
                                      onPastedStatement();
                                      onChanged(statement);
                                    } else {
                                      // Special case: the for-loop's init ('post-step') can only be a 'Update Variable' type statement.
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        createDartBlockInfoSnackBar(
                                          context,
                                          iconData: Icons.error,
                                          message:
                                              "Can only use 'Update Variable' statement for a For-Loop's post-step.",
                                          backgroundColor: Theme.of(
                                            context,
                                          ).colorScheme.errorContainer,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onErrorContainer,
                                        ),
                                      );
                                    }
                                  },
                                  onAppendNewStatement: null,
                                  customFunctions: customFunctions,
                                )
                              : TextButton.icon(
                                  onPressed: canChange
                                      ? () {
                                          final neoTechCoreInheritedWidget =
                                              DartBlockEditorInheritedWidget.of(
                                                context,
                                              );
                                          final neoTechCoreTree =
                                              neoTechCoreInheritedWidget.program
                                                  .buildTree();
                                          final existingVariableDefinitions =
                                              neoTechCoreTree
                                                  .findVariableDefinitions(
                                                    statement
                                                            .initStatement
                                                            ?.hashCode ??
                                                        statement.hashCode,
                                                    includeNode: true,
                                                  );
                                          StatementEditor.create(
                                            statementType: StatementType
                                                .variableAssignmentStatement,
                                            existingVariableDefinitions:
                                                existingVariableDefinitions,
                                            customFunctions:
                                                neoTechCoreInheritedWidget
                                                    .program
                                                    .customFunctions,
                                            onSaved: (value) {
                                              Navigator.of(context).pop();
                                              statement.postStatement = value;
                                              onChanged(statement);
                                            },
                                          ).showAsModalBottomSheet(context);
                                        }
                                      : null,
                                  icon: const Icon(Icons.add),
                                  label: const Text("Add post-step (optional)"),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                width: 1,
                child: Container(
                  margin: const EdgeInsets.only(top: 0, bottom: 12),
                  width: 1,
                  height: double.maxFinite,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              Positioned(
                bottom: 12,
                left: 0,
                width: 8,
                child: Container(
                  height: 1,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
