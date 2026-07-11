import 'package:flutter/foundation.dart';
import 'local_cache_service.dart';
import 'remote_cache_service.dart';
import 'models/cached_translation.dart';

class HybridCacheService {
  final LocalCacheService localCache;
  final RemoteCacheService remoteCache;

  HybridCacheService({
    required this.localCache,
    required this.remoteCache,
  });

  Future<CachedTranslation?> getTranslation(String text, String from, String to) async {
    try {
      // 1. Buscar en cache local (rapido)
      final localResult = await localCache.getTranslation(text, from, to);
      if (localResult != null) {
        debugPrint('Cache HIT (local): $text');
        return localResult;
      }

      // 2. Buscar en cache remoto (Firestore)
      final remoteResult = await remoteCache.getTranslation(text, from, to);
      if (remoteResult != null) {
        debugPrint('Cache HIT (remote): $text');
        // Sincronizar a local para futuras consultas
        await localCache.saveTranslation(text, remoteResult.translatedText, from, to);
        return remoteResult;
      }

      debugPrint('Cache MISS: $text');
      return null;
    } catch (e) {
      debugPrint('Error en HybridCacheService.getTranslation: $e');
      return null;
    }
  }

  Future<void> saveTranslation(String text, String translated, String from, String to) async {
    try {
      // Guardar en local inmediatamente
      await localCache.saveTranslation(text, translated, from, to);

      // Guardar en remoto en background (no bloquear)
      _saveToRemoteAsync(text, translated, from, to);
    } catch (e) {
      debugPrint('Error en HybridCacheService.saveTranslation: $e');
    }
  }

  Future<void> _saveToRemoteAsync(String text, String translated, String from, String to) async {
    try {
      await remoteCache.saveTranslation(text, translated, from, to);
    } catch (e) {
      debugPrint('Error al guardar en cache remoto: $e');
    }
  }

  Future<void> removeTranslation(String text, String from, String to) async {
    try {
      await Future.wait([
        localCache.removeTranslation(text, from, to),
        remoteCache.removeTranslation(text, from, to),
      ]);
    } catch (e) {
      debugPrint('Error en HybridCacheService.removeTranslation: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await Future.wait([
        localCache.clearExpiredCache(),
        remoteCache.clearExpiredCache(),
      ]);
    } catch (e) {
      debugPrint('Error en HybridCacheService.clearAll: $e');
    }
  }
}
