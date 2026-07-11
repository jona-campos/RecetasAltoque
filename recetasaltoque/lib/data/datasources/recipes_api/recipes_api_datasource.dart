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

  static const String _baseUrl = 'https://api.api-ninjas.com/v1/recipe';

  @override
  Future<List<RecipeModel>> searchRecipes(String query, {int offset = 0}) async {
    try {
      final uri = Uri.parse('$_baseUrl').replace(
        queryParameters: {
          'query': query,
          'offset': offset.toString(),
        },
      );

      final response = await httpClient.get(
        uri,
        headers: {
          'X-Api-Key': EnvConfig.apiKeyNinja,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((json) => RecipeModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw const ServerException(
          message: 'API Key invalida o no proporcionada',
          statusCode: 401,
        );
      } else if (response.statusCode == 429) {
        throw const ServerException(
          message: 'Limite de solicitudes alcanzado',
          statusCode: 429,
        );
      } else {
        throw ServerException(
          message: 'Error al buscar recetas: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Error de conexion con la API: ${e.toString()}',
      );
    }
  }
}
