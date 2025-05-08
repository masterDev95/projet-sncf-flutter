import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projet_sncf/container/download_progress_dialog.dart';
import 'package:projet_sncf/container/logo_rsa.dart';
import 'package:projet_sncf/enums/type_service.dart';
import 'package:projet_sncf/extensions/color_extension.dart';
import 'package:projet_sncf/extensions/string_extension.dart';
import 'package:projet_sncf/main.dart';
import 'package:projet_sncf/models/agent.dart';
import 'package:projet_sncf/models/gare.dart';
import 'package:projet_sncf/models/gare_section_data.dart';
import 'package:projet_sncf/models/rapport.dart';
import 'package:projet_sncf/pdf/pdf_generator.dart';
import 'package:projet_sncf/pdf/pdf_helper.dart';
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
  final DatabaseService _dbService = DatabaseService();
  late final Stream<QuerySnapshot> _rapportsStream;

  List<Agent> _listeAgents = [];
  List<Gare> _listeGares = [];
  bool _isLoading = false;
  bool _updateDialogShown = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _rapportsStream = _dbService.streamCollection(Collection.rapports);
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

    // Si les autres données (agents, gares) ne sont pas encore chargées, on affiche un loader
    if (_isLoading) {
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
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Une fois les autres données chargées, on utilise le StreamBuilder pour les rapports
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            LogoRSA(),
            Text(widget.title),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _rapportsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }

          // Convertir les documents en objets Rapport.
          List<Rapport> rapports = snapshot.data!.docs
              .map((doc) => Rapport.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>))
              .toList();

          // Regrouper les rapports par date
          Map<String, List<Rapport>> groupedRapports = {};
          for (var rapport in rapports) {
            String formattedDate =
                DateFormat.yMMMMd('fr_FR').format(rapport.date!);
            if (!groupedRapports.containsKey(formattedDate)) {
              groupedRapports[formattedDate] = [];
            }
            groupedRapports[formattedDate]!.add(rapport);
          }

          // Trier les dates en ordre décroissant
          List<String> sortedDates = groupedRapports.keys.toList()
            ..sort((a, b) => DateFormat.yMMMMd('fr_FR')
                .parse(b)
                .compareTo(DateFormat.yMMMMd('fr_FR').parse(a)));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              color: AppColors.cardColor.darken(15),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildColumnListe(sortedDates, context, groupedRapports),
              ),
            ),
          );
        },
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
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () {
                      showPdfDialog(
                        context,
                        listRapports: groupedRapports[date]!,
                        date: date,
                      );
                    },
                  ),
                  key: PageStorageKey(date),
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

  void showPdfDialog(BuildContext context,
      {required List<Rapport> listRapports, required String date}) {
    TypeService typeService = TypeService.matinee;

    List<Rapport> filteredRapports = listRapports
        .where((rapport) => rapport.typeService == typeService)
        .toList();

    const WidgetStateProperty<Icon> thumbIcon =
        WidgetStateProperty<Icon>.fromMap({
      WidgetState.selected: Icon(
        Icons.sunny,
        color: Color(0xFFedda39),
      ),
      WidgetState.any: Icon(
        Icons.nights_stay,
        color: Color(0xFFfaf5cf),
      ),
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Préparation du PDF'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Veillez choisir la période des rapports'),
                SizedBox(height: 10),
                SwitchListTile(
                  activeColor: Color(0xFF45a8ef),
                  inactiveThumbColor: Color(0xFF103453),
                  thumbIcon: thumbIcon,
                  title: Text(typeService == TypeService.matinee
                      ? 'Matinée'
                      : 'Soirée'),
                  value: typeService == TypeService.matinee,
                  onChanged: (value) {
                    setState(() {
                      typeService =
                          value ? TypeService.matinee : TypeService.soiree;
                      filteredRapports = listRapports
                          .where(
                              (rapport) => rapport.typeService == typeService)
                          .toList();
                    });
                  },
                ),
                if (filteredRapports.isEmpty)
                  const Text(
                    'Aucun rapport trouvé pour cette période',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: filteredRapports.isEmpty
                    ? null
                    : () async {
                        await downloadRapportPdf(
                            filteredRapports, date, typeService);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                child: const Text('Télécharger'),
              ),
            ],
          ),
        );
      },
    );
  }

  downloadRapportPdf(
      List<Rapport> listRapports, String date, TypeService typeService) async {
    final helper = PdfHelper(date, typeService);
    await helper.init();

    for (var i = 0; i < listRapports.length; i++) {
      final rapport = listRapports[i];
      helper.addSection(
        GareSectionData(
          gare: _displayGare(rapport),
          personnes: _displayAgents(rapport),
          sam: rapport.samChecked,
          agite: rapport.agiteChecked,
          cab: rapport.cab.name.splitCamelCase().capitalize(),
          commentaireVerif: rapport.commentaireVerif,
          commentaireFinal: rapport.commentaireFinal,
          artList: rapport.arts,
        ),
      );

      if (i < listRapports.length - 1) {
        helper.addPageBreak();
      }
    }

    final pdf = helper.build();
    generatePdf(pdf);
  }
}
