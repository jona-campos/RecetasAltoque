import '../../repositories/local/recipe_local_repository.dart';

class ClearRecentRecipes {
  final RecipeLocalRepository repository;

  ClearRecentRecipes(this.repository);

  Future<void> call() {
    return repository.clearRecentRecipes();
  }
}