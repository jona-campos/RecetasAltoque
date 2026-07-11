import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recetasaltoque/domain/repositories/translation_repository.dart';
import 'package:recetasaltoque/domain/usecases/translate_text.dart';

class MockTranslationRepository extends Mock implements TranslationRepository {}

void main() {
  late TranslateText useCase;
  late MockTranslationRepository mockRepository;

  setUp(() {
    mockRepository = MockTranslationRepository();
    useCase = TranslateText(mockRepository);
  });

  test('debe retornar texto traducido', () async {
    when(() => mockRepository.translate(
          any(),
          from: any(named: 'from'),
          to: any(named: 'to'),
        )).thenAnswer((_) async => 'Pollo');

    final result = await useCase('chicken');

    expect(result, equals('Pollo'));
    verify(() => mockRepository.translate(
          'chicken',
          from: 'en',
          to: 'es',
        )).called(1);
  });

  test('debe lanzar ArgumentError si texto esta vacio', () async {
    expect(() => useCase(''), throwsArgumentError);
    expect(() => useCase('   '), throwsArgumentError);
  });

  test('debe pasar idiomas correctamente', () async {
    when(() => mockRepository.translate(
          any(),
          from: any(named: 'from'),
          to: any(named: 'to'),
        )).thenAnswer((_) async => 'Huhn');

    await useCase('chicken', from: 'en', to: 'de');

    verify(() => mockRepository.translate(
          'chicken',
          from: 'en',
          to: 'de',
        )).called(1);
  });
}
