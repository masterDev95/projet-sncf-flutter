import 'package:cloud_firestore/cloud_firestore.dart';

class Gare {
  final String? id;
  final String nom;
  final List<String> arts;

  Gare({
    this.id,
    required this.nom,
    required this.arts,
  });

  @override
  String toString() => nom;

  factory Gare.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Gare(
      id: snapshot.id,
      nom: data?['nom'],
      arts: (data?['arts'] as List).map((art) => art.toString()).toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nom': nom,
      'arts': arts,
    };
  }
}
