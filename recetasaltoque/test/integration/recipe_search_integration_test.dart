import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recetasaltoque/data/datasources/recipes_api/recipes_api_datasource.dart';
import 'package:recetasaltoque/data/datasources/libretranslate/libretranslate_datasource.dart';
import 'package:recetasaltoque/data/models/recipe_model.dart';
import 'package:recetasaltoque/data/repositories_impl/recipe_repository_impl.dart';
import 'package:recetasaltoque/data/repositories_impl/translation_repository_impl.dart';
import 'package:recetasaltoque/domain/entities/recipe.dart';
import 'package:recetasaltoque/domain/usecases/get_recipes.dart';
import 'package:recetasaltoque/domain/usecases/translate_text.dart';
import 'package:recetasaltoque/shared/services/cache/hybrid_cache_service.dart';
import 'package:recetasaltoque/shared/services/cache/models/cached_translation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockRecipesApiDatasource extends Mock implements RecipesApiDatasource {}
class MockLibreTranslateDatasource extends Mock implements LibreTranslateDatasource {}
class MockHybridCacheService extends Mock implements HybridCacheService {}

void main() {
  late RecipeRepositoryImpl recipeRepository;
  late TranslationRepositoryImpl translationRepository;
  late GetRecipes getRecipes;
  late TranslateText translateText;

  late MockRecipesApiDatasource mockRecipesApiDatasource;
  late MockLibreTranslateDatasource mockLibreTranslateDatasource;
  late MockHybridCacheService mockHybridCacheService;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() {
    mockRecipesApiDatasource = MockRecipesApiDatasource();
    mockLibreTranslateDatasource = MockLibreTranslateDatasource();
    mockHybridCacheService = MockHybridCacheService();

    // Default: cache miss
    when(() => mockHybridCacheService.getTranslation(any(), any(), any()))
        .thenAnswer((_) async => null);
    when(() => mockHybridCacheService.saveTranslation(any(), any(), any(), any()))
        .thenAnswer((_) async {});

    // Default: LibreTranslate available
    when(() => mockLibreTranslateDatasource.isAvailable())
        .thenAnswer((_) async => true);

    // Default: translation succeeds
    when(() => mockLibreTranslateDatasource.translate(any(), from: any(named: 'from'), to: any(named: 'to')))
        .thenAnswer((invocation) async => 'translated_${invocation.positionalArguments.first}');
    when(() => mockLibreTranslateDatasource.translateLongText(any(), from: any(named: 'from'), to: any(named: 'to')))
        .thenAnswer((invocation) async => 'translated_${invocation.positionalArguments.first}');

    translationRepository = TranslationRepositoryImpl(
      translationDatasource: mockLibreTranslateDatasource,
      cacheService: mockHybridCacheService,
    );

    recipeRepository = RecipeRepositoryImpl(
      recipesDatasource: mockRecipesApiDatasource,
      translationRepository: translationRepository,
    );

    getRecipes = GetRecipes(recipeRepository);
    translateText = TranslateText(translationRepository);
  });

  group('Integration: English Query → API → Translated Results', () {
    final testRecipes = [
      RecipeModel(
        id: 'chicken-with-rice',
        title: 'Chicken with Rice',
        ingredients: '2 chicken breasts\n1 cup rice\n1 onion',
        servings: '4',
        instructions: '1. Cook chicken\n2. Cook rice\n3. Mix together',
      ),
      RecipeModel(
        id: 'beef-tacos',
        title: 'Beef Tacos',
        ingredients: '1 lb ground beef\n8 taco shells\nlettuce',
        servings: '4',
        instructions: '1. Cook beef\n2. Fill shells\n3. Add toppings',
      ),
    ];

    test('E2E: English query searches API, returns Spanish results', () async {
      when(() => mockRecipesApiDatasource.searchRecipes(
            any(),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => testRecipes);

      final recipes = await getRecipes('chicken, rice, onion');

      expect(recipes, isA<List<Recipe>>());
      expect(recipes.length, equals(2));
      
      verify(() => mockRecipesApiDatasource.searchRecipes(
            any(),
            offset: any(named: 'offset'),
          )).called(1);

      for (final recipe in recipes) {
        expect(recipe.titleEs, isNotNull);
        expect(recipe.ingredientsEs, isNotNull);
        expect(recipe.instructionsEs, isNotNull);
      }
    });

    test('E2E: LoadMoreRecipes uses same query', () async {
      when(() => mockRecipesApiDatasource.searchRecipes(
            any(),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => testRecipes);

      final firstResults = await getRecipes('chicken, rice, onion');
      expect(firstResults.length, equals(2));

      final moreResults = await recipeRepository.searchRecipesTranslated(
        'chicken, rice, onion',
        offset: 2,
      );

      verify(() => mockRecipesApiDatasource.searchRecipes(
            any(),
            offset: 2,
          )).called(1);

      expect(moreResults.length, equals(2));
    });

    test('E2E: Translation failure falls back gracefully', () async {
      // Arrange: API returns recipes, but translation fails
      when(() => mockRecipesApiDatasource.searchRecipes(
            any(),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => testRecipes);

      // Mock BOTH translate and translateLongText to throw
      when(() => mockLibreTranslateDatasource.translate(
            any(),
            from: any(named: 'from'),
            to: any(named: 'to'),
          )).thenThrow(Exception('Translation service down'));
      when(() => mockLibreTranslateDatasource.translateLongText(
            any(),
            from: any(named: 'from'),
            to: any(named: 'to'),
          )).thenThrow(Exception('Translation service down'));

      final recipes = await getRecipes('chicken');

      expect(recipes.length, equals(2));
      expect(recipes.first.titleEs, isNull);
      expect(recipes.first.ingredientsEs, isNull);
      expect(recipes.first.instructionsEs, isNull);
    });

    test('E2E: Partial translation - title works, ingredients fail', () async {
      when(() => mockRecipesApiDatasource.searchRecipes(
            any(),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => testRecipes);

      when(() => mockLibreTranslateDatasource.translate(
            any(),
            from: any(named: 'from'),
            to: any(named: 'to'),
          )).thenAnswer((_) async => 'Título Traducido');

      when(() => mockLibreTranslateDatasource.translateLongText(
            any(),
            from: any(named: 'from'),
            to: any(named: 'to'),
          )).thenThrow(Exception('Network error'));

      final recipes = await getRecipes('chicken');

      expect(recipes.length, equals(2));
      expect(recipes.first.titleEs, equals('Título Traducido'));
      expect(recipes.first.ingredientsEs, isNull);
      expect(recipes.first.instructionsEs, isNull);
    });
  });

group('Integration: Cache Behavior', () {
    test('Cache hit returns stored translation without calling LibreTranslate', () async {
      // Arrange: Pre-populate cache for the RECIPE TITLE
      const recipeTitle = 'Chicken Dish';
      const cachedTranslation = 'Plato de Pollo';

      // Override cache to return cached value for the specific title, null for others
      when(() => mockHybridCacheService.getTranslation(
            any(),
            'en',
            'es',
          )).thenAnswer((invocation) async {
        final text = invocation.positionalArguments[0] as String;
        if (text == recipeTitle) {
          return CachedTranslation(
            originalText: recipeTitle,
            translatedText: cachedTranslation,
            sourceLang: 'en',
            targetLang: 'es',
            timestamp: DateTime.now(),
          );
        }
        return null;
      });

      // translateLongText for ingredients/instructions (cache miss)
      when(() => mockLibreTranslateDatasource.translateLongText(
            any(),
            from: any(named: 'from'),
            to: any(named: 'to'),
          )).thenAnswer((_) async => 'traducido');

      // Make translate return a sentinel so we can detect if it's called
      when(() => mockLibreTranslateDatasource.translate(
            any(),
            from: any(named: 'from'),
            to: any(named: 'to'),
          )).thenAnswer((_) async => 'SHOULD_NOT_BE_CALLED');

      when(() => mockRecipesApiDatasource.searchRecipes(
            'chicken',
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => [
                const RecipeModel(
                  id: 'chicken-dish',
                  title: 'Chicken Dish',
                  ingredients: 'chicken\nrice',
                  servings: '2',
                  instructions: 'cook it',
                ),
              ]);

      // Act
      final recipes = await getRecipes('chicken');

      // Assert: Cached translation should be in result
      // If translate was called, titleEs would be 'SHOULD_NOT_BE_CALLED'
      // If cache worked, titleEs would be 'Plato de Pollo'
      expect(recipes.length, equals(1));
      expect(recipes.first.titleEs, equals('Plato de Pollo'));
    });

    test('Cache miss calls LibreTranslate and stores result', () async {
      // Clear previous mocks
      clearInteractions(mockHybridCacheService);
      clearInteractions(mockLibreTranslateDatasource);

      // Cache miss for all
      when(() => mockHybridCacheService.getTranslation(
            any(),
            any(),
            any(),
          )).thenAnswer((_) async => null);

      when(() => mockLibreTranslateDatasource.translate(
            'Beef Stew',
            from: 'en',
            to: 'es',
          )).thenAnswer((_) async => 'Estofado de Res');
      when(() => mockLibreTranslateDatasource.translateLongText(
            any(),
            from: any(named: 'from'),
            to: any(named: 'to'),
          )).thenAnswer((_) async => 'traducido');

      when(() => mockRecipesApiDatasource.searchRecipes(
            'beef',
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => [
                const RecipeModel(
                  id: 'beef-stew',
                  title: 'Beef Stew',
                  ingredients: 'beef\npotatoes',
                  servings: '4',
                  instructions: 'stew it',
                ),
              ]);

      final recipes = await getRecipes('beef');

      expect(recipes.length, equals(1));
      verify(() => mockLibreTranslateDatasource.translate(
            'Beef Stew',
            from: 'en',
            to: 'es',
          )).called(1);
      verify(() => mockHybridCacheService.saveTranslation(
            'Beef Stew',
            any(),
            'en',
            'es',
          )).called(1);
    });
  });
}