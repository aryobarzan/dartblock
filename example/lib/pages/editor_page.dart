import 'package:dartblock_code/widgets/dartblock_colors.dart';
import 'package:example/theme.dart';
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
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
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
              colors: DartBlockColors(
                number: MaterialTheme.number,
                boolean: MaterialTheme.boolean,
                variable: MaterialTheme.variable,
                function: MaterialTheme.function,
                string: MaterialTheme.string,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
