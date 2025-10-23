import 'package:flutter/material.dart';

/// Extra actions shown when viewing the "script" or code of a DartBlock program.
///
/// - [CodeViewAction.copy]: copy the script version, e.g., Java code, to clipboard.
/// - [CodeViewAction.save]: save the script version to a file.
enum CodeViewAction {
  copy,
  save;

  String getTooltip() {
    switch (this) {
      case CodeViewAction.copy:
        return 'Copy Code';
      case CodeViewAction.save:
        return 'Save Code';
    }
  }

  IconData getIconData() {
    switch (this) {
      case CodeViewAction.copy:
        return Icons.content_copy;
      case CodeViewAction.save:
        return Icons.save;
    }
  }
}
