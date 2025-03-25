import 'package:cloud_firestore/cloud_firestore.dart';

class Agent {
  String? id;
  String nom;
  String prenom;
  bool estSupprime = false;

  Agent({this.id, this.nom = "", this.prenom = ""});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Agent && other.prenom == prenom && other.nom == nom);

  @override
  int get hashCode => prenom.hashCode ^ nom.hashCode;

  @override
  String toString() => "$prenom $nom";

  factory Agent.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Agent(
      id: snapshot.id,
      nom: data?['nom'],
      prenom: data?['prenom'] ?? "",
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nom': nom,
      'prenom': prenom,
    };
  }
}
