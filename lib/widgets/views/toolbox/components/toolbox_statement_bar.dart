import 'dart:math';

import 'package:dartblock_code/widgets/views/toolbox/components/toolbox_statement_type.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:dartblock_code/models/statement.dart';
import '../models/toolbox_configuration.dart';

/// The statement types which can be dragged from the [DartBlockToolbox] to [ToolboxDragTarget]s.
class ToolboxStatementTypeBar extends StatelessWidget {
  final Function()? onDragStart;
  final Function()? onDragEnd;
  final ScrollController scrollController;

  const ToolboxStatementTypeBar({
    super.key,
    this.onDragStart,
    this.onDragEnd,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int maxRows = max(
          1,
          min(
            4,
            (constraints.maxHeight / (ToolboxConfig.minTouchSize)).floor(),
          ),
        );
        double itemHeight =
            8 + ToolboxConfig.minTouchSize; // Internal padding + icon size
        double runSpacing = 8;
        final double maxHeight =
            maxRows * itemHeight + (maxRows - 1) * runSpacing;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          // Constrain the height of the container
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              physics: const BouncingScrollPhysics(),
              dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 8),
              scrollDirection: maxRows == 1 ? Axis.horizontal : Axis.vertical,
              child: Wrap(
                spacing: 8,
                runSpacing: runSpacing,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                runAlignment: WrapAlignment.start,
                children: _buildAllStatementTypeWidgets(context),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildCategorySection(
    BuildContext context, {
    required Color color,
    required List<StatementType> statementTypes,
    required String categoryName,
  }) {
    return statementTypes
        .map(
          (type) => Padding(
            padding: EdgeInsets
                .zero, //const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: DartBlockToolboxStatementTypeWidget(
              statementType: type,
              categoryColor: color,
              onDragStart: onDragStart,
              onDragEnd: onDragEnd,
            ),
          ),
        )
        .toList();
  }

  List<Widget> _buildAllStatementTypeWidgets(BuildContext context) {
    return [
      ..._buildCategorySection(
        context,
        color: ToolboxConfig.categoryColors['variables']!,
        statementTypes: [
          StatementType.variableDeclarationStatement,
          StatementType.variableAssignmentStatement,
        ],
        categoryName: 'Variables',
      ),

      // Loops section
      ..._buildCategorySection(
        context,
        color: ToolboxConfig.categoryColors['loops']!,
        statementTypes: [
          StatementType.forLoopStatement,
          StatementType.whileLoopStatement,
          StatementType.breakStatement,
          StatementType.continueStatement,
        ],
        categoryName: 'Loops',
      ),

      // Logic section
      ..._buildCategorySection(
        context,
        color: ToolboxConfig.categoryColors['logic']!,
        statementTypes: [StatementType.ifElseStatement],
        categoryName: 'Logic',
      ),

      // 'Functions' section
      ..._buildCategorySection(
        context,
        color: ToolboxConfig.categoryColors['functions']!,
        statementTypes: [
          StatementType.customFunctionCallStatement,
          StatementType.returnStatement,
        ],
        categoryName: 'Functions',
      ),
      // 'Other' section
      ..._buildCategorySection(
        context,
        color: ToolboxConfig.categoryColors['other']!,
        statementTypes: [StatementType.printStatement],
        categoryName: 'Other',
      ),
    ];
  }
}
