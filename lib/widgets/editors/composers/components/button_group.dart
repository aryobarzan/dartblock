import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class ButtonGroup<T> extends StatelessWidget {
  final List<ButtonGroupItem<T>> items;
  final Set<T> selected;
  final bool emptySelectionAllowed;
  final bool multiSelectionAllowed;

  final Function(Set<T>)? onSelectionChanged;
  const ButtonGroup({
    super.key,
    required this.items,
    required this.selected,
    this.emptySelectionAllowed = true,
    this.onSelectionChanged,
    this.multiSelectionAllowed = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final fullRadius = height / 2;
        final halfRadius = height / 4;

        return Row(
          spacing: 2,
          children: items
              .mapIndexed(
                (index, item) => Expanded(
                  child: ButtonGroupItemWidget(
                    item: item,
                    isSelected: selected.contains(item.value),
                    borderRadius: selected.contains(item.value)
                        ? BorderRadius.circular(fullRadius)
                        : index == 0 && items.length > 1
                        ? BorderRadius.only(
                            topLeft: Radius.circular(fullRadius),
                            bottomLeft: Radius.circular(fullRadius),
                            topRight: Radius.circular(halfRadius),
                            bottomRight: Radius.circular(halfRadius),
                          )
                        : index == items.length - 1 && items.length > 1
                        ? BorderRadius.only(
                            topRight: Radius.circular(fullRadius),
                            bottomRight: Radius.circular(fullRadius),
                            topLeft: Radius.circular(halfRadius),
                            bottomLeft: Radius.circular(halfRadius),
                          )
                        : BorderRadius.circular(halfRadius),
                    onTap: item.enabled
                        ? () {
                            final newSelected = Set<T>.from(selected);
                            if (newSelected.contains(item.value)) {
                              if (emptySelectionAllowed ||
                                  newSelected.length > 1) {
                                newSelected.remove(item.value);
                              }
                            } else {
                              if (!multiSelectionAllowed) {
                                newSelected.clear();
                              }
                              newSelected.add(item.value);
                            }
                            if (onSelectionChanged != null) {
                              onSelectionChanged!(newSelected);
                            }
                          }
                        : null,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class ButtonGroupItem<T> {
  ButtonGroupItem({
    required this.value,
    this.icon,
    this.label,
    this.tooltip,
    this.enabled = true,
  });

  T value;
  IconData? icon;
  String? label;
  String? tooltip;
  bool enabled = true;
}

class ButtonGroupItemWidget<T> extends StatelessWidget {
  final ButtonGroupItem<T> item;
  final bool isSelected;
  final Function()? onTap;
  final BorderRadius borderRadius;
  const ButtonGroupItemWidget({
    super.key,
    required this.item,
    required this.isSelected,
    this.onTap,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor = !item.enabled
        ? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
        : isSelected
        ? Theme.of(context).colorScheme.onSecondaryContainer
        : Theme.of(context).colorScheme.onSurface;
    return Material(
      borderRadius: borderRadius,
      color: !item.enabled
          ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)
          : isSelected
          ? Theme.of(context).colorScheme.secondaryContainer
          : Theme.of(context).colorScheme.outlineVariant,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(borderRadius: borderRadius),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 4,
            children: [
              if (item.icon != null)
                Icon(item.icon!, size: 24, color: foregroundColor)
              else if (isSelected)
                Icon(Icons.check, size: 24, color: foregroundColor)
              else
                const SizedBox(height: 24),
              if (item.label != null)
                Text(
                  item.label!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.apply(color: foregroundColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
