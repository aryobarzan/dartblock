import 'package:dartblock_code/widgets/dartblock_editor_providers.dart';
import 'package:flutter/material.dart';
import 'package:dartblock_code/models/function.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:dartblock_code/widgets/dartblock_value_widgets.dart';
import 'package:dartblock_code/widgets/views/statement_listview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WhileLoopStatementWidget extends ConsumerWidget {
  final WhileLoopStatement statement;
  final bool canDelete;
  final bool canChange;
  final bool canReorder;
  final Function(WhileLoopStatement) onChanged;
  final Function(Statement statement, bool cut) onCopiedStatement;
  final Function() onPastedStatement;
  final List<DartBlockCustomFunction> customFunctions;
  const WhileLoopStatementWidget({
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
    final settings = ref.watch(settingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              if (!statement.isDoWhile)
                Row(
                  children: [
                    ColoredTitleChip(
                      title: "While",
                      color: Colors.transparent,
                      textColor: Theme.of(context).colorScheme.onSurface,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DartBlockValueWidget(
                          value: statement.condition,
                          isInteractive: false,
                          border: Border.all(
                            color: settings.colorFamily.boolean.color,
                          ),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: statement.isDoWhile
                        ? const Radius.circular(12)
                        : Radius.zero,
                    topRight: const Radius.circular(12),
                    bottomRight: const Radius.circular(12),
                    bottomLeft: statement.isDoWhile
                        ? Radius.zero
                        : const Radius.circular(12),
                  ),
                  border: Border.all(
                    width: 1,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: StatementListView(
                  neoTechCoreNodeKey: statement.bodyStatements.isNotEmpty
                      ? statement.bodyStatements.last.hashCode
                      : statement.hashCode,
                  statements: statement.bodyStatements,
                  canDelete: canDelete,
                  canReorder: canReorder,
                  onChanged: (newStatements) {
                    statement.bodyStatements = newStatements;
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
                  onCopiedStatement: onCopiedStatement,
                  onPastedStatement: onPastedStatement,
                ),
              ),
              if (statement.isDoWhile)
                Row(
                  children: [
                    ColoredTitleChip(
                      title: "While",
                      color: Colors.transparent,
                      textColor: Theme.of(context).colorScheme.onSurface,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DartBlockValueWidget(
                          value: statement.condition,
                          isInteractive: false,
                          border: Border.all(
                            color: settings.colorFamily.boolean.color,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
