import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recetasaltoque/domain/entities/recipe.dart';
import 'package:recetasaltoque/domain/repositories/recipe_repository.dart';
import 'package:recetasaltoque/domain/usecases/get_recipes.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  late GetRecipes useCase;
  late MockRecipeRepository mockRepository;

  setUp(() {
    mockRepository = MockRecipeRepository();
    useCase = GetRecipes(mockRepository);
  });

  final testRecipes = [
    const Recipe(
      title: 'Chicken Alfredo',
      ingredients: '1 lb fettuccine\n2 cups heavy cream',
      servings: '4',
      instructions: '1. Cook pasta\n2. Make sauce',
      titleEs: 'Alfredo de Pollo',
      ingredientsEs: '1 lb fettuccine\n2 tazas de crema',
      instructionsEs: '1. Cocinar pasta\n2. Hacer salsa',
    ),
  ];

  test('debe retornar lista de recetas traducidas', () async {
    when(() => mockRepository.searchRecipesTranslated(
          any(),
          offset: any(named: 'offset'),
        )).thenAnswer((_) async => testRecipes);

    final result = await useCase('chicken');

    expect(result, isA<List<Recipe>>());
    expect(result.length, equals(1));
    expect(result.first.title, equals('Chicken Alfredo'));
    verify(() => mockRepository.searchRecipesTranslated(
          'chicken',
          offset: 0,
        )).called(1);
  });

  test('debe retornar lista vacia cuando no hay resultados', () async {
    when(() => mockRepository.searchRecipesTranslated(
          any(),
          offset: any(named: 'offset'),
        )).thenAnswer((_) async => []);

    final result = await useCase('xyz123');

    expect(result, isEmpty);
  });

  test('debe lanzar ArgumentError si query esta vacio', () async {
    expect(() => useCase(''), throwsArgumentError);
    expect(() => useCase('   '), throwsArgumentError);
  });

  test('debe pasar offset correctamente', () async {
    when(() => mockRepository.searchRecipesTranslated(
          any(),
          offset: any(named: 'offset'),
        )).thenAnswer((_) async => testRecipes);

    await useCase('chicken', offset: 10);

    verify(() => mockRepository.searchRecipesTranslated(
          'chicken',
          offset: 10,
        )).called(1);
  });
}
