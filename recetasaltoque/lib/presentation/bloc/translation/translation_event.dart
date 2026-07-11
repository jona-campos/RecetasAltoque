import 'package:equatable/equatable.dart';

abstract class TranslationEvent extends Equatable {
  const TranslationEvent();

  @override
  List<Object?> get props => [];
}

class TranslateTextEvent extends TranslationEvent {
  final String text;
  final String from;
  final String to;

  const TranslateTextEvent({
    required this.text,
    this.from = 'en',
    this.to = 'es',
  });

  @override
  List<Object?> get props => [text, from, to];
}

class ClearTranslation extends TranslationEvent {
  const ClearTranslation();
}
