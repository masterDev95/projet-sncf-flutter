import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projet_sncf/container/download_progress_dialog.dart';
import 'package:projet_sncf/extensions/color_extension.dart';
import 'package:projet_sncf/main.dart';
import 'package:projet_sncf/models/agent.dart';
import 'package:projet_sncf/models/gare.dart';
import 'package:projet_sncf/models/rapport.dart';
import 'package:projet_sncf/screens/edit_rapports_screen.dart';
import 'package:projet_sncf/services/database_service.dart';
import 'package:projet_sncf/utils/app_colors.dart';

class ListeRapportsScreen extends StatefulWidget {
  const ListeRapportsScreen({super.key});

  final String title = 'Rapports';

  @override
  State<ListeRapportsScreen> createState() => _ListeRapportsScreenState();
}

class _ListeRapportsScreenState extends State<ListeRapportsScreen>
    with RouteAware {
  List<Rapport> _listeRapports = [];
  List<Agent> _listeAgents = [];
  List<Gare> _listeGares = [];
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = false;
  bool _updateDialogShown = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _fetchData();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _fetchData() async {
    _isLoading = true;
    await Future.wait([
      _fetchAgents(),
      _fetchRapports(),
      _fetchGares(),
    ]);
    setState(() {
      _isLoading = false;
    });
  }

  void showUpdateDialog(BuildContext context, String newVersion) {
    showDialog(
      context: context,
      barrierDismissible: false, // prevents closing dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mise à jour disponible'),
          content: const Text(
            'Une mise à jour est disponible. Voulez-vous la télécharger ?',
          ),
          actions: [
            if (kDebugMode)
              TextButton(
                child: const Text("Up test version on db"),
                onPressed: () {
                  updateTestVersion();
                  Navigator.pop(context);
                },
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Plus tard'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogContext) {
                    return FutureBuilder<String>(
                      future: getApkDownloadUrl(newVersion),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return AlertDialog(
                            title: const Text('Préparation du téléchargement'),
                            content: const SizedBox(
                              height: 50,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return AlertDialog(
                            title: const Text('Erreur de téléchargement'),
                            content: Text(snapshot.error.toString()),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        } else {
                          final url = snapshot.data!;
                          return DownloadProgressDialog(url: url);
                        }
                      },
                    );
                  },
                );
              },
              child: const Text('Télécharger'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String actualVersion = packageInfo.version;
    String newVersion = appVersionOnFirebase;
    bool isUpdateAvailable = actualVersion != newVersion;

    if (isUpdateAvailable && !_updateDialogShown) {
      _updateDialogShown = true; // Empêche le dialog de se réafficher
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showUpdateDialog(context, newVersion);
      });
    }

    // 1️⃣ Regrouper les rapports par date
    Map<String, List<Rapport>> groupedRapports = {};

    for (var rapport in _listeRapports) {
      String formattedDate = DateFormat.yMMMMd('fr_FR').format(rapport.date!);
      if (!groupedRapports.containsKey(formattedDate)) {
        groupedRapports[formattedDate] = [];
      }
      groupedRapports[formattedDate]!.add(rapport);
    }

    // 2️⃣ Trier les dates en ordre décroissant
    List<String> sortedDates = groupedRapports.keys.toList()
      ..sort((a, b) => DateFormat.yMMMMd('fr_FR')
          .parse(b)
          .compareTo(DateFormat.yMMMMd('fr_FR').parse(a)));

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
            Text(widget.title),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                color: AppColors.cardColor.darken(15),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                      _buildColumnListe(sortedDates, context, groupedRapports),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nouveau rapport',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditRapportScreen(
                rapportDeBase: Rapport(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Column _buildColumnListe(List<String> sortedDates, BuildContext context,
      Map<String, List<Rapport>> groupedRapports) {
    return sortedDates.isEmpty
        ? Column(
            children: [
              ListTile(
                title: const Text(
                  'Aucun rapport trouvé',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          )
        : Column(
            children: sortedDates.map((date) {
              return Card(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                child: ExpansionTile(
                  title: Text(
                    date, // 📅 Date comme titre principal
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  children: groupedRapports[date]!.map((rapport) {
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditRapportScreen(
                              rapportDeBase: rapport,
                            ),
                          ),
                        );
                      },
                      tileColor: AppColors.secondary,
                      leading: const Icon(Icons.article),
                      title: Text(_displayGare(rapport)),
                      subtitle: Text("Agents: ${_displayAgents(rapport)}"),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          );
  }

  String _displayAgents(Rapport r) {
    List<Agent> agentsManuels = r.agentsManuellementAjoutes;
    int totalAgentsCount = r.agents.length + agentsManuels.length;

    if (totalAgentsCount > 3) {
      return '$totalAgentsCount agents';
    }

    String agents = '';
    for (var i = 0; i < r.agents.length; i++) {
      var agent = _listeAgents.firstWhere((a) => a.id == r.agents[i]);
      agents += "${agent.prenom} ${agent.nom}";
      if (i < r.agents.length - 1 || agentsManuels.isNotEmpty) {
        agents += ', ';
      }
    }

    for (var i = 0; i < agentsManuels.length; i++) {
      agents += "${agentsManuels[i].prenom} ${agentsManuels[i].nom}";
      if (i < agentsManuels.length - 1) {
        agents += ', ';
      }
    }

    return agents;
  }

  Future<void> _fetchRapports() async {
    _listeRapports = await _dbService.getRapports();
  }

  Future<void> _fetchAgents() async {
    _listeAgents = await _dbService.getAgents();
  }

  Future<void> _fetchGares() async {
    _listeGares = await _dbService.getGares();
  }

  String _displayGare(Rapport rapport) {
    if (rapport.gareId.isEmpty) return '';
    var gare = _listeGares.firstWhere((g) => g.id == rapport.gareId);
    return gare.nom;
  }
}
