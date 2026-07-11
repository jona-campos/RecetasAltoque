import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

class GetRecipes {
  final RecipeRepository repository;

  GetRecipes(this.repository);

  Future<List<Recipe>> call(String query, {int offset = 0}) {
    if (query.trim().isEmpty) {
      throw ArgumentError('El query de busqueda no puede estar vacio');
    }
    return repository.searchRecipesTranslated(query, offset: offset);
  }
}
