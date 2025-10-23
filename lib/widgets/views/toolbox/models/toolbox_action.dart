import 'package:flutter/material.dart';

/// Additional secondary actions shown in the Toolbox.
///
/// - [ToolboxExtraAction.console] Opening the console to view the program's execution output.
/// - [ToolboxExtraAction.code] Switching between the DartBlock and script view of the program.
/// - [ToolboxExtraAction.dock] Docking or undocking the toolbox.
/// - [ToolboxExtraAction.help] Opening the help window for DartBlock.
enum ToolboxExtraAction {
  ///
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

  IconData getIconData() {
    switch (this) {
      case ToolboxExtraAction.console:
        return Icons.wysiwyg;
      case ToolboxExtraAction.code:
        return Icons.code;
      case ToolboxExtraAction.help:
        return Icons.help_outline;
      case ToolboxExtraAction.dock:
        return Icons.open_in_new;
    }
  }
}
