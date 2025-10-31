import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartblock_code/core/dartblock_program.dart';
import 'package:dartblock_code/models/evaluator.dart';
import 'package:dartblock_code/widgets/dartblock_editor.dart';
import 'package:dartblock_code/widgets/evaluator_editor.dart';
import 'package:dartblock_code/widgets/views/evaluation/evaluation_widget.dart';

class EvaluationEditorPage extends StatefulWidget {
  final DartBlockProgram sampleSolution;
  const EvaluationEditorPage({super.key, required this.sampleSolution});

  @override
  State<EvaluationEditorPage> createState() => _EvaluationEditorPageState();
}

class _EvaluationEditorPageState extends State<EvaluationEditorPage> {
  DartBlockEvaluator? evaluator;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Evaluator"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop(evaluator);
            },
            icon: Icon(Icons.check),
          ),
        ],
      ),
      floatingActionButton: evaluator != null
          ? FloatingActionButton.extended(
              onPressed: () {
                _showEvaluation();
              },
              label: Text("Evaluate"),
              icon: Icon(Icons.checklist),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Text(
                "Evaluation Schema(s)",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            SliverToBoxAdapter(
              child: Text(
                "Set up 1 or more evaluation schemas for your sample solution!",
              ),
            ),
            SliverToBoxAdapter(
              child: DartBlockEvaluatorEditor(
                evaluator: evaluator,
                sampleSolution: widget.sampleSolution,
                onChange: (evaluator) {
                  setState(() {
                    this.evaluator = evaluator;
                  });
                },
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: jsonEncode(evaluator?.toJson())),
                  );
                },
                child: Text("Export"),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(child: Divider()),
            SliverToBoxAdapter(
              child: Text(
                "Sample Solution (editing is disabled)",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverFillRemaining(
              child: DartBlockEditor(
                key: ValueKey(widget.sampleSolution.hashCode),
                program: widget.sampleSolution,
                canChange: false,
                canDelete: false,
                canReorder: false,
                canRun: true,
                onChanged: (updatedNeoTechCore) {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEvaluation() {
    if (evaluator != null) {
      showModalBottomSheet(
        isScrollControlled: true,
        showDragHandle: true,
        context: context,
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: FutureBuilder(
              future: evaluator!.evaluate(
                widget.sampleSolution,
                widget.sampleSolution,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 4),
                        Text("Evaluating..."),
                      ],
                    ),
                  );
                } else if (snapshot.hasData) {
                  return Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Evaluation Result",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          "Note that for demonstration purposes, the sample solution itself is being used as the input program for the evaluator. Hence, the evaluation will always be correct!",
                        ),
                        SizedBox(height: 8),
                        DartBlockEvaluationResultWidget(result: snapshot.data!),
                      ],
                    ),
                  );
                } else {
                  return const Text(
                    "Sorry, there was an issue loading the sample DartBlock programs.",
                    textAlign: TextAlign.center,
                  );
                }
              },
            ),
          ),
        ),
      );
    }
  }
}
