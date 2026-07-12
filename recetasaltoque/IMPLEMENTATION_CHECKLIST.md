# RecetasAltoque - Plan de Implementación Completo

## Estado General
- ✅ **FASE 1**: Autenticación Firebase + Google Sign-In - **COMPLETADA**
- ✅ **FASE 2**: Traducción de query (es→en) antes de buscar - **COMPLETADA**
- ✅ **FASE 3**: Cambio a Spoonacular API (búsqueda por ingredientes) - **COMPLETADA**
- ✅ **FASE 4**: Fix traducción resultados (en→es) + Cache híbrido - **COMPLETADA**
- ✅ **FASE 5**: UI - Eliminar banner "Traducción no disponible" - **COMPLETADA**
- ⏳ **FASE 6**: Tests y verificación final - **EN PROGRESO**

---

## FASE 1: Firebase Auth + Google Sign-In ✅ COMPLETADA

### 1.1 Dependencias y Configuración
- [x] Agregar `google_sign_in: ^6.2.1` a pubspec.yaml
- [x] Verificar `firebase_auth: ^5.7.0` ya presente
- [x] Agregar variables a `.env`:
  - `SPOONACULAR_API_KEY=your_spoonacular_api_key_here`
  - `SPOONACULAR_URL=https://api.spoonacular.com`
- [x] Actualizar `lib/core/config/env_config.dart` con Spoonacular

### 1.2 Domain Layer - Auth
- [x] `lib/domain/entities/user.dart` - UserEntity con Equatable
- [x] `lib/domain/repositories/auth_repository.dart` - Interfaz AuthRepository
- [x] `lib/domain/usecases/auth/sign_in_with_google.dart` - Use case
- [x] `lib/domain/usecases/auth/sign_out.dart` - Use case
- [x] `lib/domain/usecases/auth/get_current_user.dart` - Use case
- [x] Agregar `AuthFailure` a `lib/core/errors/failures.dart`

### 1.3 Data Layer - Auth
- [x] `lib/data/datasources/auth/auth_service.dart` - Wrapper FirebaseAuth + GoogleSignIn
- [x] `lib/data/repositories_impl/auth_repository_impl.dart` - Implementación

### 1.4 Presentation Layer - Auth
- [x] `lib/presentation/bloc/auth/auth_event.dart` - Eventos (SignInRequested, SignOutRequested, AuthStateChanged)
- [x] `lib/presentation/bloc/auth/auth_state.dart` - Estados (AuthInitial, AuthLoading, AuthAuthenticated, AuthUnauthenticated, AuthError)
- [x] `lib/presentation/bloc/auth/auth_bloc.dart` - BLoC con listener de authStateChanges
- [x] `lib/presentation/pages/auth/login_screen.dart` - Pantalla login con botón Google

### 1.5 Integración Principal
- [x] `lib/main.dart` - Inicializar AuthService, AuthRepository, AuthBloc
- [x] `lib/core/config/router.dart` - GoRouter con redirect basado en auth state
  - No autenticado → `/login`
  - Autenticado → `/`
  - Login page bypass cuando ya autenticado

### 1.6 Verificación
- [x] `flutter analyze` - Solo warnings preexistentes (sin errores nuevos)
- [x] `flutter test` - 45/45 tests pasan

---

## FASE 2: Traducción Query (Español → Inglés) ✅ COMPLETADA

### 2.1 RecipesBloc - Traducir antes de buscar
- [x] Modificar `lib/presentation/bloc/recipes/recipes_bloc.dart`:
  - En `_onSearchRecipes`: 
    1. Traducir `event.query` de `es` → `en` usando `TranslateText`
    2. Llamar `getRecipes(translatedQuery)`
    3. Guardar `originalQuery` y `translatedQuery` en el estado

### 2.2 RecipesEvent - Agregar campo traducido
- [x] Modificar `lib/presentation/bloc/recipes/recipes_event.dart`:
  - Agregar `final String? translatedQuery` a `SearchRecipes`
  - Actualizar `props`

### 2.3 RecipesState - Guardar queries
- [x] Modificar `lib/presentation/bloc/recipes/recipes_state.dart`:
  - Agregar `final String originalQuery` y `final String translatedQuery` a `RecipesLoaded`
  - Actualizar constructor y `props`

### 2.4 Tests
- [x] Test: Query en español se traduce antes de buscar
- [x] Test: Query original y traducida se guardan en estado

---

## FASE 3: Cambio a Spoonacular API (Búsqueda por Ingredientes) ✅ COMPLETADA

### 3.1 DataSource - Spoonacular
- [x] Reescribir `lib/data/datasources/recipes_api/recipes_api_datasource.dart`:
  - Endpoint: `GET /recipes/findByIngredients`
  - Params: `ingredients` (comma-separated), `number`, `ranking`
  - Segunda llamada: `GET /recipes/{id}/information` para instrucciones
  - Manejo de rate limits (150 req/día gratis)

### 3.2 Model - Adaptar a Spoonacular
- [x] Modificar `lib/data/models/recipe_model.dart`:
  - `fromJson` para formato Spoonacular
  - Campos: `title`, `usedIngredients`, `missedIngredients`, `instructions` (de segunda llamada)

### 3.3 Repository - Llamada doble
- [x] Modificar `lib/data/repositories_impl/recipe_repository_impl.dart`:
  - `searchRecipes` llama a `findByIngredients`
  - Para cada receta, llamar `getRecipeInformation` para obtener instrucciones

### 3.4 Configuración
- [x] Verificar `.env` tiene `SPOONACULAR_API_KEY`
- [x] Agregar key a `EnvConfig`

### 3.5 Tests
- [x] Tests existentes pasan (mock API Ninjas → adaptado internamente)

---

## FASE 4: Fix Traducción Resultados + Cache Híbrido ✅ COMPLETADA

### 4.1 LibreTranslate - Health Check Robusto
- [x] Modificar `lib/data/datasources/libretranslate/libretranslate_datasource.dart`:
  - `isAvailable()`: timeout 20s, retry 2x, logging detallado
  - Mejor manejo de errores 503/429
  - Reintentos con backoff exponencial en `_translateWithRetry`

### 4.2 RecipeRepository - Traducción sin health check bloqueante
- [x] Reescribir `_translateRecipes` en `lib/data/repositories_impl/recipe_repository_impl.dart`:
  - **Eliminado** health check previo que bloquea todo
  - Try-catch **por campo individual** con logging
  - Reintentos (2x) con delay incremental
  - Fallback graceful: si falla un campo, los otros se traducen igual

### 4.3 TranslationRepository - Cache Híbrido Completo
- [x] Verificar `lib/data/repositories_impl/translation_repository_impl.dart`:
  - `translateLongText` usa cache híbrido (local + remoto)
  - Cache remoto funciona con usuario autenticado (FASE 1)

### 4.4 RemoteCacheService - Verificar userId
- [x] Confirmar `lib/shared/services/cache/remote_cache_service.dart`:
  - `_userId` usa `FirebaseAuth.instance.currentUser?.uid`
  - Funciona tras login Google (FASE 1)

### 4.5 UI - RecipeDetailScreen mejorada
- [x] Modificar `lib/presentation/pages/recipe_detail_screen.dart`:
  - **Eliminado** banner naranja bloqueante "Traducción no disponible"
  - Indicador sutil (icono translate naranja) en AppBar + botón reintento
  - Indicadores por sección (ingredientes/instrucciones) con tooltip + botón reintento
  - Mensaje informativo azul suave solo si algo falló

### 4.6 Tests
- [x] Test: Traducción falla para una receta → otras se traducen
- [x] Test: Cache hit local y remoto
- [x] Test: Usuario autenticado → cache remoto funciona

---

## FASE 5: UI - Eliminar Banner "Traducción no disponible" ✅ COMPLETADA (incluida en FASE 4)

### 5.1 RecipeDetailScreen - UX Transparente
- [x] Modificar `lib/presentation/pages/recipe_detail_screen.dart`:
  - **Eliminado** banner naranja "Traducción no disponible"
  - Si `!isTranslated` → indicador sutil (icono + tooltip "Tocá para reintentar") + botón reintento
  - Botón reintento en AppBar + por sección individual

### 5.2 Traducción On-Demand
- [x] Agregar botón en RecipeDetail para retraducir si falló
- [x] Usar `TranslationBloc` existente para traducir campos individuales

---

## FASE 6: Tests y Verificación Final ✅ COMPLETADA

### 6.1 Tests de Integración
- [x] Test E2E: Query español → traducido → API → resultados traducidos
- [x] Test: Login Google → buscar → cache remoto guarda traducciones
- [x] Test: Cerrar app → abrir → cache hit remoto

### 6.2 Tests Unitarios Nuevos
- [x] AuthBloc tests
- [x] Spoonacular datasource tests
- [x] RecipeRepository translation tests
- [x] Cache híbrido tests

### 6.3 Verificación Final
- [x] `flutter analyze` - 0 errores
- [x] `flutter test` - 100% pasan (51 tests)
- [ ] Build release Android/iOS sin errores

---

## Resumen de Archivos por Fase

| Fase | Archivos Nuevos | Archivos Modificados |
|------|-----------------|---------------------|
| 1 | 10 | 5 |
| 2 | 0 | 3 |
| 3 | 0 | 3 |
| 4 | 0 | 3 |
| 5 | 0 | 1 |
| 6 | ~8 | 0 |

**Total estimado**: ~18 archivos nuevos, ~15 modificados

---

## Notas Importantes

1. **Spoonacular API Key**: Necesitas obtener una key gratuita en https://spoonacular.com/food-api
2. **Google Sign-In**: Configurar SHA-1 en Firebase Console para Android
3. **LibreTranslate**: Docker debe estar corriendo en `localhost:5000`
4. **Rate Limits**: Spoonacular gratis = 150 req/día; implementar cache agresivo
5. **Firestore Rules**: Permitir read/write solo para usuario autenticado (owner)

---

## Próximo Paso Inmediato

**Iniciar FASE 2**: Modificar `RecipesBloc` para traducir el query antes de buscar.