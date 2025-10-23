import 'package:dartblock_code/widgets/views/symbols.dart';
import 'package:dartblock_code/widgets/views/toolbox2/models/toolbox_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/toolbox_configuration.dart';

/// The controls of the DartBlockToolbox.
///
/// Primary: "Run", "Create New Function"
/// Secondary ("extra"): console, code, dock/undock, help
/// Exception indicator icon
class ToolboxActionBar extends StatelessWidget {
  final bool isExecuting;
  final bool isToolboxDocked;
  final Function()? onRun;
  final Function()? onAddFunction;
  final Function(ToolboxExtraAction) onTapExtraAction;
  final Widget? exceptionIndicator;

  const ToolboxActionBar({
    super.key,
    required this.isExecuting,
    required this.isToolboxDocked,
    this.onRun,
    required this.onAddFunction,
    required this.onTapExtraAction,
    this.exceptionIndicator,
  });

  @override
  Widget build(BuildContext context) {
    /// Depending on screen size, show the extra actions directly as IconButtons, rather than all under a PopupMenuButton.
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available width for extra actions
        final runButtonWidth = 100; // "Run" FilledButton
        final addFunctionWidth = onAddFunction != null
            ? 48
            : 0; // "New Function" IconButton
        final exceptionWidth = exceptionIndicator != null
            ? 48
            : 0; // "Exception" IconButton
        final padding = 16;

        final availableWidth =
            constraints.maxWidth -
            (runButtonWidth + addFunctionWidth + exceptionWidth + padding);

        // If an action is directly shown as an IconButton, it will take up a width of 48.
        // Here, we calculate how many such IconButtons we could fit into our availableWidth.
        final maxVisibleActions = (availableWidth / 48.0).floor();

        /// All extra actions
        final allActions = ToolboxExtraAction.values.toList();

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
                exceptionIndicator!,
                const SizedBox(width: 8),
              ],

              const Spacer(),

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
          ),
        );
      },
    );
  }
}
