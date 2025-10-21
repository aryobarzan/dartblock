import 'dart:convert';

import 'package:example/editor_page.dart';
import 'package:example/evaluation_editor.dart';
import 'package:example/misc/dartblock_sample_program.dart';
import 'package:example/quiz.dart';
import 'package:example/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dartblock_code/dartblock_code.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black.withValues(alpha: 0.002),
    ),
  );
  runApp(const DartBlockExample());
}

class DartBlockExample extends StatelessWidget {
  const DartBlockExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: _ScrollBehavior(),
      debugShowCheckedModeBanner: false,
      title: 'DartBlock',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        textTheme: GoogleFonts.robotoTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class _ScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int pageIndex = 0;
  late DartBlockProgram program;
  @override
  initState() {
    super.initState();
    if (kDebugMode) {
      program = DartBlockProgram.example();
    } else {
      program = DartBlockProgram.init([], []);
    }
  }

  Future<List<DartBlockSampleProgram>> _loadSamplesFromDisk() async {
    List<DartBlockSampleProgram> programs = [];
    try {
      final manifestJson = await DefaultAssetBundle.of(
        context,
      ).loadString('AssetManifest.json');
      final filePaths = json
          .decode(manifestJson)
          .keys
          .where((String key) => key.startsWith('assets/dartblockSamples'));
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
              tooltip: "Set up evaluation schemas",
              onPressed: () {
                if (program.isEmpty()) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Evaluator"),
                      content: Text(
                        "Before setting up evaluation schemas, create a non-empty DartBlock program first!",
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
                          EvaluationEditor(sampleSolution: program),
                    ),
                  );
                }
              },
              icon: Icon(Icons.checklist),
            ),
            IconButton(
              tooltip: "Sample programs",
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
        EditorPage(
          key: ValueKey(program.hashCode),
          program: program,
          onChanged: (program) {
            this.program = program;
          },
        ),
        Quiz(),
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
            future: _loadSamplesFromDisk(),
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
