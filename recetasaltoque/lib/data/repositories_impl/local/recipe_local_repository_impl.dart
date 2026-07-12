import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../domain/entities/recipe.dart';
import '../../../../domain/repositories/local/recipe_local_repository.dart';

class RecipeLocalRepositoryImpl implements RecipeLocalRepository {
  final SharedPreferences _prefs;

  RecipeLocalRepositoryImpl({required SharedPreferences prefs})
      : _prefs = prefs;

  static const String _recentRecipesKey = 'recent_recipes';
  static const String _favoriteRecipesKey = 'favorite_recipes';
  static const int _maxRecentRecipes = 20;

  @override
  Future<void> saveRecentRecipe(Recipe recipe) async {
    final recentRecipes = await getRecentRecipes();
    
    // Remove if already exists (to move to top)
    recentRecipes.removeWhere((r) => r.id == recipe.id);
    
    // Add to top
    recentRecipes.insert(0, recipe);
    
    // Limit to max
    if (recentRecipes.length > _maxRecentRecipes) {
      recentRecipes.removeRange(_maxRecentRecipes, recentRecipes.length);
    }
    
    await _saveRecentRecipes(recentRecipes);
  }

  @override
  Future<List<Recipe>> getRecentRecipes({int limit = 20}) async {
    final jsonString = _prefs.getString(_recentRecipesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      final recipes = jsonList
          .map((json) => _recipeFromJson(json as Map<String, dynamic>))
          .toList();
      return recipes.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveFavoriteRecipe(Recipe recipe) async {
    final favorites = await getFavoriteRecipes();
    
    // Check if already exists
    if (!favorites.any((r) => r.id == recipe.id)) {
      favorites.add(recipe);
      await _saveFavoriteRecipes(favorites);
    }
  }

  @override
  Future<List<Recipe>> getFavoriteRecipes() async {
    final jsonString = _prefs.getString(_favoriteRecipesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => _recipeFromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> removeFavoriteRecipe(String recipeId) async {
    final favorites = await getFavoriteRecipes();
    favorites.removeWhere((r) => r.id == recipeId);
    await _saveFavoriteRecipes(favorites);
  }

  @override
  Future<bool> isFavorite(String recipeId) async {
    final favorites = await getFavoriteRecipes();
    return favorites.any((r) => r.id == recipeId);
  }

  @override
  Future<void> clearRecentRecipes() async {
    await _prefs.remove(_recentRecipesKey);
  }

  @override
  Future<void> removeRecentRecipe(String recipeId) async {
    final recentRecipes = await getRecentRecipes();
    recentRecipes.removeWhere((r) => r.id == recipeId);
    await _saveRecentRecipes(recentRecipes);
  }

  Future<void> _saveRecentRecipes(List<Recipe> recipes) async {
    final jsonString = json.encode(recipes.map(_recipeToJson).toList());
    await _prefs.setString(_recentRecipesKey, jsonString);
  }

  Future<void> _saveFavoriteRecipes(List<Recipe> recipes) async {
    final jsonString = json.encode(recipes.map(_recipeToJson).toList());
    await _prefs.setString(_favoriteRecipesKey, jsonString);
  }

  Map<String, dynamic> _recipeToJson(Recipe recipe) {
    return {
      'id': recipe.id,
      'title': recipe.title,
      'ingredients': recipe.ingredients,
      'servings': recipe.servings,
      'instructions': recipe.instructions,
      'titleEs': recipe.titleEs,
      'ingredientsEs': recipe.ingredientsEs,
      'instructionsEs': recipe.instructionsEs,
    };
  }

  Recipe _recipeFromJson(Map<String, dynamic> json) {
    final storedId = json['id'] as String? ?? '';
    if (storedId.isNotEmpty) {
      return Recipe(
        id: storedId,
        title: json['title'] as String? ?? '',
        ingredients: json['ingredients'] as String? ?? '',
        servings: json['servings'] as String? ?? '1',
        instructions: json['instructions'] as String? ?? '',
        titleEs: json['titleEs'] as String?,
        ingredientsEs: json['ingredientsEs'] as String?,
        instructionsEs: json['instructionsEs'] as String?,
      );
    }
    return Recipe.create(
      title: json['title'] as String? ?? '',
      ingredients: json['ingredients'] as String? ?? '',
      servings: json['servings'] as String? ?? '1',
      instructions: json['instructions'] as String? ?? '',
      titleEs: json['titleEs'] as String?,
      ingredientsEs: json['ingredientsEs'] as String?,
      instructionsEs: json['instructionsEs'] as String?,
    );
  }
}