import 'package:dartblock_code/dartblock_native_theme.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:flutter/widgets.dart';

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}

class DartBlockColors {
  final ExtendedColor number;
  final ExtendedColor boolean;
  final ExtendedColor variable;
  final ExtendedColor function;
  final ExtendedColor string;
  DartBlockColors({
    required this.number,
    required this.boolean,
    required this.variable,
    required this.function,
    required this.string,
  });

  DartBlockColors.native()
    : number = DartBlockNativeMaterialTheme.number,
      boolean = DartBlockNativeMaterialTheme.boolean,
      variable = DartBlockNativeMaterialTheme.variable,
      function = DartBlockNativeMaterialTheme.function,
      string = DartBlockNativeMaterialTheme.string;

  ExtendedColor getNeoTechDataTypeColor(DartBlockDataType dataType) {
    switch (dataType) {
      case DartBlockDataType.integerType:
      case DartBlockDataType.doubleType:
        return number;
      case DartBlockDataType.booleanType:
        return boolean;
      case DartBlockDataType.stringType:
        return string;
    }
  }
}

extension ExtendedColorHelpers on ExtendedColor {
  /// Returns the appropriate ColorFamily based on the current brightness.
  ColorFamily forBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }
}

/// A brightness-aware set of colors that mirrors Flutter's ColorScheme pattern.
/// This class holds pre-resolved ColorFamily instances, so you don't need to
/// pass brightness repeatedly.
class DartBlockColorFamily {
  final ColorFamily number;
  final ColorFamily boolean;
  final ColorFamily variable;
  final ColorFamily function;
  final ColorFamily string;

  const DartBlockColorFamily({
    required this.number,
    required this.boolean,
    required this.variable,
    required this.function,
    required this.string,
  });

  ColorFamily getNeoTechDataTypeColor(DartBlockDataType dataType) {
    switch (dataType) {
      case DartBlockDataType.integerType:
      case DartBlockDataType.doubleType:
        return number;
      case DartBlockDataType.booleanType:
        return boolean;
      case DartBlockDataType.stringType:
        return string;
    }
  }

  /// Create a DartBlockColorFamily from DartBlockColors and brightness.
  factory DartBlockColorFamily.fromColors(
    DartBlockColors colors,
    Brightness brightness,
  ) {
    return DartBlockColorFamily(
      number: colors.number.forBrightness(brightness),
      boolean: colors.boolean.forBrightness(brightness),
      variable: colors.variable.forBrightness(brightness),
      function: colors.function.forBrightness(brightness),
      string: colors.string.forBrightness(brightness),
    );
  }
}
