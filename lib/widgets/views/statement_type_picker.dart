import 'package:collection/collection.dart';
import 'package:dartblock_code/widgets/views/toolbox/models/toolbox_configuration.dart';
import 'package:flutter/material.dart';
import 'package:dartblock_code/models/dartblock_interaction.dart';
import 'package:dartblock_code/models/statement.dart';

class StatementTypePicker extends StatelessWidget {
  final Function(StatementType statementType) onSelect;
  final Function()? onPasteStatement;
  const StatementTypePicker({
    super.key,
    required this.onSelect,
    this.onPasteStatement,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...StatementType.values
            .whereNot(
              (statementType) =>
                  statementType == StatementType.statementBlockStatement,
            )
            .sorted((a, b) => a.getOrderValue().compareTo(b.getOrderValue()))
            .map(
              (statementType) => _StatementTypeCard(
                statementType: statementType,
                onTap: () {
                  DartBlockInteraction.create(
                    dartBlockInteractionType: DartBlockInteractionType
                        .tapStatementFromStatementPicker,
                    content: 'StatementType-${statementType.name}',
                  ).dispatch(context);
                  onSelect(statementType);
                },
              ),
            ),
        if (onPasteStatement != null)
          _StatementPasteCard(
            onTap: () {
              DartBlockInteraction.create(
                dartBlockInteractionType:
                    DartBlockInteractionType.pasteStatementToToolboxDragTarget,
              ).dispatch(context);
              onPasteStatement!();
            },
          ),
      ],
    );
  }
}

class _StatementTypeCard extends StatelessWidget {
  final StatementType statementType;
  final Function onTap;
  const _StatementTypeCard({required this.statementType, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110, //80
      height: 72,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          onTap();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                statementType.getIconData(),
                size: 18,
                color:
                    ToolboxConfig.categoryColors[statementType.getCategory()],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              statementType.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatementPasteCard extends StatelessWidget {
  final Function onTap;
  const _StatementPasteCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 72,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          onTap();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                border: Border.all(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.paste,
                size: 18,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Paste",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.apply(
                color: Theme.of(context).colorScheme.primary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
