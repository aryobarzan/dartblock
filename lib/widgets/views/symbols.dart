import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:dartblock_code/widgets/views/other/dartblock_colors.dart';

class VoidSymbol extends StatelessWidget {
  final bool includeLabel;
  final BorderRadius? borderRadius;
  const VoidSymbol({super.key, this.includeLabel = false, this.borderRadius});

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

class NeoTechDataTypeIcon extends StatelessWidget {
  final DartBlockDataType dataType;
  final double width;
  final double height;
  final Color? color;
  const NeoTechDataTypeIcon({
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

class NeoTechDataTypeSymbol extends StatelessWidget {
  final DartBlockDataType dataType;
  final double width;
  final double height;
  final bool includeLabel;
  final BorderRadius? borderRadius;
  const NeoTechDataTypeSymbol({
    super.key,
    required this.dataType,
    this.width = 20,
    this.height = 20,
    this.includeLabel = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (includeLabel) {
      return TwoTonedChip(
        height: 25,
        left: NeoTechDataTypeIcon(
          dataType: dataType,
          width: width,
          height: height,
          color: Colors.white,
        ),
        right: Text(
          dataType.toString(),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.apply(color: Colors.white),
        ),
        leftColor: DartBlockColors.getNeoTechDataTypeColor(dataType),
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
          color: DartBlockColors.getNeoTechDataTypeColor(dataType),
        ),
        child: NeoTechDataTypeIcon(
          dataType: dataType,
          width: width,
          height: height,
          color: Colors.white,
        ),
      );
    }
  }
}

class NeoTechFunctionSymbol extends StatelessWidget {
  final double width;
  final double height;
  final Color? color;
  final bool includeLabel;
  final BorderRadius? borderRadius;
  const NeoTechFunctionSymbol({
    super.key,
    this.width = 20,
    this.height = 20,
    this.color,
    this.includeLabel = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (includeLabel) {
      return TwoTonedChip(
        height: 25,
        left: _buildAsset(),
        right: Text(
          'Function',
          style: Theme.of(context).textTheme.bodyMedium?.apply(
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
        leftColor: DartBlockColors.function,
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
          color: DartBlockColors.function,
        ),
        child: _buildAsset(),
      );
    }
  }

  Widget _buildAsset() {
    return Image.asset(
      'assets/icons/neotech_function.png',
      package: 'dartblock_code',
      width: width,
      height: height,
      color: color ?? Colors.white,
    );
  }
}

class FunctionNameSymbol extends StatelessWidget {
  final String name;
  final double width;
  final double height;
  final Color? color;
  final BorderRadius? borderRadius;
  const FunctionNameSymbol({
    super.key,
    required this.name,
    this.width = 20,
    this.height = 20,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return TwoTonedChip(
      height: 25,
      left: _buildAsset(),
      right: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.apply(color: Colors.white),
      ),
      leftColor: DartBlockColors.function,
      rightColor: Colors.white12,
    );
  }

  Widget _buildAsset() {
    return Image.asset(
      'assets/icons/neotech_function.png',
      package: 'dartblock_code',
      width: width,
      height: height,
      color: color ?? Colors.white,
    );
  }
}

class NeoTechReturnSymbol extends StatelessWidget {
  final double width;
  final double height;
  final Color? color;
  final bool includeLabel;
  final BorderRadius? borderRadius;
  const NeoTechReturnSymbol({
    super.key,
    this.width = 20,
    this.height = 20,
    this.color,
    this.includeLabel = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
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
        leftColor: DartBlockColors.function,
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

class NewFunctionSymbol extends StatelessWidget {
  final double? size;
  const NewFunctionSymbol({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Badge(
      offset: const Offset(0, 0),
      label: Icon(
        Icons.add,
        size: size != null ? (max(4, size! - 4)) : 16,
        weight: 4,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(2),
        width: size,
        height: size,
        child: NeoTechFunctionSymbol(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
