import 'dart:convert';
import 'dart:io';

import 'package:dartblock_code/widgets/dartblock_colors.dart';
import 'package:example/theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dartblock_code/core/dartblock_program.dart';
import 'package:dartblock_code/widgets/dartblock_editor.dart';

/// A simple widget integrating the main [DartBlockEditor] widget for viewing and editing a [DartBlockProgram].
class EditorView extends StatefulWidget {
  final DartBlockProgram? program;
  final Function(DartBlockProgram program) onChanged;
  const EditorView({super.key, this.program, required this.onChanged});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  late DartBlockProgram program;
  @override
  void initState() {
    super.initState();
    program = widget.program?.copy() ?? DartBlockProgram.example();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: DartBlockEditor(
        key: ValueKey(program.hashCode),
        program: program,
        canChange: true,
        canDelete: true,
        canReorder: true,
        canRun: true,
        onChanged: widget.onChanged,
        onInteraction: (dartBlockInteraction) {
          // Example interaction: user tapped on "Run" button.
          // Can be useful for collecting usage statistics and general logging.
        },
        onDownloadScript: (scriptContent, suggestedFileName) async {
          try {
            final result = await FilePicker.saveFile(
              fileName: suggestedFileName,
              bytes: utf8.encode(scriptContent),
            );
            if (result != null) {
              /// On the web, the bytes are downloaded directly by the browser.
              ///
              /// On iOS and Android, the bytes are directly written to the selected path.
              ///
              /// On desktop platforms, this has to be done as a second step.
              if (!kIsWeb &&
                  (defaultTargetPlatform == TargetPlatform.macOS ||
                      defaultTargetPlatform == TargetPlatform.windows ||
                      defaultTargetPlatform == TargetPlatform.linux)) {
                await File(result).writeAsString(scriptContent);
              }
            }
          } catch (err) {
            // Encoding failed or save failed
          }
        },
        colors: DartBlockColors(
          number: MaterialTheme.number,
          boolean: MaterialTheme.boolean,
          variable: MaterialTheme.variable,
          function: MaterialTheme.function,
          string: MaterialTheme.string,
        ),
        isToolboxDockedBottom: true,
      ),
    );
  }
}
