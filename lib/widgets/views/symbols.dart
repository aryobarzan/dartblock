import 'dart:math';

import 'package:dartblock_code/widgets/dartblock_editor_providers.dart';
import 'package:flutter/material.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DartBlockVoidSymbol extends StatelessWidget {
  final bool includeLabel;
  final BorderRadius? borderRadius;
  const DartBlockVoidSymbol({
    super.key,
    this.includeLabel = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (includeLabel) {
      return TwoTonedChip(
        left: Icon(
          Icons.adjust,
          size: 20,
          color: Theme.of(context).colorScheme.onTertiaryContainer,
        ),
        right: Text(
          'void',
          style: Theme.of(context).textTheme.bodyMedium?.apply(
            color: Theme.of(context).colorScheme.onTertiary,
          ),
        ),
        leftColor: Theme.of(context).colorScheme.tertiaryContainer,
        rightColor: Theme.of(context).colorScheme.tertiary,
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          borderRadius:
              borderRadius ??
              BorderRadius.only(
                topLeft: const Radius.circular(4),
                bottomLeft: const Radius.circular(4),
                topRight: !includeLabel
                    ? const Radius.circular(4)
                    : Radius.zero,
                bottomRight: !includeLabel
                    ? const Radius.circular(4)
                    : Radius.zero,
              ),
          color: Theme.of(context).colorScheme.tertiaryContainer,
        ),
        child: Icon(
          Icons.adjust,
          size: 20,
          color: Theme.of(context).colorScheme.onTertiaryContainer,
        ),
      );
    }
  }
}

class DartBlockDataTypeIcon extends StatelessWidget {
  final DartBlockDataType dataType;
  final double width;
  final double height;
  final Color? color;
  const DartBlockDataTypeIcon({
    super.key,
    required this.dataType,
    this.width = 20,
    this.height = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      switch (dataType) {
        DartBlockDataType.integerType =>
          'assets/icons/neotech_datatype_integer.png',
        DartBlockDataType.doubleType =>
          'assets/icons/neotech_datatype_double.png',
        DartBlockDataType.booleanType =>
          'assets/icons/neotech_datatype_boolean.png',
        DartBlockDataType.stringType =>
          'assets/icons/neotech_datatype_string.png',
      },
      package: 'dartblock_code',
      width: width,
      height: height,
      color: color ?? Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }
}

class DartBlockDataTypeSymbol extends ConsumerWidget {
  final DartBlockDataType dataType;
  final double width;
  final double height;
  final bool includeLabel;
  final BorderRadius? borderRadius;
  const DartBlockDataTypeSymbol({
    super.key,
    required this.dataType,
    this.width = 20,
    this.height = 20,
    this.includeLabel = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    if (includeLabel) {
      return TwoTonedChip(
        height: 25,
        left: DartBlockDataTypeIcon(
          dataType: dataType,
          width: width,
          height: height,
          color: settings.colorFamily.getNeoTechDataTypeColor(dataType).onColor,
        ),
        right: Text(
          dataType.toString(),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.apply(color: Colors.white),
        ),
        leftColor: settings.colorFamily.getNeoTechDataTypeColor(dataType).color,
        rightColor: const Color.fromARGB(255, 42, 42, 42),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          borderRadius:
              borderRadius ??
              BorderRadius.only(
                topLeft: const Radius.circular(4),
                bottomLeft: const Radius.circular(4),
                topRight: !includeLabel
                    ? const Radius.circular(4)
                    : Radius.zero,
                bottomRight: !includeLabel
                    ? const Radius.circular(4)
                    : Radius.zero,
              ),
          color: settings.colorFamily.getNeoTechDataTypeColor(dataType).color,
        ),
        child: DartBlockDataTypeIcon(
          dataType: dataType,
          width: width,
          height: height,
          color: settings.colorFamily.getNeoTechDataTypeColor(dataType).onColor,
        ),
      );
    }
  }
}

class DartBlockFunctionSymbol extends ConsumerWidget {
  final double width;
  final double height;
  final Color? color;
  final bool includeLabel;
  final BorderRadius? borderRadius;
  const DartBlockFunctionSymbol({
    super.key,
    this.width = 20,
    this.height = 20,
    this.color,
    this.includeLabel = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    if (includeLabel) {
      return TwoTonedChip(
        height: 25,
        left: _buildAsset(ref),
        right: Text(
          'Function',
          style: Theme.of(context).textTheme.bodyMedium?.apply(
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
        leftColor: settings.colorFamily.function.color,
        rightColor: Theme.of(context).colorScheme.shadow,
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          borderRadius:
              borderRadius ??
              BorderRadius.only(
                topLeft: const Radius.circular(4),
                bottomLeft: const Radius.circular(4),
                topRight: !includeLabel
                    ? const Radius.circular(4)
                    : Radius.zero,
                bottomRight: !includeLabel
                    ? const Radius.circular(4)
                    : Radius.zero,
              ),
          color: settings.colorFamily.function.color,
        ),
        child: _buildAsset(ref),
      );
    }
  }

  Widget _buildAsset(WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Image.asset(
      'assets/icons/neotech_function.png',
      package: 'dartblock_code',
      width: width,
      height: height,
      color: color ?? settings.colorFamily.function.onColor,
    );
  }
}

class DartBlockFunctionNameSymbol extends ConsumerWidget {
  final String name;
  final double width;
  final double height;
  final Color? color;
  final BorderRadius? borderRadius;
  const DartBlockFunctionNameSymbol({
    super.key,
    required this.name,
    this.width = 20,
    this.height = 20,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return TwoTonedChip(
      height: 25,
      left: _buildAsset(ref),
      right: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.apply(color: Colors.white),
      ),
      leftColor: settings.colorFamily.function.color,
      rightColor: Colors.white12,
    );
  }

  Widget _buildAsset(WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Image.asset(
      'assets/icons/neotech_function.png',
      package: 'dartblock_code',
      width: width,
      height: height,
      color: color ?? settings.colorFamily.function.onColor,
    );
  }
}

class DartBlockReturnSymbol extends ConsumerWidget {
  final double width;
  final double height;
  final Color? color;
  final bool includeLabel;
  final BorderRadius? borderRadius;
  const DartBlockReturnSymbol({
    super.key,
    this.width = 20,
    this.height = 20,
    this.color,
    this.includeLabel = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    if (includeLabel) {
      return TwoTonedChip(
        height: 25,
        left: _buildAsset(context),
        right: Text(
          'Output',
          style: Theme.of(context).textTheme.bodyMedium?.apply(
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
        leftColor: settings.colorFamily.function.color,
        rightColor: Theme.of(context).colorScheme.shadow,
      );
    } else {
      return _buildAsset(context);
    }
  }

  Widget _buildAsset(BuildContext context) {
    return Image.asset(
      'assets/icons/neotech_output.png',
      package: 'dartblock_code',
      width: width,
      height: height,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }
}

class DartBlockNewFunctionSymbol extends ConsumerWidget {
  final double? size;
  const DartBlockNewFunctionSymbol({super.key, this.size});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Badge(
      padding: EdgeInsets.zero,
      offset: const Offset(5, -2),
      label: Icon(
        Icons.add,
        size: size != null ? (max(4, size! - 4)) : 16,
        weight: 4,
        color: settings.colorFamily.function.onColorContainer,
      ),
      backgroundColor: settings.colorFamily.function.colorContainer,
      child: Container(
        margin: const EdgeInsets.all(2),
        width: size,
        height: size,
        child: DartBlockFunctionSymbol(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
