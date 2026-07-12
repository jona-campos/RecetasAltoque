import 'package:equatable/equatable.dart';
import '../../../domain/entities/recipe.dart';

abstract class RecipesState extends Equatable {
  const RecipesState();

  @override
  List<Object?> get props => [];
}

class RecipesInitial extends RecipesState {
  const RecipesInitial();
}

class RecipesLoading extends RecipesState {
  const RecipesLoading();
}

class RecipesLoaded extends RecipesState {
  final List<Recipe> recipes;
  final bool hasMore;
  final String query;
  final String? translatedQuery;

  const RecipesLoaded({
    required this.recipes,
    this.hasMore = true,
    required this.query,
    this.translatedQuery,
  });

  @override
  List<Object?> get props => [recipes, hasMore, query, translatedQuery];
}

class RecipesError extends RecipesState {
  final String message;

  const RecipesError({required this.message});

  @override
  List<Object?> get props => [message];
}
