import 'package:dartblock_code/core/dartblock_program.dart';
import 'package:dartblock_code/widgets/dartblock_editor_providers.dart';
import 'package:dartblock_code/widgets/helpers/adaptive_display.dart';
import 'package:dartblock_code/widgets/views/statement_type_picker.dart';
import 'package:dartblock_code/widgets/views/toolbox/models/toolbox_configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartblock_code/models/dartblock_interaction.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/editors/statement.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget on which a [StatementType] can be dropped on to start creating a statement of that type and adding it to that location of the program.
///
/// Specifically, the user drags a [Draggable] from within the [StatementStrip] of the [DartBlockToolbox].
class ToolboxDragTarget extends ConsumerWidget {
  final int nodeKey;
  final Function(Statement) onSaved;
  final bool isEnabled;
  final Widget Function(BuildContext, List<StatementType?>, List<dynamic>)?
  builder;
  final Function()? onPasteStatement;
  const ToolboxDragTarget({
    super.key,
    required this.nodeKey,
    required this.onSaved,
    required this.isEnabled,
    this.onPasteStatement,
    this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final program = ref.watch(programProvider);
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
        _onSelectStatementTypeToCreate(
          context,
          dragTargetDetails.data,
          program,
        );
      },
      builder:
          builder ??
          (dragTargetContext, candidateData, rejectedData) {
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                HapticFeedback.lightImpact();
                DartBlockInteraction.create(
                  dartBlockInteractionType:
                      DartBlockInteractionType.tapToolboxDragTarget,
                ).dispatch(context);
                showAdaptiveBottomSheetOrDialog(
                  context,
                  sheetPadding: EdgeInsets.all(8),
                  dialogPadding: EdgeInsets.all(16),
                  useProviderAwareModal: true,
                  dialogTitle: Text(
                    "Add Statement",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  child: StatementTypePicker(
                    onSelect: (statementType) {
                      Navigator.of(context).pop();
                      HapticFeedback.lightImpact();
                      _onSelectStatementTypeToCreate(
                        context,
                        statementType,
                        program,
                      );
                    },
                    onPasteStatement: onPasteStatement != null
                        ? () {
                            Navigator.of(context).pop();
                            HapticFeedback.lightImpact();
                            onPasteStatement!();
                          }
                        : null,
                  ),
                );
              },
              child: ToolboxDragTargetIndicator(
                statementType: candidateData.isNotEmpty
                    ? candidateData.first
                    : null,
              ),
            );
          },
    );
  }

  void _onSelectStatementTypeToCreate(
    BuildContext context,
    StatementType statementType,
    DartBlockProgram program,
  ) {
    final dartBlockProgramTree = program.buildTree();
    final existingVariableDefinitions = dartBlockProgramTree
        .findVariableDefinitions(nodeKey, includeNode: true);
    switch (statementType) {
      case StatementType.breakStatement:
      case StatementType.continueStatement:
        final createdStatement = statementType == StatementType.breakStatement
            ? BreakStatement.init()
            : ContinueStatement.init();
        DartBlockInteraction.create(
          dartBlockInteractionType: DartBlockInteractionType.createdStatement,
          content:
              'StatementType-${createdStatement.statementType.name}-StatementId-${createdStatement.statementId}',
        ).dispatch(context);
        // No editing needed, just directly add ContinueStatement.
        onSaved(createdStatement);
        break;
      default:
        StatementEditor.create(
          statementType: statementType,
          existingVariableDefinitions: existingVariableDefinitions,
          customFunctions: program.customFunctions,

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

class ToolboxDragTargetIndicator extends ConsumerWidget {
  final StatementType? statementType;
  const ToolboxDragTargetIndicator({super.key, required this.statementType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDraggingToolboxItem = ref.watch(
      isDraggingStatementTypeFromToolboxProvider,
    );
    return _buildBody(
      context,
      isDraggingStatementTypeGlowing: isDraggingToolboxItem,
    );
  }

  Widget _buildBody(
    BuildContext context, {
    StatementType? isDraggingStatementTypeGlowing,
  }) {
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 1,
          color: statementType == null && isDraggingStatementTypeGlowing == null
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
        ),

        color: statementType == null
            ? isDraggingStatementTypeGlowing != null
                  ? ToolboxConfig.categoryColors[isDraggingStatementTypeGlowing
                        .getCategory()]
                  : null
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
                ? isDraggingStatementTypeGlowing != null
                      ? ToolboxConfig
                            .onCategoryColors[isDraggingStatementTypeGlowing
                            .getCategory()]
                      : Theme.of(context).colorScheme.primary
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
