import 'package:dartblock_code/widgets/helpers/provider_aware_modal.dart';
import 'package:flutter/material.dart';
import 'package:dartblock_code/models/dartblock_notification.dart';

/// Depending on the screen width, display the [child] differently:
///
/// - width > 700 (large): dialog
/// - otherwise (small): modal bottom sheet
Future<void> showAdaptiveBottomSheetOrDialog(
  BuildContext context, {
  EdgeInsetsGeometry? sheetPadding,
  EdgeInsetsGeometry? dialogPadding,
  Widget? dialogTitle,
  required Widget child,
  Function(DartBlockNotification notification)? onReceiveDartBlockNotification,
  required bool useProviderAwareModal,
}) async {
  final screenWidth = MediaQuery.of(context).size.width;
  final isLargeScreen = screenWidth > 700;

  /// Due to the dialog / sheet having a separate context and thus no relation
  /// to the main context of the DartBlockEditor (the main UI of DartBlock), we capture DartBlockNotifications
  /// from the dialog's or sheet's context, and manually re-dispatch them using the parent context.
  /// The parent context may not necessarily be the DartBlockEditor's context,
  /// as certain dialogs or sheets open additional nested dialogs or sheets with their own contexts.
  /// Hence, this process needs to be repeated for every dialog / sheet until the DartBlockEditor's
  /// context is reached.
  if (isLargeScreen) {
    final dialogChild = NotificationListener<DartBlockNotification>(
      onNotification: (notification) {
        if (onReceiveDartBlockNotification != null) {
          onReceiveDartBlockNotification(notification);
        } else {
          notification.dispatch(context);
        }
        return true;
      },
      child: Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 400),
          child: SingleChildScrollView(
            child: Padding(
              padding: dialogPadding ?? EdgeInsets.zero,
              child: dialogTitle != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        dialogTitle,
                        const SizedBox(height: 8),
                        Flexible(child: child),
                      ],
                    )
                  : child,
            ),
          ),
        ),
      ),
    );
    if (useProviderAwareModal) {
      await context.showProviderAwareDialog(
        barrierDismissible: true,
        builder: (dialogContext) => dialogChild,
      );
    } else {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => dialogChild,
      );
    }
  } else {
    if (useProviderAwareModal) {
      await context.showProviderAwareBottomSheet(
        isScrollControlled: true,
        clipBehavior: Clip.hardEdge,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (modalContext) {
          return NotificationListener<DartBlockNotification>(
            onNotification: (notification) {
              notification.dispatch(context);
              return true;
            },
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    sheetPadding ??
                    EdgeInsets.only(
                      top: 8,
                      left: 8,
                      right: 8,
                      bottom:
                          16 + MediaQuery.of(modalContext).viewInsets.bottom,
                    ),
                child: child,
              ),
            ),
          );
        },
      );
    } else {
      showModalBottomSheet(
        isScrollControlled: true,
        clipBehavior: Clip.hardEdge,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        context: context,
        builder: (modalContext) {
          return NotificationListener<DartBlockNotification>(
            onNotification: (notification) {
              notification.dispatch(context);
              return true;
            },
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    sheetPadding ??
                    EdgeInsets.only(
                      top: 8,
                      left: 8,
                      right: 8,
                      bottom:
                          16 + MediaQuery.of(modalContext).viewInsets.bottom,
                    ),
                child: child,
              ),
            ),
          );
        },
      );
    }
  }
}
