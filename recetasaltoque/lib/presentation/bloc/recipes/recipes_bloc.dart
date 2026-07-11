import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_recipes.dart';
import 'recipes_event.dart';
import 'recipes_state.dart';

class RecipesBloc extends Bloc<RecipesEvent, RecipesState> {
  final GetRecipes getRecipes;

  RecipesBloc({required this.getRecipes}) : super(const RecipesInitial()) {
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
      final recipes = await getRecipes(event.query, offset: event.offset);
      emit(RecipesLoaded(
        recipes: recipes,
        hasMore: recipes.length >= 10,
        query: event.query,
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
      final newRecipes = await getRecipes(event.query, offset: event.offset);
      emit(RecipesLoaded(
        recipes: [...currentState.recipes, ...newRecipes],
        hasMore: newRecipes.length >= 10,
        query: event.query,
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
