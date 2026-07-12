import '../../entities/recipe.dart';

abstract class RecipeLocalRepository {
  Future<void> saveRecentRecipe(Recipe recipe);
  Future<List<Recipe>> getRecentRecipes({int limit = 20});
  Future<void> removeRecentRecipe(String recipeId);
  Future<void> saveFavoriteRecipe(Recipe recipe);
  Future<List<Recipe>> getFavoriteRecipes();
  Future<void> removeFavoriteRecipe(String recipeId);
  Future<bool> isFavorite(String recipeId);
  Future<void> clearRecentRecipes();
}