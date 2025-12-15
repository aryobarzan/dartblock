import 'dart:convert';

import 'package:example/misc/dartblock_sample_program.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartblock_code/core/dartblock_program.dart';
import 'package:dartblock_code/models/evaluator.dart';
import 'package:dartblock_code/widgets/dartblock_editor.dart';
import 'package:dartblock_code/widgets/views/evaluation/evaluation_widget.dart';

/// An example quiz page to demonstrate a potential use case for DartBlock, where the user is asked to compose a DartBlock program to solve the given problem.
///
/// The example makes use of a sample [DartBlockProgram] and a [DartBlockEvaluator] to immediately evaluate the user's input solution [DartBlockProgram].
class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  /// The user's composed program.
  DartBlockProgram userSolution = DartBlockProgram.init([], []);

  /// The sample program representing a potential solution to the given problem.
  DartBlockSampleProgram? sampleSolution;

  /// The evaluator used to cross-check the user's solution against the sample solution.
  DartBlockEvaluator evaluator = DartBlockEvaluator([]);

  @override
  void initState() {
    super.initState();
    _loadEvaluatorAndSampleSolutionFromAssets();
  }

  /// For demonstration purposes, we load the provided sample [DartBlockProgram]s from the `assets/` folder and load one of them as the example sample solution.
  ///
  /// In this case, the sample program related to "Custom Functions" is used.
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
      padding: const EdgeInsets.only(top: 8, bottom: 8),
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
                        "Implement a custom function with the name 'triple' which has a parameter 'number' of type double. The function should return the triple of its argument!",
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
      final evaluationFuture = evaluator.evaluate(
        sampleSolution!.program,
        userSolution,
      );
      showModalBottomSheet(
        isScrollControlled: true,
        showDragHandle: true,
        context: context,
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            /// We use a FutureBuilder, as [DartBlockEvaluator.evaluate] is an async function.
            child: FutureBuilder(
              future: evaluationFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
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

                        /// We use the natively provided widget for visualizing the evaluation results.
                        ///
                        /// However, you can also create your own custom widget to visualize the [DartBlockEvaluationResult].
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
