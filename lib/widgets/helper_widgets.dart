import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TwoTonedChip extends StatelessWidget {
  final Widget left;
  final Widget right;
  final double? height;
  final double? width;
  final Color? leftColor;
  final Color? rightColor;
  const TwoTonedChip({
    super.key,
    required this.left,
    required this.right,
    this.height,
    this.width,
    this.leftColor,
    this.rightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: width,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              bottomLeft: Radius.circular(4),
              topRight: Radius.zero,
              bottomRight: Radius.zero,
            ),
            color: leftColor ?? Theme.of(context).colorScheme.primaryContainer,
          ),
          child: left,
        ),
        Container(
          width: width,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(4),
              bottomRight: Radius.circular(4),
              topLeft: Radius.zero,
              bottomLeft: Radius.zero,
            ),
            color: rightColor ?? Theme.of(context).colorScheme.inversePrimary,
          ),
          child: right,
        ),
      ],
    );
  }
}

class PopupWidgetButton extends StatelessWidget {
  final Widget? child;
  final Widget widget;
  final String? tooltip;
  final Icon? icon;
  final bool blurBackground;
  final bool isFullWidth;
  final double? width;
  final Color? color;
  final Function()? onOpened;
  const PopupWidgetButton({
    super.key,
    this.child,
    this.icon,
    required this.widget,
    this.tooltip,
    this.blurBackground = true,
    this.isFullWidth = false,
    this.width,
    this.color,
    this.onOpened,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onOpened: onOpened,
      color: color,
      constraints: isFullWidth
          ? BoxConstraints.tightFor(width: MediaQuery.of(context).size.width)
          : width != null
          ? BoxConstraints.tightFor(
              width: max(0, min(MediaQuery.of(context).size.width, width!)),
            )
          : null,
      tooltip: tooltip,
      position: PopupMenuPosition.under,
      icon: child == null
          ? icon ??
                Icon(Icons.menu, color: Theme.of(context).colorScheme.primary)
          : null,
      itemBuilder: (context) {
        return [
          PopupMenuWidget(
            height: 100,
            // padding: EdgeInsets.zero,
            // enabled: true,
            child: UncontrolledProviderScope(
              container: ProviderScope.containerOf(context),
              child: blurBackground
                  ? BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                      child: widget,
                    )
                  : widget,
            ),
          ),
        ];
      },
      child: child,
    );
  }
}

/// An arbitrary widget that lives in a popup menu
class PopupMenuWidget<T> extends PopupMenuEntry<T> {
  const PopupMenuWidget({super.key, this.height = 200, required this.child});
  final Widget child;

  @override
  final double height;

  @override
  PopupMenuWidgetState createState() => PopupMenuWidgetState();

  @override
  bool represents(T? value) {
    return false;
  }
}

class PopupMenuWidgetState extends State<PopupMenuWidget> {
  @override
  Widget build(BuildContext context) => widget.child;
}

class WarningIconButton extends StatelessWidget {
  final String title;
  final String message;
  const WarningIconButton({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Okay"),
              ),
            ],
          ),
        );
      },
      icon: const Icon(Icons.warning, color: Colors.orange),
    );
  }
}

class CustomReorderableDelayedDragStartListener
    extends ReorderableDragStartListener {
  final Duration delay;

  const CustomReorderableDelayedDragStartListener({
    this.delay = kLongPressTimeout,
    super.key,
    required super.child,
    required super.index,
    super.enabled,
  });

  @override
  MultiDragGestureRecognizer createRecognizer() {
    return DelayedMultiDragGestureRecognizer(delay: delay, debugOwner: this);
  }
}

class SliverSizedBox extends StatelessWidget {
  final double? height;
  final double? width;
  final Widget? child;
  const SliverSizedBox({super.key, this.height, this.width, this.child});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(height: height, width: width, child: child),
    );
  }
}

class ArrowHeadWidget extends StatelessWidget {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;
  final AxisDirection direction;
  final Size size;
  const ArrowHeadWidget({
    super.key,
    this.strokeColor = Colors.black,
    this.strokeWidth = 3,
    this.paintingStyle = PaintingStyle.fill,
    required this.direction,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ArrowHeadPainter(
        strokeWidth: strokeWidth,
        strokeColor: strokeColor,
        paintingStyle: paintingStyle,
        direction: direction,
      ),
      child: SizedBox.fromSize(size: size),
    );
  }
}

class ArrowHeadPainter extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;
  final AxisDirection direction;

  ArrowHeadPainter({
    this.strokeColor = Colors.black,
    this.strokeWidth = 3,
    this.paintingStyle = PaintingStyle.stroke,
    required this.direction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    canvas.drawPath(getTrianglePath(size.width, size.height), paint);
  }

  Path getTrianglePath(double x, double y) {
    switch (direction) {
      case AxisDirection.up:
        return Path()
          ..moveTo(0, y)
          ..lineTo(x / 2, 0)
          ..lineTo(x, y)
          ..lineTo(0, y);
      case AxisDirection.right:
        return Path()
          ..moveTo(0, 0)
          ..lineTo(0, y)
          ..lineTo(x, y / 2)
          ..lineTo(0, 0);
      case AxisDirection.down:
        return Path()
          ..moveTo(0, 0)
          ..lineTo(x / 2, y)
          ..lineTo(x, 0)
          ..lineTo(0, 0);
      case AxisDirection.left:
        return Path()
          ..moveTo(x, 0)
          ..lineTo(0, y / 2)
          ..lineTo(x, y)
          ..lineTo(x, 0);
    }
  }

  @override
  bool shouldRepaint(ArrowHeadPainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class ColoredTitleChip extends StatelessWidget {
  final String title;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;
  final Border? border;
  const ColoredTitleChip({
    super.key,
    required this.title,
    this.borderRadius,
    this.color,
    this.textColor,
    this.borderColor,
    this.textStyle,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      constraints: const BoxConstraints(minWidth: 24),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.primaryContainer,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border:
            border ??
            (borderColor != null ? Border.all(color: borderColor!) : null),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          title,
          style:
              textStyle ??
              Theme.of(context).textTheme.bodyMedium?.apply(
                color:
                    textColor ??
                    Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
      ),
    );
  }
}

SnackBar createDartBlockInfoSnackBar(
  BuildContext context, {
  required IconData iconData,
  required String message,
  Color? backgroundColor,
  Color? color,
}) {
  return SnackBar(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
    ),
    elevation: 8,
    backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
    width: MediaQuery.of(context).size.width - 80,
    duration: const Duration(seconds: 2),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    content: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(iconData, color: color ?? Theme.of(context).colorScheme.onPrimary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.apply(
              color: color ?? Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    ),
  );
}
