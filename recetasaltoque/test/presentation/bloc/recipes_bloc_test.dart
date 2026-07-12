import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recetasaltoque/domain/entities/recipe.dart';
import 'package:recetasaltoque/domain/usecases/get_recipes.dart';
import 'package:recetasaltoque/domain/usecases/translate_text.dart';
import 'package:recetasaltoque/presentation/bloc/recipes/recipes_bloc.dart';
import 'package:recetasaltoque/presentation/bloc/recipes/recipes_event.dart';
import 'package:recetasaltoque/presentation/bloc/recipes/recipes_state.dart';

class MockGetRecipes extends Mock implements GetRecipes {}
class MockTranslateText extends Mock implements TranslateText {}

void main() {
  late RecipesBloc bloc;
  late MockGetRecipes mockGetRecipes;
  late MockTranslateText mockTranslateText;

  setUp(() {
    mockGetRecipes = MockGetRecipes();
    mockTranslateText = MockTranslateText();
    bloc = RecipesBloc(getRecipes: mockGetRecipes, translateText: mockTranslateText);
  });

  tearDown(() {
    bloc.close();
  });

  final testRecipes = [
    const Recipe(
      id: 'chicken-alfredo',
      title: 'Chicken Alfredo',
      ingredients: '1 lb fettuccine',
      servings: '4',
      instructions: '1. Cook pasta',
      titleEs: 'Alfredo de Pollo',
    ),
  ];

  group('RecipesBloc', () {
    test('estado inicial debe ser RecipesInitial', () {
      expect(bloc.state, isA<RecipesInitial>());
    });

    blocTest<RecipesBloc, RecipesState>(
      'debe emitir [Loading, Loaded] cuando SearchRecipes es exitoso',
      build: () {
        when(() => mockGetRecipes(any(), offset: any(named: 'offset')))
            .thenAnswer((_) async => testRecipes);
        when(() => mockTranslateText(any(), from: any(named: 'from'), to: any(named: 'to')))
            .thenAnswer((_) async => 'chicken');
        return bloc;
      },
      act: (bloc) => bloc.add(SearchRecipes(query: 'pollo')),
      expect: () => [
        isA<RecipesLoading>(),
        isA<RecipesLoaded>(),
      ],
    );

    blocTest<RecipesBloc, RecipesState>(
      'debe emitir [Loading, Error] cuando SearchRecipes falla',
      build: () {
        when(() => mockGetRecipes(any(), offset: any(named: 'offset')))
            .thenThrow(Exception('Error'));
        when(() => mockTranslateText(any(), from: any(named: 'from'), to: any(named: 'to')))
            .thenAnswer((_) async => 'chicken');
        return bloc;
      },
      act: (bloc) => bloc.add(SearchRecipes(query: 'pollo')),
      expect: () => [
        isA<RecipesLoading>(),
        isA<RecipesError>(),
      ],
    );

    blocTest<RecipesBloc, RecipesState>(
      'debe emitir Loaded con mas recetas cuando LoadMoreRecipes',
      build: () {
        when(() => mockGetRecipes(any(), offset: any(named: 'offset')))
            .thenAnswer((_) async => testRecipes);
        when(() => mockTranslateText(any(), from: any(named: 'from'), to: any(named: 'to')))
            .thenAnswer((_) async => 'chicken');
        return bloc;
      },
      seed: () => RecipesLoaded(
        recipes: testRecipes,
        query: 'pollo',
        translatedQuery: 'chicken',
        hasMore: true,
      ),
      act: (bloc) => bloc.add(LoadMoreRecipes(query: 'pollo', offset: 1, translatedQuery: 'chicken')),
      expect: () => [
        isA<RecipesLoaded>(),
      ],
    );

    blocTest<RecipesBloc, RecipesState>(
      'debe emitir Initial cuando ClearRecipes',
      build: () => bloc,
      seed: () => RecipesLoaded(recipes: testRecipes, query: 'pollo'),
      act: (bloc) => bloc.add(const ClearRecipes()),
      expect: () => [isA<RecipesInitial>()],
    );

    blocTest<RecipesBloc, RecipesState>(
      'no debe emitir Loading si query esta vacio',
      build: () => bloc,
      act: (bloc) => bloc.add(SearchRecipes(query: '')),
      expect: () => [isA<RecipesInitial>()],
    );
  });
}
