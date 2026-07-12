import 'package:equatable/equatable.dart';

abstract class RecipesEvent extends Equatable {
  const RecipesEvent();

  @override
  List<Object?> get props => [];
}

class SearchRecipes extends RecipesEvent {
  final String query;
  final String? translatedQuery;
  final int offset;

  const SearchRecipes({
    required this.query,
    this.translatedQuery,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [query, translatedQuery, offset];
}

class LoadMoreRecipes extends RecipesEvent {
  final String query;
  final String? translatedQuery;
  final int offset;

  const LoadMoreRecipes({
    required this.query,
    this.translatedQuery,
    required this.offset,
  });

  @override
  List<Object?> get props => [query, translatedQuery, offset];
}

class ClearRecipes extends RecipesEvent {
  const ClearRecipes();
}
