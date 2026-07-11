import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recetasaltoque/domain/usecases/translate_text.dart';
import 'package:recetasaltoque/presentation/bloc/translation/translation_bloc.dart';
import 'package:recetasaltoque/presentation/bloc/translation/translation_event.dart';
import 'package:recetasaltoque/presentation/bloc/translation/translation_state.dart';

class MockTranslateText extends Mock implements TranslateText {}

void main() {
  late TranslationBloc bloc;
  late MockTranslateText mockTranslateText;

  setUp(() {
    mockTranslateText = MockTranslateText();
    bloc = TranslationBloc(translateText: mockTranslateText);
  });

  tearDown(() {
    bloc.close();
  });

  group('TranslationBloc', () {
    test('estado inicial debe ser TranslationInitial', () {
      expect(bloc.state, isA<TranslationInitial>());
    });

    blocTest<TranslationBloc, TranslationState>(
      'debe emitir [Loading, Loaded] cuando TranslateTextEvent es exitoso',
      build: () {
        when(() => mockTranslateText(any(), from: any(named: 'from'), to: any(named: 'to')))
            .thenAnswer((_) async => 'Pollo');
        return bloc;
      },
      act: (bloc) => bloc.add(const TranslateTextEvent(text: 'chicken')),
      expect: () => [
        isA<TranslationLoading>(),
        isA<TranslationLoaded>(),
      ],
    );

    blocTest<TranslationBloc, TranslationState>(
      'debe emitir [Loading, Error] cuando TranslateTextEvent falla',
      build: () {
        when(() => mockTranslateText(any(), from: any(named: 'from'), to: any(named: 'to')))
            .thenThrow(Exception('Error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const TranslateTextEvent(text: 'chicken')),
      expect: () => [
        isA<TranslationLoading>(),
        isA<TranslationError>(),
      ],
    );

    blocTest<TranslationBloc, TranslationState>(
      'debe emitir Initial cuando ClearTranslation',
      build: () => bloc,
      seed: () => const TranslationLoaded(translatedText: 'Pollo', originalText: 'chicken'),
      act: (bloc) => bloc.add(const ClearTranslation()),
      expect: () => [isA<TranslationInitial>()],
    );

    blocTest<TranslationBloc, TranslationState>(
      'no debe emitir Loading si texto esta vacio',
      build: () => bloc,
      act: (bloc) => bloc.add(const TranslateTextEvent(text: '')),
      expect: () => [isA<TranslationInitial>()],
    );
  });
}
