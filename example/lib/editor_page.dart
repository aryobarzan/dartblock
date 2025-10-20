import 'package:flutter/material.dart';
import 'package:dartblock_code/core/dartblock_program.dart';
import 'package:dartblock_code/widgets/dartblock_editor.dart';

class EditorPage extends StatefulWidget {
  final DartBlockProgram? program;
  final Function(DartBlockProgram program) onChanged;
  const EditorPage({super.key, this.program, required this.onChanged});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late DartBlockProgram program;
  @override
  void initState() {
    super.initState();
    program = widget.program?.copy() ?? DartBlockProgram.example();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
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
              onChanged: (changedDartBlockProgram) {
                widget.onChanged(changedDartBlockProgram);
              },
              onInteraction: (dartBlockInteraction) {
                // example: user tapped on "Run" button
                // Useful for statistics or logging
              },
            ),
          ),
        ],
      ),
    );
  }
}
