import '../../repositories/local/recipe_local_repository.dart';
import '../../entities/recipe.dart';

class ToggleFavorite {
  final RecipeLocalRepository repository;

  ToggleFavorite(this.repository);

  Future<void> execute(Recipe recipe) async {
    final isFavorite = await repository.isFavorite(recipe.id);
    if (isFavorite) {
      await repository.removeFavoriteRecipe(recipe.id);
    } else {
      await repository.saveFavoriteRecipe(recipe);
    }
  }
}