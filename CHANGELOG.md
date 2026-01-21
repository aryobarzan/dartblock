## 3.0.1

- Fixed: `DartBlockEvaluationResultWidget` and `DartBlockEvaluatorEditor` had faulty ProviderSccope setups
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
