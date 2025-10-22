import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dartblock_code/models/function.dart';
import 'package:dartblock_code/models/dartblock_interaction.dart';
import 'package:dartblock_code/models/dartblock_notification.dart';
import 'package:dartblock_code/models/exception.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/editors/statement.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:dartblock_code/widgets/dartblock_editor.dart';
import 'package:dartblock_code/widgets/views/for_loop.dart';
import 'package:dartblock_code/widgets/views/function_call.dart';
import 'package:dartblock_code/widgets/views/if_else_then.dart';
import 'package:dartblock_code/widgets/views/other/dartblock_exception.dart';
import 'package:dartblock_code/widgets/views/toolbox_related.dart';
import 'package:dartblock_code/widgets/views/variable_assignment.dart';
import 'package:dartblock_code/widgets/views/variable_declaration.dart';
import 'package:dartblock_code/widgets/views/while_loop.dart';
import 'package:dartblock_code/widgets/widgets.dart';

class StatementWidget extends StatelessWidget {
  final Statement statement;
  final bool includeBottomPadding;
  final bool showLabel;
  final bool canDelete;
  final bool canChange;
  final bool canReorder;
  final bool canDuplicate;
  final Function(Statement) onDelete;
  final Function(Statement) onChanged;
  final Function(Statement statementToDuplicate) onDuplicate;
  final Function(Statement newStatement)? onAppendNewStatement;
  final Function(Statement statement, bool cut) onCopyStatement;
  final Function(Statement statement, bool cut) onCopiedStatement;
  final Function(Statement statementToPaste) onPasteStatement;
  final Function() onPastedStatement;
  final List<DartBlockFunction> customFunctions;
  const StatementWidget({
    super.key,
    required this.statement,
    required this.onChanged,
    required this.canDelete,
    required this.canChange,
    required this.canReorder,
    this.canDuplicate = true,
    required this.onDelete,
    required this.onDuplicate,
    required this.onAppendNewStatement,
    required this.onCopyStatement,
    required this.onCopiedStatement,
    required this.onPasteStatement,
    required this.onPastedStatement,
    this.includeBottomPadding = true,
    this.showLabel = true,
    required this.customFunctions,
  });

  @override
  Widget build(BuildContext context) {
    Widget widget = Text(statement.toScript());
    String label;
    IconData? iconData;
    bool isStatementBlock = false;
    bool canEdit = canChange;

    /// Use maybeOf here as it becomes null when the StatementWidget is being reordered,
    /// at which point it is in a different BuildContext and no longer has access to
    /// the NeoTechInheritedWidget.
    final neoTechCoreInheritedWidget = DartBlockEditorInheritedWidget.maybeOf(
      context,
    );
    DartBlockException? neoTechException =
        neoTechCoreInheritedWidget?.executor.thrownException;
    Widget? exceptionWidget =
        neoTechException != null &&
            neoTechException.statement != null &&
            // Warning: do not use hashCode of statement here - because the
            /// program execution happens in an isolate, the thrown NeoTechException's
            /// 'statement' field is in fact a copy and thus no longer has the
            /// same hashCode.
            neoTechException.statement!.statementId == statement.statementId
        ? PopupWidgetButton(
            tooltip: "Exception",
            width: MediaQuery.of(context).size.width * 0.9,
            onOpened: () {
              DartBlockInteraction.create(
                dartBlockInteractionType: DartBlockInteractionType
                    .tapExceptionIndicatorOnCausingStatement,
                content: "ExceptionTitle-${neoTechException.title}",
              ).dispatch(context);
            },
            widget: DartBlockExceptionWidget(
              dartblockException: neoTechException,
              program: neoTechCoreInheritedWidget?.program,
            ),
            child: Icon(
              Icons.error,
              color: Theme.of(context).colorScheme.error,
            ),
          )
        : null;
    switch (statement) {
      case StatementBlock():
        label = "Block";
        isStatementBlock = true;
        break;
      case ForLoopStatement():
        label = "For-Loop";
        iconData = Icons.loop;
        isStatementBlock = true;
        widget = ForLoopStatementWidget(
          statement: statement as ForLoopStatement,
          canDelete: canDelete,
          canChange: canChange,
          canReorder: canReorder,
          onChanged: onChanged,
          onCopiedStatement: onCopiedStatement,
          onPastedStatement: onPastedStatement,
          customFunctions: customFunctions,
          displayToolboxItemDragTarget:
              neoTechCoreInheritedWidget?.isDraggingToolboxItem.value ?? false,
        );
        break;
      case WhileLoopStatement():
        final whileLoopStatement = statement as WhileLoopStatement;
        iconData = Icons.loop;
        label = whileLoopStatement.isDoWhile ? "Do-While-Loop" : "While-Loop";
        isStatementBlock = true;
        widget = WhileLoopStatementWidget(
          statement: statement as WhileLoopStatement,
          canDelete: canDelete,
          canChange: canChange,
          canReorder: canReorder,
          onChanged: onChanged,
          onCopiedStatement: onCopiedStatement,
          onPastedStatement: onPastedStatement,
          customFunctions: customFunctions,
          displayToolboxItemDragTarget:
              neoTechCoreInheritedWidget?.isDraggingToolboxItem.value ?? false,
        );
        break;
      case PrintStatement():
        label = "Print";
        widget = PrintStatementWidget(statement: statement as PrintStatement);
        break;
      case ReturnStatement():
        label = "Return";
        widget = ReturnStatementWidget(statement: statement as ReturnStatement);
        break;
      case VariableDeclarationStatement():
        label = "Declare";
        widget = VariableDeclarationStatementWidget(
          statement: statement as VariableDeclarationStatement,
        );
        break;
      case VariableAssignmentStatement():
        label = "Update";
        widget = VariableAssignmentStatementWidget(
          statement: statement as VariableAssignmentStatement,
        );
        break;
      case IfElseStatement():
        label = "If-Then-Else";
        iconData = Icons.alt_route_sharp;
        isStatementBlock = true;
        widget = IfElseStatementWidget(
          statement: statement as IfElseStatement,
          canDelete: canDelete,
          canChange: canChange,
          canReorder: canReorder,
          onChanged: onChanged,
          onCopiedStatement: onCopiedStatement,
          onPastedStatement: onPastedStatement,
          customFunctions: customFunctions,
          displayToolboxItemDragTarget:
              neoTechCoreInheritedWidget?.isDraggingToolboxItem.value ?? false,
        );
        break;
      case FunctionCallStatement():
        label = "Call";
        final customFunctionCallStatement = statement as FunctionCallStatement;
        widget = FunctionCallStatementWidget(
          statement: customFunctionCallStatement,
          customFunction: customFunctions.firstWhereOrNull(
            (element) =>
                element.name == customFunctionCallStatement.customFunctionName,
          ),
        );
        break;
      case BreakStatement():
        label = "Break";
        canEdit = false;
        widget = BreakStatementWidget(statement: statement as BreakStatement);
        break;
      case ContinueStatement():
        label = "Continue";
        canEdit = false;
        widget = ContinueStatementWidget(
          statement: statement as ContinueStatement,
        );
        break;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: includeBottomPadding ? 8 : 0),
      child: InkWell(
        onTapUp: (TapUpDetails details) async {
          DartBlockInteraction.create(
            dartBlockInteractionType: DartBlockInteractionType.tapStatement,
            content:
                'StatementType-${statement.statementType.name}-StatementId-${statement.statementId}${exceptionWidget != null ? '-CausedException' : ''}',
          ).dispatch(context);

          /// Use maybeOf rather of here, as the user may have been dragging
          /// the statement and the drop animation has not yet finished.
          /// If the animation has not finished, the context will not find the NeoTechCoreInheritedWidget.
          final neoTechCoreInheritedWidget =
              DartBlockEditorInheritedWidget.maybeOf(context);
          final RenderBox overlay =
              Overlay.of(context).context.findRenderObject() as RenderBox;
          if (neoTechCoreInheritedWidget != null) {
            _showMoreOptions(
              context,
              position: RelativeRect.fromRect(
                details.globalPosition & const Size(40, 40),
                Offset.zero & overlay.size,
              ),
              canEdit: canEdit,
              canCopy: canChange,
              canDelete: canDelete,
              canDuplicate: canChange && canDuplicate,
              canPaste:
                  canChange &&
                  neoTechCoreInheritedWidget.copiedStatement != null,
            ).then((selectedOption) {
              if (selectedOption != null) {
                if (context.mounted) {
                  switch (selectedOption) {
                    case 'edit':
                      DartBlockInteraction.create(
                        dartBlockInteractionType:
                            DartBlockInteractionType.editStatement,
                        content:
                            'StatementType-${statement.statementType.name}-StatementId-${statement.statementId}${exceptionWidget != null ? '-CausedException' : ''}',
                      ).dispatch(context);
                      final existingVariableDefinitions =
                          neoTechCoreInheritedWidget.program
                              .buildTree()
                              .findVariableDefinitions(
                                statement.hashCode,
                                includeNode: false,
                              );
                      StatementEditor.edit(
                        statement: statement,
                        existingVariableDefinitions:
                            existingVariableDefinitions,
                        customFunctions:
                            neoTechCoreInheritedWidget.program.customFunctions,
                        onSaved: (value) {
                          DartBlockInteraction.create(
                            dartBlockInteractionType:
                                DartBlockInteractionType.editedStatement,
                            content:
                                'StatementType-${statement.statementType.name}-StatementId-${statement.statementId}${exceptionWidget != null ? '-CausedException' : ''}',
                          ).dispatch(context);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            createDartBlockInfoSnackBar(
                              context,
                              iconData: Icons.check,
                              message:
                                  "Saved '${value.statementType.toString()}' statement.",
                            ),
                          );
                          onChanged(value);
                        },
                      ).showAsModalBottomSheet(context);
                    case 'cut':
                      DartBlockInteraction.create(
                        dartBlockInteractionType:
                            DartBlockInteractionType.cutStatement,
                        content:
                            'StatementType-${statement.statementType.name}-StatementId-${statement.statementId}${exceptionWidget != null ? '-CausedException' : ''}',
                      ).dispatch(context);
                      onCopyStatement(statement, true);
                      break;
                    case 'copy':
                      DartBlockInteraction.create(
                        dartBlockInteractionType:
                            DartBlockInteractionType.copyStatement,
                        content:
                            'StatementType-${statement.statementType.name}-StatementId-${statement.statementId}${exceptionWidget != null ? '-CausedException' : ''}',
                      ).dispatch(context);
                      onCopyStatement(statement, false);
                      break;
                    case 'paste':
                      if (neoTechCoreInheritedWidget.copiedStatement != null) {
                        DartBlockInteraction.create(
                          dartBlockInteractionType: DartBlockInteractionType
                              .pasteStatementOnExistingStatement,
                        ).dispatch(context);
                        onPasteStatement(
                          neoTechCoreInheritedWidget.copiedStatement!,
                        );
                      }
                      break;
                    case 'duplicate':
                      DartBlockInteraction.create(
                        dartBlockInteractionType:
                            DartBlockInteractionType.duplicateStatement,
                        content:
                            'StatementType-${statement.statementType.name}-StatementId-${statement.statementId}${exceptionWidget != null ? '-CausedException' : ''}',
                      ).dispatch(context);
                      onDuplicate(statement);
                      ScaffoldMessenger.of(context).showSnackBar(
                        createDartBlockInfoSnackBar(
                          context,
                          iconData: Icons.copy,
                          message:
                              "Duplicated '${statement.statementType.toString()}' statement.",
                        ),
                      );
                      break;
                    case 'delete':
                      DartBlockInteraction.create(
                        dartBlockInteractionType:
                            DartBlockInteractionType.deleteStatement,
                        content:
                            'StatementType-${statement.statementType.name}-StatementId-${statement.statementId}${exceptionWidget != null ? '-CausedException' : ''}',
                      ).dispatch(context);
                      onDelete(statement);
                      ScaffoldMessenger.of(context).showSnackBar(
                        createDartBlockInfoSnackBar(
                          context,
                          iconData: Icons.delete,
                          message:
                              "Deleted '${statement.statementType.toString()}' statement.",
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.errorContainer,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      );
                      break;
                  }
                }
              }
            });
          }
        },
        child: isStatementBlock
            ? Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                elevation: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (iconData != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(iconData, size: 14),
                            ),
                          Flexible(
                            child: Text(
                              label,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      child: widget,
                    ),
                  ],
                ),
              )
            : ToolboxDragTarget(
                isEnabled: onAppendNewStatement != null,
                nodeKey: statement.hashCode,
                isToolboxItemBeingDragged:
                    neoTechCoreInheritedWidget?.isDraggingToolboxItem,
                onSaved: (newStatement) {
                  // Navigator.of(context).pop();
                  if (onAppendNewStatement != null) {
                    onAppendNewStatement!(newStatement);
                  }
                },
                builder: (p0, candidateData, p2) {
                  return Stack(
                    children: [
                      Row(
                        children: [
                          if (exceptionWidget != null) ...[
                            exceptionWidget,
                            const SizedBox(width: 4),
                          ],
                          if (showLabel) ...[
                            _buildLabel(context, label),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: widget,
                            ),
                          ),
                        ],
                      ),
                      if (candidateData.isNotEmpty)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withValues(alpha: 0.9),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.format_list_bulleted_add,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: FittedBox(
                                    child: Text(
                                      candidateData.first!.describeAdd(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.apply(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onPrimaryContainer,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodySmall),
    );
  }

  Future<String?> _showMoreOptions(
    BuildContext context, {
    required RelativeRect position,
    bool canEdit = true,
    bool canDuplicate = true,
    bool canCopy = true,
    bool canPaste = false,
    bool canDelete = true,
  }) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return showCupertinoModalPopup<String?>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: Text(statement.statementType.toString()),
          actions: <CupertinoActionSheetAction>[
            if (canEdit)
              CupertinoActionSheetAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context, 'edit');
                },
                child: const Text('Edit...'),
              ),
            if (canDuplicate)
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context, 'duplicate');
                },
                child: const Text('Duplicate'),
              ),
            if (canCopy)
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context, 'cut');
                },
                child: const Text('Cut'),
              ),
            if (canCopy)
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context, 'copy');
                },
                child: const Text('Copy'),
              ),
            if (canPaste)
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context, 'paste');
                },
                child: const Text('Paste'),
              ),
            if (canDelete)
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(context, 'delete');
                },
                child: const Text('Delete'),
              ),
          ],
        ),
      );
    } else if (Theme.of(context).platform == TargetPlatform.android) {
      return showModalBottomSheet<String?>(
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
            child: Padding(
              padding: EdgeInsets.only(
                bottom: 16 + MediaQuery.of(sheetContext).viewInsets.bottom,
                top: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    statement.statementType.toString(),
                    style: Theme.of(sheetContext).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const Divider(),
                  if (canEdit)
                    ListTile(
                      title: Text(
                        "Edit...",
                        style: Theme.of(sheetContext).textTheme.bodyLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(sheetContext).colorScheme.primary,
                            ),
                      ),
                      leading: Icon(
                        Icons.copy,
                        color: Theme.of(sheetContext).colorScheme.primary,
                      ),
                      onTap: () {
                        Navigator.of(sheetContext).pop('edit');
                      },
                    ),
                  if (canDuplicate)
                    ListTile(
                      title: Text(
                        "Duplicate",
                        style: Theme.of(sheetContext).textTheme.bodyLarge,
                      ),
                      leading: const Icon(Icons.library_add_outlined),
                      onTap: () {
                        Navigator.of(sheetContext).pop('duplicate');
                      },
                    ),
                  if (canCopy)
                    ListTile(
                      title: Text(
                        "Cut",
                        style: Theme.of(sheetContext).textTheme.bodyLarge,
                      ),
                      leading: const Icon(Icons.cut),
                      onTap: () {
                        Navigator.of(sheetContext).pop('cut');
                      },
                    ),
                  if (canCopy)
                    ListTile(
                      title: Text(
                        "Copy",
                        style: Theme.of(sheetContext).textTheme.bodyLarge,
                      ),
                      leading: const Icon(Icons.copy),
                      onTap: () {
                        Navigator.of(sheetContext).pop('copy');
                      },
                    ),
                  if (canPaste)
                    ListTile(
                      title: Text(
                        "Paste",
                        style: Theme.of(sheetContext).textTheme.bodyLarge,
                      ),
                      leading: const Icon(Icons.paste),
                      onTap: () {
                        Navigator.of(sheetContext).pop('paste');
                      },
                    ),
                  if (canDelete)
                    ListTile(
                      title: Text(
                        "Delete",
                        style: Theme.of(sheetContext).textTheme.bodyLarge
                            ?.copyWith(
                              color: Theme.of(sheetContext).colorScheme.error,
                            ),
                      ),
                      leading: Icon(
                        Icons.delete,
                        color: Theme.of(sheetContext).colorScheme.error,
                      ),
                      onTap: () {
                        Navigator.of(sheetContext).pop('delete');
                      },
                    ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      final List<PopupMenuItem<String>> menuItems = [
        if (canEdit)
          PopupMenuItem(
            value: 'edit',
            child: ListTile(
              leading: Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text("Edit..."),
            ),
          ),
        if (canDuplicate)
          const PopupMenuItem(
            value: 'duplicate',
            child: ListTile(
              leading: Icon(Icons.library_add_outlined),
              title: Text("Duplicate"),
            ),
          ),
        if (canCopy)
          const PopupMenuItem(
            value: 'cut',
            child: ListTile(leading: Icon(Icons.cut), title: Text("Cut")),
          ),
        if (canCopy)
          const PopupMenuItem(
            value: 'copy',
            child: ListTile(leading: Icon(Icons.copy), title: Text("Copy")),
          ),
        if (canPaste)
          const PopupMenuItem(
            value: 'paste',
            child: ListTile(leading: Icon(Icons.paste), title: Text("Paste")),
          ),
        if (canDelete)
          PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              title: const Text("Delete"),
            ),
          ),
      ];

      /// Important: keep menuItems empty if there are no real actions, otherwise
      /// the StatementWidget will be tappable!
      if (menuItems.isNotEmpty) {
        menuItems.insert(
          0,
          PopupMenuItem(
            height: 20,
            enabled: false,
            child: Text(statement.statementType.toString()),
          ),
        );
      } else {
        // If it's empty, an error will occur.
        menuItems.add(
          const PopupMenuItem(
            height: 20,
            enabled: false,
            child: Text('No actions available.'),
          ),
        );
      }

      return showMenu<String?>(
        context: context,
        position: position,
        items: menuItems,
      );
    }
  }
}
