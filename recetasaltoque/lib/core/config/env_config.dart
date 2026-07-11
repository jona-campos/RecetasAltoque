import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get apiKeyNinja => dotenv.env['API_NINJA_KEY'] ?? '';
  static String get libreTranslateUrl => dotenv.env['LIBRE_TRANSLATE_URL'] ?? 'http://localhost:5000';
}
