import 'package:flutter/material.dart';
import 'package:dartblock_code/models/dartblock_value.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:dartblock_code/widgets/helper_widgets.dart';
import 'package:dartblock_code/widgets/dartblock_value_widgets.dart';
import 'package:dartblock_code/widgets/views/other/dartblock_colors.dart';
import 'package:dartblock_code/widgets/views/symbols.dart';

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

class VariableTextWidget extends StatelessWidget {
  final DartBlockVariable variable;
  final BorderRadius? borderRadius;
  const VariableTextWidget({
    super.key,
    required this.variable,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 24,
      constraints: const BoxConstraints(minWidth: 24),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        color: DartBlockColors.variable,
      ),
      child: Text(
        variable.name,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
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
    return Row(
      children: [
        const NeoTechReturnSymbol(),
        const SizedBox(width: 4),
        DartBlockValueWidget(value: statement.value),
      ],
    );
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
