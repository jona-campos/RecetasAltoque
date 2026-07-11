import 'package:flutter/foundation.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/repositories/translation_repository.dart';
import '../datasources/recipes_api/recipes_api_datasource.dart';
import '../models/recipe_model.dart';
import '../../core/errors/failures.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipesApiDatasource recipesDatasource;
  final TranslationRepository translationRepository;

  RecipeRepositoryImpl({
    required this.recipesDatasource,
    required this.translationRepository,
  });

  @override
  Future<List<Recipe>> searchRecipes(String query, {int offset = 0}) async {
    try {
      return await recipesDatasource.searchRecipes(query, offset: offset);
    } on Exception catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<List<Recipe>> searchRecipesTranslated(String query, {int offset = 0}) async {
    try {
      final recipes = await recipesDatasource.searchRecipes(query, offset: offset);
      return _translateRecipes(recipes);
    } on Exception catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<List<Recipe>> _translateRecipes(List<RecipeModel> recipes) async {
    final List<Recipe> translatedRecipes = [];

    // Health check before translating
    final isAvailable = await translationRepository.isAvailable();
    if (!isAvailable) {
      debugPrint('Translation service unavailable, returning original recipes');
      for (final recipe in recipes) {
        translatedRecipes.add(recipe);
      }
      return translatedRecipes;
    }

    for (final recipe in recipes) {
      try {
        final titleTranslation = await translationRepository.translate(
          recipe.title,
        );

        final ingredientsTranslation = await translationRepository.translateLongText(
          recipe.ingredients,
        );

        final instructionsTranslation = await translationRepository.translateLongText(
          recipe.instructions,
        );

        translatedRecipes.add(
          recipe.copyWithTranslation(
            titleEs: titleTranslation,
            ingredientsEs: ingredientsTranslation,
            instructionsEs: instructionsTranslation,
          ),
        );
      } on Exception catch (e) {
        debugPrint('Translation failed for recipe "${recipe.title}": $e');
        translatedRecipes.add(recipe);
      }
    }

    return translatedRecipes;
  }
}
