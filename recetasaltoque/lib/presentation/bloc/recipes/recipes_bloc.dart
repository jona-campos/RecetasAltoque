import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_recipes.dart';
import '../../../domain/usecases/translate_text.dart';
import 'recipes_event.dart';
import 'recipes_state.dart';

class RecipesBloc extends Bloc<RecipesEvent, RecipesState> {
  final GetRecipes getRecipes;
  final TranslateText translateText;

  RecipesBloc({
    required this.getRecipes,
    required this.translateText,
  }) : super(const RecipesInitial()) {
    on<SearchRecipes>(_onSearchRecipes);
    on<LoadMoreRecipes>(_onLoadMoreRecipes);
    on<ClearRecipes>(_onClearRecipes);
  }

  Future<void> _onSearchRecipes(
    SearchRecipes event,
    Emitter<RecipesState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(const RecipesInitial());
      return;
    }

    emit(const RecipesLoading());

    try {
      // Translate query from Spanish to English for API search
      String searchQuery = event.query;
      String? translatedQuery;
      
      if (event.translatedQuery == null) {
        try {
          final translated = await translateText(event.query, from: 'es', to: 'en');
          translatedQuery = translated;
          searchQuery = translated;
        } catch (e) {
          // If translation fails, use original query
          translatedQuery = null;
        }
      } else {
        translatedQuery = event.translatedQuery;
        searchQuery = translatedQuery!;
      }

      final recipes = await getRecipes(searchQuery, offset: event.offset);
      emit(RecipesLoaded(
        recipes: recipes,
        hasMore: recipes.length >= 10,
        query: event.query,
        translatedQuery: translatedQuery,
      ));
    } catch (e) {
      emit(RecipesError(message: e.toString()));
    }
  }

  Future<void> _onLoadMoreRecipes(
    LoadMoreRecipes event,
    Emitter<RecipesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! RecipesLoaded) return;

    try {
      // Use translated query from state if available
      final searchQuery = currentState.translatedQuery ?? event.translatedQuery ?? event.query;
      
      final newRecipes = await getRecipes(searchQuery, offset: event.offset);
      emit(RecipesLoaded(
        recipes: [...currentState.recipes, ...newRecipes],
        hasMore: newRecipes.length >= 10,
        query: event.query,
        translatedQuery: currentState.translatedQuery ?? event.translatedQuery,
      ));
    } catch (e) {
      emit(RecipesError(message: e.toString()));
    }
  }

  void _onClearRecipes(
    ClearRecipes event,
    Emitter<RecipesState> emit,
  ) {
    emit(const RecipesInitial());
  }
}
