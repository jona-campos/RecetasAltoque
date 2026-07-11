import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recetasaltoque/domain/usecases/get_recipes.dart';
import 'package:recetasaltoque/presentation/bloc/recipes/recipes_bloc.dart';
import 'package:recetasaltoque/presentation/pages/home_screen.dart';

class MockGetRecipes extends Mock implements GetRecipes {}

void main() {
  late MockGetRecipes mockGetRecipes;

  setUp(() {
    mockGetRecipes = MockGetRecipes();
  });

  Widget createHomeScreen() {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => RecipesBloc(getRecipes: mockGetRecipes),
        child: const HomeScreen(),
      ),
    );
  }

  testWidgets('HomeScreen debe renderizar barra de busqueda', (tester) async {
    await tester.pumpWidget(createHomeScreen());

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets('HomeScreen debe mostrar titulo', (tester) async {
    await tester.pumpWidget(createHomeScreen());

    expect(find.text('RecetasAltoque'), findsOneWidget);
  });

  testWidgets('HomeScreen debe mostrar mensaje de bienvenida', (tester) async {
    await tester.pumpWidget(createHomeScreen());

    expect(find.text('Busca tu receta favorita'), findsOneWidget);
    expect(find.text('Ejemplo: pasta, pollo, ensalada...'), findsOneWidget);
  });

  testWidgets('HomeScreen debe tener icono de restaurante', (tester) async {
    await tester.pumpWidget(createHomeScreen());

    expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
  });
}
