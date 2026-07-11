import 'dart:convert';
import 'package:crypto/crypto.dart';

class CacheKeyGenerator {
  static String generate(String text, String from, String to) {
    final combined = '${from}_${to}_${text.toLowerCase().trim()}';
    final bytes = utf8.encode(combined);
    final digest = md5.convert(bytes);
    return digest.toString();
  }
}
