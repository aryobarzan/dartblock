import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/function_native.dart';
import 'package:dartblock_code/widgets/dartblock_colors.dart';
import 'package:flutter/material.dart';
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
class ProgramNotifier extends Notifier<DartBlockProgram> {
  /// Factory method to create a notifier with an initial program.
  /// Useful for overriding the provider with a specific program instance.
  static ProgramNotifier withProgram(DartBlockProgram program) {
    return _ProgramNotifierWithInitialState(program);
  }

  @override
  DartBlockProgram build() => throw UnimplementedError(
    'programProvider must be overridden with actual program',
  );

  @override
  set state(DartBlockProgram newState) => super.state = newState;

  DartBlockProgram update(
    DartBlockProgram Function(DartBlockProgram state) cb,
  ) => state = cb(state);
}

/// Private implementation of ProgramNotifier with an initial state.
class _ProgramNotifierWithInitialState extends ProgramNotifier {
  final DartBlockProgram _program;

  _ProgramNotifierWithInitialState(this._program);

  @override
  DartBlockProgram build() => _program;
}

// New approach for riverpod 3.0.0: from StateProvider to NotifierProvider
final programProvider = NotifierProvider<ProgramNotifier, DartBlockProgram>(
  ProgramNotifier.new,
);

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
  final DartBlockColors colors;
  final DartBlockColorFamily colorFamily;

  DartBlockSettings({
    this.canChange = true,
    this.canDelete = true,
    this.canReorder = true,
    this.allowedNativeFunctionCategories =
        DartBlockNativeFunctionCategory.values,
    this.allowedNativeFunctionTypes = DartBlockNativeFunctionType.values,
    DartBlockColors? colors,
    required this.colorFamily,
  }) : colors = colors ?? DartBlockColors.native();

  /// Convenience factory that automatically resolves colors based on brightness.
  factory DartBlockSettings.fromBrightness({
    bool canChange = true,
    bool canDelete = true,
    bool canReorder = true,
    List<DartBlockNativeFunctionCategory> allowedNativeFunctionCategories =
        DartBlockNativeFunctionCategory.values,
    List<DartBlockNativeFunctionType> allowedNativeFunctionTypes =
        DartBlockNativeFunctionType.values,
    DartBlockColors? colors,
    required Brightness brightness,
  }) {
    final resolvedColors = colors ?? DartBlockColors.native();
    return DartBlockSettings(
      canChange: canChange,
      canDelete: canDelete,
      canReorder: canReorder,
      allowedNativeFunctionCategories: allowedNativeFunctionCategories,
      allowedNativeFunctionTypes: allowedNativeFunctionTypes,
      colors: resolvedColors,
      colorFamily: DartBlockColorFamily.fromColors(resolvedColors, brightness),
    );
  }
}

// ============================================================================
// Editor State Providers
// ============================================================================

/// Provider for tracking whether a toolbox item is being dragged.
class IsDraggingToolboxItemNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  @override
  set state(bool newState) => super.state = newState;

  bool update(bool Function(bool state) cb) => state = cb(state);
}

final isDraggingToolboxItemProvider =
    NotifierProvider<IsDraggingToolboxItemNotifier, bool>(
      IsDraggingToolboxItemNotifier.new,
    );

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
class EditorStateNotifier extends Notifier<DartBlockEditorState> {
  @override
  DartBlockEditorState build() => const DartBlockEditorState(
    copiedStatement: null,
    isCopiedStatementCut: false,
  );

  @override
  set state(DartBlockEditorState newState) => super.state = newState;

  DartBlockEditorState update(
    DartBlockEditorState Function(DartBlockEditorState state) cb,
  ) => state = cb(state);

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

/// Provider for editor UI state (clipboard, dragging, etc.)
final editorStateProvider =
    NotifierProvider<EditorStateNotifier, DartBlockEditorState>(
      EditorStateNotifier.new,
    );

// ============================================================================
// Interaction Event Provider
// ============================================================================

/// Provider for broadcasting user interactions throughout the editor.
/// This replaces the Notification bubbling system and works across all contexts,
/// including modals and overlays, without manual re-dispatching.
class InteractionEventNotifier extends Notifier<DartBlockInteraction?> {
  @override
  DartBlockInteraction? build() => null;

  @override
  set state(DartBlockInteraction? newState) => super.state = newState;

  DartBlockInteraction? update(
    DartBlockInteraction? Function(DartBlockInteraction? state) cb,
  ) => state = cb(state);

  /// Broadcast an interaction event
  void broadcast(DartBlockInteraction interaction) {
    state = interaction;
  }
}

final interactionEventProvider =
    NotifierProvider<InteractionEventNotifier, DartBlockInteraction?>(
      InteractionEventNotifier.new,
    );

/// Helper extension to easily broadcast interactions from any widget with WidgetRef.
extension InteractionBroadcaster on WidgetRef {
  /// Broadcast a user interaction event to all listeners.
  void broadcastInteraction(DartBlockInteraction interaction) {
    read(interactionEventProvider.notifier).broadcast(interaction);
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
