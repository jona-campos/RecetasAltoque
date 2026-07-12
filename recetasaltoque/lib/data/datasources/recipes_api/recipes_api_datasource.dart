import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/env_config.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/recipe_model.dart';

abstract class RecipesApiDatasource {
  Future<List<RecipeModel>> searchRecipes(String query, {int offset = 0});
}

class RecipesApiDatasourceImpl implements RecipesApiDatasource {
  final http.Client httpClient;

  RecipesApiDatasourceImpl({required this.httpClient});

  static const String _baseUrl = 'https://api.spoonacular.com/recipes';

  @override
  Future<List<RecipeModel>> searchRecipes(String query, {int offset = 0}) async {
    try {
      // Step 1: Find recipes by ingredients
      final findUri = Uri.parse('$_baseUrl/findByIngredients').replace(
        queryParameters: {
          'ingredients': query,
          'number': '1',
          'offset': offset.toString(),
          'ranking': '2', // maximize used ingredients
          'ignorePantry': 'true',
          'apiKey': EnvConfig.spoonacularApiKey,
        },
      );

      final findResponse = await httpClient.get(findUri).timeout(const Duration(seconds: 30));

      if (findResponse.statusCode != 200) {
        throw _handleError(findResponse);
      }

      final List<dynamic> findJsonList = json.decode(findResponse.body);
      
      if (findJsonList.isEmpty) {
        return [];
      }

      // Step 2: Get detailed information (including instructions) for each recipe
      final recipeIds = findJsonList
          .map((json) => json['id'] as int)
          .toList();

      final detailUri = Uri.parse('$_baseUrl/informationBulk').replace(
        queryParameters: {
          'ids': recipeIds.join(','),
          'includeNutrition': 'false',
          'apiKey': EnvConfig.spoonacularApiKey,
        },
      );

      final detailResponse = await httpClient.get(detailUri).timeout(const Duration(seconds: 30));

      if (detailResponse.statusCode != 200) {
        throw _handleError(detailResponse);
      }

      final List<dynamic> detailJsonList = json.decode(detailResponse.body);

      // Combine find results with detail results
      final Map<int, Map<String, dynamic>> detailMap = {
        for (var detail in detailJsonList) detail['id'] as int: detail as Map<String, dynamic>
      };

      return findJsonList.map((findJson) {
        final id = findJson['id'] as int;
        final detailJson = detailMap[id] ?? {};
        return _recipeFromCombinedJson(findJson, detailJson);
      }).toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Error de conexión con Spoonacular: ${e.toString()}',
      );
    }
  }

  RecipeModel _recipeFromCombinedJson(Map<String, dynamic> findJson, Map<String, dynamic> detailJson) {
    // Extract ingredients from both used and missed ingredients
    final usedIngredients = (findJson['usedIngredients'] as List<dynamic>?)
        ?.map((i) => i['original'] as String? ?? i['name'] as String? ?? '')
        .where((s) => s.isNotEmpty)
        .toList() ?? [];
    
    final missedIngredients = (findJson['missedIngredients'] as List<dynamic>?)
        ?.map((i) => i['original'] as String? ?? i['name'] as String? ?? '')
        .where((s) => s.isNotEmpty)
        .toList() ?? [];

    final allIngredients = [...usedIngredients, ...missedIngredients].join('\n');

    // Get instructions from detail response
    String instructions = detailJson['instructions'] as String? ?? '';
    if (instructions.isEmpty && detailJson['analyzedInstructions'] != null) {
      final analyzed = detailJson['analyzedInstructions'] as List<dynamic>;
      if (analyzed.isNotEmpty) {
        final steps = analyzed.first['steps'] as List<dynamic>?;
        if (steps != null) {
          instructions = steps
              .map((s) => s['step'] as String? ?? '')
              .where((s) => s.isNotEmpty)
              .join('\n');
        }
      }
    }

    // Get servings
    final servings = detailJson['servings']?.toString() ?? '1';

    // Use Spoonacular ID as the unique identifier
    final id = findJson['id'].toString();

    return RecipeModel(
      id: id,
      title: findJson['title'] as String? ?? '',
      ingredients: allIngredients,
      servings: servings,
      instructions: instructions,
    );
  }

  ServerException _handleError(http.Response response) {
    switch (response.statusCode) {
      case 401:
        return const ServerException(
          message: 'API Key inválida o no proporcionada',
          statusCode: 401,
        );
      case 402:
        return const ServerException(
          message: 'Límite de plan superado (requiere suscripción)',
          statusCode: 402,
        );
      case 429:
        return const ServerException(
          message: 'Límite de solicitudes alcanzado',
          statusCode: 429,
        );
      default:
        return ServerException(
          message: 'Error al buscar recetas: ${response.statusCode}',
          statusCode: response.statusCode,
        );
    }
  }
}
