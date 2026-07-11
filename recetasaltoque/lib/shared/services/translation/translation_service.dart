import 'package:flutter/foundation.dart';
import '/../domain/entities/recipe.dart';
import '/../domain/repositories/translation_repository.dart';

class TranslationService {
  final TranslationRepository repository;

  TranslationService({required this.repository});

  Future<String> translate(String text, {String from = 'en', String to = 'es'}) async {
    if (text.trim().isEmpty) return '';
    return await repository.translate(text, from: from, to: to);
  }

  Future<Recipe> translateRecipe(Recipe recipe, {String from = 'en', String to = 'es'}) async {
    try {
      final translations = await repository.translateBatch([
        recipe.title,
        recipe.ingredients,
        recipe.instructions,
      ], from: from, to: to);

      return recipe.copyWith(
        titleEs: translations[0],
        ingredientsEs: translations[1],
        instructionsEs: translations[2],
      );
    } catch (e) {
      debugPrint('Error al traducir receta: $e');
      return recipe;
    }
  }

  Future<List<Recipe>> translateRecipes(List<Recipe> recipes, {String from = 'en', String to = 'es'}) async {
    final List<Recipe> translatedRecipes = [];

    for (final recipe in recipes) {
      final translated = await translateRecipe(recipe, from: from, to: to);
      translatedRecipes.add(translated);
    }

    return translatedRecipes;
  }
}
