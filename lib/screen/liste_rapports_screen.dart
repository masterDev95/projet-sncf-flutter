import 'package:flutter/material.dart';
import 'package:projet_sncf/screen/nouveau_rapports_screen.dart';

class ListeRapportsScreen extends StatefulWidget {
  const ListeRapportsScreen({super.key});

  final String title = 'Rapports';

  @override
  State<ListeRapportsScreen> createState() => _ListeRapportsScreenState();
}

class _ListeRapportsScreenState extends State<ListeRapportsScreen> {
  @override
  Widget build(BuildContext context) {
    var genericTile = InkWell(
      onTap: () {},
      child: const ListTile(
        leading: Icon(Icons.summarize),
        title: Text('Le Stade'),
        subtitle: Text('Dupont Jean'),
      ),
    );

    var randomDateHeaders = List<Widget>.generate(10, (index) {
      final date = DateTime.now().subtract(Duration(days: index));
      return Container(
        color: Theme.of(context).colorScheme.secondary,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '${date.day}/${date.month}/${date.year}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
      ),
      body: Card(
        margin: const EdgeInsets.all(12.0),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            10,
            (index) => index % 4 == 0 ? randomDateHeaders[index] : genericTile,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nouveau rapport',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NouveauRapportsScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
