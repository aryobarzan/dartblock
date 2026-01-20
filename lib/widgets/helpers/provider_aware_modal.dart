import 'package:dartblock_code/widgets/helpers/dartblock_container_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Extension on BuildContext to show modals that maintain provider access.
extension ProviderAwareModal on BuildContext {
  /// Gets the correct ProviderContainer for modals and dialogs.
  ///
  /// Tries to get DartBlockEditor's container first (via DartBlockContainerProvider),
  /// then falls back to the nearest ProviderScope's container.
  ///
  /// This ensures that modals opened from within DartBlockEditor always have access
  /// to the correct providers with overrides, even when the app has its own
  /// root-level ProviderScope.
  ProviderContainer _getProviderContainer() {
    // First, try to find DartBlockEditor's container from InheritedWidget
    final dartBlockContainer = DartBlockContainerProvider.maybeOf(this);
    if (dartBlockContainer != null) {
      return dartBlockContainer;
    }

    // Fall back to the nearest ProviderScope's container
    // This happens when the modal is not opened from within DartBlockEditor
    return ProviderScope.containerOf(this);
  }

  /// Shows a modal bottom sheet that maintains access to Riverpod providers.
  ///
  /// This automatically wraps the builder content in an UncontrolledProviderScope
  /// so that widgets inside the modal can access providers from the parent context.
  ///
  /// When called from within DartBlockEditor, it uses DartBlockEditor's provider
  /// container (with overrides). Otherwise, it uses the nearest ProviderScope's container.
  Future<T?> showProviderAwareBottomSheet<T>({
    required Widget Function(BuildContext) builder,
    bool isScrollControlled = true,
    bool showDragHandle = true,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    Color? barrierColor,
    bool useRootNavigator = false,
    RouteSettings? routeSettings,
  }) {
    return showModalBottomSheet<T>(
      context: this,
      isScrollControlled: isScrollControlled,
      showDragHandle: showDragHandle,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
      barrierColor: barrierColor,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      builder: (modalContext) {
        return UncontrolledProviderScope(
          container: _getProviderContainer(),
          child: builder(modalContext),
        );
      },
    );
  }

  /// Shows a dialog that maintains access to Riverpod providers.
  ///
  /// This automatically wraps the builder content in an UncontrolledProviderScope
  /// so that widgets inside the dialog can access providers from the parent context.
  ///
  /// When called from within DartBlockEditor, it uses DartBlockEditor's provider
  /// container (with overrides). Otherwise, it uses the nearest ProviderScope's container.
  Future<T?> showProviderAwareDialog<T>({
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
  }) {
    return showDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      anchorPoint: anchorPoint,
      traversalEdgeBehavior: traversalEdgeBehavior,
      builder: (dialogContext) {
        return UncontrolledProviderScope(
          container: _getProviderContainer(),
          child: builder(dialogContext),
        );
      },
    );
  }
}
