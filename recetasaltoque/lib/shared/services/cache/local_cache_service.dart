import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/errors/exceptions.dart';
import 'models/cached_translation.dart';
import 'utils/cache_key_generator.dart';

class LocalCacheService {
  final SharedPreferences prefs;

  LocalCacheService({required this.prefs});

  static const String _prefix = 'translation_';
  static const int _maxCacheAgeDays = 7;

  Future<void> saveTranslation(String text, String translated, String from, String to) async {
    try {
      final key = CacheKeyGenerator.generate(text, from, to);
      final translation = CachedTranslation(
        originalText: text,
        translatedText: translated,
        sourceLang: from,
        targetLang: to,
        timestamp: DateTime.now(),
      );
      await prefs.setString('$_prefix$key', json.encode(translation.toJson()));
    } catch (e) {
      throw CacheException(message: 'Error al guardar en cache local: ${e.toString()}');
    }
  }

  Future<CachedTranslation?> getTranslation(String text, String from, String to) async {
    try {
      final key = CacheKeyGenerator.generate(text, from, to);
      final jsonString = prefs.getString('$_prefix$key');

      if (jsonString == null) return null;

      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      final translation = CachedTranslation.fromJson(jsonMap);

      if (translation.isExpired) {
        await prefs.remove('$_prefix$key');
        return null;
      }

      return translation;
    } catch (e) {
      throw CacheException(message: 'Error al leer del cache local: ${e.toString()}');
    }
  }

  Future<bool> hasTranslation(String text, String from, String to) async {
    try {
      final key = CacheKeyGenerator.generate(text, from, to);
      final jsonString = prefs.getString('$_prefix$key');
      return jsonString != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> removeTranslation(String text, String from, String to) async {
    try {
      final key = CacheKeyGenerator.generate(text, from, to);
      await prefs.remove('$_prefix$key');
    } catch (e) {
      throw CacheException(message: 'Error al eliminar del cache local: ${e.toString()}');
    }
  }

  Future<void> clearExpiredCache() async {
    try {
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_prefix)) {
          final jsonString = prefs.getString(key);
          if (jsonString != null) {
            final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
            final translation = CachedTranslation.fromJson(jsonMap);
            if (translation.isExpired) {
              await prefs.remove(key);
            }
          }
        }
      }
    } catch (e) {
      throw CacheException(message: 'Error al limpiar cache local: ${e.toString()}');
    }
  }
}
