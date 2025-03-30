import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:projet_sncf/main.dart';
import 'package:projet_sncf/models/agent.dart';
import 'package:projet_sncf/models/gare.dart';
import 'package:projet_sncf/models/rapport.dart';

enum Collection { agents, gares, rapports }

class DatabaseService {
  final FirebaseFirestore _db = kDebugMode
      ? FirebaseFirestore.instanceFor(databaseId: 'test', app: app)
      : FirebaseFirestore.instance;

  Future<void> addDocument(
      Collection collection, Map<String, dynamic> data) async {
    final ref = _db.collection(collection.name).doc();
    await ref.set(data);
  }

  Future<void> deleteDocument(Collection collection, String id) async {
    await _db.collection(collection.name).doc(id).delete();
  }

  Future<void> updateDocument(
      Collection collection, String id, Map<String, dynamic> data) async {
    await _db.collection(collection.name).doc(id).update(data);
  }

  Stream<QuerySnapshot> streamCollection(Collection collection) {
    return _db.collection(collection.name).snapshots();
  }

  Future<DocumentSnapshot> getDocument(Collection collection, String id) {
    return _db.collection(collection.name).doc(id).get();
  }

  Future<QuerySnapshot> _getCollection(Collection collection) {
    return _db.collection(collection.name).get();
  }

  Future<List<Agent>> getAgents() async {
    final snapshot = await _getCollection(Collection.agents);
    return snapshot.docs.map((doc) {
      return Agent.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
    }).toList();
  }

  Future<List<Rapport>> getRapports() async {
    final snapshot = await _getCollection(Collection.rapports);
    return snapshot.docs.map((doc) {
      return Rapport.fromFirestore(
          doc as DocumentSnapshot<Map<String, dynamic>>);
    }).toList();
  }

  Future<List<Gare>> getGares() async {
    final snapshot = await _getCollection(Collection.gares);
    return snapshot.docs.map((doc) {
      return Gare.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
    }).toList();
  }

  Future<String> saveRapport(Rapport rapport, bool updated) async {
    if (updated) {
      await _db
          .collection('rapports')
          .doc(rapport.id)
          .update(rapport.toFirestore());
    } else {
      var docRef = await _db.collection('rapports').add(rapport.toFirestore());
      rapport.id = docRef.id;
    }
    return rapport.id!;
  }

  Future<int> getCountByCollection(Collection collection) async {
    final snapshot = await _getCollection(collection);
    return snapshot.docs.length;
  }
}
