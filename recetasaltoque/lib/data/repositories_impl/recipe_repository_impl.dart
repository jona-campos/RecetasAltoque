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

    for (final recipe in recipes) {
      String? titleTranslation;
      String? ingredientsTranslation;
      String? instructionsTranslation;

      // Translate title with retry
      try {
        titleTranslation = await _translateWithRetry(
          () => translationRepository.translate(recipe.title),
          'title',
          recipe.title,
        );
      } catch (e) {
        debugPrint('Title translation failed for "${recipe.title}": $e');
      }

      // Translate ingredients with retry
      try {
        ingredientsTranslation = await _translateWithRetry(
          () => translationRepository.translateLongText(recipe.ingredients),
          'ingredients',
          recipe.ingredients,
        );
      } catch (e) {
        debugPrint('Ingredients translation failed for "${recipe.title}": $e');
      }

      // Translate instructions with retry
      try {
        instructionsTranslation = await _translateWithRetry(
          () => translationRepository.translateLongText(recipe.instructions),
          'instructions',
          recipe.instructions,
        );
      } catch (e) {
        debugPrint('Instructions translation failed for "${recipe.title}": $e');
      }

      translatedRecipes.add(
        recipe.copyWithTranslation(
          titleEs: titleTranslation,
          ingredientsEs: ingredientsTranslation,
          instructionsEs: instructionsTranslation,
        ),
      );
    }

    return translatedRecipes;
  }

  Future<String> _translateWithRetry(
    Future<String> Function() translateFn,
    String field,
    String originalText,
  ) async {
    const maxRetries = 2;
    Exception? lastException;

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        return await translateFn();
      } on Exception catch (e) {
        lastException = e;
        if (attempt < maxRetries) {
          debugPrint('Translation retry $field (attempt ${attempt + 1}/${maxRetries + 1}): $e');
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
        }
      }
    }

    throw lastException ?? Exception('Translation failed after retries');
  }
}
