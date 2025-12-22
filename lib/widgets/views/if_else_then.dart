import 'package:collection/collection.dart';
import 'package:dartblock_code/widgets/dartblock_editor_providers.dart';
import 'package:flutter/material.dart';
import 'package:dartblock_code/models/function.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:dartblock_code/widgets/dartblock_value_widgets.dart';
import 'package:dartblock_code/widgets/views/statement_listview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IfElseStatementWidget extends ConsumerWidget {
  final IfElseStatement statement;
  final bool canDelete;
  final bool canChange;
  final bool canReorder;
  final Function(IfElseStatement) onChanged;
  final Function(Statement statement, bool cut) onCopiedStatement;
  final Function() onPastedStatement;
  final List<DartBlockCustomFunction> customFunctions;
  const IfElseStatementWidget({
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 4,
                children: [
                  ColoredTitleChip(
                    title: "If",
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
                        value: statement.ifCondition,
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
                constraints: const BoxConstraints(minHeight: 16),
                padding: statement.ifThenStatementBlock.statements.isEmpty
                    ? const EdgeInsets.all(1)
                    : const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  border: Border.all(
                    width: 1,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Column(
                  children: [
                    StatementListView(
                      neoTechCoreNodeKey:
                          statement.ifThenStatementBlock.statements.isNotEmpty
                          ? statement
                                .ifThenStatementBlock
                                .statements
                                .last
                                .hashCode
                          : statement.hashCode,
                      statements: statement.ifThenStatementBlock.statements,
                      canDelete: canDelete,
                      canReorder: canReorder,
                      onChanged: (newStatements) {
                        statement.ifThenStatementBlock.statements =
                            newStatements;
                        onChanged(statement);
                      },
                      onDuplicate: (index) {
                        final duplicatedStatement = statement
                            .ifThenStatementBlock
                            .statements[index]
                            .copy();
                        if (index <
                            statement.ifThenStatementBlock.statements.length -
                                1) {
                          statement.ifThenStatementBlock.statements.insert(
                            index + 1,
                            duplicatedStatement,
                          );
                        } else {
                          statement.ifThenStatementBlock.statements.add(
                            duplicatedStatement,
                          );
                        }
                        onChanged(statement);
                      },
                      onCopiedStatement: onCopiedStatement,
                      onPastedStatement: onPastedStatement,
                    ),
                  ],
                ),
              ),
              ...statement.elseIfStatementBlocks.mapIndexed(
                (index, element) =>
                    _buildElseIfStatementBlock(context, ref, index),
              ),
              if (statement.elseIfStatementBlocks.isEmpty)
                _buildVerticalLine(context),
              Row(
                children: [
                  ColoredTitleChip(
                    title: "Else",
                    color: Colors.transparent,
                    textColor: Theme.of(context).colorScheme.onSurface,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                ],
              ),
              Container(
                constraints: const BoxConstraints(minHeight: 16),
                padding: statement.elseStatementBlock.statements.isEmpty
                    ? const EdgeInsets.all(1)
                    : const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  border: Border.all(
                    width: 1,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Column(
                  children: [
                    StatementListView(
                      neoTechCoreNodeKey:
                          statement.elseStatementBlock.statements.isNotEmpty
                          ? statement
                                .elseStatementBlock
                                .statements
                                .last
                                .hashCode
                          : statement.hashCode,
                      statements: statement.elseStatementBlock.statements,
                      canDelete: canDelete,
                      canReorder: canReorder,
                      onChanged: (newStatements) {
                        statement.elseStatementBlock.statements = newStatements;
                        onChanged(statement);
                      },
                      onDuplicate: (index) {
                        final duplicatedStatement = statement
                            .elseStatementBlock
                            .statements[index]
                            .copy();
                        if (index <
                            statement.elseStatementBlock.statements.length -
                                1) {
                          statement.elseStatementBlock.statements.insert(
                            index + 1,
                            duplicatedStatement,
                          );
                        } else {
                          statement.elseStatementBlock.statements.add(
                            duplicatedStatement,
                          );
                        }
                        onChanged(statement);
                      },
                      onCopiedStatement: onCopiedStatement,
                      onPastedStatement: onPastedStatement,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalLine(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Row(
        children: [
          Container(
            height: 12,
            width: 1,
            color: Theme.of(context).colorScheme.outline,
          ),
        ],
      ),
    );
  }

  Widget _buildElseIfStatementBlock(
    BuildContext context,
    WidgetRef ref,
    int blockIndex,
  ) {
    final settings = ref.watch(settingsProvider);
    final (condition, statementBlock) =
        statement.elseIfStatementBlocks[blockIndex];
    return Column(
      children: [
        _buildVerticalLine(context),
        Row(
          children: [
            ColoredTitleChip(
              title: "Else-If",
              color: Colors.transparent,
              textColor: Theme.of(context).colorScheme.onSurface,
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DartBlockValueWidget(
                  value: condition,
                  isInteractive: false,
                  border: Border.all(color: settings.colorFamily.boolean.color),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        Container(
          constraints: const BoxConstraints(minHeight: 16),
          padding: statementBlock.statements.isEmpty
              ? const EdgeInsets.all(1)
              : const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Column(
            children: [
              StatementListView(
                neoTechCoreNodeKey: statementBlock.statements.isNotEmpty
                    ? statementBlock.statements.last.hashCode
                    : statement.hashCode,
                statements: statementBlock.statements,
                canDelete: canDelete,
                canReorder: canReorder,
                onChanged: (newStatements) {
                  statement.elseIfStatementBlocks[blockIndex].$2.statements =
                      newStatements;
                  onChanged(statement);
                },
                onDuplicate: (index) {
                  final duplicatedStatement = statement
                      .elseIfStatementBlocks[blockIndex]
                      .$2
                      .statements[index]
                      .copy();
                  if (index <
                      statement
                              .elseIfStatementBlocks[blockIndex]
                              .$2
                              .statements
                              .length -
                          1) {
                    statement.elseIfStatementBlocks[blockIndex].$2.statements
                        .insert(index + 1, duplicatedStatement);
                  } else {
                    statement.elseIfStatementBlocks[blockIndex].$2.statements
                        .add(duplicatedStatement);
                  }
                  onChanged(statement);
                },
                onCopiedStatement: onCopiedStatement,
                onPastedStatement: onPastedStatement,
              ),
            ],
          ),
        ),
        _buildVerticalLine(context),
      ],
    );
  }
}
