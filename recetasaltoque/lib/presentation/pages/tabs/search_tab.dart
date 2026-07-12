import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/recipes/recipes_bloc.dart';
import '../../bloc/recipes/recipes_event.dart';
import '../../bloc/recipes/recipes_state.dart';
import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../../bloc/home/home_state.dart';
import '../../widgets/search_bar_widget.dart';
import '../../../domain/entities/recipe.dart';

class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Buscar',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.deepOrange.shade800,
                letterSpacing: -0.5,
              ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocBuilder<RecipesBloc, RecipesState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SearchBarWidget(
                    onSearch: (query) {
                      context.read<RecipesBloc>().add(SearchRecipes(query: query));
                    },
                    hintText: 'Buscar recetas...',
                  ),
                ),
              ),
              if (state is RecipesInitial)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Populares esta semana',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.deepOrange.shade800,
                              ),
                        ),
                        const SizedBox(height: 12),
                        _buildSuggestionChips(context),
                        const SizedBox(height: 20),
                        _buildRecentRecipesSection(context),
                      ],
                    ),
                  ),
                ),
              if (state is RecipesLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.deepOrange),
                  ),
                ),
              if (state is RecipesLoaded) ...[
                if (state.recipes.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyResults(context),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildRecentRecipesSection(context),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.78,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final recipe = state.recipes[index];
                          return _SearchResultCard(recipe: recipe);
                        },
                        childCount: state.recipes.length,
                      ),
                  ),
                ),
                ],
                if (state.hasMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                  ),
              ] else if (state is RecipesError)
                SliverFillRemaining(
                  child: _ErrorState(message: state.message),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSuggestionChips(BuildContext context) {
    final suggestions = ['Pasta', 'Pollo', 'Ensaladas', 'Postres', 'Vegano', 'Rápido'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions.map((label) {
        return ActionChip(
          label: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.deepOrange.shade700,
            ),
          ),
          backgroundColor: Colors.deepOrange.shade50,
          side: BorderSide(
            color: Colors.deepOrange.shade200,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          onPressed: () {
            context.read<RecipesBloc>().add(SearchRecipes(query: label));
          },
        );
      }).toList(),
    );
  }

  Widget _buildRecentRecipesSection(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoaded) return const SizedBox.shrink();

        final recentRecipes = state.recentRecipes;
        if (recentRecipes.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recetas recientes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.deepOrange.shade800,
                  ),
            ),
            const SizedBox(height: 12),
            ...recentRecipes.take(3).map((recipe) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => context.push(
                    '/recipe/${Uri.encodeComponent(recipe.title)}',
                    extra: recipe,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.deepOrange.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.deepOrange.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.restaurant_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            recipe.displayTitle,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.deepOrange.shade800,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.deepOrange.shade400,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildEmptyResults(BuildContext context) {
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
                Icons.search_off_rounded,
                size: 60,
                color: Colors.deepOrange.shade300,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sin resultados',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.deepOrange.shade700,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Prueba con otros ingredientes\no términos de búsqueda',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<RecipesBloc>().add(const ClearRecipes());
              },
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
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text(
                'Limpiar búsqueda',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final Recipe recipe;

  const _SearchResultCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          onTap: () {
            context.read<HomeBloc>().add(SaveRecentRecipeEvent(recipe));
            context.push(
              '/recipe/${Uri.encodeComponent(recipe.title)}',
              extra: recipe,
            );
          },
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
                      Colors.deepOrange.shade100,
                      Colors.deepOrange.shade300,
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
                          size: 12,
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
                        const Spacer(),
                        Icon(
                          Icons.timer_rounded,
                          size: 12,
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
                          alignment: Alignment.centerRight,
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isFavorite
                                          ? 'Eliminado de favoritos'
                                          : 'Agregado a favoritos',
                                    ),
                                    backgroundColor: isFavorite
                                        ? Colors.grey.shade600
                                        : Colors.deepOrange.shade700,
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                );
                              },
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                transitionBuilder: (child, animation) =>
                                    ScaleTransition(
                                      scale: animation,
                                      child: RotationTransition(
                                        turns: Tween(begin: -0.125, end: 0.0)
                                            .animate(CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.elasticOut,
                                        )),
                                        child: child,
                                      ),
                                    ),
                                child: Icon(
                                  isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  key: ValueKey(isFavorite),
                                  color: isFavorite
                                      ? Colors.deepOrange.shade700
                                      : Colors.deepOrange,
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
              onPressed: () {},
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
