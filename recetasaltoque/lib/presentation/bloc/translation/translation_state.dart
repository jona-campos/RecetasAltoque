import 'package:equatable/equatable.dart';

abstract class TranslationState extends Equatable {
  const TranslationState();

  @override
  List<Object?> get props => [];
}

class TranslationInitial extends TranslationState {
  const TranslationInitial();
}

class TranslationLoading extends TranslationState {
  const TranslationLoading();
}

class TranslationLoaded extends TranslationState {
  final String translatedText;
  final String originalText;

  const TranslationLoaded({
    required this.translatedText,
    required this.originalText,
  });

  @override
  List<Object?> get props => [translatedText, originalText];
}

class TranslationError extends TranslationState {
  final String message;

  const TranslationError({required this.message});

  @override
  List<Object?> get props => [message];
}
