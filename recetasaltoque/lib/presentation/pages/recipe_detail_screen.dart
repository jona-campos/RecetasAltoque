import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/recipe.dart';
import '../../presentation/bloc/translation/translation_bloc.dart';
import '../../presentation/bloc/translation/translation_event.dart';
import '../../presentation/bloc/home/home_bloc.dart';
import '../../presentation/bloc/home/home_event.dart';
import '../../presentation/bloc/home/home_state.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.displayTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Compartir receta',
            onPressed: () {
              context.read<HomeBloc>().add(ShareRecipeRequested(recipe));
            },
          ),
          if (!recipe.isTranslated)
            IconButton(
              icon: const Icon(Icons.translate, color: Colors.orange),
              tooltip: 'Reintentar traducción',
              onPressed: () => _retryTranslation(context),
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.people, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              '${recipe.servings} porciones',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  context: context,
                  title: 'Ingredientes',
                  content: recipe.displayIngredients,
                  isTranslated: recipe.ingredientsEs != null,
                  onRetry: () => _retryFieldTranslation(
                    context, recipe.ingredients, 'ingredients'),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  context: context,
                  title: 'Instrucciones',
                  content: recipe.displayInstructions,
                  isTranslated: recipe.instructionsEs != null,
                  onRetry: () => _retryFieldTranslation(
                    context, recipe.instructions, 'instructions'),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                final isFavorite = state is HomeLoaded &&
                    state.favoriteRecipes.any((r) => r.id == recipe.id);
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                        size: 26,
                      ),
                    ),
                    tooltip: isFavorite
                        ? 'Quitar de favoritos'
                        : 'Agregar a favoritos',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required String content,
    required bool isTranslated,
    required VoidCallback onRetry,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (!isTranslated) ...[
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Traducción no disponible. Toca para reintentar.',
                    child: InkWell(
                      onTap: onRetry,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.translate,
                          size: 18,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  void _retryTranslation(BuildContext context) {
    context.read<TranslationBloc>().add(TranslateTextEvent(
      text: '${recipe.title}\n${recipe.ingredients}\n${recipe.instructions}',
      from: 'en',
      to: 'es',
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reintentando traducción...')),
    );
  }

  void _retryFieldTranslation(BuildContext context, String text, String field) {
    context.read<TranslationBloc>().add(TranslateTextEvent(
      text: text,
      from: 'en',
      to: 'es',
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reintentando traducción de $field...')),
    );
  }
}
