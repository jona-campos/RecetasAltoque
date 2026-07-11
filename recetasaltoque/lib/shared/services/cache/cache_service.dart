import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'hybrid_cache_service.dart';
import 'local_cache_service.dart';
import 'remote_cache_service.dart';

class CacheService {
  final HybridCacheService _hybridCacheService;

  CacheService({required HybridCacheService hybridCacheService})
      : _hybridCacheService = hybridCacheService;

  HybridCacheService get hybridCache => _hybridCacheService;

  static Future<CacheService> initialize({
    required FirebaseFirestore firestore,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final localCache = LocalCacheService(prefs: prefs);
    final remoteCache = RemoteCacheService(firestore: firestore);

    final hybridCache = HybridCacheService(
      localCache: localCache,
      remoteCache: remoteCache,
    );

    return CacheService(hybridCacheService: hybridCache);
  }
}
