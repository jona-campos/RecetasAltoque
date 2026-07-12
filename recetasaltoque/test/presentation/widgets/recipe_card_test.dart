import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recetasaltoque/domain/entities/recipe.dart';
import 'package:recetasaltoque/presentation/widgets/recipe_card.dart';

void main() {
  const testRecipe = Recipe(
    id: 'chicken-alfredo',
    title: 'Chicken Alfredo',
    ingredients: '1 lb fettuccine\n2 cups heavy cream',
    servings: '4',
    instructions: '1. Cook pasta',
    titleEs: 'Alfredo de Pollo',
    ingredientsEs: '1 lb fettuccine\n2 tazas de crema',
  );

  Widget createRecipeCard({VoidCallback? onTap}) {
    return MaterialApp(
      home: Scaffold(
        body: RecipeCard(
          recipe: testRecipe,
          onTap: onTap,
        ),
      ),
    );
  }

  testWidgets('RecipeCard debe renderizar titulo traducido', (tester) async {
    await tester.pumpWidget(createRecipeCard());

    expect(find.text('Alfredo de Pollo'), findsOneWidget);
  });

  testWidgets('RecipeCard debe renderizar ingredientes', (tester) async {
    await tester.pumpWidget(createRecipeCard());

    expect(find.text('1 lb fettuccine\n2 tazas de crema'), findsOneWidget);
  });

  testWidgets('RecipeCard debe renderizar porciones', (tester) async {
    await tester.pumpWidget(createRecipeCard());

    expect(find.text('4 porciones'), findsOneWidget);
    expect(find.byIcon(Icons.people), findsOneWidget);
  });

  testWidgets('RecipeCard debe llamar onTap cuando se toca', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(createRecipeCard(
      onTap: () => tapped = true,
    ));

    await tester.tap(find.byType(InkWell));
    expect(tapped, isTrue);
  });
}
