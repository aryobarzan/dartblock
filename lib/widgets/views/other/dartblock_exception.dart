import 'package:flutter/material.dart';
import 'package:dartblock_code/core/dartblock_program.dart';
import 'package:dartblock_code/models/exception.dart';
import 'package:dartblock_code/widgets/views/statement.dart';

class DartBlockExceptionWidget extends StatelessWidget {
  final DartBlockException dartblockException;

  /// IMPORTANT: if not specified, FunctionCallStatementWidgets are not properly visualized.
  /// This property is currently not populated by the NeoTechEvaluationResultWidget.
  final DartBlockProgram? program;
  const DartBlockExceptionWidget({
    super.key,
    required this.dartblockException,
    this.program,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: Theme.of(context).colorScheme.errorContainer,
      margin: const EdgeInsets.all(4),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 4),
                Text(
                  "Exception",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            Text(dartblockException.message),
            if (dartblockException.statement != null) ...[
              const Divider(),
              Text(
                "The exception was thrown by the following statement:",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),

              /// Important: do not allow interaction, e.g., taps, with this StatementWidget,
              /// as its internal tap handler tries to access NeoTechCoreInheritedWidget,
              /// which does not exist in its context and would hence throw an uncaught error.
              IgnorePointer(
                child: StatementWidget(
                  statement: dartblockException.statement!,
                  onChanged: (p0) {},
                  canDelete: false,
                  canChange: false,
                  canReorder: false,
                  includeBottomPadding: false,
                  onDelete: (p0) {},
                  onDuplicate: (statementToDuplicate) {},
                  onCopyStatement: (statement, cut) {},
                  onCopiedStatement: (statement, cut) {},
                  onPasteStatement: (statementToPaste) {},
                  onPastedStatement: () {},
                  onAppendNewStatement: null,
                  customFunctions: program?.customFunctions ?? [],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
