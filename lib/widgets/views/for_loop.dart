import 'package:flutter/material.dart';
import 'package:dartblock_code/models/function.dart';

import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/editors/statement.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:dartblock_code/widgets/dartblock_value_widgets.dart';
import 'package:dartblock_code/widgets/dartblock_editor.dart';
import 'package:dartblock_code/widgets/views/statement.dart';
import 'package:dartblock_code/widgets/views/statement_listview.dart';

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
    /// CRITICAL: do not try to retrieve DartBlockEditorInheritedWidget here.
    /// Reason: when re-ordering statements, the inherited widget does not appear to be retrievable during the drag, causing a null error to be thrown.
    /// Explanation: when a drag gesture is stared, the widget starts "floating", essentially leaving its original parent widget. As such, it loses the context of its parent who holds the DartBlockEditorInheritedWidget.
    /// Solution: only access the inherited widget in parent widgets which cannot be re-ordered,e.g., the CustomFunctionWidget.
    // final dartBlockEditorInheritedWidget = DartBlockEditorInheritedWidget.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title and execution order number
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "1",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Initialize Loop Variable",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            // Initialization statement
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: statement.initStatement != null
                  ? StatementWidget(
                      statement: statement.initStatement!,
                      includeBottomPadding: false,
                      showLabel: false,
                      canChange: canChange,
                      canDelete: canDelete,
                      canReorder: false,
                      canDuplicate: false,
                      onChanged: (value) {
                        statement.initStatement = value;
                        onChanged(statement);
                      },
                      onDelete: () {
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            createDartBlockInfoSnackBar(
                              context,
                              iconData: Icons.error,
                              message:
                                  "Can only use 'Declare Variable' statement for initialization.",
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
                      onDuplicate: (_) {
                        // The initialization statement cannot be duplicated.
                      },
                      onAppendNewStatement: null,
                      customFunctions: customFunctions,
                    )
                  : TextButton.icon(
                      onPressed: canChange
                          ? () {
                              final dartBlockInheritedWidget =
                                  DartBlockEditorInheritedWidget.of(context);
                              final programTree = dartBlockInheritedWidget
                                  .program
                                  .buildTree();
                              final existingVariableDefinitions = programTree
                                  .findVariableDefinitions(
                                    statement.hashCode,
                                    includeNode: false,
                                  );
                              StatementEditor.create(
                                statementType:
                                    StatementType.variableDeclarationStatement,
                                existingVariableDefinitions:
                                    existingVariableDefinitions,
                                customFunctions: dartBlockInheritedWidget
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
                      label: const Text("Add 'Declare Variable' statement"),
                    ),
            ),
            const SizedBox(height: 16),

            // Condition with step number 2
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "2",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Check Condition",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message:
                      "If the condition is false, exit the loop.\nIf the condition is true, continue to step 3.",
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Step 2: Check Condition"),
                          content: Text(
                            "If the condition is false, exit the loop.\nIf the condition is true, continue to step 3.",
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Okay'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    child: Icon(Icons.info_outline),
                  ),
                ),
              ],
            ),
            // Decision visualization
            Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Condition expression
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
                          child: DartBlockValueWidget(
                            value: statement.condition,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                  // Alternative approach: (slightly more performant, but requires manual calculation of padding)
                  //       SizedBox(
                  //   width: double.infinity,
                  //   child: SingleChildScrollView(
                  //     scrollDirection: Axis.horizontal,
                  //     child: Container(
                  //       constraints: BoxConstraints(
                  //         minWidth:
                  //             MediaQuery.of(context).size.width -
                  //             72 -
                  //             32, // Account for paddings
                  //       ),
                  //       child: DartBlockValueWidget(
                  //         value: statement.condition,
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 8),
                  // Decision arrows
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "If true:",
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "continue to step 3",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Else:",
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "exit the loop",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.exit_to_app, size: 16),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Loop body with step number 3
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "3",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Execute Loop Body",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            // Loop body statements
            Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: StatementListView(
                neoTechCoreNodeKey: statement.bodyStatements.isNotEmpty
                    ? statement.bodyStatements.last.hashCode
                    : (statement.initStatement?.hashCode ?? statement.hashCode),
                statements: statement.bodyStatements,
                canDelete: canDelete,
                canChange: canChange,
                canReorder: canReorder,
                onCopiedStatement: onCopiedStatement,
                onChanged: (statements) {
                  statement.bodyStatements = statements;
                  onChanged(statement);
                },
                onDuplicate: (index) {
                  final duplicatedStatement = statement.bodyStatements[index]
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

            const SizedBox(height: 16),

            // Update step with number 4
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "4",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Update Loop Variable",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message:
                      "After executing the loop body, this step updates the loop variable before checking the condition again.",
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Step 4: Update Loop Variable"),
                          content: Text(
                            "After executing the loop body, this step updates the loop variable before checking the condition again.",
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Okay'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    child: Icon(Icons.info_outline),
                  ),
                ),
              ],
            ),
            // Update statement
            Padding(
              padding: const EdgeInsets.only(left: 32),
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
                      onDelete: () {
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
                            StatementType.variableAssignmentStatement) {
                          statement.postStatement = statementToPaste.copy();
                          onPastedStatement();
                          onChanged(statement);
                        } else {
                          // Special case: the for-loop's init ('post-step') can only be a 'Update Variable' type statement.
                          ScaffoldMessenger.of(context).showSnackBar(
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
                              final dartBlockEditorInheritedWidget =
                                  DartBlockEditorInheritedWidget.of(context);
                              final programTree = dartBlockEditorInheritedWidget
                                  .program
                                  .buildTree();
                              final existingVariableDefinitions = programTree
                                  .findVariableDefinitions(
                                    statement.initStatement?.hashCode ??
                                        statement.hashCode,
                                    includeNode: true,
                                  );
                              StatementEditor.create(
                                statementType:
                                    StatementType.variableAssignmentStatement,
                                existingVariableDefinitions:
                                    existingVariableDefinitions,
                                customFunctions: dartBlockEditorInheritedWidget
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
                      label: const Text("Add 'Update Variable' statement"),
                    ),
            ),

            // Visual flow indicator showing that it goes back to step 2
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.replay, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Return to step 2",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
