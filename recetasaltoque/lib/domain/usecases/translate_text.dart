import '../repositories/translation_repository.dart';

class TranslateText {
  final TranslationRepository repository;

  TranslateText(this.repository);

  Future<String> call(String text, {String from = 'en', String to = 'es'}) {
    if (text.trim().isEmpty) {
      throw ArgumentError('El texto a traducir no puede estar vacio');
    }
    return repository.translate(text, from: from, to: to);
  }
}
