import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projet_sncf/container/page_indicator.dart';
import 'package:projet_sncf/enums/cab.dart';
import 'package:projet_sncf/enums/rechargement.dart';
import 'package:projet_sncf/enums/type_service.dart';
import 'package:projet_sncf/extensions/color_extension.dart';
import 'package:projet_sncf/extensions/string_extension.dart';
import 'package:projet_sncf/models/art.dart';
import 'package:projet_sncf/models/gare.dart';
import 'package:projet_sncf/models/rapport.dart';
import 'package:projet_sncf/services/database_service.dart';
import 'package:projet_sncf/utils/app_colors.dart';

import '../models/agent.dart';

enum FormElementToValidate {
  date,
  agents,
  gare,
}

class EditRapportScreen extends StatefulWidget {
  final Rapport rapportDeBase;

  const EditRapportScreen({required this.rapportDeBase, super.key});

  @override
  State<EditRapportScreen> createState() => _EditRapportScreenState();
}

class _EditRapportScreenState extends State<EditRapportScreen>
    with TickerProviderStateMixin {
  final _dbService = DatabaseService();

  List<Gare> _listeGares = [];
  List<Agent> _listeAgents = [];

  bool _isLoading = true;
  bool _isSaving = false;

  bool _isFormValid = false;
  bool _showError = false;

  final Map<FormElementToValidate, bool> _formElementsValidation = {
    FormElementToValidate.date: false,
    FormElementToValidate.agents: false,
    FormElementToValidate.gare: false,
  };

  final Map<int, String> _rechargementsEnumToString = {
    0: '5cts',
    1: '10cts',
    2: '20cts',
    3: '50cts',
    4: '1€',
    5: '2€',
  };

  // Utilisé pour la sélection "temporaire"
  late List<String> _checkboxAgents;
  late Agent _agentManuellementAjouteTemp;
  late Cab _cabSelectionne;

  late PageController _pageViewController;
  late Rapport _rapport;
  late TabController _tabController;
  int _currentPageIndex = 0;
  final List<String> _tabTitles = const [
    'Informations générales',
    'Sélection gare',
    'Vérifications',
    'Rechargement et caisse',
  ];

  @override
  void initState() {
    super.initState();

    _fetchData();

    setState(() {
      _fetchGares();
      _fetchAgents();
    });

    _pageViewController = PageController();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
    _rapport = widget.rapportDeBase;
    _checkboxAgents = List.from(_rapport.agents);
    _cabSelectionne = _rapport.cab;
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

  String _displayAgents() {
    int totalAgentsCount = _rapport.agents.length;

    if (totalAgentsCount == 0) {
      return 'Sélectionner un agent';
    }

    if (totalAgentsCount > 3) {
      return '$totalAgentsCount agents';
    }

    return _rapport.agents.map((agentId) {
      Agent agent = _listeAgents.firstWhere((agent) => agent.id == agentId);
      return '${agent.prenom} ${agent.nom}';
    }).join(', ');
  }

  void _agentCheckboxToggle(String agentId, bool check) {
    if (check) {
      _checkboxAgents.add(agentId);
    } else {
      _checkboxAgents.remove(agentId);
    }
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
              _rapport.date == null
                  ? 'Sélectionner une date'
                  : DateFormat.yMMMMd("fr_FR").format(_rapport.date!),
            ),
            subtitleTextStyle: TextStyle(
              color: _showError && _rapport.date == null
                  ? AppColors.error
                  : Colors.white,
            ),
            onTap: _pickDate,
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Agent'),
            subtitle: Text(_displayAgents()),
            subtitleTextStyle: TextStyle(
                color: _showError &&
                        _rapport.agents.isEmpty &&
                        _rapport.agentsManuellementAjoutes.isEmpty
                    ? AppColors.error
                    : Colors.white),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Sélectionner un agent'),
                    content: StatefulBuilder(
                      builder: (context, setState) => SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            _listeAgents.length,
                            (index) {
                              return ListTile(
                                title: Text(
                                  '${_listeAgents[index].prenom} ${_listeAgents[index].nom}',
                                ),
                                trailing: Checkbox(
                                  value: _checkboxAgents
                                      .contains(_listeAgents[index].id),
                                  onChanged: (value) {
                                    setState(() {
                                      _agentCheckboxToggle(
                                          _listeAgents[index].id!, value!);
                                    });
                                  },
                                ),
                                onTap: () {
                                  setState(() {
                                    _agentCheckboxToggle(
                                      _listeAgents[index].id!,
                                      !_checkboxAgents
                                          .contains(_listeAgents[index].id),
                                    );
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _checkboxAgents = List.from(_rapport.agents);
                        },
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _rapport.agents = List.from(_checkboxAgents);
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
          ...List.generate(
            _rapport.agentsManuellementAjoutes.length,
            (index) {
              Agent agent = _rapport.agentsManuellementAjoutes[index];
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                title: Text('${agent.prenom} ${agent.nom}',
                    style: Theme.of(context).textTheme.labelLarge),
                trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      _rapport.agentsManuellementAjoutes.remove(agent);
                    });
                  },
                  icon: const Icon(Icons.delete),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      _agentManuellementAjouteTemp = agent;

                      return AlertDialog(
                        title: const Text('Agent'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Prénom',
                                ),
                                controller:
                                    TextEditingController(text: agent.prenom),
                                onChanged: (value) {
                                  _agentManuellementAjouteTemp.prenom = value;
                                },
                              ),
                            ),
                            ListTile(
                              title: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Nom',
                                ),
                                controller:
                                    TextEditingController(text: agent.nom),
                                onChanged: (value) {
                                  _agentManuellementAjouteTemp.nom = value;
                                },
                              ),
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
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {
                                agent = _agentManuellementAjouteTemp;
                              });
                            },
                            child: const Text('Valider'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: _showError &&
                            _rapport.agents.isEmpty &&
                            _rapport.agentsManuellementAjoutes.isEmpty
                        ? AppColors.error
                        : Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: onRenseignerAgentManuellementButtonClick,
                  icon: const Icon(Icons.add),
                  label: const Text('Renseigner un agent manuellement'),
                ),
              ),
            ],
          ),
          ListTile(
            leading: Icon(
              _rapport.typeService == TypeService.matinee
                  ? Icons.wb_sunny
                  : Icons.nightlight_round,
            ),
            title: const Text('Type de service'),
            subtitle: Text(
              _rapport.typeService == TypeService.matinee
                  ? 'Matinée'
                  : 'Soirée',
            ),
            onTap: () {
              setState(() {
                _rapport.typeService =
                    _rapport.typeService == TypeService.matinee
                        ? TypeService.soiree
                        : TypeService.matinee;
              });
            },
          ),
        ],
      ),
    );
  }

  void onRenseignerAgentManuellementButtonClick() {
    showDialog(
      context: context,
      builder: (context) {
        var prenomIsEmpty = false;
        var nomIsEmpty = false;

        _agentManuellementAjouteTemp = Agent();

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Agent'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: TextField(
                    decoration: InputDecoration(
                      labelText: 'Prénom',
                      errorText:
                          prenomIsEmpty ? 'Ce champ est obligatoire' : null,
                    ),
                    onChanged: (value) {
                      setState(() => prenomIsEmpty = value.isEmpty);
                      _agentManuellementAjouteTemp.prenom = value;
                    },
                  ),
                ),
                ListTile(
                  title: TextField(
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      errorText: nomIsEmpty ? 'Ce champ est obligatoire' : null,
                    ),
                    onChanged: (value) {
                      setState(() => nomIsEmpty = value.isEmpty);
                      _agentManuellementAjouteTemp.nom = value;
                    },
                  ),
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
                onPressed: () {
                  if (_agentManuellementAjouteTemp.prenom.isEmpty ||
                      _agentManuellementAjouteTemp.nom.isEmpty) {
                    setState(() {
                      prenomIsEmpty =
                          _agentManuellementAjouteTemp.prenom.isEmpty;
                      nomIsEmpty = _agentManuellementAjouteTemp.nom.isEmpty;
                    });
                    return;
                  }

                  Navigator.of(context).pop();
                  setState(() {
                    _rapport.agentsManuellementAjoutes
                        .add(_agentManuellementAjouteTemp);
                  });
                },
                child: const Text('Valider'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _verificationsCard() {
    TextEditingController commentaireController =
        TextEditingController(text: _rapport.commentaireVerif);

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
            subtitle: Text(_rapport.samChecked ? 'Oui' : 'Non'),
            trailing: Checkbox(
                value: _rapport.samChecked,
                onChanged: (value) {
                  setState(() {
                    _rapport.samChecked = value!;
                  });
                }),
            onTap: () {
              setState(() {
                _rapport.samChecked = !_rapport.samChecked;
              });
            },
          ),
          ListTile(
            title: const Text('l\'AGITE effectué ?'),
            subtitle: Text(_rapport.agiteChecked ? 'Oui' : 'Non'),
            trailing: Checkbox(
                value: _rapport.agiteChecked,
                onChanged: (value) {
                  setState(() {
                    _rapport.agiteChecked = value!;
                  });
                }),
            onTap: () {
              setState(() {
                _rapport.agiteChecked = !_rapport.agiteChecked;
              });
            },
          ),
          ListTile(
            title: const Text('DIGISITE est à jour ?'),
            subtitle: Text(_rapport.digisiteChecked ? 'Oui' : 'Non'),
            trailing: Checkbox(
                value: _rapport.digisiteChecked,
                onChanged: (value) {
                  setState(() {
                    _rapport.digisiteChecked = value!;
                  });
                }),
            onTap: () {
              setState(() {
                _rapport.digisiteChecked = !_rapport.digisiteChecked;
              });
            },
          ),
          ListTile(
            title: const Text('CAB'),
            subtitle: Text(
              _rapport.cab.toString().split('.').last.stylizeCab(),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('CAB'),
                    content: StatefulBuilder(
                      builder: (context, setState) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...Cab.values.map(
                            (cab) => RadioListTile<Cab>(
                              value: cab,
                              groupValue: _cabSelectionne,
                              title: Text(
                                  cab.toString().split('.').last.stylizeCab()),
                              onChanged: (Cab? value) {
                                setState(() {
                                  _cabSelectionne = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _cabSelectionne = _rapport.cab;
                        },
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _rapport.cab = _cabSelectionne;
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
          ListTile(
            title: const Text('Commentaire'),
            subtitleTextStyle: TextStyle(
              color: _rapport.commentaireVerif.isEmpty
                  ? AppColors.error
                  : Colors.white,
            ),
            subtitle: Text(
              _rapport.commentaireVerif.isEmpty
                  ? 'Vide'
                  : _rapport.commentaireVerif,
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Commentaire'),
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
                              _rapport.commentaireVerif;
                        },
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _rapport.commentaireVerif =
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
      groupValue: _getGareById(_rapport.gareId),
      title: Text(_gareToString(gare)),
      selected: _rapport.gareId == gare.id,
      onChanged: onGareRadioChanged,
    );
  }

  void onGareRadioChanged(Gare? value) {
    setState(() {
      _rapport.gareId = value!.id!;
      _rapport.arts.clear();

      var gareById = _getGareById(_rapport.gareId);
      for (var idArt in gareById.arts) {
        _rapport.arts.add(Art(nom: idArt));
      }
    });
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
            subtitle: _showError && _rapport.gareId.isEmpty
                ? Text('Veuillez sélectionner une gare')
                : null,
            subtitleTextStyle: TextStyle(color: AppColors.error),
          ),
          ..._listeGares.map((gare) => _selectionGareRadioListTile(gare)),
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
    if (pickedDate != null && pickedDate != _rapport.date) {
      setState(() {
        _rapport.date = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          floatingActionButton: FloatingActionButton(
            tooltip: 'Enregistrer',
            onPressed: () => onSaveClick(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isSaving
                  ? CircularProgressIndicator(
                      color: AppColors.secondaryColorButLight)
                  : const Icon(Icons.save),
            ),
          ),
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
                Text(_displayTitreRapport()),
              ],
            ),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 24.0),
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
                          return _isLoading
                              ? Center(child: CircularProgressIndicator())
                              : SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      if (index == 0) _infosGeneralesCard(),
                                      if (index == 1) _garesCards(context),
                                      if (index == 2) _verificationsCard(),
                                      if (index == 3) _artColumn(context),
                                    ],
                                  ),
                                );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              if (_isSaving)
                ModalBarrier(
                  dismissible: false,
                  color: Colors.black54,
                )
            ],
          ),
        ),
      ],
    );
  }

  Future<void> onSaveClick() async {
    // Catch all gareIds
    var gareIds = _listeGares.map((gare) => gare.id).toList();

    for (var element in FormElementToValidate.values) {
      switch (element) {
        case FormElementToValidate.date:
          _formElementsValidation[element] = _rapport.date != null;
          break;
        case FormElementToValidate.agents:
          _formElementsValidation[element] = _rapport.agents.isNotEmpty ||
              _rapport.agentsManuellementAjoutes.isNotEmpty;
          break;
        case FormElementToValidate.gare:
          _formElementsValidation[element] = gareIds.contains(_rapport.gareId);
          break;
      }
    }

    _isFormValid = _formElementsValidation.values.every((element) => element);

    if (_isFormValid) {
      await _saveRapport();
    } else {
      setState(() => _showError = true);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erreur'),
            content:
                const Text('Veuillez remplir tous les champs obligatoires'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  _saveRapport() async {
    _isSaving = true;
    bool updated = _rapport.id != null;

    _rapport.id = await _dbService.saveRapport(_rapport);

    setState(() {
      _isSaving = false;
      _displaySavedSnackBar(updated);
    });
  }

  Column _artColumn(BuildContext context) {
    var gareById = _getGareById(_rapport.gareId);
    return Column(
      children: [
        if (gareById.arts.isEmpty)
          _artCardIfGareNotSelected(context)
        else
          _artCardIfGareSelected(context)
      ],
    );
  }

  Column _artCardIfGareSelected(BuildContext context) {
    var gareById = _getGareById(_rapport.gareId);
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(12.0),
          color: AppColors.cardColor.darken(15),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ...List.generate(gareById.arts.length, (index) {
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: ExpansionTile(
                      title: Text(
                        'ART ${gareById.arts[index]}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      children: [
                        ListTile(
                          tileColor: AppColors.secondary,
                          title: const Text('Rechargement'),
                          subtitle: Text(
                            _displayRechargement(gareById.arts[index]),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return buildAlertDialogRechargement(
                                    index, context);
                              },
                            );
                          },
                        ),
                        ListTile(
                          tileColor: AppColors.secondary,
                          title: const Text('Nombre de pièces de 5 centimes'),
                          subtitle: Text(
                            _rapport.arts[index].nombrePiecesDeCinqCentimes
                                .toString(),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return _buildAlertDialogCinqCts(index, context);
                              },
                            );
                          },
                        ),
                        ListTile(
                          tileColor: AppColors.secondary,
                          title: const Text('Doit prévoir de la monnaie'),
                          subtitle: Text(_rapport.arts[index].doitPrevoirMonnaie
                              ? "Oui"
                              : "Non"),
                          trailing: Checkbox(
                            value: _rapport.arts[index].doitPrevoirMonnaie,
                            onChanged: (value) {
                              setState(() {
                                _rapport.arts[index].doitPrevoirMonnaie =
                                    value!;
                              });
                            },
                          ),
                          onTap: () {
                            setState(() {
                              _rapport.arts[index].doitPrevoirMonnaie =
                                  !_rapport.arts[index].doitPrevoirMonnaie;
                            });
                          },
                        ),
                        ListTile(
                          tileColor: AppColors.secondary,
                          title: const Text('Changement de bobineaux'),
                          subtitle: Text(
                              _rapport.arts[index].changementDeBobineaux
                                  ? "Oui"
                                  : "Non"),
                          trailing: Checkbox(
                            value: _rapport.arts[index].changementDeBobineaux,
                            onChanged: (value) {
                              setState(() {
                                _rapport.arts[index].changementDeBobineaux =
                                    value!;
                              });
                            },
                          ),
                          onTap: () {
                            setState(() {
                              _rapport.arts[index].changementDeBobineaux =
                                  !_rapport.arts[index].changementDeBobineaux;
                            });
                          },
                        ),
                        ListTile(
                          tileColor: AppColors.secondary,
                          title: const Text('Doit prévoir des bobineaux'),
                          subtitle: Text(
                              _rapport.arts[index].doitPrevoirBobineaux
                                  ? "Oui"
                                  : "Non"),
                          trailing: Checkbox(
                            value: _rapport.arts[index].doitPrevoirBobineaux,
                            onChanged: (value) {
                              setState(() {
                                _rapport.arts[index].doitPrevoirBobineaux =
                                    value!;
                              });
                            },
                          ),
                          onTap: () {
                            setState(() {
                              _rapport.arts[index].doitPrevoirBobineaux =
                                  !_rapport.arts[index].doitPrevoirBobineaux;
                            });
                          },
                        ),
                        ListTile(
                          tileColor: AppColors.secondary,
                          title: const Text('Retrait de caisse effectué'),
                          subtitle: Text(
                              _rapport.arts[index].isRetraitCaisseEffectue
                                  ? "Oui"
                                  : "Non"),
                          trailing: Checkbox(
                            value: _rapport.arts[index].isRetraitCaisseEffectue,
                            onChanged: (value) {
                              setState(() {
                                _rapport.arts[index].isRetraitCaisseEffectue =
                                    value!;
                              });
                            },
                          ),
                          onTap: () {
                            setState(() {
                              _rapport.arts[index].isRetraitCaisseEffectue =
                                  !_rapport.arts[index].isRetraitCaisseEffectue;
                            });
                          },
                        ),
                        ListTile(
                            tileColor: AppColors.secondary,
                            title: const Text('Commentaire'),
                            subtitleTextStyle: TextStyle(
                              color: _rapport.arts[index].commentaire.isEmpty
                                  ? AppColors.error
                                  : Colors.white,
                            ),
                            subtitle: Text(
                              _rapport.arts[index].commentaire.isEmpty
                                  ? 'Vide'
                                  : _rapport.arts[index].commentaire,
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return buildAlertDialogCommentaireArt(
                                      index, context);
                                },
                              );
                            }),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        )
      ],
    );
  }

  Card _artCardIfGareNotSelected(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const ListTile(
            title: Text('Veuillez sélectionner une gare '
                'pour afficher les ARTs'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 8.0,
                  right: 8.0,
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () => _updateCurrentPageIndex(1),
                  child: const Text('Aller'),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  AlertDialog buildAlertDialogCommentaireArt(int index, BuildContext context) {
    String commentaire = _rapport.arts[index].commentaire;
    var editingController = TextEditingController(text: commentaire);

    return AlertDialog(
      title: const Text('Commentaire'),
      content: TextField(
        controller: editingController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            setState(() {
              _rapport.arts[index].commentaire = editingController.text;
            });
          },
          child: const Text('Valider'),
        ),
      ],
    );
  }

  AlertDialog _buildAlertDialogCinqCts(int index, BuildContext context) {
    int nombrePiecesDeCinqCentimes =
        _rapport.arts[index].nombrePiecesDeCinqCentimes;

    return AlertDialog(
      title: const Text('Nombre de pièces de 5 centimes'),
      content: TextField(
        controller:
            TextEditingController(text: nombrePiecesDeCinqCentimes.toString()),
        decoration: const InputDecoration(
          labelText: 'Nombre',
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() {
            nombrePiecesDeCinqCentimes = int.tryParse(value) ?? 0;
          });
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            setState(() {
              _rapport.arts[index].nombrePiecesDeCinqCentimes =
                  nombrePiecesDeCinqCentimes;
            });
          },
          child: const Text('Valider'),
        ),
      ],
    );
  }

  AlertDialog buildAlertDialogRechargement(int index, BuildContext context) {
    List<Rechargement> rechargements = _rapport.arts[index].rechargements;

    return AlertDialog(
      title: const Text('Rechargement'),
      content: StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...Rechargement.values.map(
              (rechargement) => CheckboxListTile(
                value: rechargements.contains(rechargement),
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      rechargements.add(rechargement);
                    } else {
                      rechargements.remove(rechargement);
                    }
                  });
                },
                title: Text(_rechargementsEnumToString[rechargement.index]!),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();

            setState(() {
              _rapport.arts[index].rechargements = rechargements;
            });
          },
          child: const Text('Valider'),
        ),
      ],
    );
  }

  String _displayRechargement(String idArt) {
    Art art = _rapport.arts.firstWhere((art) => art.nom == idArt);

    if (art.rechargements.isEmpty) {
      return 'Aucun rechargement';
    }

    return art.rechargements
        .map((rechargement) => _rechargementsEnumToString[rechargement.index]!)
        .join(', ');
  }

  Future<void> _fetchGares() async {
    _listeGares = await _dbService.getGares();
  }

  Future<void> _fetchAgents() async {
    _listeAgents = await _dbService.getAgents();
  }

  Gare _getGareById(String gareId) {
    if (gareId.isEmpty || _listeGares.isEmpty) {
      return Gare(nom: '', arts: []);
    }
    return _listeGares.firstWhere((gare) => gare.id == gareId);
  }

  Future<void> _fetchData() async {
    await Future.wait([
      _fetchAgents(),
      _fetchGares(),
    ]);
    setState(() {
      _isLoading = false;
    });
  }

  _displaySavedSnackBar(bool updated) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(updated ? 'Rapport mis à jour' : 'Rapport enregistré')),
    );
  }

  String _displayTitreRapport() {
    return _rapport.gareId.isEmpty || _rapport.date == null
        ? 'Nouveau rapport'
        : '${_getGareById(_rapport.gareId)} - ${DateFormat.yMMMMd("fr_FR").format(_rapport.date!)}';
  }
}
