import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../../bloc/home/home_state.dart';
import '../../../domain/entities/recipe.dart';

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const _FavoritesSkeleton();
        }

        if (state is HomeLoaded) {
          final favorites = state.favoriteRecipes;

          if (favorites.isEmpty) {
            return const _EmptyFavoritesState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(const LoadFavoriteRecipes());
            },
            color: Colors.deepOrange.shade700,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      children: [
                        Text(
                          'Favoritos',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.deepOrange.shade800,
                                letterSpacing: -0.5,
                              ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${state.favoriteRecipes.length}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.deepOrange.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.78,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final recipe = state.favoriteRecipes[index];
                        return _FavoriteRecipeCard(recipe: recipe);
                      },
                      childCount: state.favoriteRecipes.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is HomeError) {
          return _ErrorState(message: state.message);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _FavoritesSkeleton extends StatelessWidget {
  const _FavoritesSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _EmptyFavoritesState extends StatelessWidget {
  const _EmptyFavoritesState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_rounded,
                size: 60,
                color: Colors.pink.shade300,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sin favoritos aún',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.pink.shade700,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Toca el corazón en cualquier receta\ny aparecerá aquí para acceso rápido',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push('/search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 4,
                shadowColor: Colors.pink.withValues(alpha: 0.4),
              ),
              icon: const Icon(Icons.search_rounded, size: 22),
              label: const Text(
                'Buscar recetas',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 50,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Algo salió mal',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<HomeBloc>().add(const LoadFavoriteRecipes()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Reintentar', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteRecipeCard extends StatelessWidget {
  final Recipe recipe;

  const _FavoriteRecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.pink.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(
            '/recipe/${Uri.encodeComponent(recipe.title)}',
            extra: recipe,
          ),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.pink.shade100,
                      Colors.pink.shade300,
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.restaurant_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.displayTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.pink.shade800,
                            letterSpacing: -0.3,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.people_rounded,
                          size: 12,
                          color: Colors.pink.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.servings} porciones',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.pink.shade400,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.timer_rounded,
                          size: 12,
                          color: Colors.pink.shade300,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '~25 min',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.pink.shade300,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {
                            context.read<HomeBloc>().add(
                              ToggleFavoriteRequested(recipe),
                            );
                          },
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, animation) => ScaleTransition(
                              scale: animation,
                              child: RotationTransition(
                                turns: Tween(begin: -0.125, end: 0.0).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.elasticOut,
                                  ),
                                ),
                                child: child,
                              ),
                            ),
                            child: Icon(
                              Icons.favorite_rounded,
                              key: const ValueKey(true),
                              color: Colors.pink.shade600,
                              size: 22,
                            ),
                          ),
                          tooltip: 'Quitar de favoritos',
                          iconSize: 22,
                          padding: const EdgeInsets.all(10),
                          color: Colors.pink.shade100,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
