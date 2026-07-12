import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/local/recipe_local_repository.dart';
import '../datasources/recipes_firestore/recipes_firestore_datasource.dart';
import 'local/recipe_local_repository_impl.dart';

class RecipeSyncedRepositoryImpl implements RecipeLocalRepository {
  final RecipeLocalRepositoryImpl _local;
  final RecipesFirestoreDatasource _remote;
  final FirebaseAuth _auth;

  RecipeSyncedRepositoryImpl({
    required RecipeLocalRepositoryImpl local,
    required RecipesFirestoreDatasource remote,
    required FirebaseAuth auth,
  })  : _local = local,
        _remote = remote,
        _auth = auth;

  String? get _uid => _auth.currentUser?.uid;

  @override
  Future<void> saveRecentRecipe(Recipe recipe) async {
    await _local.saveRecentRecipe(recipe);
    final uid = _uid;
    if (uid != null) {
      await _remote.saveRecent(uid, recipe);
    }
  }

  @override
  Future<List<Recipe>> getRecentRecipes({int limit = 20}) async {
    return _local.getRecentRecipes(limit: limit);
  }

  @override
  Future<void> removeRecentRecipe(String recipeId) async {
    await _local.removeRecentRecipe(recipeId);
    final uid = _uid;
    if (uid != null) {
      await _remote.removeRecent(uid, recipeId);
    }
  }

  @override
  Future<void> saveFavoriteRecipe(Recipe recipe) async {
    await _local.saveFavoriteRecipe(recipe);
    final uid = _uid;
    if (uid != null) {
      await _remote.saveFavorite(uid, recipe);
    }
  }

  @override
  Future<List<Recipe>> getFavoriteRecipes() async {
    return _local.getFavoriteRecipes();
  }

  @override
  Future<void> removeFavoriteRecipe(String recipeId) async {
    await _local.removeFavoriteRecipe(recipeId);
    final uid = _uid;
    if (uid != null) {
      await _remote.removeFavorite(uid, recipeId);
    }
  }

  @override
  Future<bool> isFavorite(String recipeId) async {
    return _local.isFavorite(recipeId);
  }

  @override
  Future<void> clearRecentRecipes() async {
    await _local.clearRecentRecipes();
    final uid = _uid;
    if (uid != null) {
      await _remote.clearRecent(uid);
    }
  }
}
