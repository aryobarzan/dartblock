# DartBlock Integration Guide

## Overview

DartBlock internally uses `flutter_riverpod` for its state management, but it is compatible with integrating apps that also use `flutter_riverpod`. The package uses an InheritedWidget-based approach to ensure modals and dialogs always access the correct provider container, regardless of whether your app has its own ProviderScope.

**If your app uses `flutter_riverpod` for its own state management**, you can keep your `ProviderScope` and use DartBlockEditor without any issues. The package handles nested provider scopes.

#### Step 1: Set Up Your App's ProviderScope

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartblock_code/dartblock_code.dart';

// Your app's own providers
class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
}

final counterProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
);

void main() {
  runApp(
    const ProviderScope(  // Your app's ProviderScope
      child: MyApp(),
    ),
  );
}
```

#### Step 2: Use DartBlockEditor

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            // Your app's UI using your own providers
            Consumer(
              builder: (context, ref, _) {
                final count = ref.watch(counterProvider);
                return Text('Your counter: $count');
              },
            ),
            // DartBlockEditor with its own internal providers
            Expanded(
              child: DartBlockEditor(
                program: DartBlockProgram.example(),
                canChange: true,
                canDelete: true,
                canReorder: true,
                canRun: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### How It Works

The package uses `DartBlockContainerProvider` (an InheritedWidget) to ensure modals and dialogs always access the correct provider container:

```
Your App's ProviderScope (your providers)
  └─ MaterialApp
      └─ DartBlockEditor
          └─ DartBlockEditor's ProviderScope (DartBlock providers with overrides)
              └─ Consumer (captures container)
                  └─ DartBlockContainerProvider (provides container via InheritedWidget)
                      └─ DartBlock UI
                          └─ Button opens modal
                              └─ Modal finds DartBlockContainerProvider ✅
                                  └─ Uses correct container with overrides
```

The modal helper methods (`showProviderAwareBottomSheet` and `showProviderAwareDialog`) automatically:

1. Check for `DartBlockContainerProvider` in the widget tree
2. Use DartBlockEditor's container if found
3. Fall back to the nearest ProviderScope if not (for non-DartBlock modals)

**Result:** Both your providers and DartBlock's providers work simultaneously without conflicts!

---

## Technical Implementation Details

The package implements an InheritedWidget-based approach:

1. **DartBlockContainerProvider** ([dartblock_container_provider.dart](lib/widgets/helpers/dartblock_container_provider.dart))
   - InheritedWidget that provides DartBlockEditor's ProviderContainer to its subtree
   - Captured from the Consumer widget's build context
   - Available throughout the entire DartBlockEditor widget tree

2. **DartBlockEditor** ([dartblock_editor.dart](lib/widgets/dartblock_editor.dart))
   - Captures container from Consumer's context: `ProviderScope.containerOf(context)`
   - Wraps entire subtree with `DartBlockContainerProvider`
   - Ensures container is accessible to all descendant widgets

3. **Modal Helpers** ([provider_aware_modal.dart](lib/widgets/helpers/provider_aware_modal.dart))
   - `_getProviderContainer()` method tries `DartBlockContainerProvider.maybeOf()` first
   - Falls back to `ProviderScope.containerOf()` if not in DartBlockEditor
   - Both `showProviderAwareBottomSheet()` and `showProviderAwareDialog()` use this logic
