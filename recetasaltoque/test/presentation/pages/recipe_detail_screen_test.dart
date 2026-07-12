import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recetasaltoque/domain/entities/recipe.dart';
import 'package:recetasaltoque/domain/usecases/recipe/get_recent_recipes.dart';
import 'package:recetasaltoque/domain/usecases/recipe/get_favorite_recipes.dart';
import 'package:recetasaltoque/domain/usecases/recipe/toggle_favorite.dart';
import 'package:recetasaltoque/domain/usecases/recipe/share_recipe.dart';
import 'package:recetasaltoque/domain/usecases/recipe/save_recent_recipe.dart';
import 'package:recetasaltoque/domain/usecases/recipe/remove_recent_recipe.dart';
import 'package:recetasaltoque/domain/usecases/recipe/clear_recent_recipes.dart';
import 'package:recetasaltoque/presentation/bloc/home/home_bloc.dart';
import 'package:recetasaltoque/presentation/pages/recipe_detail_screen.dart';

class MockGetRecentRecipes extends Mock implements GetRecentRecipes {}
class MockGetFavoriteRecipes extends Mock implements GetFavoriteRecipes {}
class MockToggleFavorite extends Mock implements ToggleFavorite {}
class MockShareRecipe extends Mock implements ShareRecipe {}
class MockSaveRecentRecipe extends Mock implements SaveRecentRecipe {}
class MockRemoveRecentRecipe extends Mock implements RemoveRecentRecipe {}
class MockClearRecentRecipes extends Mock implements ClearRecentRecipes {}

void main() {
  const testRecipe = Recipe(
    id: 'chicken-alfredo',
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
      home: BlocProvider(
        create: (context) => HomeBloc(
          getRecentRecipes: MockGetRecentRecipes(),
          getFavoriteRecipes: MockGetFavoriteRecipes(),
          toggleFavorite: MockToggleFavorite(),
          shareRecipe: MockShareRecipe(),
          saveRecentRecipe: MockSaveRecentRecipe(),
          removeRecentRecipe: MockRemoveRecentRecipe(),
          clearRecentRecipes: MockClearRecentRecipes(),
        ),
        child: const RecipeDetailScreen(recipe: testRecipe),
      ),
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
