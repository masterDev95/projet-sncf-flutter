import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_sncf/enums/cab.dart';
import 'package:projet_sncf/enums/rechargement.dart';
import 'package:projet_sncf/enums/type_service.dart';
import 'package:projet_sncf/models/agent.dart';
import 'package:projet_sncf/models/art.dart';

class Rapport {
  String? id;

  // Info générales
  DateTime? date;
  List<String> agents;
  List<Agent> agentsManuellementAjoutes;
  TypeService typeService;

  // Séléction gare
  String gareId;

  // Vérification
  bool samChecked;
  bool agiteChecked;
  bool digisiteChecked;
  Cab cab;
  String commentaireVerif;

  // Rechargement et caisse
  List<Art> arts;

  Rapport({
    this.id,
    this.date,
    List<String>? agents,
    List<Agent>? agentsManuellementAjoutes,
    this.typeService = TypeService.matinee,
    String? gareId,
    this.samChecked = false,
    this.agiteChecked = false,
    this.digisiteChecked = false,
    this.cab = Cab.ko,
    this.commentaireVerif = "",
    List<Art>? arts,
  })  : agents = agents ?? [],
        gareId = gareId ?? "",
        agentsManuellementAjoutes = agentsManuellementAjoutes ?? [],
        arts = arts ?? [];

  factory Rapport.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return Rapport(
      id: snapshot.id,
      date: (data?['date'] as Timestamp).toDate(),
      agents:
          (data?['agents'] as List).map((agent) => agent.toString()).toList(),
      agentsManuellementAjoutes: (data?['agentsManuellementAjoutes'] as List)
          .map((agentData) => Agent(
                nom: agentData['nom'], // Access 'nom' from the map
                prenom: agentData['prenom'], // Access 'prenom' from the map
              ))
          .toList(),
      typeService: TypeService.values
          .firstWhere((e) => e.toString() == data?['typeService']),
      gareId: data?['gareId'],
      samChecked: data?['samChecked'],
      agiteChecked: data?['agiteChecked'],
      digisiteChecked: data?['digisiteChecked'],
      cab: Cab.values.firstWhere((e) => e.toString() == data?['cab']),
      commentaireVerif: data?['commentaireVerif'],
      arts: (data?['arts'] as List)
          .map(
            (art) => Art(
              nom: art['nom'],
              commentaire: art['commentaire'],
              nombrePiecesDeCinqCentimes: art['nombrePiecesDeCinqCentimes'],
              doitPrevoirMonnaie: art['doitPrevoirMonnaie'],
              changementDeBobineaux: art['changementDeBobineaux'],
              doitPrevoirBobineaux: art['doitPrevoirBobineaux'],
              isRetraitCaisseEffectue: art['isRetraitCaisseEffectue'],
              rechargements: (art['rechargements'] as List?)
                      ?.map((rechargement) => Rechargement.values[rechargement])
                      .toList() ??
                  [],
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': date,
      'agents': agents,
      'agentsManuellementAjoutes': agentsManuellementAjoutes
          .map((agent) => agent.toFirestore())
          .toList(),
      'typeService': typeService.toString(),
      'gareId': gareId,
      'samChecked': samChecked,
      'agiteChecked': agiteChecked,
      'digisiteChecked': digisiteChecked,
      'cab': cab.toString(),
      'commentaireVerif': commentaireVerif,
      'arts': arts.map((art) => art.toFirestore()).toList(),
    };
  }
}
