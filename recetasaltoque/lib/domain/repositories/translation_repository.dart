abstract class TranslationRepository {
  Future<String> translate(String text, {String from = 'en', String to = 'es'});
  Future<List<String>> translateBatch(List<String> texts, {String from = 'en', String to = 'es'});
  Future<String> translateLongText(String text, {String from = 'en', String to = 'es'});
  Future<bool> isAvailable();
}
