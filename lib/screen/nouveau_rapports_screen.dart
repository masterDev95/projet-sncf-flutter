import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projet_sncf/container/page_indicator.dart';

enum TypeService {
  matinee,
  soiree,
}

enum Gare {
  argenteuil,
  leStade,
  colombes,
  boisColombes,
  sannois,
}

class NouveauRapportsScreen extends StatefulWidget {
  const NouveauRapportsScreen({super.key});

  @override
  State<NouveauRapportsScreen> createState() => _NouveauRapportsScreenState();
}

class _NouveauRapportsScreenState extends State<NouveauRapportsScreen>
    with TickerProviderStateMixin {
  DateTime? _selectedDate;
  TypeService _selectedTypeService = TypeService.matinee;
  Gare? _selectedGare;
  bool _samChecked = false;
  bool _agiteChecked = false;
  bool _digisiteChecked = false;
  String _commentaireVerifications = '';

  late PageController _pageViewController;
  late TabController _tabController;
  int _currentPageIndex = 0;
  final List<String> _tabTitles = const [
    'Informations générales',
    'Sélection gare',
    'Vérifications',
    'Réchargement et caisse',
  ];

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
  }

  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  Widget _infosGeneralesCard() {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      margin: const EdgeInsets.all(12.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Date'),
            subtitle: Text(
              _selectedDate == null
                  ? 'Sélectionner une date'
                  : DateFormat.yMMMMd("fr_FR").format(_selectedDate!),
            ),
            onTap: _pickDate,
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Agent'),
            subtitle: const Text('Eugène Lelouche'),
            onTap: () {},
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Renseigner un agent manuellement'),
                ),
              ),
            ],
          ),
          ListTile(
            leading: Icon(
              _selectedTypeService == TypeService.matinee
                  ? Icons.wb_sunny
                  : Icons.nightlight_round,
            ),
            title: const Text('Type de service'),
            subtitle: Text(
              _selectedTypeService == TypeService.matinee
                  ? 'Matinée'
                  : 'Soirée',
            ),
            onTap: () {
              setState(() {
                _selectedTypeService =
                    _selectedTypeService == TypeService.matinee
                        ? TypeService.soiree
                        : TypeService.matinee;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _verificationsCard() {
    TextEditingController commentaireController =
        TextEditingController(text: _commentaireVerifications);

    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      margin: const EdgeInsets.all(12.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('SAM'),
            subtitle: Text(_samChecked ? 'Oui' : 'Non'),
            trailing: Checkbox(
                value: _samChecked,
                onChanged: (value) {
                  setState(() {
                    _samChecked = value!;
                  });
                }),
            onTap: () {
              setState(() {
                _samChecked = !_samChecked;
              });
            },
          ),
          ListTile(
            title: const Text('l\'AGITE effectué ?'),
            subtitle: Text(_agiteChecked ? 'Oui' : 'Non'),
            trailing: Checkbox(
                value: _agiteChecked,
                onChanged: (value) {
                  setState(() {
                    _agiteChecked = value!;
                  });
                }),
            onTap: () {
              setState(() {
                _agiteChecked = !_agiteChecked;
              });
            },
          ),
          ListTile(
            title: const Text('DIGISITE est à jour ?'),
            subtitle: Text(_digisiteChecked ? 'Oui' : 'Non'),
            trailing: Checkbox(
                value: _digisiteChecked,
                onChanged: (value) {
                  setState(() {
                    _digisiteChecked = value!;
                  });
                }),
            onTap: () {
              setState(() {
                _digisiteChecked = !_digisiteChecked;
              });
            },
          ),
          ListTile(
            title: const Text('CAB'),
            subtitle: const Text('KO'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Commentaires'),
            subtitle: Text(_commentaireVerifications),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Commentaires'),
                    content: TextField(
                      controller: commentaireController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          commentaireController.text =
                              _commentaireVerifications;
                        },
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _commentaireVerifications =
                                commentaireController.text;
                          });
                        },
                        child: const Text('Valider'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _selectionGareRadioListTile(Gare gare) {
    return RadioListTile<Gare>(
      value: gare,
      groupValue: _selectedGare,
      title: Text(_gareToString(gare)),
      onChanged: (Gare? value) {
        setState(() {
          _selectedGare = value;
        });
      },
    );
  }

  Widget _garesCards(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      margin: const EdgeInsets.all(12.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Gare'),
          ),
          _selectionGareRadioListTile(Gare.argenteuil),
          _selectionGareRadioListTile(Gare.leStade),
          _selectionGareRadioListTile(Gare.colombes),
          _selectionGareRadioListTile(Gare.boisColombes),
          _selectionGareRadioListTile(Gare.sannois),
        ],
      ),
    );
  }

  Widget _artCard(String numeroArt) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      margin: const EdgeInsets.all(12.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              'ART $numeroArt',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            title: const Text('Rechargement'),
            subtitle: const Text('5cts'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Nombre de pièces de 5 centimes'),
            subtitle: const Text('0'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Doit prévoir de la monnaie'),
            subtitle: const Text('Non'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Changement de bobineaux'),
            subtitle: const Text('Non'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Doit prévoir des bobineaux'),
            subtitle: const Text('Non'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Retrait de caisse effectué'),
            subtitle: const Text('Non'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Commentaire'),
            subtitle: const Text(''),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  String _gareToString(Gare gare) {
    return gare
        .toString()
        .split('.')
        .last
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) {
      return '${match.group(1)} ${match.group(2)}';
    }).capitalize();
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Nouveau Rapport'),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
            child: PageIndicator(
              tabController: _tabController,
              currentPageIndex: _currentPageIndex,
              onUpdateCurrentPageIndex: _updateCurrentPageIndex,
              tabCount: _tabTitles.length,
              tabTitles: _tabTitles,
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageViewController,
              onPageChanged: _handlePageViewChanged,
              children: List.generate(
                _tabTitles.length,
                (index) {
                  switch (index) {
                    case 0:
                      return Column(
                        children: [
                          _infosGeneralesCard(),
                        ],
                      );
                    case 1:
                      return Column(
                        children: [
                          _garesCards(context),
                        ],
                      );
                    case 2:
                      return Column(
                        children: [
                          _verificationsCard(),
                        ],
                      );
                    case 3:
                      return Column(
                        children: [
                          _artCard('001'),
                        ],
                      );
                    default:
                      return Center(child: Text('Page $index'));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
