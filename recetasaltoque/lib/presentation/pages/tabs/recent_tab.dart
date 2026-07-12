import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../../bloc/home/home_state.dart';
import '../../../domain/entities/recipe.dart';

class RecentTab extends StatelessWidget {
  const RecentTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const _RecentSkeleton();
        }

        if (state is HomeLoaded) {
          final recentRecipes = state.recentRecipes;

          if (recentRecipes.isEmpty) {
            return const _EmptyRecentState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              final bloc = context.read<HomeBloc>();
              bloc.add(const LoadRecentRecipes());
              await bloc.stream.firstWhere(
                (s) => s is HomeLoaded || s is HomeError,
              );
            },
            color: Colors.deepOrange.shade700,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Row(
                      children: [
                        Text(
                          'Recientes',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.deepOrange.shade800,
                                letterSpacing: -0.5,
                              ),
                        ),
                        const Spacer(),
                        if (state.recentRecipes.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              showDialog<bool>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: Text(
                                    'Limpiar historial',
                                    style: TextStyle(
                                      color: Colors.deepOrange.shade800,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  content: Text(
                                    '¿Eliminar todo tu historial de búsquedas?',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(dialogContext, false),
                                      child: Text(
                                        'Cancelar',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(dialogContext, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepOrange.shade600,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text('Limpiar todo'),
                                    ),
                                  ],
                                ),
                              ).then((confirmed) {
                                if (confirmed == true && context.mounted) {
                                  context.read<HomeBloc>().add(const ClearRecentRecipesRequested());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Historial limpiado'),
                                      backgroundColor: Colors.deepOrange.shade700,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  );
                                }
                              });
                            },
                            icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                            label: const Text('Limpiar'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.deepOrange.shade600,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final recipe = state.recentRecipes[index];
                        return Dismissible(
                          key: ValueKey(recipe.id),
                          direction: DismissDirection.endToStart,
                          background: _buildDismissBackground(),
                          confirmDismiss: (direction) async {
                            return showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: Text(
                                  'Eliminar de recientes',
                                  style: TextStyle(
                                    color: Colors.deepOrange.shade800,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                content: Text(
                                  '¿Eliminar "${recipe.displayTitle}" de tu historial?',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogContext, false),
                                    child: Text(
                                      'Cancelar',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(dialogContext, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade600,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            ).then((confirmed) => confirmed ?? false);
                          },
                          onDismissed: (direction) {
                            context.read<HomeBloc>().add(
                              RemoveRecentRecipeRequested(recipe.id),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '"${recipe.displayTitle}" eliminado',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                backgroundColor: Colors.deepOrange.shade700,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            );
                          },
                          child: _RecentRecipeCard(recipe: recipe),
                        );
                      },
                      childCount: state.recentRecipes.length,
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

  static Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Text(
            'Eliminar',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _RecentRecipeCard extends StatelessWidget {
  final Recipe recipe;

  const _RecentRecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withValues(alpha: 0.06),
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
          color: Colors.deepOrange.withValues(alpha: 0.08),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.deepOrange.shade100,
                        Colors.deepOrange.shade300,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepOrange.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.restaurant_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.displayTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.deepOrange.shade800,
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
                            size: 14,
                            color: Colors.deepOrange.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${recipe.servings} porciones',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.deepOrange.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.timer_rounded,
                            size: 14,
                            color: Colors.deepOrange.shade300,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '~25 min',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.deepOrange.shade300,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<HomeBloc, HomeState>(
                        builder: (context, state) {
                          final isFavorite = state is HomeLoaded &&
                              state.favoriteRecipes.any((r) => r.id == recipe.id);

                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.deepOrange.shade50,
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
                                    isFavorite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    key: ValueKey(isFavorite),
                                    color: Colors.deepOrange.shade600,
                                    size: 22,
                                  ),
                                ),
                                tooltip: isFavorite
                                    ? 'Quitar de favoritos'
                                    : 'Agregar a favoritos',
                                iconSize: 22,
                                padding: const EdgeInsets.all(10),
                                color: Colors.deepOrange.shade100,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentSkeleton extends StatelessWidget {
  const _RecentSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRecentState extends StatelessWidget {
  const _EmptyRecentState();

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
                color: Colors.deepOrange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_rounded,
                size: 60,
                color: Colors.deepOrange.shade300,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Historial vacío',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.deepOrange.shade700,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tus búsquedas recientes aparecerán aquí\npara acceso rápido',
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
                backgroundColor: Colors.deepOrange.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 4,
                shadowColor: Colors.deepOrange.withValues(alpha: 0.4),
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
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<HomeBloc>().add(const LoadRecentRecipes()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange.shade600,
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
