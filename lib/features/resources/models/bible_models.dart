enum BibleTranslation { kjv, niv }

extension BibleTranslationDetails on BibleTranslation {
  String get abbreviation {
    switch (this) {
      case BibleTranslation.kjv:
        return 'KJV';
      case BibleTranslation.niv:
        return 'NIV';
    }
  }

  String get displayName {
    switch (this) {
      case BibleTranslation.kjv:
        return 'King James Version';
      case BibleTranslation.niv:
        return 'New International Version';
    }
  }

  bool get requiresLicensedProvider => this == BibleTranslation.niv;
}

class BibleBook {
  const BibleBook({
    required this.id,
    required this.name,
    required this.chapterCount,
  });

  final String id;
  final String name;
  final int chapterCount;

  String referenceFor(int chapter) => '$name $chapter';

  @override
  String toString() => name;
}

class BibleVerse {
  const BibleVerse({
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  final String bookName;
  final int chapter;
  final int verse;
  final String text;

  String get reference => '$bookName $chapter:$verse';

  factory BibleVerse.fromMap(Map<String, dynamic> map) {
    return BibleVerse(
      bookName: (map['book_name'] as String? ?? '').trim(),
      chapter: _asInt(map['chapter']),
      verse: _asInt(map['verse']),
      text: _normalizeVerseText(map['text'] as String? ?? ''),
    );
  }

  static int _asInt(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse('$value') ?? 0;
  }

  static String _normalizeVerseText(String value) {
    return value
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('\u00B6 ', '')
        .trim();
  }
}

class BiblePassage {
  const BiblePassage({
    required this.reference,
    required this.translationName,
    required this.translationId,
    required this.verses,
    this.copyrightNotice = '',
  });

  final String reference;
  final String translationName;
  final String translationId;
  final List<BibleVerse> verses;
  final String copyrightNotice;

  bool get isEmpty => verses.isEmpty;

  String get plainText {
    final buffer = StringBuffer('$reference ($translationId)\n\n');

    for (final verse in verses) {
      buffer.writeln('${verse.verse} ${verse.text}');
    }

    if (copyrightNotice.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(copyrightNotice.trim());
    }

    return buffer.toString().trim();
  }

  factory BiblePassage.fromNormalizedMap(Map<String, dynamic> map) {
    final rawVerses = map['verses'];

    final verses = rawVerses is List
        ? rawVerses
              .whereType<Map>()
              .map(
                (verse) => BibleVerse.fromMap(Map<String, dynamic>.from(verse)),
              )
              .where((verse) => verse.verse > 0 && verse.text.isNotEmpty)
              .toList(growable: false)
        : const <BibleVerse>[];

    return BiblePassage(
      reference: (map['reference'] as String? ?? '').trim(),
      translationName: (map['translation_name'] as String? ?? '').trim(),
      translationId: (map['translation_id'] as String? ?? '').trim().isEmpty
          ? 'KJV'
          : (map['translation_id'] as String).trim().toUpperCase(),
      copyrightNotice:
          (map['copyright'] as String? ??
                  map['copyright_notice'] as String? ??
                  '')
              .trim(),
      verses: verses,
    );
  }
}

class BibleRepositoryException implements Exception {
  const BibleRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BibleLicensingException extends BibleRepositoryException {
  const BibleLicensingException(super.message);
}
