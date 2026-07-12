import '../../entities/recipe.dart';

class ShareRecipe {
  Future<String> execute(Recipe recipe, {String format = 'txt'}) async {
    final content = _generateContent(recipe, format);
    return content;
  }

  String _generateContent(Recipe recipe, String format) {
    final title = recipe.displayTitle;
    final ingredients = recipe.displayIngredients;
    final instructions = recipe.displayInstructions;
    final servings = recipe.servings;

    return '''
$title
$servings porciones

INGREDIENTES:
$ingredients

INSTRUCCIONES:
$instructions
''';
  }
}
