import 'package:projet_sncf/enums/rechargement.dart';

class Art {
  String nom;
  List<Rechargement> rechargements;
  int nombrePiecesDeCinqCentimes;
  bool doitPrevoirMonnaie;
  bool changementDeBobineaux;
  bool doitPrevoirBobineaux;
  bool isRetraitCaisseEffectue;
  String commentaire;

  Art({
    required this.nom,
    List<Rechargement>? rechargements,
    this.nombrePiecesDeCinqCentimes = 0,
    this.doitPrevoirMonnaie = false,
    this.changementDeBobineaux = false,
    this.doitPrevoirBobineaux = false,
    this.isRetraitCaisseEffectue = false,
    this.commentaire = "",
  }) : rechargements = rechargements ?? [];

  Map<String, dynamic> toFirestore() {
    return {
      'nom': nom,
      'rechargements':
          rechargements.map((rechargement) => rechargement.index).toList(),
      'nombrePiecesDeCinqCentimes': nombrePiecesDeCinqCentimes,
      'doitPrevoirMonnaie': doitPrevoirMonnaie,
      'changementDeBobineaux': changementDeBobineaux,
      'doitPrevoirBobineaux': doitPrevoirBobineaux,
      'isRetraitCaisseEffectue': isRetraitCaisseEffectue,
      'commentaire': commentaire,
    };
  }
}
