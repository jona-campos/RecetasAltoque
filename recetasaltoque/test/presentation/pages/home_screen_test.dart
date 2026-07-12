import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recetasaltoque/domain/usecases/get_recipes.dart';
import 'package:recetasaltoque/domain/usecases/translate_text.dart';
import 'package:recetasaltoque/domain/usecases/recipe/get_recent_recipes.dart';
import 'package:recetasaltoque/domain/usecases/recipe/get_favorite_recipes.dart';
import 'package:recetasaltoque/domain/usecases/recipe/toggle_favorite.dart';
import 'package:recetasaltoque/domain/usecases/recipe/share_recipe.dart';
import 'package:recetasaltoque/domain/usecases/recipe/save_recent_recipe.dart';
import 'package:recetasaltoque/domain/usecases/recipe/remove_recent_recipe.dart';
import 'package:recetasaltoque/domain/usecases/recipe/clear_recent_recipes.dart';
import 'package:recetasaltoque/domain/usecases/auth/sign_in_with_google.dart';
import 'package:recetasaltoque/domain/usecases/auth/sign_out.dart';
import 'package:recetasaltoque/domain/usecases/auth/get_current_user.dart';
import 'package:recetasaltoque/presentation/bloc/recipes/recipes_bloc.dart';
import 'package:recetasaltoque/presentation/bloc/home/home_bloc.dart';
import 'package:recetasaltoque/presentation/bloc/auth/auth_bloc.dart';
import 'package:recetasaltoque/presentation/pages/home_screen.dart';

class MockGetRecipes extends Mock implements GetRecipes {}
class MockTranslateText extends Mock implements TranslateText {}
class MockGetRecentRecipes extends Mock implements GetRecentRecipes {}
class MockGetFavoriteRecipes extends Mock implements GetFavoriteRecipes {}
class MockToggleFavorite extends Mock implements ToggleFavorite {}
class MockShareRecipe extends Mock implements ShareRecipe {}
class MockSaveRecentRecipe extends Mock implements SaveRecentRecipe {}
class MockRemoveRecentRecipe extends Mock implements RemoveRecentRecipe {}
class MockClearRecentRecipes extends Mock implements ClearRecentRecipes {}
class MockSignInWithGoogle extends Mock implements SignInWithGoogle {}
class MockSignOut extends Mock implements SignOut {}
class MockGetCurrentUser extends Mock implements GetCurrentUser {}

void main() {
  late MockGetRecipes mockGetRecipes;

  setUp(() {
    mockGetRecipes = MockGetRecipes();
    when(() => mockGetRecipes(any(), offset: any(named: 'offset'))).thenAnswer((_) async => []);
  });

  Widget createHomeScreen() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => RecipesBloc(
              getRecipes: mockGetRecipes,
              translateText: MockTranslateText(),
            ),
          ),
          BlocProvider(
            create: (context) => HomeBloc(
              getRecentRecipes: MockGetRecentRecipes(),
              getFavoriteRecipes: MockGetFavoriteRecipes(),
              toggleFavorite: MockToggleFavorite(),
              shareRecipe: MockShareRecipe(),
              saveRecentRecipe: MockSaveRecentRecipe(),
              removeRecentRecipe: MockRemoveRecentRecipe(),
              clearRecentRecipes: MockClearRecentRecipes(),
            ),
          ),
          BlocProvider(
            create: (context) => AuthBloc(
              signInWithGoogle: MockSignInWithGoogle(),
              signOut: MockSignOut(),
              getCurrentUser: MockGetCurrentUser(),
            ),
          ),
        ],
        child: const HomeScreen(),
      ),
    );
  }

  testWidgets('HomeScreen debe renderizar con navegacion de tabs', (tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Recientes'), findsOneWidget);
    expect(find.text('Favoritos'), findsOneWidget);
    expect(find.text('Buscar'), findsOneWidget);
  });

  testWidgets('HomeScreen debe tener 3 tabs navegables', (tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    expect(find.byType(PageView), findsOneWidget);
  });

  testWidgets('HomeScreen debe mostrar titulo Recientes en el tab inicial', (tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    expect(find.text('Recientes'), findsWidgets);
  });
}
