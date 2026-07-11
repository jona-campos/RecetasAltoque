import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  FirebaseService({
    required this.firestore,
    required this.auth,
  });

  static Future<FirebaseService> initialize() async {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    return FirebaseService(
      firestore: firestore,
      auth: auth,
    );
  }

  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    return await firestore.collection(collection).doc(docId).get();
  }

  Future<void> setDocument(String collection, String docId, Map<String, dynamic> data) async {
    await firestore.collection(collection).doc(docId).set(data);
  }

  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    await firestore.collection(collection).doc(docId).update(data);
  }

  Future<void> deleteDocument(String collection, String docId) async {
    await firestore.collection(collection).doc(docId).delete();
  }

  Future<QuerySnapshot> queryCollection(String collection, {Query Function(Query)? queryBuilder}) async {
    Query query = firestore.collection(collection);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return await query.get();
  }

  Future<Stream<QuerySnapshot>> streamCollection(String collection, {Query Function(Query)? queryBuilder}) async {
    Query query = firestore.collection(collection);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.snapshots();
  }

  Future<User?> getCurrentUser() async {
    return auth.currentUser;
  }

  Future<UserCredential> signInAnonymously() async {
    return await auth.signInAnonymously();
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}
