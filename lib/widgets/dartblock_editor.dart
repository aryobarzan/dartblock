import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dartblock_code/widgets/dartblock_colors.dart';
import 'package:dartblock_code/widgets/helpers/adaptive_display.dart';
import 'package:dartblock_code/widgets/helpers/provider_aware_modal.dart';
import 'package:file_picker/file_picker.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:collection/collection.dart';
import 'package:dartblock_code/widgets/views/toolbox/models/code_view_action.dart';
import 'package:dartblock_code/widgets/views/toolbox/models/toolbox_action.dart';
import 'package:dartblock_code/widgets/views/toolbox/models/toolbox_configuration.dart';
import 'package:dartblock_code/widgets/views/toolbox/toolbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/theme_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highlight/languages/all.dart';
import 'package:dartblock_code/core/dartblock_executor.dart';
import 'package:dartblock_code/core/dartblock_program.dart';
import 'package:dartblock_code/models/function.dart';
import 'package:dartblock_code/models/dartblock_interaction.dart';
import 'package:dartblock_code/models/dartblock_notification.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/editors/custom_function_basic.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:dartblock_code/widgets/views/custom_function.dart';
import 'package:dartblock_code/widgets/views/other/dartblock_console.dart';
import 'package:dartblock_code/widgets/views/other/help_center.dart';
import 'package:dartblock_code/widgets/views/symbols.dart';
import 'package:dartblock_code/widgets/dartblock_editor_providers.dart';

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

  final List<DartBlockNativeFunctionCategory> allowedNativeFunctionCategories;

  final List<DartBlockNativeFunctionType> allowedNativeFunctionTypes;

  /// Whether the visualization should be dense, i.e., non-scrollable.
  ///
  /// By default, this property is `false`, meaning [DartBlockEditor] is a scrollable widget.
  /// To integrate it in your app, rely for example on a parent [CustomScrollView], with [DartBlockEditor] being wrapped in a [SliverFillRemaining].
  /// Alternatively, place it in an existing scrollable widget by wrapping it in an [Expanded] widget. These are only examples.
  ///
  /// Set this property to `true` if you wish to integrate [DartBlockEditor] in a non-scrollable context, e.g., inside a [Column] widget.
  final bool isDense;

  final DartBlockColors? colors;

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
    List<DartBlockNativeFunctionCategory>? allowedNativeFunctionCategories,
    List<DartBlockNativeFunctionType>? allowedNativeFunctionTypes,
    this.isDense = false,
    this.colors,
    this.scrollController,
    this.onChanged,
    this.onInteraction,
    this.padding,
  }) : allowedNativeFunctionCategories =
           allowedNativeFunctionCategories ??
           DartBlockNativeFunctionCategory.values,
       allowedNativeFunctionTypes =
           allowedNativeFunctionTypes ?? DartBlockNativeFunctionType.values;

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
  }

  /// The current [DartBlockViewOption] view state of DartBlock.
  DartBlockViewOption viewOption = DartBlockViewOption.blocks;

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

  /// Whether the [DartBlockProgram] is currently being executed.
  ///
  /// Used internally to render a [CircularProgressIndicator] in the "Run" button of the [_DartBlockToolbox], as well as to disable said "Run" button.
  bool _isExecuting = false;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        programProvider.overrideWith(
          () => ProgramNotifier.withProgram(program),
        ),
        settingsProvider.overrideWith(
          (ref) => DartBlockSettings.fromBrightness(
            canChange: widget.canChange,
            canDelete: widget.canDelete,
            canReorder: widget.canReorder,
            allowedNativeFunctionCategories:
                widget.allowedNativeFunctionCategories,
            allowedNativeFunctionTypes: widget.allowedNativeFunctionTypes,
            colors: widget.colors,
            brightness: Theme.of(context).brightness,
          ),
        ),
      ],
      child: Consumer(
        builder: (context, ref, child) {
          // Listen to interaction events and forward to callback (new approach - disabled for now)
          // ref.listen<DartBlockInteraction?>(interactionEventProvider, (
          //   previous,
          //   next,
          // ) {
          //   // print(next);
          //   // if (next != null && widget.onInteraction != null) {
          //   //   widget.onInteraction!(next);
          //   // }
          // });

          return child!;
        },
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
                          ? ToolboxConfig.toolboxHeight
                          : ToolboxConfig.toolboxMinimalHeight),
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
                          child: (viewOption == DartBlockViewOption.script)
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: _buildFunctionWidgets(),
                                ),
                        ),
                      ),
                    ],
                  ),
                  if (!_isToolboxDocked)
                    Positioned(
                      left: 5,
                      right: 5,
                      top: _toolboxY,
                      // IMPORTANT: do not conditionally include the toolbox here.
                      // Otherwise, if the toolbox is hidden, it is no longer part of the widget tree.
                      // Subsequently, when the user stops dragging a statement from the toolbox,
                      // onToolboxItemDragEnd will not be triggered, resulting in the toolbox never being shown again.
                      child: Opacity(
                        opacity: _isToolboxHidden ? 0.0 : 1.0,
                        child: IgnorePointer(
                          ignoring: _isToolboxHidden,
                          child: _buildToolbox(),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
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
              (viewOption == DartBlockViewOption.script)
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
        if (!_isToolboxDocked)
          Positioned(
            left: 5,
            right: 5,
            top: _toolboxY,
            child: Opacity(
              opacity: _isToolboxHidden ? 0.0 : 1.0,
              child: IgnorePointer(
                ignoring: _isToolboxHidden,
                child: _buildToolbox(),
              ),
            ),
          ),
      ],
    );
  }

  /// Whether the [_DartBlockToolbox] was undocked the last time the user was viewing their [DartBlockProgram] in the [DartBlockViewOption.blocks] mode.
  ///
  /// Used to restore the previous docked/undocked state when switching back to [DartBlockViewOption.blocks].
  bool _wasToolboxPreviouslyDocked = false;

  Widget _buildToolbox() {
    return Consumer(
      builder: (context, ref, child) {
        final isDraggingStatement = ref.watch(isDraggingToolboxItemProvider);
        final availableFunctions = ref.watch(availableFunctionsProvider([]));
        return DartBlockToolbox(
          isTransparent: _isDraggingToolbox,
          isDocked: _isToolboxDocked,
          canUndock: widget.isDense ? false : true,
          isShowingCode: viewOption == DartBlockViewOption.script,
          isExecuting: _isExecuting,
          showActions: widget.canChange,
          onToolboxDragStart: !_isToolboxDocked && !isDraggingStatement
              ? (details) {
                  // The user has started dragging the undocked toolbox around (vertically).
                  DartBlockInteraction.create(
                    dartBlockInteractionType:
                        DartBlockInteractionType.startDraggingUndockedToolbox,
                    content: 'yCoordinate-$_toolboxY',
                  ).dispatch(context);
                  setState(() {
                    _isDraggingToolbox = true;
                  });
                }
              : null,
          onToolboxDragEnd: !_isToolboxDocked && !isDraggingStatement
              ? (details) {
                  // The user has finished dragging the undocked toolbox around (vertically).
                  DartBlockInteraction.create(
                    dartBlockInteractionType:
                        DartBlockInteractionType.finishDraggingUndockedToolbox,
                    content: 'yCoordinate-$_toolboxY',
                  ).dispatch(context);
                  setState(() {
                    _isDraggingToolbox = false;
                  });
                }
              : null,
          onToolboxDragUpdate: !_isToolboxDocked && !isDraggingStatement
              ? (details) {
                  setState(() {
                    _toolboxY += details.delta.dy;
                    _constrainToolboxY(MediaQuery.of(context).size.height);
                  });
                }
              : null,
          onToolboxItemDragStart: () {
            // The user has started dragging a statement type from the toolbox. (docked/undocked)

            /// Do not try dispatching the notification further up the widget tree, as we are at the same context level
            /// as the NotificationListener itself, meaning the notification would not be captured.
            _onReceiveDartBlockNotification(
              DartBlockInteractionNotification(
                DartBlockInteraction.create(
                  dartBlockInteractionType: DartBlockInteractionType
                      .startedDraggingStatementFromToolbox,
                ),
              ),
            );
            setState(() {
              _isToolboxHidden = true;

              ref.read(isDraggingToolboxItemProvider.notifier).state = true;
            });
            HapticFeedback.lightImpact();
          },
          onToolboxItemDragEnd: () {
            // The user has finished dragging a statement type from the toolbox. (docked/undocked)
            setState(() {
              _isToolboxHidden = false;
              ref.read(isDraggingToolboxItemProvider.notifier).state = false;
            });
          },
          existingFunctionNames: availableFunctions.map((e) => e.name).toList(),
          canAddFunction: widget.canChange,
          onAction: (extraAction) {
            switch (extraAction) {
              case ToolboxExtraAction.console:
                _showConsole(context);
                break;
              case ToolboxExtraAction.code:
                setState(() {
                  if (viewOption == DartBlockViewOption.blocks) {
                    viewOption = DartBlockViewOption.script;
                    _wasToolboxPreviouslyDocked = _isToolboxDocked;
                    _isToolboxDocked = true;
                  } else {
                    viewOption = DartBlockViewOption.blocks;
                    _isToolboxDocked = _wasToolboxPreviouslyDocked;
                  }
                });
                break;
              case ToolboxExtraAction.help:
                _showHelpCenter(context);
                break;
              case ToolboxExtraAction.dock:
                setState(() {
                  _isToolboxDocked = !_isToolboxDocked;
                });
                if (_isToolboxDocked) {
                  _toolboxY = 25;
                }
                break;
            }
          },
          onCodeViewAction: (action) {
            switch (action) {
              case CodeViewAction.copy:
                _onCopyScript();
                break;
              case CodeViewAction.save:
                _onDownloadScript();
                break;
            }
          },
          onCreateFunction: (newFunction) {
            _onCreateFunction(newFunction);
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
                    if (context.mounted) {
                      _showConsole(context);
                    }
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
      },
    );
  }

  void _onCreateFunction(DartBlockCustomFunction newFunction) {
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

  void _onCopyScript() {
    DartBlockInteraction.create(
      dartBlockInteractionType: DartBlockInteractionType.copyScript,
    ).dispatch(context);
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
  }

  void _onDownloadScript() {
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
                  await File(
                    result,
                  ).writeAsString(widget.program.toScript(language: language));
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
  }

  void _constrainToolboxY(double maxHeight) {
    _toolboxY = max(
      0,
      min(
        _toolboxY,
        maxHeight -
            (widget.canChange
                ? ToolboxConfig.toolboxHeight
                : ToolboxConfig.toolboxMinimalHeight),
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
          child: Consumer(
            builder: (context, ref, child) => CustomFunctionWidget(
              customFunction: dartBlockFunction,
              isMainFunction: dartBlockFunction.isMainFunction(),
              onChanged: (value) {
                setState(() {
                  if (!dartBlockFunction.isMainFunction()) {
                    /// IMPORTANT: -1 due to main function being the first element
                    program.customFunctions[index - 1] = value;
                  }
                });
                // Notify provider listeners of the change
                ref.read(programProvider.notifier).state = program;
                if (widget.onChanged != null) {
                  widget.onChanged!(program);
                }
              },
              onCopiedStatement: (statement, cut) {
                ScaffoldMessenger.of(context).showSnackBar(
                  createDartBlockInfoSnackBar(
                    context,
                    iconData: cut ? Icons.cut : Icons.copy,
                    message:
                        "${cut ? "Cut" : "Copied"} '${statement.statementType.toString()}' statement.",
                  ),
                );
              },
              onPastedStatement: () {
                final editorState = ref.watch(editorStateProvider);
                if (editorState.copiedStatement != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    createDartBlockInfoSnackBar(
                      context,
                      iconData: Icons.paste,
                      message:
                          "Pasted '${editorState.copiedStatement!.statementType.toString()}' statement.",
                    ),
                  );
                  if (editorState.isCopiedStatementCut) {
                    setState(() {
                      ref.read(editorStateProvider.notifier).clearClipboard();
                    });
                  }
                }
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
      ),

      /// Display a "New Function" button at the bottom of the canvas (below the functions of the DartBlockProgram), in addition to the "New Function" button found in the toolbox.
      if (widget.canChange)
        Row(
          children: [
            Consumer(
              builder: (context, ref, child) => TextButton.icon(
                onPressed: () {
                  _onReceiveDartBlockNotification(
                    DartBlockInteractionNotification(
                      DartBlockInteraction.create(
                        dartBlockInteractionType: DartBlockInteractionType
                            .openNewFunctionEditorFromCanvas,
                      ),
                    ),
                  );
                  final availableFunctions = ref.watch(
                    availableFunctionsProvider([]),
                  );
                  showNewFunctionSheet(
                    context,
                    existingFunctionNames: availableFunctions
                        .map((e) => e.name)
                        .toList(),
                    onReceiveDartBlockNotification: (notification) {
                      _onReceiveDartBlockNotification(notification);
                    },
                    onSaved: (newName, newReturnType) {
                      _onCreateFunction(
                        DartBlockCustomFunction(newName, newReturnType, [], []),
                      );
                    },
                  );
                },
                label: const Text("New Function"),
                icon: const NewFunctionSymbol(),
              ),
            ),
          ],
        ),
    ];
  }

  void _showConsole(BuildContext context) {
    context.showProviderAwareBottomSheet(
      showDragHandle: true,
      isScrollControlled: true,
      clipBehavior: Clip.hardEdge,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
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
                  exception: executor.thrownException,
                  program: program,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showHelpCenter(BuildContext context) {
    context.showProviderAwareBottomSheet(
      showDragHandle: true,
      isScrollControlled: true,
      clipBehavior: Clip.hardEdge,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),

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
              child: const DartBlockHelpCenter(),
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
enum DartBlockViewOption {
  blocks("Editor"),
  script("Script");

  final String name;
  const DartBlockViewOption(this.name);
}

void showNewFunctionSheet(
  BuildContext context, {
  required List<String> existingFunctionNames,
  required Function(String newName, DartBlockDataType? newReturnType) onSaved,

  /// If the context is the same as the main DartBlockEditor's context, indicate
  /// this argument to handle incoming DartBlockNotifications.
  /// Otherwise, the notifications will be automatically propagated upwards.
  required Function(DartBlockNotification notification)?
  onReceiveDartBlockNotification,
}) {
  HapticFeedback.mediumImpact();

  showAdaptiveBottomSheetOrDialog(
    context,
    sheetPadding: EdgeInsets.all(8),
    dialogPadding: EdgeInsets.all(16),
    onReceiveDartBlockNotification: onReceiveDartBlockNotification,
    useProviderAwareModal: true,
    child: CustomFunctionBasicEditor(
      existingCustomFunctionNames: existingFunctionNames,
      canDelete: false,
      canChange: true,
      onDelete: () {},
      onSaved: (newName, newReturnType) {
        Navigator.of(context).pop();
        onSaved(newName, newReturnType);
      },
    ),
  );
}
