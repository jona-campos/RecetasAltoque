# Plan: Fixes Post-Animation

## Issue 1: Favoritos duplicados (al tocar rápido)

**Diagnóstico**: El handler `_onToggleFavorite` ya recarga desde el repositorio después del toggle, pero al tocar el corazón muy rápido se encolan dos eventos. El primero escribe en SharedPreferences, el segundo lee `isFavorite` antes de que la escritura del primero se refleje en disco → ambos ven `false` → ambos guardan → duplicado.

**Solución**: Agregar `Set<String> _pendingToggleIds` como guarda en el BLoC para ignorar toggles concurrentes del mismo `recipeId`.

**Archivo**: `lib/presentation/bloc/home/home_bloc.dart`

```dart
final Set<String> _pendingToggleIds = {};

Future<void> _onToggleFavorite(ToggleFavoriteRequested event, Emitter<HomeState> emit) async {
  if (!_pendingToggleIds.add(event.recipe.id)) return;
  try {
    await toggleFavorite.execute(event.recipe);
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final updatedFavorites = await getFavoriteRecipes();
      emit(HomeLoaded(recentRecipes: currentState.recentRecipes, favoriteRecipes: updatedFavorites));
    }
  } catch (e) { /* manejar error */ } finally {
    _pendingToggleIds.remove(event.recipe.id);
  }
}
```

---

## Issue 2: Búsquedas recientes no se actualizan

**Diagnóstico**: `_onSaveRecentRecipe` guarda en repo y emite nuevo `HomeLoaded`. Al salir de `/recipe/...` y volver, el estado del `HomeBloc` que ve la UI puede estar desactualizado si no se refresca.

**Solución**: En `_onPageChanged` del `HomeScreen`, refrescar recents en cualquier cambio de tab, no solo al tab 0.

**Archivo**: `lib/presentation/pages/home_screen.dart`

```dart
void _onPageChanged(int index) {
  if (index != _currentIndex) {
    setState(() => _currentIndex = index);
    context.read<HomeBloc>().add(const LoadRecentRecipes());
    if (index == 1) {
      context.read<HomeBloc>().add(const LoadFavoriteRecipes());
    }
  }
}
```

---

## Issue 3: Pull-to-refresh en RecentTab no actualiza visualmente

**Diagnóstico**: `RefreshIndicator.onRefresh` dispara `LoadRecentRecipes` pero retorna inmediatamente sin esperar a que el BLoC termine.

**Solución**: Hacer `onRefresh` async y esperar el nuevo estado del stream.

**Archivo**: `lib/presentation/pages/tabs/recent_tab.dart`

```dart
onRefresh: () async {
  final bloc = context.read<HomeBloc>();
  bloc.add(const LoadRecentRecipes());
  await bloc.stream.firstWhere((s) => s is HomeLoaded || s is HomeError);
},
```

---

## Issue 4: FAB "Buscar recetas" tapa la barra de navegación

**Diagnóstico**: `FloatingActionButton.extended` en `home_screen.dart` con `centerDocked` se superpone al BottomNavigationBar en pantallas pequeñas.

**Solución**: Agregar `Padding(bottom: 16)`.

**Archivo**: `lib/presentation/pages/home_screen.dart`

```
-floatingActionButton: _buildFloatingActionButton(),
+floatingActionButton: Padding(
+  padding: const EdgeInsets.only(bottom: 16),
+  child: _buildFloatingActionButton(),
+),
 floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
```

---

## Issue 5: Botón de favoritos en vista de detalle de receta

**Diagnóstico**: `recipe_detail_screen.dart` no tiene botón de favoritos.

**Solución**: Envolver el `body` en `Stack` con `Positioned(bottom: 16, left: 16)` + `BlocBuilder<HomeBloc>` + `AnimatedSwitcher`.

**Archivo**: `lib/presentation/pages/recipe_detail_screen.dart`

```dart
body: Stack(
  children: [
    SingleChildScrollView(...),  // contenido existente
    Positioned(
      bottom: 16, left: 16,
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final isFavorite = state is HomeLoaded &&
              state.favoriteRecipes.any((r) => r.id == recipe.id);
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: IconButton(
              onPressed: () {
                context.read<HomeBloc>().add(ToggleFavoriteRequested(recipe));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isFavorite ? 'Eliminado de favoritos' : 'Agregado a favoritos'),
                    backgroundColor: isFavorite ? Colors.grey.shade600 : Colors.deepOrange.shade700,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
              },
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: RotationTransition(
                    turns: Tween(begin: -0.125, end: 0.0).animate(CurvedAnimation(parent: animation, curve: Curves.elasticOut)),
                    child: child,
                  ),
                ),
                child: Icon(
                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  key: ValueKey(isFavorite),
                  color: isFavorite ? Colors.deepOrange.shade700 : Colors.deepOrange,
                  size: 26,
                ),
              ),
              tooltip: isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
            ),
          );
        },
      ),
    ),
  ],
),
```

---

## Orden de ejecución

| # | Tarea | Archivo |
|---|-------|---------|
| 1 | Guarda concurrente (`_pendingToggleIds`) | `home_bloc.dart` |
| 2 | Pull-to-refresh await stream | `recent_tab.dart` |
| 3 | FAB subir + padding | `home_screen.dart` |
| 4 | Favorito en detalle (`Stack` + `Positioned`) | `recipe_detail_screen.dart` |
| 5 | Recent recipes refresh al volver a SearchTab | `home_screen.dart` |

## Verificación

```bash
flutter analyze
flutter test
```
