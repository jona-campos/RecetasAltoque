class CachedTranslation {
  final String originalText;
  final String translatedText;
  final String sourceLang;
  final String targetLang;
  final DateTime timestamp;

  const CachedTranslation({
    required this.originalText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    required this.timestamp,
  });

  factory CachedTranslation.fromJson(Map<String, dynamic> json) {
    return CachedTranslation(
      originalText: json['originalText'] as String? ?? '',
      translatedText: json['translatedText'] as String? ?? '',
      sourceLang: json['sourceLang'] as String? ?? 'en',
      targetLang: json['targetLang'] as String? ?? 'es',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originalText': originalText,
      'translatedText': translatedText,
      'sourceLang': sourceLang,
      'targetLang': targetLang,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get isExpired {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference.inDays > 30;
  }

  CachedTranslation copyWith({
    String? originalText,
    String? translatedText,
    String? sourceLang,
    String? targetLang,
    DateTime? timestamp,
  }) {
    return CachedTranslation(
      originalText: originalText ?? this.originalText,
      translatedText: translatedText ?? this.translatedText,
      sourceLang: sourceLang ?? this.sourceLang,
      targetLang: targetLang ?? this.targetLang,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
