/// A block-based programming framework, primarily designed for mobile devices.
///
/// The main entry points are [DartBlockEditor] to view and edit a
/// [DartBlockProgram], [DartBlockEvaluatorEditor] to configure evaluation
/// schemas, and [DartBlockEvaluationWidget] to display an evaluation result.
library;

// Core: programs and their execution.
export 'src/core/dartblock_execution_result.dart';
export 'src/core/dartblock_executor.dart';
export 'src/core/dartblock_program.dart';

// Models: statements, values, functions, evaluation and exceptions.
export 'src/models/dartblock_interaction.dart';
export 'src/models/dartblock_value.dart';
export 'src/models/environment.dart';
export 'src/models/evaluator.dart';
export 'src/models/exception.dart';
export 'src/models/function.dart';
export 'src/models/function_native.dart';
export 'src/models/statement.dart';

// Widgets.
export 'src/widgets/dartblock_colors.dart'
    show DartBlockColors, ExtendedColor, ColorFamily;
export 'src/widgets/dartblock_editor.dart' show DartBlockEditor;
export 'src/widgets/evaluator_editor.dart' show DartBlockEvaluatorEditor;
export 'src/widgets/views/evaluation/evaluation_widget.dart'
    show DartBlockEvaluationWidget, DartBlockEvaluationResultWidget;
