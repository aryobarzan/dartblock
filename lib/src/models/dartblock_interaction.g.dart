// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dartblock_interaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DartBlockInteraction _$DartBlockInteractionFromJson(
  Map<String, dynamic> json,
) => DartBlockInteraction(
  $enumDecode(
    _$DartBlockInteractionTypeEnumMap,
    json['dartBlockInteractionType'],
  ),
  json['content'] as String,
  DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$DartBlockInteractionToJson(
  DartBlockInteraction instance,
) => <String, dynamic>{
  'dartBlockInteractionType':
      _$DartBlockInteractionTypeEnumMap[instance.dartBlockInteractionType]!,
  'timestamp': instance.timestamp.toIso8601String(),
  'content': instance.content,
};

const _$DartBlockInteractionTypeEnumMap = {
  DartBlockInteractionType.tapExceptionIndicatorInToolbox:
      'tapExceptionIndicatorInToolbox',
  DartBlockInteractionType.tapExceptionIndicatorOnCausingStatement:
      'tapExceptionIndicatorOnCausingStatement',
  DartBlockInteractionType.executedProgram: 'executedProgram',
  DartBlockInteractionType.executedProgramInterruptedByException:
      'executedProgramInterruptedByException',
  DartBlockInteractionType.openHelpCenter: 'openHelpCenter',
  DartBlockInteractionType.viewHelpCenterItem: 'viewHelpCenterItem',
  DartBlockInteractionType.openConsole: 'openConsole',
  DartBlockInteractionType.viewScript: 'viewScript',
  DartBlockInteractionType.copyScript: 'copyScript',
  DartBlockInteractionType.saveScriptToFile: 'saveScriptToFile',
  DartBlockInteractionType.returnToEditorFromScriptView:
      'returnToEditorFromScriptView',
  DartBlockInteractionType.undockToolbox: 'undockToolbox',
  DartBlockInteractionType.dockToolbox: 'dockToolbox',
  DartBlockInteractionType.startDraggingUndockedToolbox:
      'startDraggingUndockedToolbox',
  DartBlockInteractionType.finishDraggingUndockedToolbox:
      'finishDraggingUndockedToolbox',
  DartBlockInteractionType.changeToolboxTab: 'changeToolboxTab',
  DartBlockInteractionType.openNewFunctionEditorFromToolbox:
      'openNewFunctionEditorFromToolbox',
  DartBlockInteractionType.openNewFunctionEditorFromCanvas:
      'openNewFunctionEditorFromCanvas',
  DartBlockInteractionType.editFunction: 'editFunction',
  DartBlockInteractionType.createdFunction: 'createdFunction',
  DartBlockInteractionType.editedFunction: 'editedFunction',
  DartBlockInteractionType.deletedFunction: 'deletedFunction',
  DartBlockInteractionType.createFunctionParameter: 'createFunctionParameter',
  DartBlockInteractionType.createdFunctionParameter: 'createdFunctionParameter',
  DartBlockInteractionType.editFunctionParameter: 'editFunctionParameter',
  DartBlockInteractionType.editedFunctionParameter: 'editedFunctionParameter',
  DartBlockInteractionType.deletedFunctionParameter: 'deletedFunctionParameter',
  DartBlockInteractionType.tapMainFunctionHeader: 'tapMainFunctionHeader',
  DartBlockInteractionType.startedDraggingStatementFromToolbox:
      'startedDraggingStatementFromToolbox',
  DartBlockInteractionType.droppedStatementFromToolboxToDragTarget:
      'droppedStatementFromToolboxToDragTarget',
  DartBlockInteractionType.droppedStatementFromToolboxToExistingStatement:
      'droppedStatementFromToolboxToExistingStatement',
  DartBlockInteractionType.tapToolboxDragTarget: 'tapToolboxDragTarget',
  DartBlockInteractionType.tapStatementFromStatementPicker:
      'tapStatementFromStatementPicker',
  DartBlockInteractionType.createdStatement: 'createdStatement',
  DartBlockInteractionType.tapStatement: 'tapStatement',
  DartBlockInteractionType.editStatement: 'editStatement',
  DartBlockInteractionType.editedStatement: 'editedStatement',
  DartBlockInteractionType.copyStatement: 'copyStatement',
  DartBlockInteractionType.cutStatement: 'cutStatement',
  DartBlockInteractionType.duplicateStatement: 'duplicateStatement',
  DartBlockInteractionType.deleteStatement: 'deleteStatement',
  DartBlockInteractionType.pasteStatementOnExistingStatement:
      'pasteStatementOnExistingStatement',
  DartBlockInteractionType.pasteStatementToToolboxDragTarget:
      'pasteStatementToToolboxDragTarget',
  DartBlockInteractionType.startedDraggingStatementToReorder:
      'startedDraggingStatementToReorder',
  DartBlockInteractionType.reorderedStatement: 'reorderedStatement',
  DartBlockInteractionType.changeWhileLoopType: 'changeWhileLoopType',
  DartBlockInteractionType.tapNumberComposerConstant:
      'tapNumberComposerConstant',
  DartBlockInteractionType.tapNumberComposerDecimalPoint:
      'tapNumberComposerDecimalPoint',
  DartBlockInteractionType.tapNumberComposerOperator:
      'tapNumberComposerOperator',
  DartBlockInteractionType.tapNumberComposerNegate: 'tapNumberComposerNegate',
  DartBlockInteractionType.tapNumberComposerBackspace:
      'tapNumberComposerBackspace',
  DartBlockInteractionType.tapNumberComposerUndo: 'tapNumberComposerUndo',
  DartBlockInteractionType.tapNumberComposerRedo: 'tapNumberComposerRedo',
  DartBlockInteractionType.tapNumberComposerFunctionCall:
      'tapNumberComposerFunctionCall',
  DartBlockInteractionType.tapNumberComposerVariablePicker:
      'tapNumberComposerVariablePicker',
  DartBlockInteractionType.saveNumberComposerFunctionCall:
      'saveNumberComposerFunctionCall',
  DartBlockInteractionType.pickNumberComposerVariable:
      'pickNumberComposerVariable',
  DartBlockInteractionType.changeNumberComposerOperatorThroughNode:
      'changeNumberComposerOperatorThroughNode',
  DartBlockInteractionType.selectNumberComposerValueNode:
      'selectNumberComposerValueNode',
  DartBlockInteractionType.deselectNumberComposerValueNode:
      'deselectNumberComposerValueNode',
  DartBlockInteractionType.swipeNumberComposerValueToBackspace:
      'swipeNumberComposerValueToBackspace',
  DartBlockInteractionType.tapBooleanComposerConstant:
      'tapBooleanComposerConstant',
  DartBlockInteractionType.tapBooleanComposerBackspace:
      'tapBooleanComposerBackspace',
  DartBlockInteractionType.tapBooleanComposerUndo: 'tapBooleanComposerUndo',
  DartBlockInteractionType.tapBooleanComposerRedo: 'tapBooleanComposerRedo',
  DartBlockInteractionType.tapBooleanComposerFunctionCall:
      'tapBooleanComposerFunctionCall',
  DartBlockInteractionType.tapBooleanComposerVariablePicker:
      'tapBooleanComposerVariablePicker',
  DartBlockInteractionType.tapBooleanComposerLogicalOperator:
      'tapBooleanComposerLogicalOperator',
  DartBlockInteractionType.tapBooleanComposerEqualityOperator:
      'tapBooleanComposerEqualityOperator',
  DartBlockInteractionType.tapBooleanComposerNumberComparisonOperator:
      'tapBooleanComposerNumberComparisonOperator',
  DartBlockInteractionType.tapBooleanComposerTextToggleToShow:
      'tapBooleanComposerTextToggleToShow',
  DartBlockInteractionType.tapBooleanComposerTextToggleToHide:
      'tapBooleanComposerTextToggleToHide',
  DartBlockInteractionType.tapBooleanComposerNumberToggleToShow:
      'tapBooleanComposerNumberToggleToShow',
  DartBlockInteractionType.tapBooleanComposerNumberToggleToHide:
      'tapBooleanComposerNumberToggleToHide',
  DartBlockInteractionType.changeBooleanComposerLogicalOperatorThroughNode:
      'changeBooleanComposerLogicalOperatorThroughNode',
  DartBlockInteractionType.changeBooleanComposerEqualityOperatorThroughNode:
      'changeBooleanComposerEqualityOperatorThroughNode',
  DartBlockInteractionType
          .changeBooleanComposerNumberComparisonOperatorThroughNode:
      'changeBooleanComposerNumberComparisonOperatorThroughNode',
  DartBlockInteractionType.selectBooleanComposerValueNode:
      'selectBooleanComposerValueNode',
  DartBlockInteractionType.deselectBooleanComposerValueNode:
      'deselectBooleanComposerValueNode',
  DartBlockInteractionType.swipeBooleanComposerValueToBackspace:
      'swipeBooleanComposerValueToBackspace',
  DartBlockInteractionType.saveBooleanComposerFunctionCall:
      'saveBooleanComposerFunctionCall',
  DartBlockInteractionType.pickBooleanComposerVariable:
      'pickBooleanComposerVariable',
  DartBlockInteractionType.tapConcatenationValueComposerBackspace:
      'tapConcatenationValueComposerBackspace',
  DartBlockInteractionType.tapConcatenationValueComposerUndo:
      'tapConcatenationValueComposerUndo',
  DartBlockInteractionType.tapConcatenationValueComposerRedo:
      'tapConcatenationValueComposerRedo',
  DartBlockInteractionType.tapConcatenationValueComposerTextToggleToShow:
      'tapConcatenationValueComposerTextToggleToShow',
  DartBlockInteractionType.tapConcatenationValueComposerTextToggleToHide:
      'tapConcatenationValueComposerTextToggleToHide',
  DartBlockInteractionType
          .tapConcatenationValueComposerFunctionCallToggleToShow:
      'tapConcatenationValueComposerFunctionCallToggleToShow',
  DartBlockInteractionType
          .tapConcatenationValueComposerFunctionCallToggleToHide:
      'tapConcatenationValueComposerFunctionCallToggleToHide',
  DartBlockInteractionType
          .tapConcatenationValueComposerVariablePickerToggleToShow:
      'tapConcatenationValueComposerVariablePickerToggleToShow',
  DartBlockInteractionType
          .tapConcatenationValueComposerVariablePickerToggleToHide:
      'tapConcatenationValueComposerVariablePickerToggleToHide',
  DartBlockInteractionType.tapConcatenationValueComposerNumberToggleToShow:
      'tapConcatenationValueComposerNumberToggleToShow',
  DartBlockInteractionType.tapConcatenationValueComposerNumberToggleToHide:
      'tapConcatenationValueComposerNumberToggleToHide',
  DartBlockInteractionType.tapConcatenationValueComposerBooleanToggleToShow:
      'tapConcatenationValueComposerBooleanToggleToShow',
  DartBlockInteractionType.tapConcatenationValueComposerBooleanToggleToHide:
      'tapConcatenationValueComposerBooleanToggleToHide',
  DartBlockInteractionType.selectConcatenationValueComposerValueNode:
      'selectConcatenationValueComposerValueNode',
  DartBlockInteractionType.deselectConcatenationValueComposerValueNode:
      'deselectConcatenationValueComposerValueNode',
  DartBlockInteractionType.reorderConcatenationValueComposerValueNode:
      'reorderConcatenationValueComposerValueNode',
  DartBlockInteractionType.addElseIfBlockToIfThenElseStatement:
      'addElseIfBlockToIfThenElseStatement',
  DartBlockInteractionType.deleteElseIfBlockToIfThenElseStatement:
      'deleteElseIfBlockToIfThenElseStatement',
  DartBlockInteractionType.reorderElseIfBlockOfIfThenElseStatement:
      'reorderElseIfBlockOfIfThenElseStatement',
};
