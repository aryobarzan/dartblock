import 'package:dartblock_code/models/dartblock_interaction.dart';
import 'package:dartblock_code/widgets/dartblock_editor.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:dartblock_code/widgets/views/other/dartblock_exception.dart';
import 'package:dartblock_code/widgets/views/toolbox/models/toolbox_action.dart';
import 'package:dartblock_code/widgets/views/toolbox/models/code_view_action.dart';
import 'package:flutter/material.dart';
import 'package:dartblock_code/models/function.dart';
import 'components/toolbox_statement_bar.dart';
import 'components/toolbox_action_bar.dart';
import 'models/toolbox_configuration.dart';

/// A mobile-optimized toolbox widget that displays all statement types in a horizontal scrollable strip,
/// with visual category grouping and a compact action bar.
class DartBlockToolbox extends StatefulWidget {
  final bool isTransparent;
  final bool isDocked;
  final bool canUndock;
  final bool isShowingCode;
  final bool showActions;
  final bool isExecuting;
  final Function()? onToolboxItemDragStart;
  final Function()? onToolboxItemDragEnd;
  final Function()? onRun;
  final List<String> existingFunctionNames;
  final bool canAddFunction;
  final Function(DartBlockFunction) onCreateFunction;
  final Function(ToolboxExtraAction action) onAction;
  final Function(CodeViewAction action) onCodeViewAction;

  const DartBlockToolbox({
    super.key,
    this.isTransparent = false,
    this.isDocked = true,
    this.canUndock = true,
    this.isShowingCode = false,
    this.showActions = true,
    this.isExecuting = false,
    required this.existingFunctionNames,
    this.onToolboxItemDragStart,
    this.onToolboxItemDragEnd,
    this.onRun,
    this.canAddFunction = false,
    required this.onCreateFunction,
    required this.onAction,
    required this.onCodeViewAction,
  });

  @override
  State<DartBlockToolbox> createState() => _DartBlockToolboxState();
}

class _DartBlockToolboxState extends State<DartBlockToolbox> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dartBlockEditorInheritedWidget = DartBlockEditorInheritedWidget.of(
      context,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        double toolboxHeight = 120;
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        final itemHeight = ToolboxConfig.minTouchSize;
        final rowHeight = itemHeight + 4;
        if (screenHeight > 900 &&
            (screenWidth < 580 || screenWidth > 700) &&
            screenWidth < 1270) {
          toolboxHeight += rowHeight;
        }

        return Opacity(
          opacity: widget.isTransparent ? 0.5 : 1.0,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(ToolboxConfig.borderRadius),
            child: AnimatedSize(
              duration: Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              child: widget.isShowingCode
                  ? Container(
                      height: ToolboxConfig.toolboxMinimalHeight,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(
                          ToolboxConfig.borderRadius,
                        ),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline
                            ..withValues(alpha: 0.5),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          IconButton.filled(
                            tooltip: "Back to DartBlock editor.",
                            onPressed: () {
                              DartBlockInteraction.create(
                                dartBlockInteractionType:
                                    DartBlockInteractionType
                                        .returnToEditorFromScriptView,
                              ).dispatch(context);
                              widget.onAction(ToolboxExtraAction.code);
                            },
                            icon: Icon(Icons.arrow_back),
                          ),
                          const SizedBox(width: 12),
                          RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.titleSmall,
                              children: [
                                TextSpan(text: "DartBlock "),
                                TextSpan(
                                  text: ">>",
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: " Java",
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          const SizedBox(width: 12),
                          IconButton(
                            tooltip: CodeViewAction.copy.getTooltip(),
                            onPressed: () =>
                                widget.onCodeViewAction(CodeViewAction.copy),
                            icon: Icon(CodeViewAction.copy.getIconData()),
                          ),

                          IconButton(
                            tooltip: CodeViewAction.save.getTooltip(),
                            onPressed: () =>
                                widget.onCodeViewAction(CodeViewAction.save),
                            icon: Icon(CodeViewAction.save.getIconData()),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      height: widget.showActions
                          ? toolboxHeight // ToolboxConfig.toolboxHeight
                          : ToolboxConfig.toolboxMinimalHeight,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(
                          ToolboxConfig.borderRadius,
                        ),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline
                            ..withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ToolboxActionBar(
                                  isExecuting: widget.isExecuting,
                                  isToolboxDocked: widget.isDocked,
                                  exceptionIndicator:
                                      dartBlockEditorInheritedWidget
                                              .executor
                                              .thrownException !=
                                          null
                                      ? PopupWidgetButton(
                                          isFullWidth: true,
                                          blurBackground: true,
                                          tooltip: "Exception...",
                                          onOpened: () {
                                            DartBlockInteraction.create(
                                              dartBlockInteractionType:
                                                  DartBlockInteractionType
                                                      .tapExceptionIndicatorInToolbox,
                                              content:
                                                  "ExceptionTitle-${dartBlockEditorInheritedWidget.executor.thrownException?.title}",
                                            ).dispatch(context);
                                          },
                                          widget: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              const Text(
                                                "An exception was thrown during the last execution:",
                                              ),
                                              DartBlockExceptionWidget(
                                                dartblockException:
                                                    dartBlockEditorInheritedWidget
                                                        .executor
                                                        .thrownException!,
                                                program:
                                                    dartBlockEditorInheritedWidget
                                                        .program,
                                              ),
                                              Text(
                                                "Think it's fixed now? Try running your program again.",
                                                textAlign: TextAlign.center,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodySmall,
                                              ),
                                            ],
                                          ),
                                          icon: Icon(
                                            Icons.error,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                          ),
                                        )
                                      : null,
                                  onRun: widget.onRun,
                                  onAddFunction: widget.canAddFunction
                                      ? () {
                                          DartBlockInteraction.create(
                                            dartBlockInteractionType:
                                                DartBlockInteractionType
                                                    .openNewFunctionEditorFromToolbox,
                                          ).dispatch(context);
                                          showNewFunctionSheet(
                                            context,
                                            existingCustomFunctionNames:
                                                widget.existingFunctionNames,
                                            onReceiveDartBlockNotification:
                                                null,
                                            onSaved: (newName, newReturnType) {
                                              widget.onCreateFunction(
                                                DartBlockFunction(
                                                  newName,
                                                  newReturnType,
                                                  [],
                                                  [],
                                                ),
                                              );
                                            },
                                          );
                                        }
                                      : null,
                                  onTapExtraAction: (action) {
                                    widget.onAction(action);
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (widget.showActions) ...[
                            const Divider(height: 1),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ToolboxStatementTypeBar(
                                scrollController: _scrollController,
                                onDragStart: () {
                                  widget.onToolboxItemDragStart?.call();
                                },
                                onDragEnd: widget.onToolboxItemDragEnd,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
