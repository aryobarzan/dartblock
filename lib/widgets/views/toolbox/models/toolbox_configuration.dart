import 'package:dartblock_code/models/statement.dart';
import 'package:flutter/material.dart';

/// Configuration constants for the toolbox.
class ToolboxConfig {
  /// Height of the toolbox when both the actions (Run, ...) and the statement types.
  static const double toolboxHeight = 120;

  /// Height of the toolbox when only showing a single row.
  static const double toolboxMinimalHeight = 50;

  /// Minimum size for touch targets.
  static const double minTouchSize = 48;

  /// Standard horizontal padding.
  static const double horizontalPadding = 8;

  /// Border radius for components.
  static const double borderRadius = 12;

  /// Animation duration for transitions.
  static const Duration animationDuration = Duration(milliseconds: 200);

  /// Category colors for the different statement types.
  static final Map<StatementCategory, Color> categoryColors = {
    StatementCategory.variable: const Color(0xFF2196F3), // Blue
    StatementCategory.loop: const Color(0xFFFFC107), // Amber
    StatementCategory.decisionStructure: const Color(0xFF4CAF50), // Green
    StatementCategory.function: const Color(0xFF9C27B0), // Purple
    StatementCategory.other: const Color(0xFF607D8B), // Blue Grey
  };
}
