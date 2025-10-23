import 'package:dartblock_code/widgets/dartblock_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartblock_code/models/function.dart';
import 'package:dartblock_code/models/dartblock_interaction.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:dartblock_code/widgets/views/other/dartblock_exception.dart';
import 'package:dartblock_code/widgets/views/symbols.dart';

const double _toolboxHeight = 120;
const double _toolboxShowingCodeHeight = 100;
const double _toolboxNoActionsHeight = 50;

enum ToolboxExtraAction {
  console,
  code,
  dock,
  help;

  @override
  String toString() {
    switch (this) {
      case ToolboxExtraAction.console:
        return 'Console';
      case ToolboxExtraAction.code:
        return 'Code';
      case ToolboxExtraAction.help:
        return 'Help';
      case ToolboxExtraAction.dock:
        return 'Dock';
    }
  }
}

class DartBlockToolbox extends StatelessWidget {
  final TabController toolboxTabController;
  final bool isTransparent;
  final bool isDocked;
  final bool canUndock;
  final bool isShowingCode;
  final bool showActions;
  final bool isExecuting;
  final DartBlockTypedLanguage language;
  final ToolboxCategory toolboxCategory;
  final Function()? onToolboxItemDragStart;
  final Function()? onToolboxItemDragEnd;
  final Function() onCopyScript;
  final Function() onDownloadScript;
  final Function()? onRun;

  final List<String> existingFunctionNames;
  final bool canAddFunction;
  final Function(DartBlockFunction) onCreateFunction;
  final Function(ToolboxExtraAction) onTapExtraAction;
  const DartBlockToolbox({
    super.key,
    required this.toolboxTabController,
    this.isTransparent = false,
    bool isDocked = false,
    this.canUndock = true,
    this.isShowingCode = false,
    this.showActions = true,
    this.isExecuting = false,
    this.language = DartBlockTypedLanguage.java,
    this.toolboxCategory = ToolboxCategory.variables,
    this.onToolboxItemDragStart,
    this.onToolboxItemDragEnd,
    required this.existingFunctionNames,
    required this.canAddFunction,
    required this.onCreateFunction,
    required this.onCopyScript,
    required this.onDownloadScript,
    required this.onRun,
    required this.onTapExtraAction,
  }) : isDocked = !canUndock ? true : isDocked;

  @override
  Widget build(BuildContext context) {
    final dartBlockEditorInheritedWidget = DartBlockEditorInheritedWidget.of(
      context,
    );
    return Opacity(
      opacity: isTransparent ? 0.5 : 1.0,
      child: Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 125),
          padding: const EdgeInsets.only(top: 0, left: 2, right: 2, bottom: 0),
          width: double.maxFinite,
          height: isShowingCode
              ? _toolboxShowingCodeHeight
              : showActions
              ? _toolboxHeight
              : _toolboxNoActionsHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            color: isShowingCode
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surface,
          ),
          child: isShowingCode
              ? _buildCodeViewActiveWidget(context)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FilledButton.icon(
                            onPressed: onRun != null && !isExecuting
                                ? () {
                                    DartBlockInteraction.create(
                                      dartBlockInteractionType:
                                          DartBlockInteractionType
                                              .executedProgram,
                                    ).dispatch(context);
                                    HapticFeedback.heavyImpact();
                                    onRun!();
                                  }
                                : null,
                            icon: isExecuting
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  )
                                : const Icon(Icons.play_circle_outline),
                            label: const Text("Run"),
                          ),
                          if (canAddFunction && showActions) ...[
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () {
                                DartBlockInteraction.create(
                                  dartBlockInteractionType:
                                      DartBlockInteractionType
                                          .openNewFunctionEditorFromToolbox,
                                ).dispatch(context);
                                showNewFunctionSheet(
                                  context,
                                  existingCustomFunctionNames:
                                      existingFunctionNames,
                                  onReceiveDartBlockNotification: null,
                                  onSaved: (newName, newReturnType) {
                                    onCreateFunction(
                                      DartBlockFunction(
                                        newName,
                                        newReturnType,
                                        [],
                                        [],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: const Tooltip(
                                message: "Create new function...",
                                child: NewFunctionSymbol(),
                              ),
                            ),
                          ],
                          if (dartBlockEditorInheritedWidget
                                  .executor
                                  .thrownException !=
                              null)
                            PopupWidgetButton(
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
                                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                        dartBlockEditorInheritedWidget.program,
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
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          const Spacer(),
                          _buildExtraButtons(
                            context,
                            isShowingExceptionIconButton:
                                dartBlockEditorInheritedWidget
                                    .executor
                                    .thrownException !=
                                null,
                          ),
                        ],
                      ),
                    ),
                    if (showActions) ...[
                      TabBar(
                        dividerColor: Colors.transparent,
                        controller: toolboxTabController,
                        onTap: (value) {
                          DartBlockInteraction.create(
                            dartBlockInteractionType:
                                DartBlockInteractionType.changeToolboxTab,
                            content: "Index-$value",
                          ).dispatch(context);
                          HapticFeedback.lightImpact();
                        },
                        tabs: ToolboxCategory.values
                            .map(
                              (e) => Tab(height: 28, icon: e.getSymbol(24, 24)),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: TabBarView(
                          controller: toolboxTabController,
                          children: ToolboxCategory.values
                              .map(
                                (e) => SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: _DartBlockToolboxCategoryWidget(
                                    category: e,
                                    onItemDragStart: onToolboxItemDragStart,
                                    onItemDragEnd: onToolboxItemDragEnd,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildExtraButtons(
    BuildContext context, {
    bool isShowingExceptionIconButton = false,
  }) {
    List<ToolboxExtraAction> items = ToolboxExtraAction.values.toList();
    if (!canUndock) {
      items.remove(ToolboxExtraAction.dock);
    }
    List<ToolboxExtraAction> displayedActions = [];
    final List<Widget> children = [];
    var availableWidth =
        MediaQuery.of(context).size.width -
        (isShowingExceptionIconButton ? 160 : 120);
    if (isShowingExceptionIconButton) {
      availableWidth -= kMinInteractiveDimension;
    }
    if (canAddFunction) {
      availableWidth -= kMinInteractiveDimension;
    }
    while (availableWidth >= kMinInteractiveDimension && items.isNotEmpty) {
      displayedActions.add(items.removeAt(0));
      availableWidth -= kMinInteractiveDimension;
    }
    for (final item in displayedActions) {
      children.add(switch (item) {
        ToolboxExtraAction.console => IconButton(
          tooltip: "Console",
          onPressed: () {
            DartBlockInteraction.create(
              dartBlockInteractionType: DartBlockInteractionType.openConsole,
            ).dispatch(context);
            onTapExtraAction(item);
          },
          icon: const Icon(Icons.wysiwyg),
        ),
        ToolboxExtraAction.code => IconButton(
          tooltip: "Code",
          onPressed: () {
            DartBlockInteraction.create(
              dartBlockInteractionType: DartBlockInteractionType.viewScript,
            ).dispatch(context);
            onTapExtraAction(item);
          },
          icon: const Icon(Icons.code),
        ),
        ToolboxExtraAction.help => IconButton(
          tooltip: "Help",
          onPressed: () {
            DartBlockInteraction.create(
              dartBlockInteractionType: DartBlockInteractionType.openHelpCenter,
            ).dispatch(context);
            onTapExtraAction(item);
          },
          icon: const Icon(Icons.help_outline),
        ),
        ToolboxExtraAction.dock => IconButton(
          tooltip: isDocked ? "Undock" : "Dock",
          onPressed: () {
            if (isDocked) {
              DartBlockInteraction.create(
                dartBlockInteractionType:
                    DartBlockInteractionType.undockToolbox,
              ).dispatch(context);
            } else {
              DartBlockInteraction.create(
                dartBlockInteractionType: DartBlockInteractionType.dockToolbox,
              ).dispatch(context);
            }
            HapticFeedback.lightImpact();
            onTapExtraAction(item);
          },
          icon: Icon(isDocked ? Icons.open_in_new : Icons.publish),
        ),
      });
    }
    if (items.isNotEmpty) {
      children.add(
        PopupMenuButton(
          position: PopupMenuPosition.under,
          tooltip: "More",
          onSelected: (value) {
            switch (value) {
              case ToolboxExtraAction.console:
                DartBlockInteraction.create(
                  dartBlockInteractionType:
                      DartBlockInteractionType.openConsole,
                ).dispatch(context);
                break;
              case ToolboxExtraAction.code:
                DartBlockInteraction.create(
                  dartBlockInteractionType: DartBlockInteractionType.viewScript,
                ).dispatch(context);
                break;
              case ToolboxExtraAction.dock:
                if (isDocked) {
                  DartBlockInteraction.create(
                    dartBlockInteractionType:
                        DartBlockInteractionType.undockToolbox,
                  ).dispatch(context);
                } else {
                  DartBlockInteraction.create(
                    dartBlockInteractionType:
                        DartBlockInteractionType.dockToolbox,
                  ).dispatch(context);
                }
                break;
              case ToolboxExtraAction.help:
                DartBlockInteraction.create(
                  dartBlockInteractionType:
                      DartBlockInteractionType.openHelpCenter,
                ).dispatch(context);
                break;
            }
            onTapExtraAction(value);
          },
          itemBuilder: (context) => items
              .map(
                (e) => PopupMenuItem(
                  value: e,
                  child: ListTile(
                    leading: Icon(switch (e) {
                      ToolboxExtraAction.console => Icons.wysiwyg,
                      ToolboxExtraAction.code => Icons.code,
                      ToolboxExtraAction.help => Icons.help_outline,
                      ToolboxExtraAction.dock =>
                        isDocked ? Icons.open_in_new : Icons.publish,
                    }),
                    title: Text(switch (e) {
                      ToolboxExtraAction.console => 'Console',
                      ToolboxExtraAction.code => 'Code',
                      ToolboxExtraAction.help => 'Help',
                      ToolboxExtraAction.dock => isDocked ? 'Undock' : 'Dock',
                    }),
                  ),
                ),
              )
              .toList(),
        ),
      );
    }
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget _buildCodeViewActiveWidget(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OverflowBar(
          alignment: MainAxisAlignment.spaceBetween,
          children: [
            FilledButton.icon(
              onPressed: () {
                DartBlockInteraction.create(
                  dartBlockInteractionType:
                      DartBlockInteractionType.returnToEditorFromScriptView,
                ).dispatch(context);
                onTapExtraAction(ToolboxExtraAction.code);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text("Editor"),
            ),
            OverflowBar(
              children: [
                IconButton(
                  tooltip: "Save ${language.name} code to file...",
                  onPressed: () {
                    DartBlockInteraction.create(
                      dartBlockInteractionType:
                          DartBlockInteractionType.saveScriptToFile,
                    ).dispatch(context);
                    onDownloadScript();
                  },
                  icon: const Icon(Icons.download),
                ),
                IconButton(
                  tooltip: "Copy code to clipboard.",
                  onPressed: () {
                    DartBlockInteraction.create(
                      dartBlockInteractionType:
                          DartBlockInteractionType.copyScript,
                    ).dispatch(context);
                    onCopyScript();
                  },
                  icon: const Icon(Icons.copy),
                ),
              ],
            ),
          ],
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: RichText(
            maxLines: 1,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium?.apply(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              children: [
                const TextSpan(text: "DartBlock program as "),
                TextSpan(
                  text: language.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const TextSpan(text: " code:"),
              ],
            ),
          ),
        ),
        const SizedBox(height: 2),
      ],
    );
  }
}

enum ToolboxCategory {
  variables('Variables'),
  loops('Loops'),
  decisionStructures('Decision Structures'),
  other('Other');

  final String name;
  const ToolboxCategory(this.name);

  IconData getIcon() {
    switch (this) {
      case ToolboxCategory.variables:
        return Icons.code;
      case ToolboxCategory.loops:
        return Icons.loop;
      case ToolboxCategory.decisionStructures:
        return Icons.confirmation_number;
      case ToolboxCategory.other:
        return Icons.devices_other;
    }
  }

  Widget getSymbol(double width, double height, {Color? color}) {
    switch (this) {
      case ToolboxCategory.variables:
        return Icon(Icons.data_object, size: width);
      case ToolboxCategory.loops:
        return Icon(Icons.loop, size: width);
      case ToolboxCategory.decisionStructures:
        return Icon(Icons.alt_route, size: width);
      case ToolboxCategory.other:
        return Icon(Icons.dashboard_outlined, size: width);
    }
  }
}

class _DartBlockToolboxCategoryWidget extends StatelessWidget {
  final ToolboxCategory category;
  final Function()? onItemDragStart;
  final Function()? onItemDragEnd;
  const _DartBlockToolboxCategoryWidget({
    required this.category,
    this.onItemDragStart,
    this.onItemDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    List<StatementType> statementTypes;
    switch (category) {
      case ToolboxCategory.variables:
        statementTypes = [
          StatementType.variableDeclarationStatement,
          StatementType.variableAssignmentStatement,
          StatementType.returnStatement,
          StatementType.customFunctionCallStatement,
        ];
        break;
      case ToolboxCategory.loops:
        statementTypes = [
          StatementType.forLoopStatement,
          StatementType.whileLoopStatement,
          StatementType.breakStatement,
          StatementType.continueStatement,
        ];
        break;
      case ToolboxCategory.decisionStructures:
        statementTypes = [StatementType.ifElseStatement];
        break;
      case ToolboxCategory.other:
        statementTypes = [StatementType.printStatement];
    }

    List<Widget> items = [];
    for (var statementType in statementTypes) {
      if (statementType == StatementType.statementBlockStatement) {
        continue;
      }
      items.add(
        _DartBlockToolboxItemWidget(
          statementType: statementType,
          onDragStart: onItemDragStart,
          onDragEnd: onItemDragEnd,
        ),
      );
    }

    return Wrap(spacing: 4, runSpacing: 0, children: items);
  }
}

class _DartBlockToolboxItemWidget extends StatelessWidget {
  final StatementType statementType;
  final Function()? onDragStart;
  final Function()? onDragEnd;
  const _DartBlockToolboxItemWidget({
    required this.statementType,
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable(
      data: statementType,
      delay: const Duration(milliseconds: 150),
      feedback: _build(context, true),
      onDragStarted: onDragStart,
      onDragEnd: (details) {
        if (onDragEnd != null) {
          onDragEnd!();
        }
      },
      onDraggableCanceled: (velocity, offset) {
        if (onDragEnd != null) {
          onDragEnd!();
        }
      },
      onDragCompleted: () {
        if (onDragEnd != null) {
          onDragEnd!();
        }
      },
      child: _build(context, false),
    );
  }

  Widget _build(BuildContext context, bool isDragging) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: !isDragging
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isDragging)
            Icon(
              Icons.add,
              size: 18,
              color: !isDragging
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onPrimary,
            ),
          Text(
            statementType.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: !isDragging
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
