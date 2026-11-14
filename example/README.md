# DartBlock Example

An example Flutter app using the [`dartblock_code`](https://pub.dev/packages/dartblock_code) package.

It showcases the editor, the evaluator editor and a quiz-style evaluation flow. It depends on the package via a local path (`path: ../`). In your own app, depend on the published version instead:

```yaml
dependencies:
  dartblock_code: ^4.1.0
```

Run it with:

```sh
cd example
flutter pub get
flutter run
```

This example requires Flutter 3.47.0 or newer. For integrating DartBlock into your own app, see the [Integration Guide](../INTEGRATION_GUIDE.md).
