# Plan: Firestore + Fix Duplicados + Fix Recientes

## Diagnóstico

### 🐛 RAÍZ de favoritos duplicados — INCONSISTENCIA DE ID

Hay **dos esquemas de ID diferentes** según dónde se cree el Recipe:

| Origen | Cómo genera el ID | Ejemplo |
|--------|-------------------|---------|
| `_recipeFromCombinedJson()` (API) | `findJson["id"].toString()` → ID numérico de Spoonacular | `"716429"` |
| `Recipe.create()` / `_recipeFromJson()` (local) | `title.hashCode.toString()` → hash del título | `"1827349165"` |

**Flujo del bug:**
1. API devuelve receta con Spoonacular ID `"716429"` → se guarda en SharedPreferences con ID `"716429"`
2. Al cargar desde SharedPreferences, `_recipeFromJson()` llama a `Recipe.create()` que recalcula `id = title.hashCode.toString()` → obtiene `"1827349165"`
3. Al tocar favorito: `ToggleFavorite.execute()` chequea `isFavorite("716429")` — busca en lista donde los IDs ahora son `"1827349165"` → no lo encuentra → `saveFavoriteRecipe("716429")` → **se guarda OTRA vez** → duplicado
4. Al recargar de nuevo, ambos registros cargan con IDs recalculados → parecen recetas distintas → el círculo se repite

**Esto es lo que causa los duplicados** — no es race condition, es corrupción de datos en cada ciclo guardar/cargar.

### 🐛 Recientes no se actualizan

1. `SearchTab._buildRecentRecipesSection` usa `BlocBuilder<HomeBloc>` pero **solo se muestra cuando `RecipesBloc` está en estado `RecipesInitial`** (antes de buscar). Después de buscar, el estado es `RecipesLoaded` y la sección de recientes desaparece.
2. Al volver de `/recipe/...`, no hay refresh automático del `HomeBloc`.
3. La UI está condicionada a mostrar recientes solo en estado inicial, no post-búsqueda.

### 🐛 Firestore vacío

El repositorio de recetas (`RecipeLocalRepositoryImpl`) **solo usa SharedPreferences**. No escribe ni lee de Firestore. Las recetas, favoritos, y datos de usuario quedan en el dispositivo sin persistencia cloud. Firestore solo se usa para cache de traducciones.

---

## Tasks (orden de ejecución)

### Task 1: Fix ID inconsistency (root cause de duplicados)

**Archivos**: `lib/domain/entities/recipe.dart`, `lib/data/repositories_impl/local/recipe_local_repository_impl.dart`, `lib/data/models/recipe_model.dart`

1. `Recipe.create()` → aceptar `id` opcional; si no se provee, usar `title.hashCode.toString()` (backward compatible)
2. `_recipeFromJson()` → **usar `json["id"]` almacenado** en vez de recalcular. Solo fallback a `Recipe.create()` si `id` está vacío
3. `RecipeModel.fromJson()` → usar `json["id"]` si existe (está en la respuesta de Spoonacular `findByIngredients`), fallback a `title.hashCode.toString()`

### Task 2: Firestore datasource y modelo para recetas

**Archivos nuevos**: `lib/data/datasources/recipes_firestore/recipes_firestore_datasource.dart`, `lib/data/models/recipe_firestore_model.dart`
**Archivo nuevo**: `lib/data/repositories_impl/recipe_remote_repository_impl.dart`

1. `RecipeFirestoreModel` con `fromFirestore()` / `toFirestore()` — serializa Recipe para Firestore
2. `RecipesFirestoreDatasource` — CRUD contra colección `users/{uid}/recipes/{type}/{id}` donde type = "favorites" | "recent"
3. `RecipeRemoteRepositoryImpl` — implementa `RecipeLocalRepository` pero persiste en Firestore (no SharedPreferences)

### Task 3: Sync layer (local ↔ Firestore)

**Archivo nuevo**: `lib/data/repositories_impl/recipe_synced_repository_impl.dart`

1. `RecipeSyncedRepositoryImpl` — implementa `RecipeLocalRepository` y coordina:
   - Write: SharedPreferences + Firestore (async, fire-and-forget para no bloquear UI)
   - Read: SharedPreferences primero (rápido), background sync desde Firestore
2. Usa `FirebaseAuth.instance.currentUser?.uid` para scoping user-specific data
3. Si no hay usuario autenticado: solo SharedPreferences

### Task 4: Fix recent searches UI

**Archivos**: `lib/presentation/pages/tabs/search_tab.dart`, `lib/presentation/pages/home_screen.dart`

1. `search_tab.dart`: Mostrar la sección "Recetas recientes" también cuando `RecipesLoaded` (no solo `RecipesInitial`), abajo de los resultados o arriba si no hay resultados
2. `home_screen.dart`: Al volver de `/recipe/...`, refrescar `HomeBloc` recents (podría ser en `_onPageChanged` o en un listener de GoRouter)
3. Asegurar que `_onSaveRecentRecipe` dispare correctamente y el `BlocBuilder<HomeBloc>` reaccione

### Task 5: Wire dependencies en main.dart

**Archivo**: `lib/main.dart`

1. Instanciar `RecipeFirestoreDatasource` con `FirebaseFirestore`
2. Instanciar `RecipeRemoteRepositoryImpl` o `RecipeSyncedRepositoryImpl`
3. Pasar a los use cases en lugar de (o además de) `RecipeLocalRepositoryImpl`

### Task 6: Verificación

```bash
flutter analyze
flutter test
# Probar manualmente: tocar favorito 10 veces rápido → 1 sola entrada
# Verificar Firestore: users/{uid}/recipes/favorites/{id} tiene los datos
# Verificar recientes: buscar, tap receta, volver → aparece en recientes
```

---

## Checklist

- [ ] **Task 1**: `Recipe.create()` acepta `id` opcional
- [ ] **Task 1**: `_recipeFromJson()` usa `json["id"]` almacenado
- [ ] **Task 1**: `RecipeModel.fromJson()` usa `json["id"]` de Spoonacular
- [ ] **Task 2**: `RecipeFirestoreModel` con `fromFirestore()`/`toFirestore()`
- [ ] **Task 2**: `RecipesFirestoreDatasource` CRUD
- [ ] **Task 2**: `RecipeRemoteRepositoryImpl` (Firestore-only)
- [ ] **Task 3**: `RecipeSyncedRepositoryImpl` (SharedPreferences + Firestore)
- [ ] **Task 3**: Scoping por `currentUser.uid`
- [ ] **Task 4**: Recent section visible en SearchTab también post-búsqueda
- [ ] **Task 4**: Refresh `HomeBloc` al volver de `/recipe`
- [ ] **Task 5**: DI wiring en `main.dart`
- [ ] **Task 6**: `flutter analyze` → 0 errors
- [ ] **Task 6**: `flutter test` → 50/50
