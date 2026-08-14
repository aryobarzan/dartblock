import 'package:example/pages/root_page.dart';
import 'package:example/theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' as legacy_material;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black.withValues(alpha: 0.002),
    ),
  );
  runApp(const DartBlockExample());
}

class DartBlockExample extends StatelessWidget {
  const DartBlockExample({super.key});

  @override
  Widget build(BuildContext context) {
    /// Important: the dartblock_code package relies on riverpod for state management.
    /// However, if the host app also relies on riverpod, there will be no conflicts between
    /// the ProviderScopes of the host app and dartblock_code itself.
    ///
    /// In other words, whether your app uses riverpod or not, dartblock_code will work seamlessly.
    return ProviderScope(
      child: MaterialApp(
        scrollBehavior: _ScrollBehavior(),
        debugShowCheckedModeBanner: false,
        title: 'DartBlock',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: MaterialTheme.lightScheme(),
          textTheme: _materialUiTextTheme(GoogleFonts.robotoTextTheme()),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: MaterialTheme.darkScheme(),
          textTheme: _materialUiTextTheme(
            GoogleFonts.robotoTextTheme(
              legacy_material.ThemeData(brightness: Brightness.dark).textTheme,
            ),
          ),
        ),
        home: const RootPage(),
      ),
    );
  }
}

/// google_fonts hasn't migrated to `package:material_ui` yet, so it still
/// returns a `package:flutter/material.dart` [legacy_material.TextTheme],
/// which is a distinct type from `package:material_ui`'s [TextTheme]. This
/// copies the resolved styles across the two otherwise-identical types.
TextTheme _materialUiTextTheme(legacy_material.TextTheme theme) {
  return TextTheme(
    displayLarge: theme.displayLarge,
    displayMedium: theme.displayMedium,
    displaySmall: theme.displaySmall,
    headlineLarge: theme.headlineLarge,
    headlineMedium: theme.headlineMedium,
    headlineSmall: theme.headlineSmall,
    titleLarge: theme.titleLarge,
    titleMedium: theme.titleMedium,
    titleSmall: theme.titleSmall,
    bodyLarge: theme.bodyLarge,
    bodyMedium: theme.bodyMedium,
    bodySmall: theme.bodySmall,
    labelLarge: theme.labelLarge,
    labelMedium: theme.labelMedium,
    labelSmall: theme.labelSmall,
  );
}

class _ScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
