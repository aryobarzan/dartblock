import 'package:flutter/material.dart';

import 'widgets/dartblock_colors.dart';

class DartBlockNativeMaterialTheme {
  final TextTheme textTheme;

  const DartBlockNativeMaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff1f6587),
      surfaceTint: Color(0xff1f6587),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffc6e7ff),
      onPrimaryContainer: Color(0xff004c6b),
      secondary: Color(0xff8d4a5b),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffd9e0),
      onSecondaryContainer: Color(0xff713344),
      tertiary: Color(0xff64558f),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffe8ddff),
      onTertiaryContainer: Color(0xff4c3e76),
      error: Color(0xff904a43),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad5),
      onErrorContainer: Color(0xff73342d),
      surface: Color(0xfff6fafe),
      onSurface: Color(0xff181c1f),
      onSurfaceVariant: Color(0xff41484d),
      outline: Color(0xff71787e),
      outlineVariant: Color(0xffc1c7ce),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c3134),
      inversePrimary: Color(0xff91cef5),
      primaryFixed: Color(0xffc6e7ff),
      onPrimaryFixed: Color(0xff001e2d),
      primaryFixedDim: Color(0xff91cef5),
      onPrimaryFixedVariant: Color(0xff004c6b),
      secondaryFixed: Color(0xffffd9e0),
      onSecondaryFixed: Color(0xff3a0719),
      secondaryFixedDim: Color(0xffffb1c2),
      onSecondaryFixedVariant: Color(0xff713344),
      tertiaryFixed: Color(0xffe8ddff),
      onTertiaryFixed: Color(0xff1f1047),
      tertiaryFixedDim: Color(0xffcebdfe),
      onTertiaryFixedVariant: Color(0xff4c3e76),
      surfaceDim: Color(0xffd7dadf),
      surfaceBright: Color(0xfff6fafe),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f4f8),
      surfaceContainer: Color(0xffebeef3),
      surfaceContainerHigh: Color(0xffe5e8ed),
      surfaceContainerHighest: Color(0xffdfe3e7),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003a53),
      surfaceTint: Color(0xff1f6587),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff337396),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff5c2233),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff9e586a),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff3b2d64),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff73649f),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff5e231e),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffa25850),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff6fafe),
      onSurface: Color(0xff0d1215),
      onSurfaceVariant: Color(0xff30373c),
      outline: Color(0xff4c5359),
      outlineVariant: Color(0xff676e74),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c3134),
      inversePrimary: Color(0xff91cef5),
      primaryFixed: Color(0xff337396),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff0f5b7c),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff9e586a),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff824052),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff73649f),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff5a4c85),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc3c7cb),
      surfaceBright: Color(0xfff6fafe),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f4f8),
      surfaceContainer: Color(0xffe5e8ed),
      surfaceContainerHigh: Color(0xffd9dde2),
      surfaceContainerHighest: Color(0xffced2d6),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003045),
      surfaceTint: Color(0xff1f6587),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff004f6e),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff501829),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff743546),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff302259),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff4e4078),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff511a15),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff76362f),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff6fafe),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff262d32),
      outlineVariant: Color(0xff434a4f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c3134),
      inversePrimary: Color(0xff91cef5),
      primaryFixed: Color(0xff004f6e),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff00374e),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff743546),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff581f30),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff4e4078),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff372960),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb5b9bd),
      surfaceBright: Color(0xfff6fafe),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeef1f6),
      surfaceContainer: Color(0xffdfe3e7),
      surfaceContainerHigh: Color(0xffd1d5d9),
      surfaceContainerHighest: Color(0xffc3c7cb),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff91cef5),
      surfaceTint: Color(0xff91cef5),
      onPrimary: Color(0xff00344b),
      primaryContainer: Color(0xff004c6b),
      onPrimaryContainer: Color(0xffc6e7ff),
      secondary: Color(0xffffb1c2),
      onSecondary: Color(0xff551d2e),
      secondaryContainer: Color(0xff713344),
      onSecondaryContainer: Color(0xffffd9e0),
      tertiary: Color(0xffcebdfe),
      onTertiary: Color(0xff35275e),
      tertiaryContainer: Color(0xff4c3e76),
      onTertiaryContainer: Color(0xffe8ddff),
      error: Color(0xffffb4ab),
      onError: Color(0xff561e19),
      errorContainer: Color(0xff73342d),
      onErrorContainer: Color(0xffffdad5),
      surface: Color(0xff0f1417),
      onSurface: Color(0xffdfe3e7),
      onSurfaceVariant: Color(0xffc1c7ce),
      outline: Color(0xff8b9298),
      outlineVariant: Color(0xff41484d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdfe3e7),
      inversePrimary: Color(0xff1f6587),
      primaryFixed: Color(0xffc6e7ff),
      onPrimaryFixed: Color(0xff001e2d),
      primaryFixedDim: Color(0xff91cef5),
      onPrimaryFixedVariant: Color(0xff004c6b),
      secondaryFixed: Color(0xffffd9e0),
      onSecondaryFixed: Color(0xff3a0719),
      secondaryFixedDim: Color(0xffffb1c2),
      onSecondaryFixedVariant: Color(0xff713344),
      tertiaryFixed: Color(0xffe8ddff),
      onTertiaryFixed: Color(0xff1f1047),
      tertiaryFixedDim: Color(0xffcebdfe),
      onTertiaryFixedVariant: Color(0xff4c3e76),
      surfaceDim: Color(0xff0f1417),
      surfaceBright: Color(0xff353a3d),
      surfaceContainerLowest: Color(0xff0a0f12),
      surfaceContainerLow: Color(0xff181c1f),
      surfaceContainer: Color(0xff1c2024),
      surfaceContainerHigh: Color(0xff262b2e),
      surfaceContainerHighest: Color(0xff313539),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffb8e2ff),
      surfaceTint: Color(0xff91cef5),
      onPrimary: Color(0xff00293b),
      primaryContainer: Color(0xff5a98bc),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffffd1d9),
      onSecondary: Color(0xff471223),
      secondaryContainer: Color(0xffc77a8d),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffe2d6ff),
      onTertiary: Color(0xff2a1b52),
      tertiaryContainer: Color(0xff9788c5),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff48130f),
      errorContainer: Color(0xffcc7b72),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff0f1417),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd7dde4),
      outline: Color(0xffacb3b9),
      outlineVariant: Color(0xff8a9197),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdfe3e7),
      inversePrimary: Color(0xff004d6c),
      primaryFixed: Color(0xffc6e7ff),
      onPrimaryFixed: Color(0xff00131e),
      primaryFixedDim: Color(0xff91cef5),
      onPrimaryFixedVariant: Color(0xff003a53),
      secondaryFixed: Color(0xffffd9e0),
      onSecondaryFixed: Color(0xff2c000f),
      secondaryFixedDim: Color(0xffffb1c2),
      onSecondaryFixedVariant: Color(0xff5c2233),
      tertiaryFixed: Color(0xffe8ddff),
      onTertiaryFixed: Color(0xff15033d),
      tertiaryFixedDim: Color(0xffcebdfe),
      onTertiaryFixedVariant: Color(0xff3b2d64),
      surfaceDim: Color(0xff0f1417),
      surfaceBright: Color(0xff414549),
      surfaceContainerLowest: Color(0xff04080b),
      surfaceContainerLow: Color(0xff1a1e21),
      surfaceContainer: Color(0xff24282c),
      surfaceContainerHigh: Color(0xff2f3337),
      surfaceContainerHighest: Color(0xff3a3e42),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffe2f2ff),
      surfaceTint: Color(0xff91cef5),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff8dcaf1),
      onPrimaryContainer: Color(0xff000d16),
      secondary: Color(0xffffebee),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffffabbe),
      onSecondaryContainer: Color(0xff210009),
      tertiary: Color(0xfff5edff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffcab9fa),
      onTertiaryContainer: Color(0xff0e0033),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220000),
      surface: Color(0xff0f1417),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffeaf1f7),
      outlineVariant: Color(0xffbdc3ca),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdfe3e7),
      inversePrimary: Color(0xff004d6c),
      primaryFixed: Color(0xffc6e7ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff91cef5),
      onPrimaryFixedVariant: Color(0xff00131e),
      secondaryFixed: Color(0xffffd9e0),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffffb1c2),
      onSecondaryFixedVariant: Color(0xff2c000f),
      tertiaryFixed: Color(0xffe8ddff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffcebdfe),
      onTertiaryFixedVariant: Color(0xff15033d),
      surfaceDim: Color(0xff0f1417),
      surfaceBright: Color(0xff4c5154),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1c2024),
      surfaceContainer: Color(0xff2c3134),
      surfaceContainerHigh: Color(0xff373c40),
      surfaceContainerHighest: Color(0xff43474b),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
  );

  /// Function
  static const function = ExtendedColor(
    seed: Color(0xff487452),
    value: Color(0xff487452),
    light: ColorFamily(
      color: Color(0xff316a42),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffb3f1be),
      onColorContainer: Color(0xff16512c),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff316a42),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffb3f1be),
      onColorContainer: Color(0xff16512c),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff316a42),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffb3f1be),
      onColorContainer: Color(0xff16512c),
    ),
    dark: ColorFamily(
      color: Color(0xff98d4a4),
      onColor: Color(0xff003919),
      colorContainer: Color(0xff16512c),
      onColorContainer: Color(0xffb3f1be),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xff98d4a4),
      onColor: Color(0xff003919),
      colorContainer: Color(0xff16512c),
      onColorContainer: Color(0xffb3f1be),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xff98d4a4),
      onColor: Color(0xff003919),
      colorContainer: Color(0xff16512c),
      onColorContainer: Color(0xffb3f1be),
    ),
  );

  /// Variable
  static const variable = ExtendedColor(
    seed: Color(0xffc4a160),
    value: Color(0xffc4a160),
    light: ColorFamily(
      color: Color(0xff7a590c),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdea5),
      onColorContainer: Color(0xff5d4200),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff7a590c),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdea5),
      onColorContainer: Color(0xff5d4200),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff7a590c),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdea5),
      onColorContainer: Color(0xff5d4200),
    ),
    dark: ColorFamily(
      color: Color(0xffecc06c),
      onColor: Color(0xff412d00),
      colorContainer: Color(0xff5d4200),
      onColorContainer: Color(0xffffdea5),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffecc06c),
      onColor: Color(0xff412d00),
      colorContainer: Color(0xff5d4200),
      onColorContainer: Color(0xffffdea5),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffecc06c),
      onColor: Color(0xff412d00),
      colorContainer: Color(0xff5d4200),
      onColorContainer: Color(0xffffdea5),
    ),
  );

  /// Number
  static const number = ExtendedColor(
    seed: Color(0xff5644b8),
    value: Color(0xff5644b8),
    light: ColorFamily(
      color: Color(0xff5f5791),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffe5deff),
      onColorContainer: Color(0xff473f77),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff5f5791),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffe5deff),
      onColorContainer: Color(0xff473f77),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff5f5791),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffe5deff),
      onColorContainer: Color(0xff473f77),
    ),
    dark: ColorFamily(
      color: Color(0xffc8bfff),
      onColor: Color(0xff30285f),
      colorContainer: Color(0xff473f77),
      onColorContainer: Color(0xffe5deff),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffc8bfff),
      onColor: Color(0xff30285f),
      colorContainer: Color(0xff473f77),
      onColorContainer: Color(0xffe5deff),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffc8bfff),
      onColor: Color(0xff30285f),
      colorContainer: Color(0xff473f77),
      onColorContainer: Color(0xffe5deff),
    ),
  );

  /// Boolean
  static const boolean = ExtendedColor(
    seed: Color(0xfff91796),
    value: Color(0xfff91796),
    light: ColorFamily(
      color: Color(0xff8a4a64),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffd9e4),
      onColorContainer: Color(0xff6f334c),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff8a4a64),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffd9e4),
      onColorContainer: Color(0xff6f334c),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff8a4a64),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffd9e4),
      onColorContainer: Color(0xff6f334c),
    ),
    dark: ColorFamily(
      color: Color(0xffffb0cc),
      onColor: Color(0xff541d35),
      colorContainer: Color(0xff6f334c),
      onColorContainer: Color(0xffffd9e4),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffffb0cc),
      onColor: Color(0xff541d35),
      colorContainer: Color(0xff6f334c),
      onColorContainer: Color(0xffffd9e4),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffffb0cc),
      onColor: Color(0xff541d35),
      colorContainer: Color(0xff6f334c),
      onColorContainer: Color(0xffffd9e4),
    ),
  );

  /// String
  static const string = ExtendedColor(
    seed: Color(0xff0aaa81),
    value: Color(0xff0aaa81),
    light: ColorFamily(
      color: Color(0xff1a6b52),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffa6f2d2),
      onColorContainer: Color(0xff00513c),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff1a6b52),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffa6f2d2),
      onColorContainer: Color(0xff00513c),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff1a6b52),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffa6f2d2),
      onColorContainer: Color(0xff00513c),
    ),
    dark: ColorFamily(
      color: Color(0xff8ad6b7),
      onColor: Color(0xff003828),
      colorContainer: Color(0xff00513c),
      onColorContainer: Color(0xffa6f2d2),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xff8ad6b7),
      onColor: Color(0xff003828),
      colorContainer: Color(0xff00513c),
      onColorContainer: Color(0xffa6f2d2),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xff8ad6b7),
      onColor: Color(0xff003828),
      colorContainer: Color(0xff00513c),
      onColorContainer: Color(0xffa6f2d2),
    ),
  );

  List<ExtendedColor> get extendedColors => [
    function,
    variable,
    number,
    boolean,
    string,
  ];
}
