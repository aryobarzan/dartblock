import 'package:flutter/material.dart';
import 'package:dartblock_code/core/dartblock_program.dart';
import 'package:dartblock_code/models/exception.dart';
import 'package:dartblock_code/widgets/views/other/dartblock_exception.dart';

class DartBlockConsole extends StatelessWidget {
  final List<String> content;
  final DartBlockException? exception;
  final DartBlockProgram program;
  const DartBlockConsole({
    super.key,
    required this.content,
    this.exception,
    required this.program,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.wysiwyg),
            const SizedBox(width: 4),
            Text("Console", style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
        const Divider(),
        if (content.isEmpty && exception == null)
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                const TextSpan(text: "Nothing to view. Tap '"),
                TextSpan(
                  text: "Run",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const TextSpan(
                  text:
                      "' in the toolbox to execute your program and see its output here.",
                ),
              ],
            ),
          ),
        // To support newline (\n) and tab (\t) indicated by the user in their print statements
        Text(
          content
              .map(
                (elem) => elem.replaceAll(r'\n', '\n').replaceAll(r'\t', '\t'),
              )
              .join("\n"),
        ),
        if (exception != null)
          DartBlockExceptionWidget(
            dartblockException: exception!,
            program: program,
          ),
      ],
    );
  }
}
