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
