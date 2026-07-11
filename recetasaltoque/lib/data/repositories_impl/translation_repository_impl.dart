import '../../domain/repositories/translation_repository.dart';
import '../datasources/libretranslate/libretranslate_datasource.dart';
import '../../core/errors/failures.dart';
import '../../shared/services/cache/hybrid_cache_service.dart';

class TranslationRepositoryImpl implements TranslationRepository {
  final LibreTranslateDatasource translationDatasource;
  final HybridCacheService cacheService;

  TranslationRepositoryImpl({
    required this.translationDatasource,
    required this.cacheService,
  });

  @override
  Future<String> translate(String text, {String from = 'en', String to = 'es'}) async {
    try {
      // 1. Buscar en cache
      final cached = await cacheService.getTranslation(text, from, to);
      if (cached != null) {
        return cached.translatedText;
      }

      // 2. Llamar a LibreTranslate
      final translation = await translationDatasource.translate(text, from: from, to: to);

      // 3. Guardar en cache
      await cacheService.saveTranslation(text, translation, from, to);

      return translation;
    } on Exception catch (e) {
      throw TranslationFailure(message: e.toString());
    }
  }

  @override
  Future<List<String>> translateBatch(List<String> texts, {String from = 'en', String to = 'es'}) async {
    try {
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
    } on Exception catch (e) {
      throw TranslationFailure(message: e.toString());
    }
  }

  @override
  Future<String> translateLongText(String text, {String from = 'en', String to = 'es'}) async {
    try {
      // Check cache first for the full text
      final cached = await cacheService.getTranslation(text, from, to);
      if (cached != null) {
        return cached.translatedText;
      }

      // Translate the full text using the datasource's translateLongText
      final translation = await translationDatasource.translateLongText(text, from: from, to: to);

      // Save to cache
      await cacheService.saveTranslation(text, translation, from, to);

      return translation;
    } on Exception catch (e) {
      throw TranslationFailure(message: e.toString());
    }
  }

  @override
  Future<bool> isAvailable() async {
    return translationDatasource.isAvailable();
  }
}
