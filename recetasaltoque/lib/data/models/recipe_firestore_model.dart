import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/recipe.dart';

class RecipeFirestoreModel {
  final Recipe recipe;
  final DateTime? savedAt;

  const RecipeFirestoreModel({required this.recipe, this.savedAt});

  Map<String, dynamic> toFirestore() {
    return {
      'id': recipe.id,
      'title': recipe.title,
      'ingredients': recipe.ingredients,
      'servings': recipe.servings,
      'instructions': recipe.instructions,
      'titleEs': recipe.titleEs,
      'ingredientsEs': recipe.ingredientsEs,
      'instructionsEs': recipe.instructionsEs,
      if (savedAt != null) 'savedAt': savedAt!.toIso8601String(),
    };
  }

  factory RecipeFirestoreModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecipeFirestoreModel(
      recipe: Recipe(
        id: data['id'] as String? ?? doc.id,
        title: data['title'] as String? ?? '',
        ingredients: data['ingredients'] as String? ?? '',
        servings: data['servings'] as String? ?? '1',
        instructions: data['instructions'] as String? ?? '',
        titleEs: data['titleEs'] as String?,
        ingredientsEs: data['ingredientsEs'] as String?,
        instructionsEs: data['instructionsEs'] as String?,
      ),
      savedAt: data['savedAt'] != null
          ? DateTime.tryParse(data['savedAt'] as String)
          : null,
    );
  }
}
