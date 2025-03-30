import 'package:flutter/material.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0, left: 8.0),
              child: Image.asset(
                "assets/images/logo.png",
                height: 36,
              ),
            ),
            Text('Admin Dashboard'),
          ],
        ),
      ),
      body: _buildDbColumn(),
    );
  }

  Widget _buildDbColumn() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 18.0, bottom: 16.0),
            child: Text(
              "Base de données",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          _collectionCards(),
        ],
      ),
    );
  }

  _collectionCards() {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 4,
        runSpacing: 4,
        children: [
          _buildCard("Agents", Icons.person, () {}),
          _buildCard("Gares", Icons.train, () {}),
          _buildCard("Rapports", Icons.article, () {}),
          // add more cards as needed
        ],
      ),
    );
  }

  Widget _buildCard(String s, IconData iconData, Null Function() action) {
    return SizedBox(
      width: 170,
      height: 100,
      child: Card(
        child: InkWell(
          onTap: action,
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: Column(
                    children: [
                      Icon(
                        iconData,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          "666",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(
                          s,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
