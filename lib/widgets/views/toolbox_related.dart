import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartblock_code/models/dartblock_interaction.dart';
import 'package:dartblock_code/models/dartblock_notification.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/editors/statement.dart';
import 'package:dartblock_code/widgets/dartblock_editor.dart';

class ToolboxDragTarget extends StatelessWidget {
  final int neoTechCoreNodeKey;
  final Function(Statement) onSaved;
  final bool isEnabled;
  final ValueNotifier<bool>? isToolboxItemBeingDragged;
  final Widget Function(BuildContext, List<StatementType?>, List<dynamic>)?
  builder;
  final Function()? onPasteStatement;
  const ToolboxDragTarget({
    super.key,
    required this.neoTechCoreNodeKey,
    required this.onSaved,
    required this.isEnabled,
    required this.isToolboxItemBeingDragged,
    this.onPasteStatement,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<StatementType>(
      onWillAcceptWithDetails: (data) {
        if (!isEnabled) {
          return false;
        }

        return true;
      },
      onAcceptWithDetails: (dragTargetDetails) {
        DartBlockInteraction.create(
          dartBlockInteractionType: builder != null
              ? DartBlockInteractionType
                    .droppedStatementFromToolboxToExistingStatement
              : DartBlockInteractionType
                    .droppedStatementFromToolboxToDragTarget,
          content: 'StatementType-${dragTargetDetails.data.name}',
        ).dispatch(context);
        _onSelectStatementTypeToCreate(context, dragTargetDetails.data);
      },
      builder:
          builder ??
          (dragTargetContext, candidateData, rejectedData) {
            return InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                DartBlockInteraction.create(
                  dartBlockInteractionType:
                      DartBlockInteractionType.tapToolboxDragTarget,
                ).dispatch(context);
                showModalBottomSheet(
                  isScrollControlled: true,
                  clipBehavior: Clip.hardEdge,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  context: dragTargetContext,
                  builder: (modalSheetContext) {
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
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: StatementTypePicker(
                            onSelect: (statementType) {
                              Navigator.of(modalSheetContext).pop();
                              HapticFeedback.lightImpact();
                              _onSelectStatementTypeToCreate(
                                context,
                                statementType,
                              );
                            },
                            onPasteStatement: onPasteStatement != null
                                ? () {
                                    Navigator.of(modalSheetContext).pop();
                                    HapticFeedback.mediumImpact();
                                    onPasteStatement!();
                                  }
                                : null,
                          ),
                        ),
                      ),
                    );
                  },
                );
                // ScaffoldMessenger.of(context).showSnackBar(
                //     createDartBlockInfoSnackBar(context,
                //         iconData: Icons.edit,
                //         message:
                //             "Drag a new statement here from the Toolbox!"));
              },
              child: ToolboxDragTargetIndicator(
                statementType: candidateData.isNotEmpty
                    ? candidateData.first
                    : null,
                isToolboxItemBeingDragged: isToolboxItemBeingDragged,
              ),
            );
          },
    );
  }

  void _onSelectStatementTypeToCreate(
    BuildContext context,
    StatementType statementType,
  ) {
    final neoTechCoreInheritedWidget = DartBlockEditorInheritedWidget.of(
      context,
    );
    final neoTechCoreTree = neoTechCoreInheritedWidget.program.buildTree();
    final existingVariableDefinitions = neoTechCoreTree.findVariableDefinitions(
      neoTechCoreNodeKey,
      includeNode: true,
    );
    switch (statementType) {
      case StatementType.breakStatement:
        final breakStatement = BreakStatement.init();
        DartBlockInteraction.create(
          dartBlockInteractionType: DartBlockInteractionType.createdStatement,
          content:
              'StatementType-${breakStatement.statementType.name}-StatementId-${breakStatement.statementId}',
        ).dispatch(context);
        // No editing needed, just directly add BreakStatement.
        onSaved(breakStatement);
        break;
      case StatementType.continueStatement:
        final continueStatement = ContinueStatement.init();
        DartBlockInteraction.create(
          dartBlockInteractionType: DartBlockInteractionType.createdStatement,
          content:
              'StatementType-${continueStatement.statementType.name}-StatementId-${continueStatement.statementId}',
        ).dispatch(context);
        // No editing needed, just directly add ContinueStatement.
        onSaved(continueStatement);
        break;
      default:
        StatementEditor.create(
          statementType: statementType,
          existingVariableDefinitions: existingVariableDefinitions,
          customFunctions: neoTechCoreInheritedWidget.program.customFunctions,

          /// DO NOT call Navigator.of(context).pop(); here, e.g., onSaved: (newStatement){Navigator.of(context).pop();onSaved(newStatement);}
          /// This can cause a context disposal error in certain cases.
          /// UPDATE: This now seems to work after all...
          onSaved: (newStatement) {
            DartBlockInteraction.create(
              dartBlockInteractionType:
                  DartBlockInteractionType.createdStatement,
              content:
                  'StatementType-${newStatement.statementType.name}-StatementId-${newStatement.statementId}',
            ).dispatch(context);
            Navigator.of(context).pop();
            onSaved(newStatement);
          },
        ).showAsModalBottomSheet(context);
        break;
    }
  }
}

class ToolboxDragTargetIndicator extends StatelessWidget {
  final StatementType? statementType;
  final ValueNotifier<bool>? isToolboxItemBeingDragged;
  const ToolboxDragTargetIndicator({
    super.key,
    required this.statementType,
    this.isToolboxItemBeingDragged,
  });

  @override
  Widget build(BuildContext context) {
    if (isToolboxItemBeingDragged != null) {
      return ListenableBuilder(
        listenable: isToolboxItemBeingDragged!,
        builder: (context, child) {
          return _buildBody(
            context,
            isGlowing: isToolboxItemBeingDragged!.value,
          );
        },
      );
    } else {
      return _buildBody(context);
    }
  }

  Widget _buildBody(BuildContext context, {bool isGlowing = false}) {
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        border: Border.all(
          width: 0.5,
          color: Theme.of(context).colorScheme.primary,
        ),
        borderRadius: BorderRadius.circular(12),
        color: statementType == null
            ? isGlowing
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.primary,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: statementType == null
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Icon(
            Icons.add,
            color: statementType == null
                ? isGlowing
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onPrimary,
          ),
          if (statementType != null) ...[
            const SizedBox(width: 4),
            Flexible(
              child: FittedBox(
                child: Text(
                  (statementType!.describeAdd()),
                  style: Theme.of(context).textTheme.bodyMedium?.apply(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
