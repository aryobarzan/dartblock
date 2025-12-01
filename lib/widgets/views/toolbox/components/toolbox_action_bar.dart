import 'dart:math';

import 'package:dartblock_code/core/dartblock_executor.dart';
import 'package:dartblock_code/models/dartblock_interaction.dart';
import 'package:dartblock_code/widgets/dartblock_editor_providers.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:dartblock_code/widgets/views/other/dartblock_exception.dart';
import 'package:dartblock_code/widgets/views/symbols.dart';
import 'package:dartblock_code/widgets/views/toolbox/models/toolbox_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/toolbox_configuration.dart';

/// The controls of the DartBlockToolbox.
///
/// Primary: "Run", "Create New Function"
/// Secondary ("extra"): console, code, dock/undock, help
/// Exception indicator icon
class ToolboxActionBar extends ConsumerWidget {
  final bool isExecuting;
  final bool isToolboxDocked;
  final Function()? onRun;
  final Function()? onAddFunction;
  final Function(ToolboxExtraAction) onTapExtraAction;

  const ToolboxActionBar({
    super.key,
    required this.isExecuting,
    required this.isToolboxDocked,
    this.onRun,
    required this.onAddFunction,
    required this.onTapExtraAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final executor = ref.watch(executorProvider);
    final exceptionIndicator = _buildExceptionIndicator(context, executor);

    /// Depending on screen size, show the extra actions directly as IconButtons, rather than all under a PopupMenuButton.
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available width for extra actions
        final runButtonWidth = 94; // "Run" FilledButton
        final addFunctionWidth = onAddFunction != null
            ? 32
            : 0; // "New Function" IconButton
        final exceptionWidth = exceptionIndicator != null
            ? 32
            : 0; // "Exception" IconButton
        final padding = 8 + 16 + 48;

        final availableWidth = max(
          0,
          constraints.maxWidth -
              (runButtonWidth + addFunctionWidth + exceptionWidth + padding),
        );

        // If an action is directly shown as an IconButton, it will take up a width of 48.
        // Here, we calculate how many such IconButtons we could fit into our availableWidth.
        var maxVisibleActions = (availableWidth / 48.0).floor();

        /// All extra actions
        final allActions = ToolboxExtraAction.values.toList();
        // Don't place a singular action under a PopupMenuButton.
        if (maxVisibleActions == allActions.length - 1) {
          maxVisibleActions += 1;
        }

        // Take the first maxVisibleActions from the full list of actions, to be shown as IconButtons.
        final visibleActions = allActions.take(maxVisibleActions).toList();
        // Any remaining actions should be shown under a PopupMenuButton.
        final menuActions = allActions.skip(maxVisibleActions).toList();

        return Container(
          height: ToolboxConfig.minTouchSize,
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            children: [
              /// Run button
              FilledButton.icon(
                onPressed: !isExecuting ? onRun : null,
                icon: isExecuting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: const Text('Run'),
              ),
              const SizedBox(width: 8),

              /// Create New Function button
              if (onAddFunction != null) ...[
                InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onAddFunction!();
                  },
                  child: const Tooltip(
                    message: "Create new function",
                    child: NewFunctionSymbol(),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              /// Exception indicator
              if (exceptionIndicator != null) ...[
                exceptionIndicator,
                const SizedBox(width: 8),
              ],

              const Spacer(),
              if (maxVisibleActions > 0) ...[
                /// Extra actions as IconButtons
                ...visibleActions.map(
                  (action) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      tooltip: action == ToolboxExtraAction.dock
                          ? isToolboxDocked
                                ? "Undock"
                                : "Dock"
                          : action.toString(),
                      onPressed: () {
                        onTapExtraAction(action);
                      },
                      icon: Icon(
                        action == ToolboxExtraAction.dock
                            ? isToolboxDocked
                                  ? Icons.open_in_new
                                  : Icons.publish
                            : action.getIconData(),
                      ),
                    ),
                  ),
                ),

                /// Any remaining axtra actions under a PopupMenuButton
                if (menuActions.isNotEmpty)
                  PopupMenuButton<ToolboxExtraAction>(
                    tooltip: 'More Actions',
                    onSelected: (action) {
                      onTapExtraAction(action);
                    },
                    itemBuilder: (context) => menuActions
                        .map(
                          (action) => PopupMenuItem(
                            value: action,
                            child: ListTile(
                              leading: Icon(
                                action == ToolboxExtraAction.dock
                                    ? isToolboxDocked
                                          ? Icons.open_in_new
                                          : Icons.publish
                                    : action.getIconData(),
                              ),
                              title: Text(
                                action == ToolboxExtraAction.dock
                                    ? isToolboxDocked
                                          ? "Undock"
                                          : "Dock"
                                    : action.toString(),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget? _buildExceptionIndicator(
    BuildContext context,
    DartBlockExecutor executor,
  ) {
    if (executor.thrownException != null) {
      return PopupWidgetButton(
        isFullWidth: true,
        blurBackground: true,
        tooltip: "Exception...",
        onOpened: () {
          DartBlockInteraction.create(
            dartBlockInteractionType:
                DartBlockInteractionType.tapExceptionIndicatorInToolbox,
            content: "ExceptionTitle-${executor.thrownException?.title}",
          ).dispatch(context);
        },
        widget: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("An exception was thrown during the last execution:"),
            DartBlockExceptionWidget(
              dartblockException: executor.thrownException!,
              program:
                  // TODO: safe to pass executor's program instead of ref.watch(programProvider)?
                  executor.program,
            ),
            Text(
              "Think it's fixed now? Try running your program again.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        icon: Icon(Icons.error, color: Theme.of(context).colorScheme.error),
      );
    } else {
      return null;
    }
  }
}
