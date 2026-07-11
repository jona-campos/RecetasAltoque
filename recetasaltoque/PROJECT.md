# RecetasAltoque - Aplicacion de Recetas con Flutter

## Descripcion
Aplicacion movil desarrollada en Flutter/Dart para buscar y visualizar recetas. Consume la API de ApiNinjas (en ingles) y utiliza LibreTranslate (Docker local) para traducir al español. Implementa un sistema de cache hibrido con Firebase para almacenar traducciones y reducir tiempos de respuesta.

## Stack Tecnologico
- **Framework:** Flutter 3.x + Dart
- **Estado:** BLoC (Business Logic Component)
- **Arquitectura:** Clean Architecture
- **API Recetas:** ApiNinjas
- **Traduccion:** LibreTranslate (Docker local)
- **Base de datos:** Firebase (Firestore)
- **Cache Hibrido:** Firebase + SharedPreferences

## Estructura del Proyecto

```
lib/
├── core/                          # Configuracion central
│   ├── config/                    # Variables de entorno, URLs
│   ├── constants/                 # Constantes de la app
│   ├── errors/                    # Manejo de excepciones
│   └── utils/                     # Utilidades generales
├── data/                          # Capa de datos
│   ├── datasources/
│   │   ├── libretranslate/        # Fuente de datos LibreTranslate
│   │   └── recipes_api/           # Fuente de datos ApiNinjas
│   ├── models/                    # Modelos de datos (JSON <-> Entity)
│   └── repositories_impl/         # Implementacion de repositorios
├── domain/                        # Capa de dominio
│   ├── entities/                  # Entidades del negocio
│   ├── repositories/              # Contratos de repositorios (abstracciones)
│   └── usecases/                  # Casos de uso
├── presentation/                  # Capa de presentacion
│   ├── bloc/
│   │   ├── recipes/               # BLoC de recetas
│   │   └── translation/           # BLoC de traduccion
│   ├── pages/                     # Pantallas de la app
│   └── widgets/                   # Widgets reutilizables
└── shared/
    └── services/
        ├── cache/                 # Servicio de cache hibrido
        ├── firebase/              # Servicio de Firebase
        └── translation/           # Servicio de traduccion
```

---

## Checklist de Fases

### Fase 1: Configuracion Inicial
- [x] Configurar `pubspec.yaml` con dependencias (flutter_bloc, http, firebase_core, cloud_firestore, shared_preferences)
- [ ] Configurar Firebase en el proyecto (flutterfire configure) - **REQUIERE ACCION DEL USUARIO**
- [x] Configurar Docker Compose para LibreTranslate
- [ ] Verificar conexion local con LibreTranslate en `http://localhost:5000` - **REQUIERE ACCION DEL USUARIO**
- [x] Crear archivo `.env` con API_KEY de ApiNinjas y URLs

### Fase 2: Domain Layer (Capa de Dominio)
- [x] Crear entidad `Recipe` (domain/entities/recipe.dart)
- [x] Crear contrato `RecipeRepository` (domain/repositories/recipe_repository.dart)
- [x] Crear caso de uso `GetRecipes` (domain/usecases/get_recipes.dart)
- [x] Crear contrato `TranslationRepository` (domain/repositories/translation_repository.dart)
- [x] Crear caso de uso `TranslateText` (domain/usecases/translate_text.dart)
- [x] Crear clases de error (core/errors/failures.dart)

### Fase 3: Data Layer (Capa de Datos)
- [x] Crear modelo `RecipeModel` con serializacion JSON (data/models/recipe_model.dart)
- [x] Implementar `RecipesApiDatasource` - consumo de ApiNinjas (data/datasources/recipes_api/)
- [x] Implementar `LibreTranslateDatasource` - consumo de LibreTranslate (data/datasources/libretranslate/)
- [x] Implementar `RecipeRepositoryImpl` (data/repositories_impl/)
- [x] Implementar `TranslationRepositoryImpl` (data/repositories_impl/)
- [x] Crear excepciones de la capa data (core/errors/exceptions.dart)

### Fase 4: Cache Hibrido
- [x] Implementar servicio de cache con SharedPreferences (local)
- [x] Implementar servicio de cache con Firestore (nube)
- [x] Crear `HybridCacheService` que orqueste local + remoto
- [x] Integrar cache en los repositories de traduccion
- [x] Crear modelo CachedTranslation y generador de keys MD5

### Fase 5: Shared Services
- [x] Implementar `TranslationService` (servicio central de traduccion)
- [x] Implementar `FirebaseService` (inicializacion y operaciones Firestore)
- [x] Implementar `CacheService` (servicio de cache hibrido)
- [x] Actualizar `main.dart` con inicializacion de servicios

### Fase 6: Presentation Layer (Capa de Presentacion)
- [x] Crear `RecipesBloc` con eventos y estados (presentation/bloc/recipes/)
- [x] Crear `TranslationBloc` con eventos y estados (presentation/bloc/translation/)
- [x] Crear pantalla de inicio/home (presentation/pages/)
- [x] Crear pantalla de detalle de receta
- [x] Crear pantalla de busqueda de recetas
- [x] Crear widgets reutilizables (cards, search bar, loading, etc.)
- [x] Crear router con GoRouter (core/config/router.dart)
- [x] Actualizar main.dart con BLoC providers y router

### Fase 7: Integracion y Pruebas
- [x] Conectar BLoC con las pantallas
- [x] Probar flujo completo: busqueda -> traduccion -> visualizacion
- [x] Probar cache: primera consulta vs segunda consulta (debe ser mas rapida)
- [x] Manejo de errores y estados de carga
- [x] Pruebas unitarias para usecases y repositories
- [x] Pruebas de BLoC
- [x] Pruebas de widget para pantallas principales

### Fase 8: Pulido y Optimizacion
- [x] Diseno UI/UX responsivo
- [x] Animaciones y transiciones en router
- [x] Optimizacion de rendimiento del cache
- [x] Manejo offline (ConnectivityService + OfflineIndicator)
- [x] Variables de entorno configuradas

---

## Diagrama de Flujo

```
Usuario -> UI (Pages)
    ↓
BLoC (Events/States)
    ↓
UseCases
    ↓
Repositories (Contratos)
    ↓
DataSources (Implementaciones)
    ↓
┌─────────────────┬──────────────────┐
│   ApiNinjas     │  LibreTranslate  │
│   (Recetas)     │   (Traduccion)   │
└─────────────────┴──────────────────┘
         ↓
   Hybrid Cache
   (Firebase + SharedPreferences)
```

## Notas
- LibreTranslate corre en Docker: `docker run -p 5000:5000 libretranslate/libretranslate`
- ApiNinjas requiere API Key (obtener en https://api-ninjas.com/)
- El cache hibrido prioriza: 1) Local (rapido) -> 2) Firebase (nube) -> 3) API (lento)
