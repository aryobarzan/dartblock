import 'package:dartblock_code/widgets/views/toolbox/components/toolbox_statement_type.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:dartblock_code/models/statement.dart';
import '../models/toolbox_configuration.dart';

/// The statement types which can be dragged from the [DartBlockToolbox] to [ToolboxDragTarget]s.
class ToolboxStatementTypePicker extends StatelessWidget {
  final Function()? onDragStart;
  final Function()? onDragEnd;
  final ScrollController scrollController;

  const ToolboxStatementTypePicker({
    super.key,
    this.onDragStart,
    this.onDragEnd,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ToolboxConfig.minTouchSize,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          physics: const BouncingScrollPhysics(),
          dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
        ),
        child: ListView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          children: [
            // Variables section
            _buildCategorySection(
              context,
              color: ToolboxConfig.categoryColors['variables']!,
              statements: [
                StatementType.variableDeclarationStatement,
                StatementType.variableAssignmentStatement,
              ],
              categoryName: 'Variables',
            ),

            // Loops section
            _buildCategorySection(
              context,
              color: ToolboxConfig.categoryColors['loops']!,
              statements: [
                StatementType.forLoopStatement,
                StatementType.whileLoopStatement,
                StatementType.breakStatement,
                StatementType.continueStatement,
              ],
              categoryName: 'Loops',
            ),

            // Logic section
            _buildCategorySection(
              context,
              color: ToolboxConfig.categoryColors['logic']!,
              statements: [StatementType.ifElseStatement],
              categoryName: 'Logic',
            ),

            // 'Other' section
            _buildCategorySection(
              context,
              color: ToolboxConfig.categoryColors['functions']!,
              statements: [
                StatementType.customFunctionCallStatement,
                StatementType.returnStatement,
                StatementType.printStatement,
              ],
              categoryName: 'Functions',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context, {
    required Color color,
    required List<StatementType> statements,
    required String categoryName,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...statements.map(
            (type) => DartBlockToolboxStatementTypeWidget(
              statementType: type,
              categoryColor: color,
              onDragStart: onDragStart,
              onDragEnd: onDragEnd,
            ),
          ),
        ],
      ),
    );
  }
}
