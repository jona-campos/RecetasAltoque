import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recetasaltoque/domain/entities/recipe.dart';
import 'package:recetasaltoque/domain/usecases/get_recipes.dart';
import 'package:recetasaltoque/presentation/bloc/recipes/recipes_bloc.dart';
import 'package:recetasaltoque/presentation/bloc/recipes/recipes_event.dart';
import 'package:recetasaltoque/presentation/bloc/recipes/recipes_state.dart';

class MockGetRecipes extends Mock implements GetRecipes {}

void main() {
  late RecipesBloc bloc;
  late MockGetRecipes mockGetRecipes;

  setUp(() {
    mockGetRecipes = MockGetRecipes();
    bloc = RecipesBloc(getRecipes: mockGetRecipes);
  });

  tearDown(() {
    bloc.close();
  });

  final testRecipes = [
    const Recipe(
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
        return bloc;
      },
      act: (bloc) => bloc.add(SearchRecipes(query: 'chicken')),
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
        return bloc;
      },
      act: (bloc) => bloc.add(SearchRecipes(query: 'chicken')),
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
        return bloc;
      },
      act: (bloc) {
        bloc.add(SearchRecipes(query: 'chicken'));
        bloc.add(LoadMoreRecipes(query: 'chicken', offset: 1));
      },
      expect: () => [
        isA<RecipesLoading>(),
        isA<RecipesLoaded>(),
        isA<RecipesLoaded>(),
      ],
    );

    blocTest<RecipesBloc, RecipesState>(
      'debe emitir Initial cuando ClearRecipes',
      build: () => bloc,
      seed: () => RecipesLoaded(recipes: testRecipes, query: 'chicken'),
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
