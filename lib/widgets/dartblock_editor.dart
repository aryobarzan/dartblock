import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:code_text_field/code_text_field.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/theme_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highlight/languages/all.dart';
import 'package:dartblock/core/dartblock_executor.dart';
import 'package:dartblock/core/dartblock_program.dart';
import 'package:dartblock/models/function.dart';
import 'package:dartblock/models/dartblock_interaction.dart';
import 'package:dartblock/models/dartblock_notification.dart';
import 'package:dartblock/models/dartblock_value.dart';
import 'package:dartblock/models/statement.dart';
import 'package:dartblock/widgets/editors/custom_function_basic.dart';
import 'package:dartblock/widgets/helper_widgets.dart';
import 'package:dartblock/widgets/views/custom_function.dart';
import 'package:dartblock/widgets/views/other/dartblock_console.dart';
import 'package:dartblock/widgets/views/other/help_center.dart';
import 'package:dartblock/widgets/views/other/dartblock_exception.dart';
import 'package:dartblock/widgets/views/symbols.dart';

const double _toolboxHeight = 120;
const double _toolboxShowingCodeHeight = 100;
const double _toolboxNoActionsHeight = 50;

/// Inherited widget to keep track of dynamic data.
class DartBlockEditorInheritedWidget extends InheritedWidget {
  DartBlockEditorInheritedWidget({
    super.key,
    required this.program,
    required this.executor,
    required super.child,
    this.canChange = true,
    this.canDelete = true,
    this.canReorder = true,
    required bool isDraggingToolboxItem,
    required this.copiedStatement,
    required this.isCopiedStatementCut,
  }) : isDraggingToolboxItem = ValueNotifier(isDraggingToolboxItem);

  /// The DartBlock program.
  ///
  /// Includes main function and custom functions.
  final DartBlockProgram program;

  /// The DartBlock program executor.
  ///
  /// Keeps track of the execution result, including the console output and any exception that was thrown.
  final DartBlockExecutor executor;

  /// Whether new statements and custom functions can be created.
  final bool canChange;

  /// Whenever existing statements and custom functions can be deleted.
  final bool canDelete;

  /// Whether existing statements can have their order re-arranged.
  final bool canReorder;

  /// Whether a statement type ('chip') is being dragged from the toolbox.
  final ValueNotifier<bool> isDraggingToolboxItem;

  /// The last statement copied to the clipboard.
  final Statement? copiedStatement;

  /// Whether pasting the statement should clear out the clipboard.
  final bool isCopiedStatementCut;

  static DartBlockEditorInheritedWidget? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DartBlockEditorInheritedWidget>();
  }

  static DartBlockEditorInheritedWidget of(BuildContext context) {
    final DartBlockEditorInheritedWidget? result = maybeOf(context);
    assert(result != null, 'No NeoTechCoreInheritedWidget found in context');

    return result!;
  }

  @override
  bool updateShouldNotify(DartBlockEditorInheritedWidget oldWidget) =>
      program != oldWidget.program;
}

/// The main widget for viewing and editing a [DartBlockProgram].
///
/// Use this to integrate DartBlock into your program.
///
/// Note that this is a scrollable widget; include it in your program accordingly, e.g., by wrapping it in an `Expanded` widget.
class DartBlockEditor extends StatefulWidget {
  /// The DartBlock program.
  ///
  /// Includes main function and custom functions.
  final DartBlockProgram program;

  /// Whether new statements and custom functions can be created.
  final bool canChange;

  /// Whenever existing statements and custom functions can be deleted.
  final bool canDelete;

  /// Whether existing statements can have their order re-arranged.
  final bool canReorder;

  /// Whether the DartBlock program can be executed by the user.
  final bool canRun;

  /// The duration that DartBlock should wait until it automatically interrupts the execution of the [DartBlockProgram].
  ///
  /// By default, the duration is 5s, which is also the minimum.
  ///
  /// For more information, see [DartBlockExecutor.execute].
  final Duration? maximumExecutionDuration;

  /// Whether the visualization should be dense, i.e., non-scrollable.
  ///
  /// By default, this property is `false`, meaning [DartBlockEditor] is a scrollable widget.
  /// To integrate it in your app, rely for example on a parent [CustomScrollView], with [DartBlockEditor] being wrapped in a [SliverFillRemaining].
  /// Alternatively, place it in an existing scrollable widget by wrapping it in an [Expanded] widget. These are only examples.
  ///
  /// Set this property to `true` if you wish to integrate [DartBlockEditor] in a non-scrollable context, e.g., inside a [Column] widget.
  final bool isDense;

  /// The [ScrollController] to use for the widget.
  ///
  /// If null, the default [ScrollController] is used.
  final ScrollController? scrollController;

  /// Callback function to notify about changes to the program.
  ///
  /// Changes can include the addition, modification, re-ordering and deletion of statements and custom functions.
  final Function(DartBlockProgram changedDartBlockProgram)? onChanged;

  /// Callback function to notify about a user interaction with the user interface of DartBlock.
  final Function(DartBlockInteraction dartBlockInteraction)? onInteraction;

  /// The padding to include around the scrollable part of the widget.
  ///
  /// If null, no padding is applied.
  final EdgeInsets? padding;
  const DartBlockEditor({
    super.key,
    required this.program,
    required this.canChange,
    required this.canDelete,
    required this.canReorder,
    required this.canRun,
    this.maximumExecutionDuration,
    this.isDense = false,
    this.scrollController,
    this.onChanged,
    this.onInteraction,
    this.padding,
  });

  @override
  State<DartBlockEditor> createState() => _DartBlockEditorState();
}

class _DartBlockEditorState extends State<DartBlockEditor>
    with TickerProviderStateMixin {
  late DartBlockProgram program;
  late DartBlockExecutor executor;
  @override
  void initState() {
    super.initState();
    program = widget.program;
    executor = DartBlockExecutor(program);
    _toolboxTabController = TabController(
      length: 4,
      vsync: this,
      animationDuration: Duration.zero,
    );
    _toolboxTabController.addListener(() {
      _toolboxCategory = ToolboxCategory.values[_toolboxTabController.index];
    });
  }

  @override
  void dispose() {
    _toolboxTabController.dispose();
    super.dispose();
  }

  /// The current [_ViewOption] view state of DartBlock.
  _ViewOption viewOption = _ViewOption.blocks;

  /// The typed language the program should be exported to.
  DartBlockTypedLanguage language = DartBlockTypedLanguage.java;

  /// The current position of the [_DartBlockToolbox] in terms of its y-coordinate.
  ///
  /// -1 is a special value indicating that it has not been moved yet from its initial default location.
  double _toolboxY = -1;

  /// Whether the [_DartBlockToolbox] is currently being dragged vertically by the user.
  bool _isDraggingToolbox = false;

  /// Whether the [_DartBlockToolbox] is docked, i.e., fixed to its default location at the top of the widget.
  ///
  /// If `false`, the [_DartBlockToolbox] is undocked, meaning it can be freely moved around vertically by the user to place it elsewhere on the screen, including over the canvas (DartBlock program).
  bool _isToolboxDocked = true;

  /// Whether the [_DartBlockToolbox] is currently hidden.
  ///
  /// This property is `true` when [_isToolboxDocked] is `false` and the user is currently dragging a statement type from the toolbox to the canvas.
  bool _isToolboxHidden = false;

  /// The currently active tab of the [_DartBlockToolbox].
  ToolboxCategory _toolboxCategory = ToolboxCategory.variables;
  late TabController _toolboxTabController;

  /// Whether the [DartBlockProgram] is currently being executed.
  ///
  /// Used internally to render a [CircularProgressIndicator] in the "Run" button of the [_DartBlockToolbox], as well as to disable said "Run" button.
  bool _isExecuting = false;

  /// The [Statement] currently copied to the clipboard.
  Statement? _copiedStatement;

  /// Whether the copied statement is cut, i.e., it has been removed from the program rather than simply being copied to memory.
  bool _isCopiedStatementCut = false;
  @override
  Widget build(BuildContext context) {
    return DartBlockEditorInheritedWidget(
      program: program,
      executor: executor,
      canChange: widget.canChange,
      canDelete: widget.canDelete,
      canReorder: widget.canReorder,
      isDraggingToolboxItem: _isDraggingToolboxItem,
      copiedStatement: _copiedStatement,
      isCopiedStatementCut: _isCopiedStatementCut,
      child: NotificationListener<DartBlockNotification>(
        onNotification: (notification) {
          _onReceiveDartBlockNotification(notification);
          return true;
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (_toolboxY == -1) {
              _toolboxY = max(
                0,
                constraints.maxHeight -
                    (widget.canChange
                        ? _toolboxHeight
                        : _toolboxNoActionsHeight),
              );
            }
            // Render it as a non-scrollable widget.
            if (widget.isDense) {
              return _buildDenseBody(constraints);
            }

            /// Use a Stack widget such that the toolbox can potentially float over the program (canvas).
            return Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isToolboxDocked) _buildToolbox(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: widget.padding,
                        controller: widget.scrollController,
                        child: (viewOption == _ViewOption.script)
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: CodeTheme(
                                  data: CodeThemeData(
                                    styles:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? themeMap['monokai-sublime']!
                                        : themeMap["github-gist"]!,
                                  ),
                                  child: CodeField(
                                    lineNumberStyle: const LineNumberStyle(
                                      margin: 8,
                                      width: 34, // 34
                                    ),
                                    readOnly: true,
                                    isDense: true,
                                    horizontalScroll: true,
                                    wrap: false,
                                    enabled: true,
                                    controller: CodeController(
                                      text: widget.program
                                          .toScript(language: language)
                                          .trim(),
                                      language: allLanguages[language.name],
                                    ),
                                    textStyle: GoogleFonts.sourceCodePro(
                                      fontSize:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.fontSize ??
                                          12,
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: _buildFunctionWidgets(),
                              ),
                      ),
                    ),
                  ],
                ),
                if (!_isToolboxDocked && !_isToolboxHidden)
                  Positioned(
                    left: 5,
                    right: 5,
                    top: _toolboxY,
                    child: GestureDetector(
                      child: _buildToolbox(),
                      onVerticalDragStart: (details) {
                        DartBlockInteraction.create(
                          dartBlockInteractionType: DartBlockInteractionType
                              .startDraggingUndockedToolbox,
                          content: 'yCoordinate-$_toolboxY',
                        ).dispatch(context);
                        _isDraggingToolbox = true;
                      },
                      onVerticalDragEnd: (details) {
                        DartBlockInteraction.create(
                          dartBlockInteractionType: DartBlockInteractionType
                              .finishDraggingUndockedToolbox,
                          content: 'yCoordinate-$_toolboxY',
                        ).dispatch(context);
                        setState(() {
                          _isDraggingToolbox = false;
                        });
                      },
                      onVerticalDragUpdate: (details) {
                        setState(() {
                          _toolboxY += details.delta.dy;
                          _constrainToolboxY(constraints.maxHeight);
                        });
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _onReceiveDartBlockNotification(DartBlockNotification notification) {
    switch (notification) {
      case DartBlockInteractionNotification():
        if (widget.onInteraction != null) {
          widget.onInteraction!(notification.dartBlockInteraction);
        }
        break;
    }
  }

  Widget _buildDenseBody(BoxConstraints constraints) {
    return Stack(
      fit: StackFit.loose,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: !_isToolboxDocked && !_isToolboxHidden ? 200 : 0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isToolboxDocked) _buildToolbox(),
              (viewOption == _ViewOption.script)
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: CodeTheme(
                        data: CodeThemeData(
                          styles:
                              Theme.of(context).brightness == Brightness.dark
                              ? themeMap['monokai-sublime']!
                              : themeMap["github-gist"]!,
                        ),
                        child: CodeField(
                          lineNumberStyle: const LineNumberStyle(
                            margin: 8,
                            width: 34, // 34
                          ),
                          readOnly: true,
                          isDense: true,
                          horizontalScroll: true,
                          wrap: false,
                          enabled: true,
                          controller: CodeController(
                            text: widget.program
                                .toScript(language: language)
                                .trim(),
                            language: allLanguages[language.name],
                          ),
                          textStyle: GoogleFonts.sourceCodePro(
                            fontSize:
                                Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.fontSize ??
                                12,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _buildFunctionWidgets(),
                    ),
            ],
          ),
        ),
        if (!_isToolboxDocked && !_isToolboxHidden)
          Positioned(
            left: 5,
            right: 5,
            top: _toolboxY,
            child: GestureDetector(
              child: _buildToolbox(),
              onVerticalDragStart: (details) {
                _isDraggingToolbox = true;
              },
              onVerticalDragEnd: (details) {
                setState(() {
                  _isDraggingToolbox = false;
                });
              },
              onVerticalDragUpdate: (details) {
                setState(() {
                  _toolboxY += details.delta.dy;
                  _constrainToolboxY(constraints.maxHeight);
                });
              },
            ),
          ),
      ],
    );
  }

  /// Whether the [_DartBlockToolbox] was undocked the last time the user was viewing their [DartBlockProgram] in the [_ViewOption.blocks] mode.
  ///
  /// Used to restore the previous docked/undocked state when switching back to [_ViewOption.blocks].
  bool _wasToolboxPreviouslyDocked = false;

  /// Whether a statement type (block) is currently being dragged from the [_DartBlockToolbox].
  bool _isDraggingToolboxItem = false;
  Widget _buildToolbox() {
    return _DartBlockToolbox(
      toolboxTabController: _toolboxTabController,
      isTransparent: _isDraggingToolbox,
      isDocked: _isToolboxDocked,
      canUndock: widget.isDense ? false : true,
      isShowingCode: viewOption == _ViewOption.script,
      isExecuting: _isExecuting,
      showActions: widget.canChange,
      language: language,
      toolboxCategory: _toolboxCategory,
      onToolboxItemDragStart: () {
        /// Do not try dispatching the notification further up the widget tree, as we are at the same context level
        /// as the NotificationListener itself, meaning the notification would not be captured.
        _onReceiveDartBlockNotification(
          DartBlockInteractionNotification(
            DartBlockInteraction.create(
              dartBlockInteractionType:
                  DartBlockInteractionType.startedDraggingStatementFromToolbox,
            ),
          ),
        );
        setState(() {
          _isToolboxHidden = true;
          _isDraggingToolboxItem = true;
        });
        HapticFeedback.lightImpact();
      },
      onToolboxItemDragEnd: () {
        setState(() {
          _isToolboxHidden = false;
          _isDraggingToolboxItem = false;
        });
      },
      existingFunctionNames: program.customFunctions
          .map((e) => e.name)
          .toList(),
      canAddFunction: widget.canChange,
      onTapExtraAction: (extraAction) {
        switch (extraAction) {
          case _ToolboxExtraAction.console:
            _showConsole();
            break;
          case _ToolboxExtraAction.code:
            setState(() {
              if (viewOption == _ViewOption.blocks) {
                viewOption = _ViewOption.script;
                _wasToolboxPreviouslyDocked = _isToolboxDocked;
                _isToolboxDocked = true;
              } else {
                viewOption = _ViewOption.blocks;
                _isToolboxDocked = _wasToolboxPreviouslyDocked;
              }
            });
            break;
          case _ToolboxExtraAction.help:
            _showHelpCenter();
            break;
          case _ToolboxExtraAction.dock:
            setState(() {
              _isToolboxDocked = !_isToolboxDocked;
            });
            if (_isToolboxDocked) {
              _toolboxY = 25;
            }
            break;
        }
      },
      onCreateFunction: (newFunction) {
        _onCreateFunction(newFunction);
      },
      onCopyScript: () {
        Clipboard.setData(
          ClipboardData(text: widget.program.toScript(language: language)),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          createDartBlockInfoSnackBar(
            context,
            iconData: Icons.copy,
            message: "Copied code to clipboard.",
          ),
        );
      },
      onDownloadScript: () {
        try {
          FilePicker.platform
              .saveFile(
                fileName: 'DartBlock_script.${language.getFileExtension()}',
                bytes: utf8.encode(widget.program.toScript(language: language)),
              )
              .then((result) async {
                if (mounted && result != null) {
                  /// On iOS and Android, the bytes are directly written to the selected path.
                  ///
                  /// On desktop platforms, this has to be done as a second step.
                  if (Theme.of(context).platform == TargetPlatform.macOS ||
                      Theme.of(context).platform == TargetPlatform.windows ||
                      Theme.of(context).platform == TargetPlatform.linux) {
                    try {
                      await File(result).writeAsString(
                        widget.program.toScript(language: language),
                      );
                    } catch (err) {
                      // Failed to write contents of file
                    }
                  }
                }
              })
              .catchError((error) {
                return null;
              });
        } catch (err) {
          // Encoding failed or save failed
        }
      },
      onRun: widget.canRun
          ? () async {
              if (!_isExecuting) {
                setState(() {
                  _isExecuting = true;
                });
                if (widget.maximumExecutionDuration != null) {
                  await executor.execute(
                    duration: widget.maximumExecutionDuration!,
                  );
                } else {
                  await executor.execute();
                }
                if (executor.thrownException != null) {
                  /// In case the execution is interrupted by an exception,
                  /// additionally log this as a pseudo user interaction to best
                  /// keep track of the user's context.
                  _onReceiveDartBlockNotification(
                    DartBlockInteractionNotification(
                      DartBlockInteraction.create(
                        dartBlockInteractionType: DartBlockInteractionType
                            .executedProgramInterruptedByException,
                      ),
                    ),
                  );
                }
                _isExecuting = false;
                _showConsole();
                setState(() {});
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Your program is already executing..."),
                  ),
                );
              }
            }
          : null,
    );
  }

  void _onCreateFunction(DartBlockFunction newFunction) {
    setState(() {
      program.customFunctions.add(newFunction);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      createDartBlockInfoSnackBar(
        context,
        iconData: Icons.add,
        message: "Created custom function: ${newFunction.name}",
      ),
    );
  }

  void _constrainToolboxY(double maxHeight) {
    _toolboxY = max(
      0,
      min(
        _toolboxY,
        maxHeight -
            (widget.canChange ? _toolboxHeight : _toolboxNoActionsHeight),
      ),
    );
  }

  List<Widget> _buildFunctionWidgets() {
    return [
      ...([program.mainFunction] + program.customFunctions).mapIndexed(
        (index, dartBlockFunction) => Padding(
          padding: dartBlockFunction.isMainFunction()
              ? EdgeInsets.only(
                  bottom: program.customFunctions.isNotEmpty ? 8 : 0,
                )
              : EdgeInsets.only(
                  bottom: index < program.customFunctions.length - 1 ? 8 : 0,
                ),
          child: CustomFunctionWidget(
            customFunction: dartBlockFunction,
            isMainFunction: dartBlockFunction.isMainFunction(),
            onChanged: (value) {
              setState(() {
                if (!dartBlockFunction.isMainFunction()) {
                  /// IMPORTANT: -1 due to main function being the first element
                  program.customFunctions[index - 1] = value;
                }
              });
              if (widget.onChanged != null) {
                widget.onChanged!(program);
              }
            },
            onCopiedStatement: (statement, cut) {
              _onCopyStatement(statement, cut);
            },
            onPastedStatement: () {
              _onPastedStatement();
            },
            onDelete: dartBlockFunction.isMainFunction()
                ? null
                : () {
                    setState(() {
                      /// IMPORTANT: -1 due to main function being the first element
                      program.customFunctions.removeAt(index - 1);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      createDartBlockInfoSnackBar(
                        context,
                        iconData: Icons.delete,
                        message:
                            "Deleted custom function: ${dartBlockFunction.name}",
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.errorContainer,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    );
                    if (widget.onChanged != null) {
                      widget.onChanged!(program);
                    }
                  },
          ),
        ),
      ),

      /// Display a "New Function" button at the bottom of the canvas (below the functions of the DartBlockProgram), in addition to the "New Function" button found in the toolbox.
      if (widget.canChange)
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                _onReceiveDartBlockNotification(
                  DartBlockInteractionNotification(
                    DartBlockInteraction.create(
                      dartBlockInteractionType: DartBlockInteractionType
                          .openNewFunctionEditorFromCanvas,
                    ),
                  ),
                );
                _showNewFunctionSheet(
                  context,
                  existingCustomFunctionNames: program.customFunctions
                      .map((e) => e.name)
                      .toList(),
                  onReceiveDartBlockNotification: (notification) {
                    _onReceiveDartBlockNotification(notification);
                  },
                  onSaved: (newName, newReturnType) {
                    _onCreateFunction(
                      DartBlockFunction(newName, newReturnType, [], []),
                    );
                  },
                );
              },
              label: const Text("New Function"),
              icon: const NewFunctionSymbol(),
            ),
          ],
        ),
    ];
  }

  /// Copy a statement to memory.
  ///
  /// Show a SnackBar message about this event.
  ///
  /// If 'cut' is true, the copied statement can only be pasted once.
  void _onCopyStatement(Statement statement, bool cut) {
    setState(() {
      _copiedStatement = statement.copy();
      _isCopiedStatementCut = cut;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      createDartBlockInfoSnackBar(
        context,
        iconData: cut ? Icons.cut : Icons.copy,
        message:
            "${cut ? "Cut" : "Copied"} '${statement.statementType.toString()}' statement.",
      ),
    );
  }

  /// The copied statement has already been pasted at some part of the DartBlock program.
  ///
  /// Show a SnackBar message about this event.
  ///
  /// If the copied statement had been cut, clear out the copied statement such that it cannot be pasted again.
  void _onPastedStatement() {
    if (_copiedStatement != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        createDartBlockInfoSnackBar(
          context,
          iconData: Icons.paste,
          message:
              "Pasted '${_copiedStatement!.statementType.toString()}' statement.",
        ),
      );
      if (_isCopiedStatementCut) {
        setState(() {
          _copiedStatement = null;
          _isCopiedStatementCut = false;
        });
      }
    }
  }

  void _showConsole() {
    showModalBottomSheet(
      isScrollControlled: true,
      showDragHandle: true,
      clipBehavior: Clip.hardEdge,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      context: context,
      builder: (sheetContext) {
        /// Due to the modal sheet having a separate context and thus having no relation
        /// to the main context of DartBlockEditor, we capture DartBlockNotifications
        /// from the sheet's context and manually re-dispatch them using the parent context.
        ///
        /// The parent context may not necessarily be the DartBlockEditor's context,
        /// as certain sheets open additional nested sheets with their own contexts.
        /// Hence, this process needs to be repeated for every sheet until the DartBlockEditor's
        /// context is reached.
        ///
        /// Additionally, as notifications are not captured if they are dispatched at the same level as the
        /// NotificationListener, we no longer re-dispatch the notification, but
        /// immediately handle it.
        return NotificationListener<DartBlockNotification>(
          onNotification: (notification) {
            _onReceiveDartBlockNotification(notification);
            return true;
          },
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.13,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: DartBlockConsole(
                  content: executor.consoleOutput,
                  neoTechException: executor.thrownException,
                  neoTechCore: program,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showHelpCenter() {
    showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: true,
      clipBehavior: Clip.hardEdge,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      context: context,
      builder: (sheetContext) {
        /// Due to the modal sheet having a separate context and thus having no relation
        /// to the main context of DartBlockEditor, we capture DartBlockNotifications
        /// from the sheet's context and manually re-dispatch them using the parent context.
        ///
        /// The parent context may not necessarily be the DartBlockEditor's context,
        /// as certain sheets open additional nested sheets with their own contexts.
        /// Hence, this process needs to be repeated for every sheet until the DartBlockEditor's
        /// context is reached.
        ///
        /// Additionally, as notifications are not captured if they are dispatched at the same level as the
        /// NotificationListener, we no longer re-dispatch the notification, but
        /// immediately handle it.
        return NotificationListener<DartBlockNotification>(
          onNotification: (notification) {
            _onReceiveDartBlockNotification(notification);
            return true;
          },
          child: DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.13,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              child: const NeoTechHelpCenter(),
            ),
          ),
        );
      },
    );
  }
}

/// The available view options for the rendering of a DartBlock program.
///
/// `blocks` - Block-based view, which supports editing.
///
/// `script` - Typed language-based view, e.g., Java, which does not support editing.
enum _ViewOption {
  blocks("Editor"),
  script("Script");

  final String name;
  const _ViewOption(this.name);
}

enum _ToolboxExtraAction {
  console,
  code,
  dock,
  help;

  @override
  String toString() {
    switch (this) {
      case _ToolboxExtraAction.console:
        return 'Console';
      case _ToolboxExtraAction.code:
        return 'Code';
      case _ToolboxExtraAction.help:
        return 'Help';
      case _ToolboxExtraAction.dock:
        return 'Dock';
    }
  }
}

class _DartBlockToolbox extends StatelessWidget {
  final TabController toolboxTabController;
  final bool isTransparent;
  final bool isDocked;
  final bool canUndock;
  final bool isShowingCode;
  final bool showActions;
  final bool isExecuting;
  final DartBlockTypedLanguage language;
  final ToolboxCategory toolboxCategory;
  final Function()? onToolboxItemDragStart;
  final Function()? onToolboxItemDragEnd;
  final Function() onCopyScript;
  final Function() onDownloadScript;
  final Function()? onRun;

  final List<String> existingFunctionNames;
  final bool canAddFunction;
  final Function(DartBlockFunction) onCreateFunction;
  final Function(_ToolboxExtraAction) onTapExtraAction;
  const _DartBlockToolbox({
    required this.toolboxTabController,
    this.isTransparent = false,
    bool isDocked = false,
    this.canUndock = true,
    this.isShowingCode = false,
    this.showActions = true,
    this.isExecuting = false,
    this.language = DartBlockTypedLanguage.java,
    this.toolboxCategory = ToolboxCategory.variables,
    this.onToolboxItemDragStart,
    this.onToolboxItemDragEnd,
    required this.existingFunctionNames,
    required this.canAddFunction,
    required this.onCreateFunction,
    required this.onCopyScript,
    required this.onDownloadScript,
    required this.onRun,
    required this.onTapExtraAction,
  }) : isDocked = !canUndock ? true : isDocked;

  @override
  Widget build(BuildContext context) {
    final dartBlockEditorInheritedWidget = DartBlockEditorInheritedWidget.of(
      context,
    );
    return Opacity(
      opacity: isTransparent ? 0.5 : 1.0,
      child: Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 125),
          padding: const EdgeInsets.only(top: 0, left: 2, right: 2, bottom: 0),
          width: double.maxFinite,
          height: isShowingCode
              ? _toolboxShowingCodeHeight
              : showActions
              ? _toolboxHeight
              : _toolboxNoActionsHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            color: isShowingCode
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surface,
          ),
          child: isShowingCode
              ? _buildCodeViewActiveWidget(context)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FilledButton.icon(
                            onPressed: onRun != null && !isExecuting
                                ? () {
                                    DartBlockInteraction.create(
                                      dartBlockInteractionType:
                                          DartBlockInteractionType
                                              .executedProgram,
                                    ).dispatch(context);
                                    HapticFeedback.heavyImpact();
                                    onRun!();
                                  }
                                : null,
                            icon: isExecuting
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  )
                                : const Icon(Icons.play_circle_outline),
                            label: const Text("Run"),
                          ),
                          if (canAddFunction && showActions) ...[
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () {
                                DartBlockInteraction.create(
                                  dartBlockInteractionType:
                                      DartBlockInteractionType
                                          .openNewFunctionEditorFromToolbox,
                                ).dispatch(context);
                                _showNewFunctionSheet(
                                  context,
                                  existingCustomFunctionNames:
                                      existingFunctionNames,
                                  onReceiveDartBlockNotification: null,
                                  onSaved: (newName, newReturnType) {
                                    onCreateFunction(
                                      DartBlockFunction(
                                        newName,
                                        newReturnType,
                                        [],
                                        [],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: const Tooltip(
                                message: "Create new function...",
                                child: NewFunctionSymbol(),
                              ),
                            ),
                          ],
                          if (dartBlockEditorInheritedWidget
                                  .executor
                                  .thrownException !=
                              null)
                            PopupWidgetButton(
                              isFullWidth: true,
                              blurBackground: true,
                              tooltip: "Exception...",
                              onOpened: () {
                                DartBlockInteraction.create(
                                  dartBlockInteractionType:
                                      DartBlockInteractionType
                                          .tapExceptionIndicatorInToolbox,
                                  content:
                                      "ExceptionTitle-${dartBlockEditorInheritedWidget.executor.thrownException?.title}",
                                ).dispatch(context);
                              },
                              widget: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    "An exception was thrown during the last execution:",
                                  ),
                                  DartBlockExceptionWidget(
                                    dartblockException:
                                        dartBlockEditorInheritedWidget
                                            .executor
                                            .thrownException!,
                                    program:
                                        dartBlockEditorInheritedWidget.program,
                                  ),
                                  Text(
                                    "Think it's fixed now? Try running your program again.",
                                    textAlign: TextAlign.center,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              icon: Icon(
                                Icons.error,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          const Spacer(),
                          _buildExtraButtons(
                            context,
                            isShowingExceptionIconButton:
                                dartBlockEditorInheritedWidget
                                    .executor
                                    .thrownException !=
                                null,
                          ),
                        ],
                      ),
                    ),
                    if (showActions) ...[
                      TabBar(
                        dividerColor: Colors.transparent,
                        controller: toolboxTabController,
                        onTap: (value) {
                          DartBlockInteraction.create(
                            dartBlockInteractionType:
                                DartBlockInteractionType.changeToolboxTab,
                            content: "Index-$value",
                          ).dispatch(context);
                          HapticFeedback.lightImpact();
                        },
                        tabs: ToolboxCategory.values
                            .map(
                              (e) => Tab(height: 28, icon: e.getSymbol(24, 24)),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: TabBarView(
                          controller: toolboxTabController,
                          children: ToolboxCategory.values
                              .map(
                                (e) => SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: _DartBlockToolboxCategoryWidget(
                                    category: e,
                                    onItemDragStart: onToolboxItemDragStart,
                                    onItemDragEnd: onToolboxItemDragEnd,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildExtraButtons(
    BuildContext context, {
    bool isShowingExceptionIconButton = false,
  }) {
    List<_ToolboxExtraAction> items = _ToolboxExtraAction.values.toList();
    if (!canUndock) {
      items.remove(_ToolboxExtraAction.dock);
    }
    List<_ToolboxExtraAction> displayedActions = [];
    final List<Widget> children = [];
    var availableWidth =
        MediaQuery.of(context).size.width -
        (isShowingExceptionIconButton ? 160 : 120);
    if (isShowingExceptionIconButton) {
      availableWidth -= kMinInteractiveDimension;
    }
    if (canAddFunction) {
      availableWidth -= kMinInteractiveDimension;
    }
    while (availableWidth >= kMinInteractiveDimension && items.isNotEmpty) {
      displayedActions.add(items.removeAt(0));
      availableWidth -= kMinInteractiveDimension;
    }
    for (final item in displayedActions) {
      children.add(switch (item) {
        _ToolboxExtraAction.console => IconButton(
          tooltip: "Console",
          onPressed: () {
            DartBlockInteraction.create(
              dartBlockInteractionType: DartBlockInteractionType.openConsole,
            ).dispatch(context);
            onTapExtraAction(item);
          },
          icon: const Icon(Icons.wysiwyg),
        ),
        _ToolboxExtraAction.code => IconButton(
          tooltip: "Code",
          onPressed: () {
            DartBlockInteraction.create(
              dartBlockInteractionType: DartBlockInteractionType.viewScript,
            ).dispatch(context);
            onTapExtraAction(item);
          },
          icon: const Icon(Icons.code),
        ),
        _ToolboxExtraAction.help => IconButton(
          tooltip: "Help",
          onPressed: () {
            DartBlockInteraction.create(
              dartBlockInteractionType: DartBlockInteractionType.openHelpCenter,
            ).dispatch(context);
            onTapExtraAction(item);
          },
          icon: const Icon(Icons.help_outline),
        ),
        _ToolboxExtraAction.dock => IconButton(
          tooltip: isDocked ? "Undock" : "Dock",
          onPressed: () {
            if (isDocked) {
              DartBlockInteraction.create(
                dartBlockInteractionType:
                    DartBlockInteractionType.undockToolbox,
              ).dispatch(context);
            } else {
              DartBlockInteraction.create(
                dartBlockInteractionType: DartBlockInteractionType.dockToolbox,
              ).dispatch(context);
            }
            HapticFeedback.lightImpact();
            onTapExtraAction(item);
          },
          icon: Icon(isDocked ? Icons.open_in_new : Icons.publish),
        ),
      });
    }
    if (items.isNotEmpty) {
      children.add(
        PopupMenuButton(
          position: PopupMenuPosition.under,
          tooltip: "More",
          onSelected: (value) {
            switch (value) {
              case _ToolboxExtraAction.console:
                DartBlockInteraction.create(
                  dartBlockInteractionType:
                      DartBlockInteractionType.openConsole,
                ).dispatch(context);
                break;
              case _ToolboxExtraAction.code:
                DartBlockInteraction.create(
                  dartBlockInteractionType: DartBlockInteractionType.viewScript,
                ).dispatch(context);
                break;
              case _ToolboxExtraAction.dock:
                if (isDocked) {
                  DartBlockInteraction.create(
                    dartBlockInteractionType:
                        DartBlockInteractionType.undockToolbox,
                  ).dispatch(context);
                } else {
                  DartBlockInteraction.create(
                    dartBlockInteractionType:
                        DartBlockInteractionType.dockToolbox,
                  ).dispatch(context);
                }
                break;
              case _ToolboxExtraAction.help:
                DartBlockInteraction.create(
                  dartBlockInteractionType:
                      DartBlockInteractionType.openHelpCenter,
                ).dispatch(context);
                break;
            }
            onTapExtraAction(value);
          },
          itemBuilder: (context) => items
              .map(
                (e) => PopupMenuItem(
                  value: e,
                  child: ListTile(
                    leading: Icon(switch (e) {
                      _ToolboxExtraAction.console => Icons.wysiwyg,
                      _ToolboxExtraAction.code => Icons.code,
                      _ToolboxExtraAction.help => Icons.help_outline,
                      _ToolboxExtraAction.dock =>
                        isDocked ? Icons.open_in_new : Icons.publish,
                    }),
                    title: Text(switch (e) {
                      _ToolboxExtraAction.console => 'Console',
                      _ToolboxExtraAction.code => 'Code',
                      _ToolboxExtraAction.help => 'Help',
                      _ToolboxExtraAction.dock => isDocked ? 'Undock' : 'Dock',
                    }),
                  ),
                ),
              )
              .toList(),
        ),
      );
    }
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget _buildCodeViewActiveWidget(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OverflowBar(
          alignment: MainAxisAlignment.spaceBetween,
          children: [
            FilledButton.icon(
              onPressed: () {
                DartBlockInteraction.create(
                  dartBlockInteractionType:
                      DartBlockInteractionType.returnToEditorFromScriptView,
                ).dispatch(context);
                onTapExtraAction(_ToolboxExtraAction.code);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text("Editor"),
            ),
            OverflowBar(
              children: [
                IconButton(
                  tooltip: "Save ${language.name} code to file...",
                  onPressed: () {
                    DartBlockInteraction.create(
                      dartBlockInteractionType:
                          DartBlockInteractionType.saveScriptToFile,
                    ).dispatch(context);
                    onDownloadScript();
                  },
                  icon: const Icon(Icons.download),
                ),
                IconButton(
                  tooltip: "Copy code to clipboard.",
                  onPressed: () {
                    DartBlockInteraction.create(
                      dartBlockInteractionType:
                          DartBlockInteractionType.copyScript,
                    ).dispatch(context);
                    onCopyScript();
                  },
                  icon: const Icon(Icons.copy),
                ),
              ],
            ),
          ],
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: RichText(
            maxLines: 1,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium?.apply(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              children: [
                const TextSpan(text: "DartBlock program as "),
                TextSpan(
                  text: language.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const TextSpan(text: " code:"),
              ],
            ),
          ),
        ),
        const SizedBox(height: 2),
      ],
    );
  }
}

enum ToolboxCategory {
  variables('Variables'),
  loops('Loops'),
  decisionStructures('Decision Structures'),
  other('Other');

  final String name;
  const ToolboxCategory(this.name);

  IconData getIcon() {
    switch (this) {
      case ToolboxCategory.variables:
        return Icons.code;
      case ToolboxCategory.loops:
        return Icons.loop;
      case ToolboxCategory.decisionStructures:
        return Icons.confirmation_number;
      case ToolboxCategory.other:
        return Icons.devices_other;
    }
  }

  Widget getSymbol(double width, double height, {Color? color}) {
    switch (this) {
      case ToolboxCategory.variables:
        return Icon(Icons.data_object, size: width);
      case ToolboxCategory.loops:
        return Icon(Icons.loop, size: width);
      case ToolboxCategory.decisionStructures:
        return Icon(Icons.alt_route, size: width);
      case ToolboxCategory.other:
        return Icon(Icons.dashboard_outlined, size: width);
    }
  }
}

class _DartBlockToolboxCategoryWidget extends StatelessWidget {
  final ToolboxCategory category;
  final Function()? onItemDragStart;
  final Function()? onItemDragEnd;
  const _DartBlockToolboxCategoryWidget({
    required this.category,
    this.onItemDragStart,
    this.onItemDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    List<StatementType> statementTypes;
    switch (category) {
      case ToolboxCategory.variables:
        statementTypes = [
          StatementType.variableDeclarationStatement,
          StatementType.variableAssignmentStatement,
          StatementType.returnStatement,
          StatementType.customFunctionCallStatement,
        ];
        break;
      case ToolboxCategory.loops:
        statementTypes = [
          StatementType.forLoopStatement,
          StatementType.whileLoopStatement,
          StatementType.breakStatement,
          StatementType.continueStatement,
        ];
        break;
      case ToolboxCategory.decisionStructures:
        statementTypes = [StatementType.ifElseStatement];
        break;
      case ToolboxCategory.other:
        statementTypes = [StatementType.printStatement];
    }

    List<Widget> items = [];
    for (var statementType in statementTypes) {
      if (statementType == StatementType.statementBlockStatement) {
        continue;
      }
      items.add(
        _DartBlockToolboxItemWidget(
          statementType: statementType,
          onDragStart: onItemDragStart,
          onDragEnd: onItemDragEnd,
        ),
      );
    }

    return Wrap(spacing: 4, runSpacing: 0, children: items);
  }
}

class _DartBlockToolboxItemWidget extends StatelessWidget {
  final StatementType statementType;
  final Function()? onDragStart;
  final Function()? onDragEnd;
  const _DartBlockToolboxItemWidget({
    required this.statementType,
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable(
      data: statementType,
      delay: const Duration(milliseconds: 150),
      feedback: _build(context, true),
      onDragStarted: onDragStart,
      onDragEnd: (details) {
        if (onDragEnd != null) {
          onDragEnd!();
        }
      },
      onDraggableCanceled: (velocity, offset) {
        if (onDragEnd != null) {
          onDragEnd!();
        }
      },
      onDragCompleted: () {
        if (onDragEnd != null) {
          onDragEnd!();
        }
      },
      child: _build(context, false),
    );
  }

  Widget _build(BuildContext context, bool isDragging) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: !isDragging
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isDragging)
            Icon(
              Icons.add,
              size: 18,
              color: !isDragging
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onPrimary,
            ),
          Text(
            statementType.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: !isDragging
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class StatementTypePicker extends StatelessWidget {
  final Function(StatementType statementType) onSelect;
  final Function()? onPasteStatement;
  const StatementTypePicker({
    super.key,
    required this.onSelect,
    this.onPasteStatement,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...StatementType.values
            .whereNot(
              (statementType) =>
                  statementType == StatementType.statementBlockStatement,
            )
            .sorted((a, b) => a.getOrderValue().compareTo(b.getOrderValue()))
            .map(
              (statementType) => _StatementTypeCard(
                statementType: statementType,
                onTap: () {
                  DartBlockInteraction.create(
                    dartBlockInteractionType: DartBlockInteractionType
                        .tapStatementFromStatementPicker,
                    content: 'StatementType-${statementType.name}',
                  ).dispatch(context);
                  onSelect(statementType);
                },
              ),
            ),
        if (onPasteStatement != null)
          _StatementPasteCard(
            onTap: () {
              DartBlockInteraction.create(
                dartBlockInteractionType:
                    DartBlockInteractionType.pasteStatementToToolboxDragTarget,
              ).dispatch(context);
              onPasteStatement!();
            },
          ),
      ],
    );
  }
}

class _StatementTypeCard extends StatelessWidget {
  final StatementType statementType;
  final Function onTap;
  const _StatementTypeCard({required this.statementType, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110, //80
      height: 72,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          onTap();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: statementType.getCategory().getIconData(18),
            ),
            const SizedBox(height: 4),
            Text(
              statementType.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatementPasteCard extends StatelessWidget {
  final Function onTap;
  const _StatementPasteCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 72,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          onTap();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                border: Border.all(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.paste,
                size: 18,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Paste",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

void _showNewFunctionSheet(
  BuildContext context, {
  required List<String> existingCustomFunctionNames,
  required Function(String newName, DartBlockDataType? newReturnType) onSaved,

  /// If the context is the same as the main DartBlockEditor's context, indicate
  /// this argument to handle incoming DartBlockNotifications.
  /// Otherwise, the notifications will be automatically propagated upwards.
  required Function(DartBlockNotification notification)?
  onReceiveDartBlockNotification,
}) {
  HapticFeedback.mediumImpact();
  showModalBottomSheet(
    isScrollControlled: true,
    clipBehavior: Clip.hardEdge,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
    ),
    context: context,
    builder: (sheetContext) {
      /// Due to the modal sheet having a separate context and thus no relation
      /// to the main context of the DartBlockEditor, we capture DartBlockNotifications
      /// from the sheet's context and manually re-dispatch them using the parent context.
      /// The parent context may not necessarily be the DartBlockEditor's context,
      /// as certain sheets open additional nested sheets with their own contexts,
      /// hence this process needs to be repeated for every sheet until the DartBlockEditor's
      /// context is reached.
      return NotificationListener<DartBlockNotification>(
        onNotification: (notification) {
          if (onReceiveDartBlockNotification != null) {
            onReceiveDartBlockNotification(notification);
          } else {
            notification.dispatch(context);
          }

          return true;
        },
        child: Padding(
          padding: EdgeInsets.only(
            left: 8,
            right: 8,
            top: 8,

            /// Important: do not use context, but sheetContext, otherwise the on-screen keyboard
            /// will cover the editor and not properly push it up the screen.
            bottom: 16 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: CustomFunctionBasicEditor(
            existingCustomFunctionNames: existingCustomFunctionNames,
            canDelete: false,
            canChange: true,
            onDelete: () {},
            onSaved: (newName, newReturnType) {
              Navigator.of(context).pop();
              onSaved(newName, newReturnType);
            },
          ),
        ),
      );
    },
  );
}
