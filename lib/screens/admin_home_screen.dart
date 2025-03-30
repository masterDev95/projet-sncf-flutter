import 'package:flutter/material.dart';
import 'package:projet_sncf/services/database_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final Map<Collection, int> _counts = {
    Collection.agents: 0,
    Collection.gares: 0,
    Collection.rapports: 0,
  };

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCounts();
  }

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
            padding: const EdgeInsets.only(left: 18.0, bottom: 40.0),
            child: Text(
              "Base de données",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          _collectionCards(),
        ],
      ),
    );
  }

  Widget _collectionCards() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCard(Collection.agents, Icons.person, () {}),
          _buildCard(Collection.gares, Icons.train, () {}),
          _buildCard(Collection.rapports, Icons.article, () {}),
        ],
      ),
    );
  }

  Widget _buildCard(Collection c, IconData iconData, Null Function() action) {
    return SizedBox(
      width: 250,
      height: 100,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: action,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                flex: 8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      iconData,
                      size: 40,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _getCountWidget(c),
                    Text(
                      c.name,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getCounts() async {
    for (var c in _counts.keys) {
      final count = await DatabaseService().getCountByCollection(c);
      _counts[c] = count;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _getCountWidget(Collection c) {
    if (_isLoading) {
      return const CircularProgressIndicator();
    } else {
      return Text(
        _counts[c].toString(),
        style: Theme.of(context).textTheme.headlineLarge,
      );
    }
  }
}
