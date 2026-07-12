import '../../domain/entities/recipe.dart';

class RecipeModel extends Recipe {
  const RecipeModel({
    required super.id,
    required super.title,
    required super.ingredients,
    required super.servings,
    required super.instructions,
    super.titleEs,
    super.ingredientsEs,
    super.instructionsEs,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String? ?? '';
    final spoonacularId = json['id']?.toString();
    return RecipeModel(
      id: spoonacularId ?? title.hashCode.toString(),
      title: title,
      ingredients: json['ingredients'] as String? ?? '',
      servings: json['servings'] as String? ?? '1',
      instructions: json['instructions'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'ingredients': ingredients,
      'servings': servings,
      'instructions': instructions,
      'titleEs': titleEs,
      'ingredientsEs': ingredientsEs,
      'instructionsEs': instructionsEs,
    };
  }

  factory RecipeModel.fromTranslation(Recipe recipe, {
    String? titleEs,
    String? ingredientsEs,
    String? instructionsEs,
  }) {
    return RecipeModel(
      id: recipe.id,
      title: recipe.title,
      ingredients: recipe.ingredients,
      servings: recipe.servings,
      instructions: recipe.instructions,
      titleEs: titleEs ?? recipe.titleEs,
      ingredientsEs: ingredientsEs ?? recipe.ingredientsEs,
      instructionsEs: instructionsEs ?? recipe.instructionsEs,
    );
  }

  RecipeModel copyWithTranslation({
    String? titleEs,
    String? ingredientsEs,
    String? instructionsEs,
  }) {
    return RecipeModel(
      id: id,
      title: title,
      ingredients: ingredients,
      servings: servings,
      instructions: instructions,
      titleEs: titleEs ?? this.titleEs,
      ingredientsEs: ingredientsEs ?? this.ingredientsEs,
      instructionsEs: instructionsEs ?? this.instructionsEs,
    );
  }
}
