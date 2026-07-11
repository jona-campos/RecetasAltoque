import '../entities/recipe.dart';

abstract class RecipeRepository {
  Future<List<Recipe>> searchRecipes(String query, {int offset = 0});
  Future<List<Recipe>> searchRecipesTranslated(String query, {int offset = 0});
}
