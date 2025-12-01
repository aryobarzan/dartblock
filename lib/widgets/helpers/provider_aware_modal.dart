import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Extension on BuildContext to show modals that maintain provider access.
extension ProviderAwareModal on BuildContext {
  /// Shows a modal bottom sheet that maintains access to Riverpod providers.
  ///
  /// This automatically wraps the builder content in an UncontrolledProviderScope
  /// so that widgets inside the modal can access providers from the parent context.
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
          container: ProviderScope.containerOf(this),
          child: builder(modalContext),
        );
      },
    );
  }

  /// Shows a dialog that maintains access to Riverpod providers.
  ///
  /// This automatically wraps the builder content in an UncontrolledProviderScope
  /// so that widgets inside the dialog can access providers from the parent context.
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
          container: ProviderScope.containerOf(this),
          child: builder(dialogContext),
        );
      },
    );
  }
}
