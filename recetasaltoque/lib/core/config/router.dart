import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../presentation/pages/home_screen.dart';
import '../../presentation/pages/search_screen.dart';
import '../../presentation/pages/recipe_detail_screen.dart';
import '../../presentation/pages/auth/login_screen.dart';

GoRouter router(AuthRepository authRepository) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authRepository.getCurrentUser() != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }
      if (isLoggedIn && isLoggingIn) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      ),
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
          final recipe = state.extra;
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
            child: RecipeDetailScreen(recipe: recipe as dynamic),
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
}
