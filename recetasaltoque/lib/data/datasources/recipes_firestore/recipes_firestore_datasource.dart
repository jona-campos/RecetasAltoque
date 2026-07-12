import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/recipe.dart';
import '../../models/recipe_firestore_model.dart';

class RecipesFirestoreDatasource {
  final FirebaseFirestore _firestore;

  RecipesFirestoreDatasource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference _favoritesRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('favorites');

  CollectionReference _recentRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('recent');

  Future<void> saveFavorite(String uid, Recipe recipe) async {
    final model = RecipeFirestoreModel(recipe: recipe);
    await _favoritesRef(uid).doc(recipe.id).set(model.toFirestore());
  }

  Future<void> removeFavorite(String uid, String recipeId) async {
    await _favoritesRef(uid).doc(recipeId).delete();
  }

  Future<List<Recipe>> getFavorites(String uid) async {
    final snapshot = await _favoritesRef(uid).get();
    return snapshot.docs
        .map((doc) => RecipeFirestoreModel.fromFirestore(doc).recipe)
        .toList();
  }

  Future<void> saveRecent(String uid, Recipe recipe) async {
    final model = RecipeFirestoreModel(recipe: recipe);
    await _recentRef(uid).doc(recipe.id).set(model.toFirestore());
  }

  Future<List<Recipe>> getRecent(String uid) async {
    final snapshot = await _recentRef(uid)
        .orderBy('savedAt', descending: true)
        .limit(20)
        .get();
    return snapshot.docs
        .map((doc) => RecipeFirestoreModel.fromFirestore(doc).recipe)
        .toList();
  }

  Future<void> removeRecent(String uid, String recipeId) async {
    await _recentRef(uid).doc(recipeId).delete();
  }

  Future<void> clearRecent(String uid) async {
    final batch = _firestore.batch();
    final snapshot = await _recentRef(uid).get();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<bool> isFavorite(String uid, String recipeId) async {
    final doc = await _favoritesRef(uid).doc(recipeId).get();
    return doc.exists;
  }
}
