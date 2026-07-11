import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recetasaltoque/data/datasources/libretranslate/libretranslate_datasource.dart';
import 'package:recetasaltoque/data/repositories_impl/translation_repository_impl.dart';
import 'package:recetasaltoque/shared/services/cache/hybrid_cache_service.dart';
import 'package:recetasaltoque/shared/services/cache/models/cached_translation.dart';
import 'package:recetasaltoque/core/errors/failures.dart';

class MockLibreTranslateDatasource extends Mock implements LibreTranslateDatasource {}
class MockHybridCacheService extends Mock implements HybridCacheService {}

void main() {
  late TranslationRepositoryImpl repository;
  late MockLibreTranslateDatasource mockDatasource;
  late MockHybridCacheService mockCache;

  setUp(() {
    mockDatasource = MockLibreTranslateDatasource();
    mockCache = MockHybridCacheService();
    repository = TranslationRepositoryImpl(
      translationDatasource: mockDatasource,
      cacheService: mockCache,
    );
  });

  group('translate', () {
    test('debe retornar traduccion del cache si existe', () async {
      when(() => mockCache.getTranslation(
            any(),
            any(),
            any(),
          )).thenAnswer((_) async => CachedTranslation(
            originalText: 'chicken',
            translatedText: 'Pollo',
            sourceLang: 'en',
            targetLang: 'es',
            timestamp: DateTime.now(),
          ));

      final result = await repository.translate('chicken');

      expect(result, equals('Pollo'));
      verify(() => mockCache.getTranslation('chicken', 'en', 'es')).called(1);
      verifyNever(() => mockDatasource.translate(any(), from: any(named: 'from'), to: any(named: 'to')));
    });

    test('debe llamar a datasource si no hay cache', () async {
      when(() => mockCache.getTranslation(any(), any(), any()))
          .thenAnswer((_) async => null);
      when(() => mockDatasource.translate(any(), from: any(named: 'from'), to: any(named: 'to')))
          .thenAnswer((_) async => 'Pollo');
      when(() => mockCache.saveTranslation(any(), any(), any(), any()))
          .thenAnswer((_) async {});

      final result = await repository.translate('chicken');

      expect(result, equals('Pollo'));
      verify(() => mockDatasource.translate('chicken', from: 'en', to: 'es')).called(1);
      verify(() => mockCache.saveTranslation('chicken', 'Pollo', 'en', 'es')).called(1);
    });

    test('debe lanzar TranslationFailure cuando hay error', () async {
      when(() => mockCache.getTranslation(any(), any(), any()))
          .thenAnswer((_) async => null);
      when(() => mockDatasource.translate(any(), from: any(named: 'from'), to: any(named: 'to')))
          .thenThrow(Exception('Error'));

      expect(
        () => repository.translate('chicken'),
        throwsA(isA<TranslationFailure>()),
      );
    });
  });

  group('translateBatch', () {
    test('debe traducir lista de textos', () async {
      when(() => mockCache.getTranslation(any(), any(), any()))
          .thenAnswer((_) async => null);
      when(() => mockDatasource.translate(any(), from: any(named: 'from'), to: any(named: 'to')))
          .thenAnswer((_) async => 'Traduccion');
      when(() => mockCache.saveTranslation(any(), any(), any(), any()))
          .thenAnswer((_) async {});

      final result = await repository.translateBatch(['hello', 'world']);

      expect(result.length, equals(2));
      verify(() => mockDatasource.translate('hello', from: 'en', to: 'es')).called(1);
      verify(() => mockDatasource.translate('world', from: 'en', to: 'es')).called(1);
    });

    test('debe ignorar textos vacios', () async {
      final result = await repository.translateBatch(['', '  ', '']);

      expect(result.length, equals(3));
      expect(result, equals(['', '', '']));
    });
  });
}
