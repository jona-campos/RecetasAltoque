import '../../repositories/local/recipe_local_repository.dart';
import '../../entities/recipe.dart';

class RemoveRecentRecipe {
  final RecipeLocalRepository repository;

  RemoveRecentRecipe(this.repository);

  Future<void> call(String recipeId) {
    return repository.removeRecentRecipe(recipeId);
  }
}