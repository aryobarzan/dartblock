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
  static final Map<String, Color> categoryColors = {
    'variables': const Color(0xFF2196F3), // Blue
    'loops': const Color(0xFFFFC107), // Amber
    'logic': const Color(0xFF4CAF50), // Green
    'functions': const Color(0xFF9C27B0), // Purple
    'other': const Color(0xFF607D8B), // Blue Grey
  };
}
