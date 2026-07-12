import '../../repositories/local/recipe_local_repository.dart';
import '../../entities/recipe.dart';

class GetRecentRecipes {
  final RecipeLocalRepository repository;

  GetRecentRecipes(this.repository);

  Future<List<Recipe>> call({int limit = 20}) {
    return repository.getRecentRecipes(limit: limit);
  }
}