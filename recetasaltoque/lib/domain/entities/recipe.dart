import 'package:equatable/equatable.dart';

class Recipe extends Equatable {
  final String title;
  final String ingredients;
  final String servings;
  final String instructions;
  final String? titleEs;
  final String? ingredientsEs;
  final String? instructionsEs;

  const Recipe({
    required this.title,
    required this.ingredients,
    required this.servings,
    required this.instructions,
    this.titleEs,
    this.ingredientsEs,
    this.instructionsEs,
  });

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
      title: title ?? this.title,
      ingredients: ingredients ?? this.ingredients,
      servings: servings ?? this.servings,
      instructions: instructions ?? this.instructions,
      titleEs: titleEs ?? this.titleEs,
      ingredientsEs: ingredientsEs ?? this.ingredientsEs,
      instructionsEs: instructionsEs ?? this.instructionsEs,
    );
  }

  String get displayTitle => titleEs ?? title;
  String get displayIngredients => ingredientsEs ?? ingredients;
  String get displayInstructions => instructionsEs ?? instructions;

  bool get isTranslated => titleEs != null && ingredientsEs != null && instructionsEs != null;

  @override
  List<Object?> get props => [
        title,
        ingredients,
        servings,
        instructions,
        titleEs,
        ingredientsEs,
        instructionsEs,
      ];
}
