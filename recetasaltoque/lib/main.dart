import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'firebase_options.dart';
import 'shared/services/firebase/firebase_service.dart';
import 'shared/services/cache/cache_service.dart';
import 'data/datasources/recipes_api/recipes_api_datasource.dart';
import 'data/datasources/libretranslate/libretranslate_datasource.dart';
import 'data/repositories_impl/recipe_repository_impl.dart';
import 'data/repositories_impl/translation_repository_impl.dart';
import 'domain/usecases/get_recipes.dart';
import 'domain/usecases/translate_text.dart';
import 'presentation/bloc/recipes/recipes_bloc.dart';
import 'presentation/bloc/translation/translation_bloc.dart';
import 'core/config/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  final translationRepository = TranslationRepositoryImpl(
    translationDatasource: libreTranslateDatasource,
    cacheService: cacheService.hybridCache,
  );

  final recipeRepository = RecipeRepositoryImpl(
    recipesDatasource: recipesDatasource,
    translationRepository: translationRepository,
  );

  final getRecipes = GetRecipes(recipeRepository);
  final translateText = TranslateText(translationRepository);

  runApp(MyApp(
    getRecipes: getRecipes,
    translateText: translateText,
  ));
}

class MyApp extends StatelessWidget {
  final GetRecipes getRecipes;
  final TranslateText translateText;

  const MyApp({
    super.key,
    required this.getRecipes,
    required this.translateText,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => RecipesBloc(getRecipes: getRecipes),
        ),
        BlocProvider(
          create: (context) => TranslationBloc(translateText: translateText),
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
        routerConfig: router,
      ),
    );
  }
}
