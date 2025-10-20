import 'package:flutter/material.dart';
import 'package:dartblock_code/models/dartblock_interaction.dart';
import 'package:dartblock_code/models/help.dart';

class NeoTechHelpCenter extends StatefulWidget {
  const NeoTechHelpCenter({super.key});

  @override
  State<NeoTechHelpCenter> createState() => _NeoTechHelpCenterState();
}

class _NeoTechHelpCenterState extends State<NeoTechHelpCenter> {
  DartBlockHelpItem? selectedHelpItem;
  @override
  Widget build(BuildContext context) {
    return selectedHelpItem != null
        ? _buildHelpItem()
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.help_outline),
                    const SizedBox(width: 4),
                    Text("Help", style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),
              const Divider(),
              ...DartBlockHelpItem.getHelpItems().map(
                (e) => ListTile(
                  title: Text(e.title),
                  subtitle: Text(e.shortDescription),
                  onTap: () {
                    DartBlockInteraction.create(
                      dartBlockInteractionType:
                          DartBlockInteractionType.viewHelpCenterItem,
                      content: "Title-${e.title}",
                    ).dispatch(context);
                    setState(() {
                      selectedHelpItem = e;
                    });
                  },
                ),
              ),
            ],
          );
  }

  Widget _buildHelpItem() {
    if (selectedHelpItem == null) {
      return const SizedBox();
    } else {
      DartBlockHelpItem item = selectedHelpItem!;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    selectedHelpItem = null;
                  });
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text("Help"),
              ),
            ],
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              item.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: item.build(context),
          ),
        ],
      );
    }
  }
}
