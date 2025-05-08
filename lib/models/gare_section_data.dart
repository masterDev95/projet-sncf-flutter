import 'package:projet_sncf/models/art.dart';

class GareSectionData {
  final String gare;
  final String personnes;
  final bool sam;
  final bool agite;
  final String cab;
  final String commentaireVerif;
  final String commentaireFinal;
  final List<Art> artList;

  GareSectionData({
    required this.gare,
    required this.personnes,
    required this.sam,
    required this.agite,
    required this.cab,
    required this.commentaireVerif,
    required this.commentaireFinal,
    this.artList = const [],
  });
}
