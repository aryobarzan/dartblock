import 'package:collection/collection.dart';
import 'package:dartblock_code/widgets/dartblock_editor_providers.dart';
import 'package:dartblock_code/widgets/views/toolbox/misc/toolbox_drag_target.dart';
import 'package:flutter/material.dart';
import 'package:dartblock_code/models/dartblock_interaction.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:dartblock_code/widgets/views/statement.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatementListView extends ConsumerWidget {
  final int neoTechCoreNodeKey;
  final List<Statement> statements;
  final bool canDelete;
  final bool canReorder;
  final Function(List<Statement>) onChanged;
  final Function(int index) onDuplicate;
  final Function(Statement statement, bool cut) onCopiedStatement;

  /// The StatementListView handles the logic of pasting the statement.
  ///
  /// This callback simply signals that the operation has been processed, such that the parent NeoTechCoreInheritedWidget can be adjusted accordingly to clear the clipboard in case the statement had been cut.
  final Function() onPastedStatement;
  const StatementListView({
    super.key,
    required this.neoTechCoreNodeKey,
    required this.statements,
    required this.canDelete,
    required this.canReorder,
    required this.onChanged,
    required this.onDuplicate,
    required this.onCopiedStatement,
    required this.onPastedStatement,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorStateProvider);
    final settings = ref.watch(settingsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (statements.isEmpty && !settings.canChange)
          Text(
            "No statements.",
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.apply(fontStyle: FontStyle.italic),
          ),
        ReorderableListView(
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          shrinkWrap: true,
          children: statements
              .mapIndexed(
                (
                  index,
                  bodyStatement,
                ) => CustomReorderableDelayedDragStartListener(
                  delay: const Duration(milliseconds: 500),

                  /// Important to disable dragging when only 1 statement is there:
                  /// Otherwise, Flutter throws rendering errors when the single statement is moved outside this widget.
                  enabled: canReorder && statements.length > 1,
                  index: index,
                  key: ValueKey(bodyStatement.hashCode),
                  // IMPORTANT: on the use of UncontrolledProviderScope here:
                  // When a drag operation is started, e.g., using Draggable or ReorderableListView,
                  // The dragged widget is moved to an Overlay. Consequently, the original widget is
                  // no longer part of the main widget tree, i.e., it uses a different BuildContext.
                  // This can cause issues with InheritedWidgets and Providers (including riverpod),
                  // as they rely on the BuildContext to retrieve the correct dependencies.
                  // For example, if the main ProviderScope wraps the main app widget (DartBlockEditor),
                  // and it defines a provider such as programProvider, the dragged widget cannot rely
                  // on a ConsumerWidget to access programProvider anymore, because its BuildContext is now
                  // different and does not have access to the original ProviderScope.
                  // Illustration of the problem:
                  // MaterialApp
                  // - ProviderScope
                  //     - ...
                  // - Overlay (DIFFERENT BUILDCONTEXT)

                  // SOLUTION: By wrapping the widget which can be dragged with UncontrolledProviderScope,
                  // we expose our original ProviderScope to the dragged widget, ensuring it can still access
                  // all providers once a drag operation has started.
                  child: UncontrolledProviderScope(
                    container: ProviderScope.containerOf(context),
                    child: StatementWidget(
                      statement: bodyStatement,
                      includeBottomPadding:
                          true, // statements.length > 1 &&   (index < statements.length - 1)
                      onChanged: (value) {
                        statements[index] = value;
                        onChanged(statements);
                      },
                      canReorder: canReorder,
                      canDelete: canDelete,
                      onDelete: () {
                        statements.removeAt(index);
                        onChanged(statements);
                      },
                      onDuplicate: (statementToDuplicate) {
                        onDuplicate(index);
                      },
                      onAppendNewStatement: (newStatement) {
                        if (index + 1 < statements.length) {
                          statements.insert(index + 1, newStatement);
                        } else {
                          statements.add(newStatement);
                        }
                        onChanged(statements);
                      },
                      onCopyStatement: (statementToCopy, cut) {
                        if (cut) {
                          statements.removeAt(index);
                          onChanged(statements);
                        }
                        onCopiedStatement(statementToCopy, cut);
                      },
                      onCopiedStatement: onCopiedStatement,
                      onPastedStatement: onPastedStatement,
                      onPasteStatement: (statementToPaste) {
                        // If the current statement is not the last one, paste the copied statement after it.
                        if (index + 1 < statements.length) {
                          statements.insert(index + 1, statementToPaste.copy());
                        } else {
                          // Otherwise, append the copied statement at the end.
                          statements.add(statementToPaste.copy());
                        }
                        onPastedStatement();
                        onChanged(statements);
                      },
                    ),
                  ),
                ),
              )
              .toList(),
          onReorderStart: (index) {
            DartBlockInteraction.create(
              dartBlockInteractionType:
                  DartBlockInteractionType.startedDraggingStatementToReorder,
            ).dispatch(context);
          },
          onReorder: (oldIndex, newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            DartBlockInteraction.create(
              dartBlockInteractionType:
                  DartBlockInteractionType.reorderedStatement,
            ).dispatch(context);
            final targetStatement = statements.removeAt(oldIndex);
            statements.insert(newIndex, targetStatement);
            onChanged(statements);
          },
        ),
        if (settings.canChange) //  && statements.isEmpty
          ToolboxDragTarget(
            isEnabled: settings.canChange,
            nodeKey: neoTechCoreNodeKey,
            onSaved: (savedStatement) {
              //Navigator.of(context).pop();
              statements.add(savedStatement);
              ScaffoldMessenger.of(context).showSnackBar(
                createDartBlockInfoSnackBar(
                  context,
                  iconData: Icons.add,
                  message:
                      "Created '${savedStatement.statementType.toString()}' statement.",
                ),
              );
              onChanged(statements);
            },
            onPasteStatement:
                // Only show "Paste" option if there is a copied statement
                editorState.copiedStatement != null
                ? () {
                    // Retrieve copied statement and make a copy of it.
                    final statementToPaste = editorState.copiedStatement
                        ?.copy();
                    if (statementToPaste != null) {
                      statements.add(statementToPaste);
                      onPastedStatement();
                      onChanged(statements);
                    }
                  }
                : null,
          ),
      ],
    );
  }
}
