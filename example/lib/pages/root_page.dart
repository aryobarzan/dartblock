import 'dart:convert';

import 'package:example/pages/editor_page.dart';
import 'package:example/pages/evaluation_editor_page.dart';
import 'package:example/misc/dartblock_sample_program.dart';
import 'package:example/pages/quiz_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartblock_code/dartblock_code.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int pageIndex = 0;
  late DartBlockProgram program;
  late final Future<List<DartBlockSampleProgram>> _samplesFuture;
  @override
  initState() {
    super.initState();
    _samplesFuture = _loadSamplesFromDisk();
    program = DartBlockProgram.example();
  }

  /// Load sample [DartBlockProgram]s from the `assets/dartBlockSamples/` folder.
  Future<List<DartBlockSampleProgram>> _loadSamplesFromDisk() async {
    List<DartBlockSampleProgram> programs = [];
    try {
      final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final assets = assetManifest.listAssets();
      final filePaths = assets.where(
        (String key) => key.startsWith('assets/dartblockSamples'),
      );
      for (final filePath in filePaths) {
        final program = DartBlockSampleProgram.fromJson(
          jsonDecode(await rootBundle.loadString(filePath)),
        );
        programs.add(program);
      }
    } catch (err) {
      //
    }
    programs.sort((a, b) => a.index.compareTo(b.index));
    return programs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DartBlock"),
        actions: [
          if (pageIndex == 0) ...[
            IconButton(
              tooltip: "Set up evaluator...",
              onPressed: () {
                if (program.isEmpty()) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Evaluator"),
                      content: Text(
                        "Before setting up the program evaluator, create a non-empty DartBlock program first!",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Okay"),
                        ),
                      ],
                    ),
                  );
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          EvaluationEditorPage(sampleSolution: program),
                    ),
                  );
                }
              },
              icon: Icon(Icons.checklist),
            ),
            IconButton(
              tooltip: "Sample programs...",
              onPressed: () {
                showSamplePicker();
              },
              icon: Icon(Icons.info),
            ),
          ],
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            pageIndex = index;
          });
        },
        selectedIndex: pageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.edit),
            icon: Icon(Icons.edit_outlined),
            label: 'Editor',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.quiz),
            icon: Icon(Icons.quiz_outlined),
            label: 'Quiz',
          ),
        ],
      ),
      body: [
        EditorView(
          key: ValueKey(program.hashCode),
          program: program,
          onChanged: (program) {
            this.program = program;
          },
        ),
        QuizPage(),
      ][pageIndex],
    );
  }

  void showSamplePicker() {
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
            future: _samplesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                return Column(
                  children:
                      <Widget>[
                        Text(
                          "Sample Programs",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ] +
                      snapshot.data!
                          .map(
                            (sampleProgram) => ListTile(
                              title: Text(sampleProgram.title),
                              subtitle: Text(sampleProgram.description),
                              onTap: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  program = sampleProgram.program.copy();
                                });
                              },
                            ),
                          )
                          .toList(),
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
