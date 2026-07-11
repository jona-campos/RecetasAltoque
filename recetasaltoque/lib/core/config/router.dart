import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/recipe.dart';
import '../../presentation/pages/home_screen.dart';
import '../../presentation/pages/search_screen.dart';
import '../../presentation/pages/recipe_detail_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/search',
      name: 'search',
      pageBuilder: (context, state) {
        final query = state.uri.queryParameters['q'] ?? '';
        return CustomTransitionPage(
          child: SearchScreen(initialQuery: query),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/recipe/:name',
      name: 'recipe',
      pageBuilder: (context, state) {
        final recipe = state.extra as Recipe?;
        if (recipe == null) {
          return CustomTransitionPage(
            child: const Scaffold(
              body: Center(child: Text('Receta no encontrada')),
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return child;
            },
          );
        }
        return CustomTransitionPage(
          child: RecipeDetailScreen(recipe: recipe),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
        );
      },
    ),
  ],
);
