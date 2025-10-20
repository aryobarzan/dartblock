import 'dart:convert';

import 'package:example/misc/dartblock_sample_program.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartblock_code/core/dartblock_program.dart';
import 'package:dartblock_code/models/evaluator.dart';
import 'package:dartblock_code/widgets/dartblock_editor.dart';
import 'package:dartblock_code/widgets/views/evaluation/evaluation_widget.dart';

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  DartBlockProgram userSolution = DartBlockProgram.init([], []);
  DartBlockEvaluator evaluator = DartBlockEvaluator([]);
  DartBlockSampleProgram? sampleSolution;
  @override
  void initState() {
    super.initState();
    _loadEvaluatorAndSampleSolutionFromAssets();
  }

  Future _loadEvaluatorAndSampleSolutionFromAssets() async {
    try {
      final manifestJson = await DefaultAssetBundle.of(
        context,
      ).loadString('AssetManifest.json');
      // Evaluator
      final evaluator = DartBlockEvaluator.fromJson(
        jsonDecode(
          await rootBundle.loadString(
            json
                .decode(manifestJson)
                .keys
                .where(
                  (String key) =>
                      key.startsWith('assets/dartblockEvaluatorSamples'),
                )
                .first,
          ),
        ),
      );
      this.evaluator = evaluator;
      // Sample Solution
      final filePaths = json
          .decode(manifestJson)
          .keys
          .where((String key) => key.startsWith('assets/dartblockSamples'));
      for (final filePath in filePaths) {
        final program = DartBlockSampleProgram.fromJson(
          jsonDecode(await rootBundle.loadString(filePath)),
        );
        if (program.title == "Custom Function") {
          sampleSolution = program;
          break;
        }
      }
    } catch (err) {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: Card.outlined(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        "Implement a custom function which has a parameter of type double. The function should return the triple of that value!",
                      ),
                    ),
                  ),
                ),
              ),
              SliverFillRemaining(
                child: DartBlockEditor(
                  key: ValueKey(userSolution.hashCode),
                  program: userSolution,
                  canChange: true,
                  canDelete: true,
                  canReorder: true,
                  canRun: true,
                  onChanged: (changedDartBlockProgram) {
                    setState(() {
                      userSolution = changedDartBlockProgram;
                    });
                  },
                ),
              ),
            ],
          ),
          if (!userSolution.isEmpty())
            Positioned(
              bottom: 8,
              right: 8,
              child: FloatingActionButton.extended(
                onPressed: () {
                  _showEvaluation();
                },
                icon: Icon(Icons.check),
                label: Text("Submit"),
              ),
            ),
        ],
      ),
    );
  }

  void _showEvaluation() {
    if (sampleSolution != null) {
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
              future: evaluator.evaluate(sampleSolution!.program, userSolution),
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
