import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:dartblock/models/dartblock_notification.dart';
part 'dartblock_interaction.g.dart';

@JsonSerializable()
class DartBlockInteraction {
  final DartBlockInteractionType dartBlockInteractionType;
  final DateTime timestamp;
  final String content;
  DartBlockInteraction.create({
    required this.dartBlockInteractionType,
    this.content = '',
  }) : timestamp = DateTime.now();

  DartBlockInteraction(
    this.dartBlockInteractionType,
    this.content,
    this.timestamp,
  );

  factory DartBlockInteraction.fromJson(Map<String, dynamic> json) =>
      _$DartBlockInteractionFromJson(json);
  Map<String, dynamic> toJson() => _$DartBlockInteractionToJson(this);

  @override
  int get hashCode => timestamp.hashCode;

  @override
  bool operator ==(Object other) {
    return other is DartBlockInteraction &&
        timestamp == other.timestamp &&
        dartBlockInteractionType == other.dartBlockInteractionType &&
        content == other.content;
  }

  @override
  String toString() {
    return "DartBlock interaction: ${dartBlockInteractionType.name} ($content)";
  }

  void dispatch(BuildContext context) {
    DartBlockInteractionNotification(this).dispatch(context);
  }
}

@JsonEnum()
enum DartBlockInteractionType {
  tapExceptionIndicatorInToolbox,
  tapExceptionIndicatorOnCausingStatement,
  executedProgram,

  /// Special: this is not necessarily a user interaction, but it results automatically
  /// after the user's 'exectedProgram' interaction in case the program's execution
  /// is interrupted by an exception being thrown.
  executedProgramInterruptedByException,
  openHelpCenter,
  viewHelpCenterItem,
  openConsole,
  viewScript,
  copyScript,
  saveScriptToFile,
  returnToEditorFromScriptView,
  undockToolbox,
  dockToolbox,
  startDraggingUndockedToolbox,
  finishDraggingUndockedToolbox,
  changeToolboxTab,
  openNewFunctionEditorFromToolbox,
  openNewFunctionEditorFromCanvas,
  editFunction,
  createdFunction,
  editedFunction,
  deletedFunction,
  createFunctionParameter,
  createdFunctionParameter,
  editFunctionParameter,
  editedFunctionParameter, // test
  deletedFunctionParameter,
  tapMainFunctionHeader,
  startedDraggingStatementFromToolbox,
  droppedStatementFromToolboxToDragTarget,
  droppedStatementFromToolboxToExistingStatement, // 1 - check if not duplicated
  tapToolboxDragTarget,
  tapStatementFromStatementPicker,
  createdStatement,
  tapStatement,
  editStatement,
  editedStatement,
  copyStatement,
  cutStatement,
  duplicateStatement,
  deleteStatement,
  pasteStatementOnExistingStatement,
  pasteStatementToToolboxDragTarget,
  startedDraggingStatementToReorder,
  reorderedStatement,
  changeWhileLoopType,
  tapNumberComposerConstant,
  tapNumberComposerDecimalPoint,
  tapNumberComposerOperator,
  tapNumberComposerNegate,
  tapNumberComposerBackspace,
  tapNumberComposerUndo,
  tapNumberComposerRedo,
  tapNumberComposerFunctionCall,
  tapNumberComposerVariablePicker,
  saveNumberComposerFunctionCall,
  pickNumberComposerVariable,
  changeNumberComposerOperatorThroughNode,
  selectNumberComposerValueNode,
  deselectNumberComposerValueNode,
  swipeNumberComposerValueToBackspace,
  tapBooleanComposerConstant,
  tapBooleanComposerBackspace,
  tapBooleanComposerUndo,
  tapBooleanComposerRedo,
  tapBooleanComposerFunctionCall,
  tapBooleanComposerVariablePicker,
  tapBooleanComposerLogicalOperator,
  tapBooleanComposerEqualityOperator,
  tapBooleanComposerNumberComparisonOperator,
  tapBooleanComposerTextToggleToShow,
  tapBooleanComposerTextToggleToHide,
  tapBooleanComposerNumberToggleToShow,
  tapBooleanComposerNumberToggleToHide,
  changeBooleanComposerLogicalOperatorThroughNode,
  changeBooleanComposerEqualityOperatorThroughNode,
  changeBooleanComposerNumberComparisonOperatorThroughNode,
  selectBooleanComposerValueNode,
  deselectBooleanComposerValueNode,
  swipeBooleanComposerValueToBackspace,
  saveBooleanComposerFunctionCall,
  pickBooleanComposerVariable,
  tapConcatenationValueComposerBackspace,
  tapConcatenationValueComposerUndo,
  tapConcatenationValueComposerRedo,
  tapConcatenationValueComposerTextToggleToShow,
  tapConcatenationValueComposerTextToggleToHide,
  tapConcatenationValueComposerFunctionCallToggleToShow,
  tapConcatenationValueComposerFunctionCallToggleToHide,
  tapConcatenationValueComposerVariablePickerToggleToShow,
  tapConcatenationValueComposerVariablePickerToggleToHide,
  tapConcatenationValueComposerNumberToggleToShow,
  tapConcatenationValueComposerNumberToggleToHide,
  tapConcatenationValueComposerBooleanToggleToShow,
  tapConcatenationValueComposerBooleanToggleToHide,
  selectConcatenationValueComposerValueNode,
  deselectConcatenationValueComposerValueNode,
  reorderConcatenationValueComposerValueNode,
  addElseIfBlockToIfThenElseStatement,
  deleteElseIfBlockToIfThenElseStatement,
  reorderElseIfBlockOfIfThenElseStatement,
}
