import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recetasaltoque/data/datasources/recipes_api/recipes_api_datasource.dart';
import 'package:recetasaltoque/domain/repositories/translation_repository.dart';
import 'package:recetasaltoque/data/models/recipe_model.dart';
import 'package:recetasaltoque/data/repositories_impl/recipe_repository_impl.dart';
import 'package:recetasaltoque/core/errors/failures.dart';

class MockRecipesApiDatasource extends Mock implements RecipesApiDatasource {}
class MockTranslationRepository extends Mock implements TranslationRepository {}

void main() {
  late RecipeRepositoryImpl repository;
  late MockRecipesApiDatasource mockRecipesDatasource;
  late MockTranslationRepository mockTranslationRepository;

  setUp(() {
    mockRecipesDatasource = MockRecipesApiDatasource();
    mockTranslationRepository = MockTranslationRepository();
    repository = RecipeRepositoryImpl(
      recipesDatasource: mockRecipesDatasource,
      translationRepository: mockTranslationRepository,
    );
  });

  final testRecipeModel = const RecipeModel(
    title: 'Chicken Alfredo',
    ingredients: '1 lb fettuccine\n2 cups heavy cream',
    servings: '4',
    instructions: '1. Cook pasta\n2. Make sauce',
  );

  final testRecipes = [testRecipeModel];

  group('searchRecipes', () {
    test('debe retornar recetas del datasource', () async {
      when(() => mockRecipesDatasource.searchRecipes(
            any(),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => testRecipes);

      final result = await repository.searchRecipes('chicken');

      expect(result, isA<List>());
      expect(result.length, equals(1));
      verify(() => mockRecipesDatasource.searchRecipes(
            'chicken',
            offset: 0,
          )).called(1);
    });

    test('debe lanzar ServerFailure cuando hay error', () async {
      when(() => mockRecipesDatasource.searchRecipes(
            any(),
            offset: any(named: 'offset'),
          )).thenThrow(Exception('Error de conexion'));

      expect(
        () => repository.searchRecipes('chicken'),
        throwsA(isA<ServerFailure>()),
      );
    });
  });

  group('searchRecipesTranslated', () {
    test('debe retornar recetas traducidas', () async {
      when(() => mockRecipesDatasource.searchRecipes(
            any(),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => testRecipes);
      when(() => mockTranslationRepository.translate(
            any(),
            from: any(named: 'from'),
            to: any(named: 'to'),
          )).thenAnswer((_) async => 'Alfredo de Pollo');
      when(() => mockTranslationRepository.translateLongText(
            any(),
            from: any(named: 'from'),
            to: any(named: 'to'),
          )).thenAnswer((_) async => '1 lb fettuccine\n2 tazas de crema');
      when(() => mockTranslationRepository.isAvailable()).thenAnswer((_) async => true);

      final result = await repository.searchRecipesTranslated('chicken');

      expect(result, isA<List>());
      expect(result.first.titleEs, equals('Alfredo de Pollo'));
    });

    test('debe retornar recetas sin traducir si falla traduccion', () async {
      when(() => mockRecipesDatasource.searchRecipes(
            any(),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => testRecipes);
      when(() => mockTranslationRepository.translate(
            any(),
            from: any(named: 'from'),
            to: any(named: 'to'),
          )).thenThrow(Exception('Error de traduccion'));
      when(() => mockTranslationRepository.isAvailable()).thenAnswer((_) async => true);

      final result = await repository.searchRecipesTranslated('chicken');

      expect(result, isA<List>());
      expect(result.first.titleEs, isNull);
    });
    
    test('debe retornar recetas sin traducir si servicio no disponible', () async {
      when(() => mockRecipesDatasource.searchRecipes(
            any(),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => testRecipes);
      when(() => mockTranslationRepository.isAvailable()).thenAnswer((_) async => false);

      final result = await repository.searchRecipesTranslated('chicken');

      expect(result, isA<List>());
      expect(result.first.titleEs, isNull);
    });
  });
}
