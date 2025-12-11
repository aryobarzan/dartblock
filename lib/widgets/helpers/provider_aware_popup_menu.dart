import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A PopupMenuButton that maintains access to Riverpod providers.
///
/// This widget wraps the standard PopupMenuButton and ensures that the menu
/// items and their callbacks have access to the parent context's providers.
class ProviderAwarePopupMenuButton<T> extends StatelessWidget {
  final List<PopupMenuEntry<T>> Function(BuildContext) itemBuilder;
  final T? initialValue;
  final void Function(T)? onSelected;
  final void Function()? onCanceled;
  final String? tooltip;
  final double? elevation;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? menuPadding;
  final BorderRadius? borderRadius;
  final double? splashRadius;
  final ButtonStyle? style;
  final bool? requestFocus;
  final bool useRootNavigator;
  final Widget? child;
  final Widget? icon;
  final Offset offset;
  final bool enabled;
  final ShapeBorder? shape;
  final Color? color;
  final Color? iconColor;
  final double? iconSize;
  final bool? enableFeedback;
  final BoxConstraints? constraints;
  final PopupMenuPosition? position;
  final Clip clipBehavior;
  final RouteSettings? routeSettings;
  final AnimationStyle? popUpAnimationStyle;
  final VoidCallback? onOpened;

  const ProviderAwarePopupMenuButton({
    super.key,
    required this.itemBuilder,
    this.initialValue,
    this.onOpened,
    this.onSelected,
    this.onCanceled,
    this.tooltip,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.padding = const EdgeInsets.all(8.0),
    this.menuPadding,
    this.child,
    this.borderRadius,
    this.splashRadius,
    this.icon,
    this.iconSize,
    this.offset = Offset.zero,
    this.enabled = true,
    this.shape,
    this.color,
    this.iconColor,
    this.enableFeedback,
    this.constraints,
    this.position,
    this.clipBehavior = Clip.none,
    this.useRootNavigator = false,
    this.popUpAnimationStyle,
    this.routeSettings,
    this.style,
    this.requestFocus,
  });

  @override
  Widget build(BuildContext context) {
    // Capture the provider container from the current context
    final container = ProviderScope.containerOf(context);

    return PopupMenuButton<T>(
      initialValue: initialValue,
      onSelected: onSelected,
      onCanceled: onCanceled,
      tooltip: tooltip,
      elevation: elevation,
      padding: padding ?? const EdgeInsets.all(8.0),
      offset: offset,
      enabled: enabled,
      shape: shape,
      color: color,
      iconColor: iconColor,
      iconSize: iconSize,
      enableFeedback: enableFeedback,
      constraints: constraints,
      position: position,
      clipBehavior: clipBehavior,
      routeSettings: routeSettings,
      popUpAnimationStyle: popUpAnimationStyle,
      onOpened: onOpened,
      icon: icon,
      borderRadius: borderRadius,
      splashRadius: splashRadius,
      surfaceTintColor: surfaceTintColor,
      shadowColor: shadowColor,
      menuPadding: menuPadding,
      style: style,
      requestFocus: requestFocus,
      useRootNavigator: useRootNavigator,
      // Wrap the itemBuilder to provide the container to menu items
      itemBuilder: (menuContext) {
        return itemBuilder(menuContext).map<PopupMenuEntry<T>>((item) {
          // Wrap each menu item in UncontrolledProviderScope
          if (item is PopupMenuItem<T>) {
            return PopupMenuItem<T>(
              key: item.key,
              value: item.value,
              onTap: item.onTap,
              enabled: item.enabled,
              height: item.height,
              padding: item.padding,
              textStyle: item.textStyle,
              labelTextStyle: item.labelTextStyle,
              mouseCursor: item.mouseCursor,
              child: UncontrolledProviderScope(
                container: container,
                child: item.child ?? const SizedBox.shrink(),
              ),
            );
          } else if (item is CheckedPopupMenuItem<T>) {
            return CheckedPopupMenuItem<T>(
              key: item.key,
              value: item.value,
              checked: item.checked,
              enabled: item.enabled,
              padding: item.padding,
              height: item.height,
              labelTextStyle: item.labelTextStyle,
              mouseCursor: item.mouseCursor,
              onTap: item.onTap,
              child: UncontrolledProviderScope(
                container: container,
                child: item.child ?? const SizedBox.shrink(),
              ),
            );
          }
          // Return other types (like PopupMenuDivider) as-is
          return item;
        }).toList();
      },
      child: child,
    );
  }
}

/// Extension on BuildContext to show provider-aware popup menus.
extension ProviderAwarePopupMenuExtension on BuildContext {
  /// Shows a popup menu that maintains access to Riverpod providers.
  ///
  /// This automatically wraps the menu items in an UncontrolledProviderScope
  /// so that widgets inside the menu can access providers from the parent context.
  Future<T?> showProviderAwareMenu<T>({
    required RelativeRect position,
    required List<PopupMenuEntry<T>> items,
    T? initialValue,
    double? elevation,
    Color? shadowColor,
    Color? surfaceTintColor,
    String? semanticLabel,
    ShapeBorder? shape,
    Color? color,
    BoxConstraints? constraints,
    Clip clipBehavior = Clip.none,
    RouteSettings? routeSettings,
    AnimationStyle? popUpAnimationStyle,
    bool useRootNavigator = false,
  }) {
    // Capture the provider container from the current context
    final container = ProviderScope.containerOf(this);

    // Wrap each menu item in UncontrolledProviderScope
    final wrappedItems = items.map<PopupMenuEntry<T>>((item) {
      if (item is PopupMenuItem<T>) {
        return PopupMenuItem<T>(
          key: item.key,
          value: item.value,
          onTap: item.onTap,
          enabled: item.enabled,
          height: item.height,
          padding: item.padding,
          textStyle: item.textStyle,
          labelTextStyle: item.labelTextStyle,
          mouseCursor: item.mouseCursor,
          child: UncontrolledProviderScope(
            container: container,
            child: item.child ?? const SizedBox.shrink(),
          ),
        );
      } else if (item is CheckedPopupMenuItem<T>) {
        return CheckedPopupMenuItem<T>(
          key: item.key,
          value: item.value,
          checked: item.checked,
          enabled: item.enabled,
          padding: item.padding,
          height: item.height,
          labelTextStyle: item.labelTextStyle,
          mouseCursor: item.mouseCursor,
          onTap: item.onTap,
          child: UncontrolledProviderScope(
            container: container,
            child: item.child ?? const SizedBox.shrink(),
          ),
        );
      }
      // Return other types (like PopupMenuDivider) as-is
      return item;
    }).toList();

    return showMenu<T>(
      context: this,
      position: position,
      items: wrappedItems,
      initialValue: initialValue,
      elevation: elevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      semanticLabel: semanticLabel,
      shape: shape,
      color: color,
      constraints: constraints,
      clipBehavior: clipBehavior,
      routeSettings: routeSettings,
      popUpAnimationStyle: popUpAnimationStyle,
      useRootNavigator: useRootNavigator,
    );
  }
}
