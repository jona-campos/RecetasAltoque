import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recetasaltoque/domain/entities/recipe.dart';
import 'package:recetasaltoque/presentation/pages/recipe_detail_screen.dart';

void main() {
  const testRecipe = Recipe(
    title: 'Chicken Alfredo',
    ingredients: '1 lb fettuccine\n2 cups heavy cream',
    servings: '4',
    instructions: '1. Cook pasta\n2. Make sauce',
    titleEs: 'Alfredo de Pollo',
    ingredientsEs: '1 lb fettuccine\n2 tazas de crema',
    instructionsEs: '1. Cocinar pasta\n2. Hacer salsa',
  );

  Widget createRecipeDetailScreen() {
    return MaterialApp(
      home: const RecipeDetailScreen(recipe: testRecipe),
    );
  }

  testWidgets('RecipeDetailScreen debe renderizar titulo traducido', (tester) async {
    await tester.pumpWidget(createRecipeDetailScreen());

    expect(find.text('Alfredo de Pollo'), findsOneWidget);
  });

  testWidgets('RecipeDetailScreen debe mostrar porciones', (tester) async {
    await tester.pumpWidget(createRecipeDetailScreen());

    expect(find.text('4 porciones'), findsOneWidget);
    expect(find.byIcon(Icons.people), findsOneWidget);
  });

  testWidgets('RecipeDetailScreen debe mostrar ingredientes', (tester) async {
    await tester.pumpWidget(createRecipeDetailScreen());

    expect(find.text('Ingredientes'), findsOneWidget);
    expect(find.text('1 lb fettuccine\n2 tazas de crema'), findsOneWidget);
  });

  testWidgets('RecipeDetailScreen debe mostrar instrucciones', (tester) async {
    await tester.pumpWidget(createRecipeDetailScreen());

    expect(find.text('Instrucciones'), findsOneWidget);
    expect(find.text('1. Cocinar pasta\n2. Hacer salsa'), findsOneWidget);
  });

  testWidgets('RecipeDetailScreen debe tener boton de regreso', (tester) async {
    await tester.pumpWidget(createRecipeDetailScreen());

    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });
}
