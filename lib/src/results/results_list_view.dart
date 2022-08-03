import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import '../settings/settings_view.dart';

/// Displays a list of SampleItems.
class ResultsListView extends StatelessWidget {
  const ResultsListView({Key? key}) : super(key: key);

  static const routeName = '/results';
  static const targetValue = 30000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rangliste'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),

      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: ValueListenableBuilder(
          valueListenable: Hive.box("guessess").listenable(),
          builder: (context, Box box, _) {
            if (box.values.isEmpty) {
              return const Center(
                child: Text("Noch keine Schätzungen"),
              );
            }
            var items = box.toMap().entries.toList();
            items.sort((a, b) => (int.parse(a.value.toString()) - targetValue)
                .abs()
                .compareTo(
                    (targetValue - int.parse(b.value.toString())).abs()));
            return ListView.builder(
              // Providing a restorationId allows the ListView to restore the
              // scroll position when a user leaves and returns to the app after it
              // has been killed while running in the background.
              restorationId: 'sampleItemListView',
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                final value = items[index].value;
                final key = items[index].key;
                final diff = (int.parse(value) - targetValue).abs();
                return ListTile(
                  title: Text(key),
                  subtitle: Text('$value - Diff: $diff'),
                  leading: CircleAvatar(
                    // Display the Flutter Logo image asset.
                    child: Text((index + 1).toString()),
                    backgroundColor: Colors.black,
                  ),
                );
              },
            );
          }),
    );
  }
}
