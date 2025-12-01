import 'package:flutter/material.dart';
import 'package:dartblock_code/models/function.dart';
import 'package:dartblock_code/models/dartblock_notification.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/editors/for_loop.dart';
import 'package:dartblock_code/widgets/editors/function_call.dart';
import 'package:dartblock_code/widgets/editors/if_else_then.dart';
import 'package:dartblock_code/widgets/editors/print.dart';
import 'package:dartblock_code/widgets/editors/return.dart';
import 'package:dartblock_code/widgets/editors/variable_assignment.dart';
import 'package:dartblock_code/widgets/editors/variable_declaration.dart';
import 'package:dartblock_code/widgets/editors/while_loop.dart';
import 'package:dartblock_code/widgets/helpers/provider_aware_modal.dart';

class StatementEditor extends StatelessWidget {
  final StatementType statementType;
  final Statement? statement;
  final List<DartBlockVariableDefinition> existingVariableDefinitions;
  final List<DartBlockCustomFunction> customFunctions;
  final Function(Statement) onSaved;
  const StatementEditor.create({
    super.key,
    required this.statementType,
    required this.existingVariableDefinitions,
    required this.customFunctions,
    required this.onSaved,
  }) : statement = null;
  StatementEditor.edit({
    super.key,
    required Statement this.statement,
    required this.existingVariableDefinitions,
    required this.customFunctions,
    required this.onSaved,
  }) : statementType = statement.statementType;

  @override
  Widget build(BuildContext context) {
    switch (statementType) {
      case StatementType.variableDeclarationStatement:
        return VariableDeclarationEditor(
          onSaved: (savedStatement) {
            onSaved(savedStatement);
          },
          existingVariableDefinitions: existingVariableDefinitions,
          customFunctions: customFunctions,
          statement:
              statement != null && statement is VariableDeclarationStatement
              ? statement as VariableDeclarationStatement
              : null,
        );
      case StatementType.variableAssignmentStatement:
        return VariableAssignmentEditor(
          onSaved: (savedStatement) {
            onSaved(savedStatement);
          },
          existingVariableDefinitions: existingVariableDefinitions,
          customFunctions: customFunctions,
          statement:
              statement != null && statement is VariableAssignmentStatement
              ? statement as VariableAssignmentStatement
              : null,
        );
      case StatementType.forLoopStatement:
        return ForLoopStatementEditor(
          onSaved: (savedStatement) {
            onSaved(savedStatement);
          },
          existingVariableDefinitions: existingVariableDefinitions,
          customFunctions: customFunctions,
          statement: statement != null && statement is ForLoopStatement
              ? statement as ForLoopStatement
              : null,
        );
      case StatementType.whileLoopStatement:
        return WhileLoopStatementEditor(
          onSaved: (savedStatement) {
            onSaved(savedStatement);
          },
          existingVariableDefinitions: existingVariableDefinitions,
          customFunctions: customFunctions,
          statement: statement != null && statement is WhileLoopStatement
              ? statement as WhileLoopStatement
              : null,
        );
      case StatementType.ifElseStatement:
        return IfElseStatementEditor(
          existingVariableDefinitions: existingVariableDefinitions,
          customFunctions: customFunctions,
          onSaved: onSaved,
          statement: statement != null && statement is IfElseStatement
              ? statement as IfElseStatement
              : null,
        );
      case StatementType.customFunctionCallStatement:
        return FunctionCallComposer(
          statement: statement != null && statement is FunctionCallStatement
              ? statement as FunctionCallStatement
              : null,
          customFunctions: customFunctions,
          restrictToDataTypes: const [],
          existingVariableDefinitions: existingVariableDefinitions,
          onSaved: (customFunction, savedStatement) {
            onSaved(savedStatement);
          },
        );
      case StatementType.printStatement:
        return PrintStatementEditor(
          onSaved: (savedStatement) {
            onSaved(savedStatement);
          },
          existingVariableDefinitions: existingVariableDefinitions,
          customFunctions: customFunctions,
          statement: statement != null && statement is PrintStatement
              ? statement as PrintStatement
              : null,
        );
      case StatementType.returnStatement:
        return ReturnStatementEditor(
          onSaved: (savedStatement) {
            onSaved(savedStatement);
          },
          existingVariableDefinitions: existingVariableDefinitions,
          customFunctions: customFunctions,
          statement: statement != null && statement is ReturnStatement
              ? statement as ReturnStatement
              : null,
        );
      case StatementType.statementBlockStatement:
        break;
      case StatementType.breakStatement:
        return const Text("Break statements are not editable.");
      case StatementType.continueStatement:
        return const Text("Continue statements are not editable.");
    }

    return Text("Editor not available: $statementType");
  }

  void showAsModalBottomSheet(BuildContext sheetContext) {
    sheetContext.showProviderAwareBottomSheet(
      isScrollControlled: true,
      clipBehavior: Clip.hardEdge,

      /// Due to a Flutter issue, the bottom sheet cannot be dragged down to dismiss it once its content fills the screen height.
      /// Until it has been fixed, the drag handle should be shown such that the user can still dismiss the sheet by dragging the handle at the top.
      /// https://github.com/flutter/flutter/issues/36283
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.0)),
      ),
      builder: (context) {
        /// Due to the modal sheet having a separate context and thus no relation
        /// to the main context of the NeoTechWidget, we capture DartBlockNotifications
        /// from the sheet's context and manually re-dispatch them using the parent context.
        /// The parent context may not necessarily be the NeoTechWidget's context,
        /// as certain sheets open additional nested sheets with their own contexts,
        /// hence this process needs to be repeated for every sheet until the NeoTechWidget's
        /// context is reached.
        return NotificationListener<DartBlockNotification>(
          onNotification: (notification) {
            notification.dispatch(sheetContext);
            return true;
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 8,
                right: 8,
                top: 8 + MediaQuery.of(context).viewInsets.top,
                bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: this,
            ),
          ),
        );
        // return DraggableScrollableSheet(
        //   initialChildSize: 0.75,
        //   minChildSize: 0.13,
        //   maxChildSize: 0.9,
        //   expand: false,
        //   builder: (context, scrollController) => SingleChildScrollView(
        //     controller: scrollController,
        //     child: Padding(
        //       padding: const EdgeInsets.all(8),
        //       child: this,
        //     ),
        //   ),
        // );
      },
    );
  }
}
