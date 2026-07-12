import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/recipes/recipes_bloc.dart';
import '../bloc/recipes/recipes_event.dart';
import '../bloc/recipes/recipes_state.dart';
import '../widgets/recipe_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_widget.dart';
import '../widgets/search_bar_widget.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<RecipesBloc>().add(SearchRecipes(query: widget.initialQuery!));
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<RecipesBloc>().state;
      if (state is RecipesLoaded && state.hasMore) {
        context.read<RecipesBloc>().add(LoadMoreRecipes(
              query: state.query,
              translatedQuery: state.translatedQuery,
              offset: state.recipes.length,
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Recetas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          SearchBarWidget(
            onSearch: (query) {
              context.read<RecipesBloc>().add(SearchRecipes(query: query));
            },
          ),
          Expanded(
            child: BlocBuilder<RecipesBloc, RecipesState>(
              builder: (context, state) {
                if (state is RecipesInitial) {
                  return const Center(
                    child: Text('Escribe para buscar recetas'),
                  );
                }

                if (state is RecipesLoading) {
                  return const LoadingIndicator(message: 'Buscando recetas...');
                }

                if (state is RecipesError) {
                  return ErrorDisplayWidget(
                    message: state.message,
                    onRetry: () {
                      final currentState = context.read<RecipesBloc>().state;
                      if (currentState is RecipesLoaded) {
                        context.read<RecipesBloc>().add(SearchRecipes(query: currentState.query));
                      }
                    },
                  );
                }

                if (state is RecipesLoaded) {
                  if (state.recipes.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron recetas'),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: state.recipes.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.recipes.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final recipe = state.recipes[index];
                      return RecipeCard(
                        recipe: recipe,
                        onTap: () {
                          context.push('/recipe/${Uri.encodeComponent(recipe.title)}', extra: recipe);
                        },
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
