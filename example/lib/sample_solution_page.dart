import 'package:flutter/material.dart';
import 'package:dartblock_code/core/dartblock_program.dart';
import 'package:dartblock_code/widgets/dartblock_editor.dart';

class SampleSolutionPage extends StatefulWidget {
  final DartBlockProgram? sampleSolution;
  const SampleSolutionPage({super.key, this.sampleSolution});

  @override
  State<SampleSolutionPage> createState() => _SampleSolutionPageState();
}

class _SampleSolutionPageState extends State<SampleSolutionPage> {
  DartBlockProgram? sampleSolution;
  @override
  void initState() {
    super.initState();
    sampleSolution = widget.sampleSolution?.copy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sample Solution"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop(sampleSolution);
            },
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: DartBlockEditor(
        key: ValueKey(sampleSolution.hashCode),
        program: sampleSolution ?? DartBlockProgram.init([], []),
        canChange: true,
        canDelete: true,
        canReorder: true,
        canRun: true,
        onChanged: (updatedNeoTechCore) {
          setState(() {
            sampleSolution = updatedNeoTechCore;
          });
        },
      ),
    );
  }
}
