import 'package:dartblock_code/widgets/dartblock_editor_providers.dart';
import 'package:flutter/material.dart';
import 'package:dartblock_code/models/function.dart';

import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/editors/statement.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:dartblock_code/widgets/dartblock_value_widgets.dart';
import 'package:dartblock_code/widgets/views/statement.dart';
import 'package:dartblock_code/widgets/views/statement_listview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForLoopStatementWidget extends ConsumerWidget {
  final ForLoopStatement statement;
  final bool canDelete;
  final bool canChange;
  final bool canReorder;
  final Function(ForLoopStatement) onChanged;
  final Function(Statement statement, bool cut) onCopiedStatement;
  final Function() onPastedStatement;
  final List<DartBlockCustomFunction> customFunctions;

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
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final program = ref.watch(programProvider);

    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title and execution order number
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
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
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Initialize",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          // Initialization statement
          statement.initStatement != null
              ? StatementWidget(
                  statement: statement.initStatement!,
                  includeBottomPadding: false,
                  showLabel: false,
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
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      );
                    }
                  },
                  onDuplicate: (_) {
                    // The initialization statement cannot be duplicated.
                  },
                  onAppendNewStatement: null,
                )
              : TextButton.icon(
                  onPressed: canChange
                      ? () {
                          final programTree = program.buildTree();
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
                            customFunctions: program.customFunctions,
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
          const SizedBox(height: 16),
          // Condition with step number 2
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
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
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Condition",
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
                    child: Icon(Icons.info_outline, size: 18),
                  ),
                ),
              ],
            ),
          ),
          // Condition expression
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                  child: DartBlockValueWidget(
                    value: statement.condition,
                    borderRadius: BorderRadius.circular(12),
                    isInteractive: false,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Loop body with step number 3
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
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
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text("Body", style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
          // Loop body statements
          StatementListView(
            neoTechCoreNodeKey: statement.bodyStatements.isNotEmpty
                ? statement.bodyStatements.last.hashCode
                : (statement.initStatement?.hashCode ?? statement.hashCode),
            statements: statement.bodyStatements,
            canDelete: canDelete,
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
                statement.bodyStatements.insert(index + 1, duplicatedStatement);
              } else {
                statement.bodyStatements.add(duplicatedStatement);
              }
              onChanged(statement);
            },
            onPastedStatement: onPastedStatement,
          ),
          const SizedBox(height: 16),
          // Update step with number 4
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 8,
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
                    ),
                  ),
                ),
                Text("Update", style: Theme.of(context).textTheme.titleMedium),
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
                    child: Icon(Icons.info_outline, size: 18),
                  ),
                ),
              ],
            ),
          ),
          // Update statement
          statement.postStatement != null
              ? StatementWidget(
                  statement: statement.postStatement!,
                  includeBottomPadding: false,
                  showLabel: false,
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
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      );
                    }
                  },
                  onAppendNewStatement: null,
                )
              : TextButton.icon(
                  onPressed: canChange
                      ? () {
                          final programTree = program.buildTree();
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
                            customFunctions: program.customFunctions,
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
          const SizedBox(height: 16),
          // Visual flow indicator showing that it goes back to step 2
          Row(
            children: [
              const Icon(Icons.replay, size: 20),
              const SizedBox(width: 8),
              Text(
                "Return to step 2",
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
