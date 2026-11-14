import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides access to DartBlockEditor's ProviderContainer throughout its subtree.
///
/// This ensures that modals, dialogs, and overlays opened from within DartBlockEditor
/// can access the correct provider container with all the necessary overrides,
/// even when the app has its own ProviderScope at the root level.
///
/// The container is captured from the Consumer widget's build context in DartBlockEditor,
/// ensuring it's always the correct nested ProviderScope with overrides.
class DartBlockContainerProvider extends InheritedWidget {
  /// The provider container for this DartBlockEditor instance.
  final ProviderContainer container;

  const DartBlockContainerProvider({
    super.key,
    required this.container,
    required super.child,
  });

  /// Retrieves the DartBlockEditor's ProviderContainer from the context.
  ///
  /// Returns null if no DartBlockContainerProvider is found in the widget tree.
  /// This allows graceful fallback to the default behavior when not within DartBlockEditor.
  static ProviderContainer? maybeOf(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<DartBlockContainerProvider>();
    return provider?.container;
  }

  /// Retrieves the DartBlockEditor's ProviderContainer from the context.
  ///
  /// Throws an assertion error if no DartBlockContainerProvider is found in the widget tree.
  /// Use this when you're certain the context is within a DartBlockEditor.
  static ProviderContainer of(BuildContext context) {
    final container = maybeOf(context);
    assert(
      container != null,
      'DartBlockContainerProvider not found in widget tree. '
      'This widget must be a descendant of DartBlockEditor.',
    );
    return container!;
  }

  @override
  bool updateShouldNotify(DartBlockContainerProvider oldWidget) {
    return container != oldWidget.container;
  }
}
