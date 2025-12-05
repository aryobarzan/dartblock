import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/function_native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartblock_code/core/dartblock_executor.dart';
import 'package:dartblock_code/core/dartblock_program.dart';
import 'package:dartblock_code/models/dartblock_interaction.dart';
import 'package:dartblock_code/models/function.dart';
import 'package:dartblock_code/models/statement.dart';

// ============================================================================
// Program & Execution Providers
// ============================================================================

/// Global provider for the DartBlock program.
/// Must be overridden per DartBlockEditor instance.
final programProvider = StateProvider<DartBlockProgram>((ref) {
  throw UnimplementedError(
    'programProvider must be overridden with actual program',
  );
});

/// Derived provider that exposes the list of custom functions.
final customFunctionsProvider = Provider<List<DartBlockCustomFunction>>((ref) {
  return ref.watch(programProvider).customFunctions;
});

/// Derived provider that creates an executor for the current program.
/// Keeps track of the execution result, including the console output and any exception that was thrown.
final executorProvider = Provider<DartBlockExecutor>((ref) {
  final program = ref.watch(programProvider);
  return DartBlockExecutor(program);
});

// ============================================================================
// Settings Provider
// ============================================================================

/// Global provider for editor settings (permissions).
/// Must be overridden per DartBlockEditor instance.
final settingsProvider = Provider<DartBlockSettings>((ref) {
  throw UnimplementedError('settingsProvider must be overridden');
});

/// Immutable settings for the DartBlock editor.
class DartBlockSettings {
  final bool canChange;
  final bool canDelete;
  final bool canReorder;
  final List<DartBlockNativeFunctionCategory> allowedNativeFunctionCategories;
  final List<DartBlockNativeFunctionType> allowedNativeFunctionTypes;

  const DartBlockSettings({
    this.canChange = true,
    this.canDelete = true,
    this.canReorder = true,
    this.allowedNativeFunctionCategories =
        DartBlockNativeFunctionCategory.values,
    this.allowedNativeFunctionTypes = DartBlockNativeFunctionType.values,
  });
}

// ============================================================================
// Editor State Providers
// ============================================================================

/// Provider for editor UI state (clipboard, dragging, etc.)
final editorStateProvider =
    StateNotifierProvider<EditorStateNotifier, DartBlockEditorState>((ref) {
      return EditorStateNotifier();
    });

/// Provider for tracking whether a toolbox item is being dragged.
final isDraggingToolboxItemProvider = StateProvider<bool>((ref) => false);

/// Immutable state for the DartBlock editor clipboard.
class DartBlockEditorState {
  final Statement? copiedStatement;
  final bool isCopiedStatementCut;

  const DartBlockEditorState({
    required this.copiedStatement,
    required this.isCopiedStatementCut,
  });
}

/// State notifier for managing editor clipboard operations.
class EditorStateNotifier extends StateNotifier<DartBlockEditorState> {
  EditorStateNotifier()
    : super(
        const DartBlockEditorState(
          copiedStatement: null,
          isCopiedStatementCut: false,
        ),
      );

  /// Copy or cut a statement to the clipboard.
  void copyStatement(Statement statement, {bool cut = false}) {
    state = DartBlockEditorState(
      copiedStatement: statement.copy(),
      isCopiedStatementCut: cut,
    );
  }

  /// Clear the clipboard.
  void clearClipboard() {
    state = const DartBlockEditorState(
      copiedStatement: null,
      isCopiedStatementCut: false,
    );
  }
}

// ============================================================================
// Interaction Event Provider
// ============================================================================

/// Provider for broadcasting user interactions throughout the editor.
/// This replaces the Notification bubbling system and works across all contexts,
/// including modals and overlays, without manual re-dispatching.
final interactionEventProvider = StateProvider<DartBlockInteraction?>(
  (ref) => null,
);

/// Helper extension to easily broadcast interactions from any widget with WidgetRef.
extension InteractionBroadcaster on WidgetRef {
  /// Broadcast a user interaction event to all listeners.
  void broadcastInteraction(DartBlockInteraction interaction) {
    read(interactionEventProvider.notifier).state = interaction;
  }
}

/// Available custom functions filtered by return type restrictions
final availableCustomFunctionsProvider =
    Provider.family<List<DartBlockCustomFunction>, List<DartBlockDataType>>((
      ref,
      restrictToDataTypes,
    ) {
      return ref
          .watch(programProvider)
          .customFunctions
          .where(
            (f) =>
                restrictToDataTypes.isEmpty ||
                restrictToDataTypes.contains(f.returnType),
          )
          .toList();
    });

/// Available native functions filtered by settings and return type
final availableNativeFunctionsProvider =
    Provider.family<List<DartBlockNativeFunction>, List<DartBlockDataType>>((
      ref,
      restrictToDataTypes,
    ) {
      final settings = ref.watch(settingsProvider);
      return DartBlockNativeFunctions.filter(
            settings.allowedNativeFunctionCategories,
            settings.allowedNativeFunctionTypes,
          )
          .where(
            (f) =>
                restrictToDataTypes.isEmpty ||
                restrictToDataTypes.contains(f.returnType),
          )
          .toList();
    });

final availableFunctionsProvider =
    Provider.family<List<DartBlockFunction>, List<DartBlockDataType>>((
      ref,
      restrictToDataTypes,
    ) {
      final customFunctions = ref.watch(
        availableCustomFunctionsProvider(restrictToDataTypes),
      );
      final nativeFunctions = ref.watch(
        availableNativeFunctionsProvider(restrictToDataTypes),
      );
      return [...customFunctions, ...nativeFunctions];
    });
