import 'package:flutter/material.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/widgets/views/symbols.dart';

class DartBlockDataTypePicker extends StatelessWidget {
  final DartBlockDataType? dataType;
  final bool allowVoid;
  final Function(DartBlockDataType?)? onChanged;
  final String? tooltip;
  final Icon? icon;
  final bool isIconLeft;
  final bool isExpanded;
  const DartBlockDataTypePicker({
    super.key,
    required this.dataType,
    this.onChanged,
    this.tooltip,
    this.icon,
    this.isIconLeft = false,
    this.isExpanded = false,
  }) : allowVoid = true;

  const DartBlockDataTypePicker.noVoid({
    super.key,
    required DartBlockDataType this.dataType,
    this.allowVoid = false,
    this.onChanged,
    this.tooltip,
    this.icon,
    this.isIconLeft = false,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    if (onChanged != null) {
      return PopupMenuButton<DartBlockDataType?>(
        offset: const Offset(0, 8),
        tooltip: tooltip ?? "Data type",
        position: PopupMenuPosition.under,
        initialValue: dataType,
        // Callback that sets the selected popup menu item.
        onSelected: (DartBlockDataType? item) {
          if (onChanged != null) {
            onChanged!(item);
          }
        },
        itemBuilder: (BuildContext context) =>
            [
              if (allowVoid)
                PopupMenuItem<DartBlockDataType>(
                  value: null,
                  child: const VoidSymbol(includeLabel: true),
                  onTap: () {
                    /// onTap is necessary here, as PopupMenuButton's onSelected
                    /// callback is not triggered for null value.
                    if (onChanged != null) {
                      onChanged!(null);
                    }
                  },
                ),
            ] +
            DartBlockDataType.values
                .map(
                  (e) => PopupMenuItem<DartBlockDataType>(
                    value: e,
                    child: NeoTechDataTypeSymbol(
                      dataType: e,
                      includeLabel: true,
                    ),
                  ),
                )
                .toList(),
        child: _buildLabel(),
      );
    } else {
      return _buildLabel();
    }
  }

  Widget _buildLabel() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onChanged != null && isIconLeft)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: icon ?? const Icon(Icons.arrow_drop_down),
          ),
        dataType != null
            ? NeoTechDataTypeSymbol(dataType: dataType!, includeLabel: true)
            : const VoidSymbol(includeLabel: true),
        if (onChanged != null && !isIconLeft)
          icon ?? const Icon(Icons.arrow_drop_down),
      ],
    );
  }
}
