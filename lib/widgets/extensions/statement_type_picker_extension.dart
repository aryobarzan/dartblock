import 'package:flutter/material.dart';
import 'package:dartblock_code/widgets/dartblock_editor.dart';
import 'package:dartblock_code/models/dartblock_notification.dart';

/// Helper functions for [StatementTypePicker].
extension StatementTypePickerExtension on StatementTypePicker {
  /// Depending on the screen width, display the [StatementTypePicker] differently:
  ///
  /// - width > 700 (large): dialog
  /// - otherwise (small): modal bottom sheet
  Future<void> show(BuildContext context) async {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 700;

    if (isLargeScreen) {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => NotificationListener<DartBlockNotification>(
          onNotification: (notification) {
            notification.dispatch(context);
            return true;
          },
          child: Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 400),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Add Statement',
                        style: Theme.of(dialogContext).textTheme.titleLarge,
                      ),
                    ),
                    Expanded(child: this),
                  ],
                ),
              ),
            ),
          ),
        ),
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
          /// Due to the modal sheet having a separate context and thus no relation
          /// to the main context of the NeoTechWidget, we capture DartBlockNotifications
          /// from the sheet's context and manually re-dispatch them using the parent context.
          /// The parent context may not necessarily be the NeoTechWidget's context,
          /// as certain sheets open additional nested sheets with their own contexts,
          /// hence this process needs to be repeated for every sheet until the NeoTechWidget's
          /// context is reached.
          return NotificationListener<DartBlockNotification>(
            onNotification: (notification) {
              notification.dispatch(context);
              return true;
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: this,
              ),
            ),
          );
        },
      );
    }
  }
}
