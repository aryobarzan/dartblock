import 'package:dartblock_code/widgets/dartblock_editor_providers.dart';
import 'package:flutter/material.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:dartblock_code/widgets/dartblock_value_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NeoValueTextWidget extends StatelessWidget {
  final DartBlockValue? neoValue;
  const NeoValueTextWidget({super.key, this.neoValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 25),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      height: 25,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: FittedBox(fit: BoxFit.scaleDown, child: Text(neoValue.toString())),
    );
  }
}

class VariableTextWidget extends ConsumerWidget {
  final DartBlockVariable variable;
  final BorderRadius? borderRadius;
  const VariableTextWidget({
    super.key,
    required this.variable,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Container(
      alignment: Alignment.center,
      height: 24,
      constraints: const BoxConstraints(minWidth: 24),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        color: settings.colorFamily.variable.color,
      ),
      child: Text(
        variable.name,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: settings.colorFamily.variable.onColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class PrintStatementWidget extends StatelessWidget {
  final PrintStatement statement;
  const PrintStatementWidget({super.key, required this.statement});

  @override
  Widget build(BuildContext context) {
    return DartBlockValueWidget(value: statement.value);
  }
}

class ReturnStatementWidget extends StatelessWidget {
  final ReturnStatement statement;
  const ReturnStatementWidget({super.key, required this.statement});

  @override
  Widget build(BuildContext context) {
    return Row(children: [DartBlockValueWidget(value: statement.value)]);
  }
}

class BreakStatementWidget extends StatelessWidget {
  final BreakStatement statement;
  const BreakStatementWidget({super.key, required this.statement});

  @override
  Widget build(BuildContext context) {
    return const Row(children: [ColoredTitleChip(title: "Exit current loop")]);
  }
}

class ContinueStatementWidget extends StatelessWidget {
  final ContinueStatement statement;
  const ContinueStatementWidget({super.key, required this.statement});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        ColoredTitleChip(title: "Stop current loop iteration and repeat"),
      ],
    );
  }
}
