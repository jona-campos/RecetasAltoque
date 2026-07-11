import 'package:equatable/equatable.dart';

abstract class RecipesEvent extends Equatable {
  const RecipesEvent();

  @override
  List<Object?> get props => [];
}

class SearchRecipes extends RecipesEvent {
  final String query;
  final int offset;

  const SearchRecipes({
    required this.query,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [query, offset];
}

class LoadMoreRecipes extends RecipesEvent {
  final String query;
  final int offset;

  const LoadMoreRecipes({
    required this.query,
    required this.offset,
  });

  @override
  List<Object?> get props => [query, offset];
}

class ClearRecipes extends RecipesEvent {
  const ClearRecipes();
}
