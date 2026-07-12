import 'package:equatable/equatable.dart';
import '../../../domain/entities/recipe.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecentRecipes extends HomeEvent {
  const LoadRecentRecipes();
}

class LoadFavoriteRecipes extends HomeEvent {
  const LoadFavoriteRecipes();
}

class ToggleFavoriteRequested extends HomeEvent {
  final Recipe recipe;

  const ToggleFavoriteRequested(this.recipe);

  @override
  List<Object?> get props => [recipe];
}

class ShareRecipeRequested extends HomeEvent {
  final Recipe recipe;

  const ShareRecipeRequested(this.recipe);

  @override
  List<Object?> get props => [recipe];
}

class RemoveRecentRecipeRequested extends HomeEvent {
  final String recipeId;

  const RemoveRecentRecipeRequested(this.recipeId);

  @override
  List<Object?> get props => [recipeId];
}

class ClearRecentRecipesRequested extends HomeEvent {
  const ClearRecentRecipesRequested();
}

class SaveRecentRecipeEvent extends HomeEvent {
  final Recipe recipe;

  const SaveRecentRecipeEvent(this.recipe);

  @override
  List<Object?> get props => [recipe];
}