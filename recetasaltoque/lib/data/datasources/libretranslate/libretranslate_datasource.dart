import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/env_config.dart';
import '../../../core/errors/exceptions.dart';

abstract class LibreTranslateDatasource {
  Future<String> translate(String text, {String from = 'en', String to = 'es'});
  Future<List<String>> translateBatch(List<String> texts, {String from = 'en', String to = 'es'});
  Future<String> translateLongText(String text, {String from = 'en', String to = 'es'});
  Future<bool> isAvailable();
}

class LibreTranslateDatasourceImpl implements LibreTranslateDatasource {
  final http.Client httpClient;

  LibreTranslateDatasourceImpl({required this.httpClient});

  @override
  Future<String> translate(String text, {String from = 'en', String to = 'es'}) async {
    try {
      final uri = Uri.parse('${EnvConfig.libreTranslateUrl}/translate');

      final response = await httpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'q': text,
          'source': from,
          'target': to,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['translatedText'] as String;
      } else if (response.statusCode == 400) {
        throw const TranslationException(
          message: 'Texto invalido para traducir',
        );
      } else if (response.statusCode == 422) {
        throw const TranslationException(
          message: 'Idioma no soportado o texto demasiado largo',
        );
      } else if (response.statusCode == 503) {
        throw const TranslationException(
          message: 'Servicio de traduccion no disponible',
        );
      } else {
        throw TranslationException(
          message: 'Error en la traduccion: ${response.statusCode}',
        );
      }
    } on TranslationException {
      rethrow;
    } catch (e) {
      throw TranslationException(
        message: 'Error de conexion con LibreTranslate: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<String>> translateBatch(List<String> texts, {String from = 'en', String to = 'es'}) async {
    final List<String> translations = [];
    
    for (final text in texts) {
      if (text.trim().isEmpty) {
        translations.add('');
        continue;
      }
      
      final translation = await translate(text, from: from, to: to);
      translations.add(translation);
    }
    
    return translations;
  }

  @override
  Future<String> translateLongText(String text, {String from = 'en', String to = 'es'}) async {
    if (text.trim().isEmpty) return '';

    final lines = text.split('\n');
    final translatedLines = <String>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        translatedLines.add('');
        continue;
      }

      final translatedLine = await translate(line.trim(), from: from, to: to);
      translatedLines.add(translatedLine);
    }

    return translatedLines.join('\n');
  }

  @override
  Future<bool> isAvailable() async {
    try {
      final uri = Uri.parse('${EnvConfig.libreTranslateUrl}/languages');
      final response = await httpClient.get(uri).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('LibreTranslate health check failed: $e');
      return false;
    }
  }
}
