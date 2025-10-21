import 'package:flutter/material.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:dartblock_code/widgets/views/symbols.dart';
import 'package:dartblock_code/widgets/views/toolbox_related.dart';
import 'package:dartblock_code/widgets/views/variable_definition.dart';

/// An explainer for a DartBlock feature.
class DartBlockHelpItem {
  /// A unique ID.
  final String id;

  /// A short title for the explainer.
  final String title;

  /// A short description of the explainer, used as a preview.
  final String shortDescription;

  /// The full body of the explainer.
  final String body;

  /// The widget to render the help item.
  ///
  /// If null, a simple Text([body]) is used.
  final Widget Function(BuildContext context)? builder;

  DartBlockHelpItem({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.body,
    required this.builder,
  });

  /// How the explainer should be rendered.
  Widget build(BuildContext context) {
    if (builder != null) {
      return builder!(context);
    } else {
      return Text(body);
    }
  }

  /// The default list of help items for the main concepts of DartBlock.
  static List<DartBlockHelpItem> getHelpItems() {
    return [
      DartBlockHelpItem(
        id: 'help-0',
        title: 'Data Types',
        shortDescription: 'int, double, boolean and String.',
        body: 'Data types',
        builder: (context) => const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '4 data types are available, each symbolized by a unique color and icon:',
            ),
            ListTile(
              leading: NeoTechDataTypeSymbol(
                dataType: DartBlockDataType.integerType,
              ),
              title: Text("Integer"),
              subtitle: Text('Whole number (not fractional): -1, 0, 8, ...'),
            ),
            ListTile(
              leading: NeoTechDataTypeSymbol(
                dataType: DartBlockDataType.doubleType,
              ),
              title: Text("Double"),
              subtitle: Text('Real number (fractional): -4.0, 0.0, 8.42, ...'),
            ),
            ListTile(
              leading: NeoTechDataTypeSymbol(
                dataType: DartBlockDataType.booleanType,
              ),
              title: Text("Boolean"),
              subtitle: Text('Logical value: true or false'),
            ),
            ListTile(
              leading: NeoTechDataTypeSymbol(
                dataType: DartBlockDataType.stringType,
              ),
              title: Text("String"),
              subtitle: Text('Textual value: "The white rabbit has 4 feet."'),
            ),
          ],
        ),
      ),
      DartBlockHelpItem(
        id: 'help-1',
        title: 'Variables',
        shortDescription: 'Storing values.',
        body: 'Data types',
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "A variable maps a value of a given data type to a name. This allows you to retrieve and reuse a value in multiple parts of your program, which will also reflect any updates you make to the value associated with the variable.",
            ),
            ListTile(
              leading: VariableDefinitionWidget(
                variableDefinition: DartBlockVariableDefinition(
                  "x",
                  DartBlockDataType.booleanType,
                ),
              ),
              title: const Text("Variable"),
              subtitle: const Text(
                'The symbol on the left is an example of a variable "x" with the data type "boolean".',
              ),
            ),
            const Text(
              "Your programs will typically always start with 1 or more variable declarations.\nNote that there is a difference between a variable declaration and a variable update:",
            ),
            ListTile(
              title: const Text("Variable Declaration"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Specify the data type and name of the variable. The initial value is optional, meaning it is 'null' if not specified.\nA variable declaration always precedes a variable update.",
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ColoredTitleChip(
                        title: StatementType.variableDeclarationStatement
                            .toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text("Variable Update"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Update the value associated with a variable, i.e., either assign an initial value or change the existing value of the variable.\nA variable update only requires the specification of the name and new value, not its data type as that is already known from the preceding variable declaration.",
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ColoredTitleChip(
                        title: StatementType.variableAssignmentStatement
                            .toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      DartBlockHelpItem(
        id: 'help-2',
        title: 'Toolbox',
        shortDescription: 'Accessing the main controls.',
        body: 'Toolbox',
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "The toolbox contains the main controls for running your program, creating new functions and more.",
            ),
            ListTile(
              leading: Icon(
                Icons.play_circle_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text("Run"),
              subtitle: const Text(
                "Execute your program.",
              ), // : if all goes well, the console will be opened to display your program's output.\nIn case of an error, the console will display the relevant information.
            ),
            const ListTile(
              leading: NewFunctionSymbol(size: 20),
              title: Text("New Function"),
              subtitle: Text("Tap to create a new custom function."),
            ),
            const ListTile(
              leading: Icon(Icons.wysiwyg),
              title: Text("Console"),
              subtitle: Text(
                "View the output of your program from its latest execution.",
              ),
            ),
            const ListTile(
              leading: Icon(Icons.code),
              title: Text("Code"),
              subtitle: Text("View your program as real code."),
            ),
            const ListTile(
              leading: Icon(Icons.open_in_new),
              title: Text("Undock"),
              subtitle: Text(
                "Undock the toolbox, allowing you to drag it around.",
              ),
            ),
            const ListTile(
              leading: Icon(Icons.publish),
              title: Text("Dock"),
              subtitle: Text(
                "Dock the toolbox, fixing it to the top of the screen.",
              ),
            ),
            const ListTile(
              leading: Icon(Icons.help_outline),
              title: Text("Help"),
              subtitle: Text("Access this help page!"),
            ),
          ],
        ),
      ),
      DartBlockHelpItem(
        id: 'help-3',
        title: 'Statements',
        shortDescription: 'Adding new statements.',
        body: 'Statements',
        builder: (context) => const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "To create a statement and add it to your program, drag the statement type from the Toolbox and drop it in the position you want it to be created.",
            ),
            ListTile(
              title: ToolboxDragTargetIndicator(statementType: null),
              subtitle: Text(
                "Drop the new statement inside this indicator to add it to your program.",
              ),
            ),
            ListTile(
              title: Text("Alternative"),
              subtitle: Text(
                "Alternatively, drop the new statement on top of an existing statement if you want to insert it right after that statement.",
              ),
            ),
          ],
        ),
      ),
      DartBlockHelpItem(
        id: 'help-4',
        title: 'Custom Functions',
        shortDescription: 'Adding new statements.',
        body: 'Statements',
        builder: (context) => const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              trailing: NewFunctionSymbol(),
              title: Text("Create"),
              subtitle: Text(
                """To create a custom function, tap the green function icon in the Toolbox next to the 'Run' button!""",
              ),
            ),
            ListTile(
              trailing: NeoTechDataTypeSymbol(
                dataType: DartBlockDataType.booleanType,
                includeLabel: true,
              ),
              title: Text("Return Type"),
              subtitle: Text(
                """Indicate the custom function's return type, i.e., what type of value a call to the function will yield.
If the function is not meant to return a value, indicate 'void' as the return type.""",
              ),
            ),
            ListTile(
              title: Text("Name"),
              subtitle: Text("Indicate a unique name for the custom function."),
            ),
            ListTile(
              title: Text("Parameters"),
              subtitle: Text(
                "After creating the custom function, you can additionally add parameters to it: essentially, this means whenever the function should be called, specific input values need to be passed to the function.",
              ),
            ),
            ListTile(
              title: Text("Return Value"),
              subtitle: Text(
                """If the return type of the custom function is not 'void', the custom function must always return a value of the appropriate type when executed.
As such, ensure you add a 'Return Value' statement to your custom function, or multiple in case there are different execution branches due to for example an 'If-Then-Else' statement.""",
              ),
            ),
          ],
        ),
      ),
      DartBlockHelpItem(
        id: 'help-5',
        title: 'Common statement actions',
        shortDescription: 'Editing, deleting, reordering.',
        body: 'Common actions',
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text("Edit"),
              subtitle: const Text(
                "Tap the statement you want to edit and select 'Edit' from the shown menu.",
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              title: const Text("Delete"),
              subtitle: const Text(
                "Tap the statement you want to delete and select 'Delete' from the shown menu.",
              ),
            ),
            const ListTile(
              leading: Icon(Icons.sort),
              title: Text("Reorder"),
              subtitle: Text(
                "Long-press the statement you want to reorder for a brief moment, then start dragging it to its new position.",
              ),
            ),
          ],
        ),
      ),
      DartBlockHelpItem(
        id: 'help-6',
        title: 'Exceptions',
        shortDescription: 'Errors when running your program.',
        body: 'Common actions',
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              """When your program is malformed, running it will cause an 'Exception' to be thrown. In most cases, the exception, as well as the relevant statement which caused it, are clearly detailed such that you can fix the issue and re-run the program.""",
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.titleMedium,
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.error,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: "Stack Overflow",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const Text(
              """This is a special type of error which may be thrown for various reasons:
- Your program might contain an infinite loop.
- One of your recursive functions might lack an ending condition.
- Your program is too 'complex', meaning if its execution does not terminate within 5 seconds, it is automatically interrupted.""",
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.titleMedium,
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.error,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: "Critical Error",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const Text(
              """In very extreme cases, a 'critical error' might be thrown when executing your program.
Please send a bug report in that case!""",
            ),
          ],
        ),
      ),
    ];
  }
}
