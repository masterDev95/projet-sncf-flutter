import 'package:projet_sncf/enums/rechargement.dart';

class Art {
  Rechargement rechargement;
  int nombrePiecesDeCinqCentimes;
  bool doitPrevoirMonnaie;
  bool changementDeBobineaux;
  bool doitPrevoirBobineaux;
  bool isRetraitCaisseEffectue;
  String commentaire;

  Art({
    required this.rechargement,
    required this.nombrePiecesDeCinqCentimes,
    required this.doitPrevoirMonnaie,
    required this.changementDeBobineaux,
    required this.doitPrevoirBobineaux,
    required this.isRetraitCaisseEffectue,
    required this.commentaire,
  });
}
