import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/translate_text.dart';
import 'translation_event.dart';
import 'translation_state.dart';

class TranslationBloc extends Bloc<TranslationEvent, TranslationState> {
  final TranslateText translateText;

  TranslationBloc({required this.translateText}) : super(const TranslationInitial()) {
    on<TranslateTextEvent>(_onTranslateText);
    on<ClearTranslation>(_onClearTranslation);
  }

  Future<void> _onTranslateText(
    TranslateTextEvent event,
    Emitter<TranslationState> emit,
  ) async {
    if (event.text.trim().isEmpty) {
      emit(const TranslationInitial());
      return;
    }

    emit(const TranslationLoading());

    try {
      final translation = await translateText(
        event.text,
        from: event.from,
        to: event.to,
      );
      emit(TranslationLoaded(
        translatedText: translation,
        originalText: event.text,
      ));
    } catch (e) {
      emit(TranslationError(message: e.toString()));
    }
  }

  void _onClearTranslation(
    ClearTranslation event,
    Emitter<TranslationState> emit,
  ) {
    emit(const TranslationInitial());
  }
}
