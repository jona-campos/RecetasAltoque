import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'shared/services/firebase/firebase_service.dart';
import 'shared/services/cache/cache_service.dart';
import 'data/datasources/recipes_api/recipes_api_datasource.dart';
import 'data/datasources/libretranslate/libretranslate_datasource.dart';
import 'data/datasources/auth/auth_service.dart';
import 'data/repositories_impl/recipe_repository_impl.dart';
import 'data/repositories_impl/translation_repository_impl.dart';
import 'data/repositories_impl/auth_repository_impl.dart';
import 'data/repositories_impl/local/recipe_local_repository_impl.dart';
import 'data/repositories_impl/recipe_synced_repository_impl.dart';
import 'data/datasources/recipes_firestore/recipes_firestore_datasource.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/get_recipes.dart';
import 'domain/usecases/translate_text.dart';
import 'domain/usecases/auth/sign_in_with_google.dart';
import 'domain/usecases/auth/sign_out.dart';
import 'domain/usecases/auth/get_current_user.dart';
import 'domain/usecases/recipe/get_recent_recipes.dart';
import 'domain/usecases/recipe/get_favorite_recipes.dart';
import 'domain/usecases/recipe/toggle_favorite.dart';
import 'domain/usecases/recipe/share_recipe.dart';
import 'domain/usecases/recipe/save_recent_recipe.dart';
import 'domain/usecases/recipe/remove_recent_recipe.dart';
import 'domain/usecases/recipe/clear_recent_recipes.dart';
import 'presentation/bloc/recipes/recipes_bloc.dart';
import 'presentation/bloc/translation/translation_bloc.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/home/home_bloc.dart';
import 'presentation/bloc/home/home_event.dart';
import 'core/config/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final firebaseService = await FirebaseService.initialize();
    final cacheService = await CacheService.initialize(
      firestore: firebaseService.firestore,
    );

    final httpClient = http.Client();

    final recipesDatasource = RecipesApiDatasourceImpl(httpClient: httpClient);
    final libreTranslateDatasource = LibreTranslateDatasourceImpl(httpClient: httpClient);

    final authService = AuthService();
    final authRepository = AuthRepositoryImpl(authService: authService);

    final translationRepository = TranslationRepositoryImpl(
      translationDatasource: libreTranslateDatasource,
      cacheService: cacheService.hybridCache,
    );

    final recipeRepository = RecipeRepositoryImpl(
      recipesDatasource: recipesDatasource,
      translationRepository: translationRepository,
    );

    final prefs = await SharedPreferences.getInstance();
    final localRepository = RecipeLocalRepositoryImpl(prefs: prefs);
    final firestoreDatasource = RecipesFirestoreDatasource(
      firestore: firebaseService.firestore,
    );
    final syncedRepository = RecipeSyncedRepositoryImpl(
      local: localRepository,
      remote: firestoreDatasource,
      auth: firebaseService.auth,
    );

    final getRecipes = GetRecipes(recipeRepository);
    final translateText = TranslateText(translationRepository);
    final signInWithGoogle = SignInWithGoogle(authRepository);
    final signOut = SignOut(authRepository);
    final getCurrentUser = GetCurrentUser(authRepository);
    final getRecentRecipes = GetRecentRecipes(syncedRepository);
    final getFavoriteRecipes = GetFavoriteRecipes(syncedRepository);
    final toggleFavorite = ToggleFavorite(syncedRepository);
    final shareRecipe = ShareRecipe();
    final saveRecentRecipe = SaveRecentRecipe(syncedRepository);
    final removeRecentRecipe = RemoveRecentRecipe(syncedRepository);
    final clearRecentRecipes = ClearRecentRecipes(syncedRepository);

    runApp(MyApp(
      getRecipes: getRecipes,
      translateText: translateText,
      signInWithGoogle: signInWithGoogle,
      signOut: signOut,
      getCurrentUser: getCurrentUser,
      authRepository: authRepository,
      getRecentRecipes: getRecentRecipes,
      getFavoriteRecipes: getFavoriteRecipes,
      toggleFavorite: toggleFavorite,
      shareRecipe: shareRecipe,
      saveRecentRecipe: saveRecentRecipe,
      removeRecentRecipe: removeRecentRecipe,
      clearRecentRecipes: clearRecentRecipes,
    ));
  } catch (e) {
    runApp(ErrorApp(error: e));
  }
}

class ErrorApp extends StatelessWidget {
  final Object error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  'Error al iniciar',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final GetRecipes getRecipes;
  final TranslateText translateText;
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  final AuthRepository authRepository;
  final GetRecentRecipes getRecentRecipes;
  final GetFavoriteRecipes getFavoriteRecipes;
  final ToggleFavorite toggleFavorite;
  final ShareRecipe shareRecipe;
  final SaveRecentRecipe saveRecentRecipe;
  final RemoveRecentRecipe removeRecentRecipe;
  final ClearRecentRecipes clearRecentRecipes;

  const MyApp({
    super.key,
    required this.getRecipes,
    required this.translateText,
    required this.signInWithGoogle,
    required this.signOut,
    required this.getCurrentUser,
    required this.authRepository,
    required this.getRecentRecipes,
    required this.getFavoriteRecipes,
    required this.toggleFavorite,
    required this.shareRecipe,
    required this.saveRecentRecipe,
    required this.removeRecentRecipe,
    required this.clearRecentRecipes,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => RecipesBloc(
            getRecipes: getRecipes,
            translateText: translateText,
          ),
        ),
        BlocProvider(
          create: (context) => TranslationBloc(translateText: translateText),
        ),
        BlocProvider(
          create: (context) => AuthBloc(
            signInWithGoogle: signInWithGoogle,
            signOut: signOut,
            getCurrentUser: getCurrentUser,
          ),
        ),
        BlocProvider(
          create: (context) {
            final bloc = HomeBloc(
              getRecentRecipes: getRecentRecipes,
              getFavoriteRecipes: getFavoriteRecipes,
              toggleFavorite: toggleFavorite,
              shareRecipe: shareRecipe,
              saveRecentRecipe: saveRecentRecipe,
              removeRecentRecipe: removeRecentRecipe,
              clearRecentRecipes: clearRecentRecipes,
            );
            bloc.add(const LoadRecentRecipes());
            return bloc;
          },
        ),
      ],
      child: MaterialApp.router(
        title: 'RecetasAltoque',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        routerConfig: router(authRepository),
      ),
    );
  }
}
