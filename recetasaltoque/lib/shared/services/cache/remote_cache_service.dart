import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/exceptions.dart';
import 'models/cached_translation.dart';
import 'utils/cache_key_generator.dart';

class RemoteCacheService {
  final FirebaseFirestore firestore;

  RemoteCacheService({required this.firestore});

  static const String _collection = 'translations';
  static const int _maxCacheAgeDays = 30;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

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

      final docData = translation.toJson();
      if (_userId != null) {
        docData['userId'] = _userId;
      }

      await firestore.collection(_collection).doc(key).set(docData);
    } catch (e) {
      throw CacheException(message: 'Error al guardar en cache remoto: ${e.toString()}');
    }
  }

  Future<CachedTranslation?> getTranslation(String text, String from, String to) async {
    try {
      final key = CacheKeyGenerator.generate(text, from, to);
      final doc = await firestore.collection(_collection).doc(key).get();

      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      final translation = CachedTranslation.fromJson(data);

      if (translation.isExpired) {
        await firestore.collection(_collection).doc(key).delete();
        return null;
      }

      return translation;
    } catch (e) {
      throw CacheException(message: 'Error al leer del cache remoto: ${e.toString()}');
    }
  }

  Future<bool> hasTranslation(String text, String from, String to) async {
    try {
      final key = CacheKeyGenerator.generate(text, from, to);
      final doc = await firestore.collection(_collection).doc(key).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  Future<void> removeTranslation(String text, String from, String to) async {
    try {
      final key = CacheKeyGenerator.generate(text, from, to);
      await firestore.collection(_collection).doc(key).delete();
    } catch (e) {
      throw CacheException(message: 'Error al eliminar del cache remoto: ${e.toString()}');
    }
  }

  Future<void> clearExpiredCache() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: _maxCacheAgeDays));
      final query = firestore
          .collection(_collection)
          .where('timestamp', isLessThan: cutoffDate);

      final snapshot = await query.get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw CacheException(message: 'Error al limpiar cache remoto: ${e.toString()}');
    }
  }
}
