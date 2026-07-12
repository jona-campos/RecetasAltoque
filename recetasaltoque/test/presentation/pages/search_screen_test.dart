import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recetasaltoque/domain/entities/recipe.dart';
import 'package:recetasaltoque/domain/usecases/get_recipes.dart';
import 'package:recetasaltoque/domain/usecases/translate_text.dart';
import 'package:recetasaltoque/presentation/bloc/recipes/recipes_bloc.dart';
import 'package:recetasaltoque/presentation/bloc/recipes/recipes_state.dart';
import 'package:recetasaltoque/presentation/pages/search_screen.dart';

class MockGetRecipes extends Mock implements GetRecipes {}
class MockTranslateText extends Mock implements TranslateText {}

void main() {
  late MockGetRecipes mockGetRecipes;

  setUp(() {
    mockGetRecipes = MockGetRecipes();
  });

  Widget createSearchScreen({RecipesState? initialState}) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) {
          final bloc = RecipesBloc(
            getRecipes: mockGetRecipes,
            translateText: MockTranslateText(),
          );
          if (initialState != null) {
            // Simular estado inicial
          }
          return bloc;
        },
        child: const SearchScreen(),
      ),
    );
  }

  testWidgets('SearchScreen debe renderizar barra de busqueda', (tester) async {
    await tester.pumpWidget(createSearchScreen());

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets('SearchScreen debe tener boton de regreso', (tester) async {
    await tester.pumpWidget(createSearchScreen());

    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('SearchScreen debe mostrar titulo', (tester) async {
    await tester.pumpWidget(createSearchScreen());

    expect(find.text('Buscar Recetas'), findsOneWidget);
  });

  testWidgets('SearchScreen debe mostrar mensaje inicial', (tester) async {
    await tester.pumpWidget(createSearchScreen());

    expect(find.text('Escribe para buscar recetas'), findsOneWidget);
  });
}
