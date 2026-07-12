import '../../repositories/local/recipe_local_repository.dart';
import '../../entities/recipe.dart';

class SaveRecentRecipe {
  final RecipeLocalRepository repository;

  SaveRecentRecipe(this.repository);

  Future<void> call(Recipe recipe) {
    return repository.saveRecentRecipe(recipe);
  }
}