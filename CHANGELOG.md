## 4.0.0

- Fixed: the on-screen keyboard would cover the active textfield in the Custom Function editor when shown as part of a bottom sheet.
  - The on-screen keyboard now correctly pushes up the entire bottom sheet so as to not cover its contents.
- Migrated to the standalone `material_ui` and `cupertino_ui` packages, decoupled from the Flutter SDK as of Flutter 3.47.
  - All `package:flutter/material.dart` and `package:flutter/cupertino.dart` imports have been replaced with `package:material_ui/material_ui.dart` and `package:cupertino_ui/cupertino_ui.dart` respectively.
  - Consuming apps that also render Material/Cupertino widgets should migrate to `material_ui`/`cupertino_ui` themselves; otherwise, wrap the app in `MaterialUiCompatibilityBridge` to bridge the widget tree with any still-unmigrated dependencies.
  - This is a breaking change: `material_ui`'s `TextTheme` and other types are distinct from the Flutter SDK's own types, so any code passing SDK types (e.g. from packages that haven't migrated yet, such as `google_fonts`) into `dartblock_code` widgets or theming APIs will need to be converted.
  - Fixed: the script view's `CodeField` (from the still-unmigrated `flutter_code_editor` package) failed to render with "No material widget found. TextField widgets require a Material widget ancestor." It is now wrapped in a legacy `Material` ancestor and `MaterialUiCompatibilityBridge` so it resolves both a `Material` ancestor and the legacy Material/Cupertino/Widgets localizations it needs.
  - Updated the example app's Android build to Gradle 9.3.1 and Android Gradle Plugin 9.1.0 (Flutter 3.47's verified versions), needed to build under JDK 25. The Kotlin Gradle Plugin stays on the classic (non-built-in) 2.4.0 setup for now: this Flutter SDK build errors under `android.newDsl=true`, and AGP 9.1.0's built-in Kotlin compiler (2.2.10) is below Flutter's own minimum of 2.2.20.

## 3.1.0

- Removed the `file_picker` 3rd-party dependency from the package.
  - `DartBlockEditor` now exposes an optional `onDownloadScript` callback, which receives the script's content and a suggested file name, allowing consumers to integrate their own file-saving mechanism (e.g., `file_picker`) for downloading the script view of a `DartBlockProgram`.
  - If `onDownloadScript` is not provided, the download button is hidden from the script view's toolbar.
- Upgraded 3rd-party dependencies.

## 3.0.5

- Migrated `onReorder` to `onReorderItem`.
- Upgraded 3rd-party dependencies.

## 3.0.4

- Disabled `flutter_test` dependency to enable WASM support.
- Upgraded 3rd-party dependencies.

## 3.0.3

- Fixed `file_picker`-related issue
- Upgraded 3rd-party dependencies.

## 3.0.2

- Fixed: `file_picker`-related issue

## 3.0.1

- Fixed: `DartBlockEvaluationResultWidget` and `DartBlockEvaluatorEditor` had faulty ProviderScope setups
- Fixed: `DartBlockEditor` had a memory leak related to its isolated ProviderScope container

## 3.0.0

- Revamped "Number Composer" UI
  - Includes a full refresh of the buttons' sizing, colors and spacing.
  - A new clear ("C") button has been added.
- Revamped "Boolean Composer" UI
  - Re-arranged the buttons, with the inclusion of a new button group ("Logic", "Math", "Text") based on Material 3 Expressive.
  - Number comparison operators (>=, >, <, <=) are now included under the "Math" tab.
  - Boolean constants (true, false) are now included under the "Logic" tab.
- Revamped "String Composer" UI
  - New button group design based on Material 3 Expressive.
- All value composers now rely on horizontal scrolling for the display of their values. (previously based on vertical wrapping)
- Revamped "Variable Picker"
  - Available variables are now grouped by type.
- DartBlock's color set can now be customized, though a default set of colors is included.
  - Custom colors can be provided via the new `colors` parameter of `DartBlockEditor`.
- DartBlock values' visualization has been revamped, with a lessened emphasis on various colors to reduce visual overload.
  - Additionally, instead of the usage of padding and elevation, parts of an expression are now delimited using paranthesis.
- Revamped "Toolbox"
  - Removed "docking" mechanism.
  - The toolbox can now be placed either above or below the canvas using the new parameter `isToolboxDockedBottom` for `DartBlockEditor`.
  - Refreshed look.
- Various riverpod-related fixes to ensure the integration of `DartBlockEditor` inside an app does not lead to interference with the host app's `ProviderScope`.
- Revamped function header and body UI
- Fixed condition operators being erroneously interactible when displayed in the canvas.
- Functions in the function picker are now sorted alphabetically.
- Increased spacing between statements and functions.
- Adjusted the `example/` app to migrate its usage of the deprecated `AssetManifest.json` file.
- 3rd-party package `code_text_editor` replaced with `flutter_code_editor`.
- 3rd-party package `reorderables` removed.
- Updated 3rd-party packages.

## 2.0.0

Introducing native functions (min, max, startsWith, ...)!

- New: native DartBlock functions.
  - In contrast to custom functions, which can be defined by the user, DartBlock comes with a set of built-in (native) functions.
  - The initial set of native functions includes: randomInt, sqrt, abs, pow, round, min, max, lowercase, uppercase, startsWith, endsWith, contains, substring
  - Native functions can also be selectively enabled by providing arguments to `DartBlockEditor` for the parameters `allowedNativeFunctionCategories` and `allowedNativeFunctionTypes`.
  - When defining a custom function, its name cannot conflict with that of native functions.
- Fixed: DartBlock exceptions would not interrupt the program execution.
- Changed: the function call composer in the String composer no longer opens as an additional modal bottom sheet, but it is integrated directly within the String composer.
- Fixed: the function call composer no longer automatically closes while the user is editing a parameter. (in the context of the String composer)
- Fixed: when undocked, the toolbox would remain hidden after the user ended dragging a statement type.
- Improved: replaced usage of InheritedWidget with riverpod Providers.
  - Several issues related to faulty BuildContext accesses in relation to modal sheets have been addressed in the process.

## 1.2.0

- Fixed: DartBlockExecutor now kills the spawned isolate if there is an execution timeout.
- Fixed: the program execution via an isolate is now deterministic, with the spawned isolate and the timeout timer on the host no longer being able to return a result at the same time (race condition).
- Improved: a serialized payload is now sent to the spawned isolate for the program execution, with the response to the host also being serialized.

## 1.1.1

- The icons and colors used to represent statement types are now the same across the ToolboxStatementTypeBar and the modal StatementTypePicker.
- Fixes renderflow issues regarding the toolbox when the screen width is too small.
- Adjusted For-loop widget to have its steps be horizontally scrollable when the screen width is too small.
- Minor adjustments to example app.

## 1.1.0

- New dynamic UI elements depending on screen size:
  - Display the statement types in the toolbox in multiple rows (up to 4), depending on the screen height.
  - Display the label for each statement type in the toolbox, depending on the screen width.
  - The following editors will now open in a centered dialog rather than a modal bottom sheet, depending on the screen width:
    - Function editor
    - Function parameter editor
    - Statement type picker
- New visualization for the "For-Loop" statement type.
- New animation when toggling between the "Editor" and "Code" views.
- Added a slight delay (100ms) to the statement type draggable in the toolbox, to avoid conflicts with the scrollable nature of the parent statement bar.
- Changed the color of the "Print" statement type in the toolbox.
- Example app refactor, with additional documentation.

## 1.0.4

- Updated docs

## 1.0.3

- Updated formatting
- Updated docs

## 1.0.2

- Re-generated json_serializable files to fix JSON encoding/decoding functionality.

## 1.0.1

- Public API adjustment

## 1.0.0

- Initial release
