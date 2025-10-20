import 'package:flutter/widgets.dart';
import 'package:dartblock/models/dartblock_interaction.dart';

/// A [Notification] which can bubble up the widget tree of [DartBlockEditor].
///
/// It is currently used to notify about the user's interactions with the UI, i.e., taps on the various UI elements.
sealed class DartBlockNotification extends Notification {
  final DartBlockNotificationType notificationType;
  DartBlockNotification(this.notificationType);
}

enum DartBlockNotificationType { interaction }

class DartBlockInteractionNotification extends DartBlockNotification {
  final DartBlockInteraction dartBlockInteraction;
  DartBlockInteractionNotification(this.dartBlockInteraction)
    : super(DartBlockNotificationType.interaction);

  @override
  String toString() {
    return dartBlockInteraction.toString();
  }
}
