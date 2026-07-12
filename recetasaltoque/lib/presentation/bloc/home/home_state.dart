import 'package:equatable/equatable.dart';
import '../../../domain/entities/recipe.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<Recipe> recentRecipes;
  final List<Recipe> favoriteRecipes;

  const HomeLoaded({
    required this.recentRecipes,
    required this.favoriteRecipes,
  });

  @override
  List<Object?> get props => [recentRecipes, favoriteRecipes];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}