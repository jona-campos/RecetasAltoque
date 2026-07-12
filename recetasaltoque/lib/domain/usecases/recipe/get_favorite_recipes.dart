import '../../repositories/local/recipe_local_repository.dart';
import '../../entities/recipe.dart';

class GetFavoriteRecipes {
  final RecipeLocalRepository repository;

  GetFavoriteRecipes(this.repository);

  Future<List<Recipe>> call() {
    return repository.getFavoriteRecipes();
  }
}