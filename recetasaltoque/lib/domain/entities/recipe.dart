import 'package:equatable/equatable.dart';

class Recipe extends Equatable {
  final String id;
  final String title;
  final String ingredients;
  final String servings;
  final String instructions;
  final String? titleEs;
  final String? ingredientsEs;
  final String? instructionsEs;

  const Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.servings,
    required this.instructions,
    this.titleEs,
    this.ingredientsEs,
    this.instructionsEs,
  });

  factory Recipe.create({
    String? id,
    required String title,
    required String ingredients,
    required String servings,
    required String instructions,
    String? titleEs,
    String? ingredientsEs,
    String? instructionsEs,
  }) {
    final recipeId = id ?? title.hashCode.toString();
    return Recipe(
      id: recipeId,
      title: title,
      ingredients: ingredients,
      servings: servings,
      instructions: instructions,
      titleEs: titleEs,
      ingredientsEs: ingredientsEs,
      instructionsEs: instructionsEs,
    );
  }

  Recipe copyWith({
    String? title,
    String? ingredients,
    String? servings,
    String? instructions,
    String? titleEs,
    String? ingredientsEs,
    String? instructionsEs,
  }) {
    return Recipe(
      id: id,
      title: title ?? this.title,
      ingredients: ingredients ?? this.ingredients,
      servings: servings ?? this.servings,
      instructions: instructions ?? this.instructions,
      titleEs: titleEs ?? this.titleEs,
      ingredientsEs: ingredientsEs ?? this.ingredientsEs,
      instructionsEs: instructionsEs ?? this.instructionsEs,
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

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      ingredients: json['ingredients'] as String? ?? '',
      servings: json['servings'] as String? ?? '1',
      instructions: json['instructions'] as String? ?? '',
      titleEs: json['titleEs'] as String?,
      ingredientsEs: json['ingredientsEs'] as String?,
      instructionsEs: json['instructionsEs'] as String?,
    );
  }

  String get displayTitle => titleEs ?? title;
  String get displayIngredients => ingredientsEs ?? ingredients;
  String get displayInstructions => instructionsEs ?? instructions;

  bool get isTranslated => titleEs != null && ingredientsEs != null && instructionsEs != null;

  @override
  List<Object?> get props => [
        id,
        title,
        ingredients,
        servings,
        instructions,
        titleEs,
        ingredientsEs,
        instructionsEs,
      ];
}
