import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A DropdownButton that maintains access to Riverpod providers.
///
/// This widget wraps the standard DropdownButton and ensures that the dropdown
/// items and their callbacks have access to the parent context's providers.
class ProviderAwareDropdownButton<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>>? items;
  final List<DropdownMenuItem<T>> Function(BuildContext)? itemBuilder;
  final T? value;
  final Widget? hint;
  final Widget? disabledHint;
  final void Function(T?)? onChanged;
  final void Function()? onTap;
  final int elevation;
  final TextStyle? style;
  final Widget? underline;
  final Widget? icon;
  final Color? iconDisabledColor;
  final Color? iconEnabledColor;
  final double iconSize;
  final bool isDense;
  final bool isExpanded;
  final double? itemHeight;
  final Color? focusColor;
  final FocusNode? focusNode;
  final bool autofocus;
  final Color? dropdownColor;
  final double? menuMaxHeight;
  final bool? enableFeedback;
  final AlignmentGeometry alignment;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const ProviderAwareDropdownButton({
    super.key,
    this.items,
    this.itemBuilder,
    this.value,
    this.hint,
    this.disabledHint,
    required this.onChanged,
    this.onTap,
    this.elevation = 8,
    this.style,
    this.underline,
    this.icon,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.iconSize = 24.0,
    this.isDense = false,
    this.isExpanded = false,
    this.itemHeight,
    this.focusColor,
    this.focusNode,
    this.autofocus = false,
    this.dropdownColor,
    this.menuMaxHeight,
    this.enableFeedback,
    this.alignment = AlignmentDirectional.centerStart,
    this.borderRadius,
    this.padding,
  }) : assert(
         items != null || itemBuilder != null,
         'Either items or itemBuilder must be provided',
       );

  @override
  Widget build(BuildContext context) {
    // Capture the provider container from the current context
    final container = ProviderScope.containerOf(context);

    // Wrap items if provided directly
    List<DropdownMenuItem<T>>? wrappedItems;
    if (items != null) {
      wrappedItems = items!.map((item) {
        return DropdownMenuItem<T>(
          value: item.value,
          onTap: item.onTap,
          enabled: item.enabled,
          alignment: item.alignment,
          child: UncontrolledProviderScope(
            container: container,
            child: item.child,
          ),
        );
      }).toList();
    }

    return DropdownButton<T>(
      items: wrappedItems,
      selectedItemBuilder: itemBuilder != null
          ? (menuContext) {
              return itemBuilder!(menuContext).map((item) {
                return UncontrolledProviderScope(
                  container: container,
                  child: item.child,
                );
              }).toList();
            }
          : null,
      value: value,
      hint: hint,
      disabledHint: disabledHint,
      onChanged: onChanged,
      onTap: onTap,
      elevation: elevation,
      style: style,
      underline: underline,
      icon: icon,
      iconDisabledColor: iconDisabledColor,
      iconEnabledColor: iconEnabledColor,
      iconSize: iconSize,
      isDense: isDense,
      isExpanded: isExpanded,
      itemHeight: itemHeight,
      focusColor: focusColor,
      focusNode: focusNode,
      autofocus: autofocus,
      dropdownColor: dropdownColor,
      menuMaxHeight: menuMaxHeight,
      enableFeedback: enableFeedback,
      alignment: alignment,
      borderRadius: borderRadius,
      padding: padding,
    );
  }
}

/// A DropdownButtonFormField that maintains access to Riverpod providers.
///
/// This widget wraps the standard DropdownButtonFormField and ensures that the
/// dropdown items and their callbacks have access to the parent context's providers.
class ProviderAwareDropdownButtonFormField<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>>? items;
  final List<DropdownMenuItem<T>> Function(BuildContext)? itemBuilder;
  final T? initialValue;
  final Widget? hint;
  final Widget? disabledHint;
  final void Function(T?)? onChanged;
  final void Function()? onTap;
  final int elevation;
  final TextStyle? style;
  final Widget? icon;
  final Color? iconDisabledColor;
  final Color? iconEnabledColor;
  final double iconSize;
  final bool isDense;
  final bool isExpanded;
  final double? itemHeight;
  final Color? focusColor;
  final FocusNode? focusNode;
  final bool autofocus;
  final Color? dropdownColor;
  final double? menuMaxHeight;
  final bool? enableFeedback;
  final AlignmentGeometry alignment;
  final BorderRadius? borderRadius;
  final InputDecoration? decoration;
  final FormFieldSetter<T>? onSaved;
  final FormFieldValidator<T>? validator;
  final AutovalidateMode? autovalidateMode;
  final EdgeInsetsGeometry? padding;

  const ProviderAwareDropdownButtonFormField({
    super.key,
    this.items,
    this.itemBuilder,
    this.initialValue,
    this.hint,
    this.disabledHint,
    required this.onChanged,
    this.onTap,
    this.elevation = 8,
    this.style,
    this.icon,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.iconSize = 24.0,
    this.isDense = false,
    this.isExpanded = false,
    this.itemHeight,
    this.focusColor,
    this.focusNode,
    this.autofocus = false,
    this.dropdownColor,
    this.menuMaxHeight,
    this.enableFeedback,
    this.alignment = AlignmentDirectional.centerStart,
    this.borderRadius,
    this.decoration,
    this.onSaved,
    this.validator,
    this.autovalidateMode,
    this.padding,
  }) : assert(
         items != null || itemBuilder != null,
         'Either items or itemBuilder must be provided',
       );

  @override
  Widget build(BuildContext context) {
    // Capture the provider container from the current context
    final container = ProviderScope.containerOf(context);

    // Wrap items if provided directly
    List<DropdownMenuItem<T>>? wrappedItems;
    if (items != null) {
      wrappedItems = items!.map((item) {
        return DropdownMenuItem<T>(
          value: item.value,
          onTap: item.onTap,
          enabled: item.enabled,
          alignment: item.alignment,
          child: UncontrolledProviderScope(
            container: container,
            child: item.child,
          ),
        );
      }).toList();
    }

    return DropdownButtonFormField<T>(
      items: wrappedItems,
      selectedItemBuilder: itemBuilder != null
          ? (menuContext) {
              return itemBuilder!(menuContext).map((item) {
                return UncontrolledProviderScope(
                  container: container,
                  child: item.child,
                );
              }).toList();
            }
          : null,
      initialValue: initialValue,
      hint: hint,
      disabledHint: disabledHint,
      onChanged: onChanged,
      onTap: onTap,
      elevation: elevation,
      style: style,
      icon: icon,
      iconDisabledColor: iconDisabledColor,
      iconEnabledColor: iconEnabledColor,
      iconSize: iconSize,
      isDense: isDense,
      isExpanded: isExpanded,
      itemHeight: itemHeight,
      focusColor: focusColor,
      focusNode: focusNode,
      autofocus: autofocus,
      dropdownColor: dropdownColor,
      menuMaxHeight: menuMaxHeight,
      enableFeedback: enableFeedback,
      alignment: alignment,
      borderRadius: borderRadius,
      decoration: decoration,
      onSaved: onSaved,
      validator: validator,
      autovalidateMode: autovalidateMode,
      padding: padding,
    );
  }
}
