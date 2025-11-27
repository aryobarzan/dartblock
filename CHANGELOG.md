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
