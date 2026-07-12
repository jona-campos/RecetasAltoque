import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../domain/usecases/recipe/get_recent_recipes.dart';
import '../../../domain/usecases/recipe/get_favorite_recipes.dart';
import '../../../domain/usecases/recipe/toggle_favorite.dart';
import '../../../domain/usecases/recipe/share_recipe.dart';
import '../../../domain/usecases/recipe/save_recent_recipe.dart';
import '../../../domain/usecases/recipe/remove_recent_recipe.dart';
import '../../../domain/usecases/recipe/clear_recent_recipes.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetRecentRecipes getRecentRecipes;
  final GetFavoriteRecipes getFavoriteRecipes;
  final ToggleFavorite toggleFavorite;
  final ShareRecipe shareRecipe;
  final SaveRecentRecipe saveRecentRecipe;
  final RemoveRecentRecipe removeRecentRecipe;
  final ClearRecentRecipes clearRecentRecipes;
  final Set<String> _pendingToggleIds = {};

  HomeBloc({
    required this.getRecentRecipes,
    required this.getFavoriteRecipes,
    required this.toggleFavorite,
    required this.shareRecipe,
    required this.saveRecentRecipe,
    required this.removeRecentRecipe,
    required this.clearRecentRecipes,
  }) : super(const HomeInitial()) {
    on<LoadRecentRecipes>(_onLoadRecentRecipes);
    on<LoadFavoriteRecipes>(_onLoadFavoriteRecipes);
    on<ToggleFavoriteRequested>(_onToggleFavorite);
    on<ShareRecipeRequested>(_onShareRecipe);
    on<SaveRecentRecipeEvent>(_onSaveRecentRecipe);
    on<RemoveRecentRecipeRequested>(_onRemoveRecentRecipe);
    on<ClearRecentRecipesRequested>(_onClearRecentRecipes);
  }

  Future<void> _onLoadRecentRecipes(
    LoadRecentRecipes event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      final recentRecipes = await getRecentRecipes();
      final favoriteRecipes = await getFavoriteRecipes();
      emit(HomeLoaded(
        recentRecipes: recentRecipes,
        favoriteRecipes: favoriteRecipes,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onLoadFavoriteRecipes(
    LoadFavoriteRecipes event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final favoriteRecipes = await getFavoriteRecipes();
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        emit(HomeLoaded(
          recentRecipes: currentState.recentRecipes,
          favoriteRecipes: favoriteRecipes,
        ));
      }
    } catch (e) {
      // Keep current state or show error
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteRequested event,
    Emitter<HomeState> emit,
  ) async {
    if (!_pendingToggleIds.add(event.recipe.id)) return;
    try {
      await toggleFavorite.execute(event.recipe);

      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        final updatedFavorites = await getFavoriteRecipes();

        emit(HomeLoaded(
          recentRecipes: currentState.recentRecipes,
          favoriteRecipes: updatedFavorites,
        ));
      }
    } catch (e) {
      // Handle error
    } finally {
      _pendingToggleIds.remove(event.recipe.id);
    }
  }

  Future<void> _onShareRecipe(
    ShareRecipeRequested event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final content = await shareRecipe.execute(event.recipe);
      await Share.share(content, subject: event.recipe.displayTitle);
    } catch (e) {
      // Handle error - could emit a snackbar message
    }
  }

  Future<void> _onSaveRecentRecipe(
    SaveRecentRecipeEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      await saveRecentRecipe(event.recipe);
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        final updatedRecent = await getRecentRecipes();
        emit(HomeLoaded(
          recentRecipes: updatedRecent,
          favoriteRecipes: currentState.favoriteRecipes,
        ));
      }
    } catch (e) {
      // silently fail
    }
  }

  Future<void> _onRemoveRecentRecipe(
    RemoveRecentRecipeRequested event,
    Emitter<HomeState> emit,
  ) async {
    try {
      await removeRecentRecipe.call(event.recipeId);
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        emit(HomeLoaded(
          recentRecipes: currentState.recentRecipes.where((r) => r.id != event.recipeId).toList(),
          favoriteRecipes: currentState.favoriteRecipes,
        ));
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _onClearRecentRecipes(
    ClearRecentRecipesRequested event,
    Emitter<HomeState> emit,
  ) async {
    try {
      await clearRecentRecipes.call();
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        emit(HomeLoaded(
          recentRecipes: [],
          favoriteRecipes: currentState.favoriteRecipes,
        ));
      }
    } catch (e) {
      // Handle error
    }
  }
}