import 'package:flutter_test/flutter_test.dart';

import 'package:churchsnap/features/resources/data/bible_books.dart';
import 'package:churchsnap/features/resources/models/bible_models.dart';

void main() {
  group('Bible catalog', () {
    test('contains all 66 canonical books', () {
      expect(bibleBooks, hasLength(66));
      expect(bibleBooks.first.id, 'GEN');
      expect(bibleBooks.first.chapterCount, 50);
      expect(bibleBooks.last.id, 'REV');
      expect(bibleBooks.last.chapterCount, 22);
    });

    test('looks up John and its chapter count', () {
      final john = bibleBookById('JHN');

      expect(john.name, 'John');
      expect(john.chapterCount, 21);
      expect(john.referenceFor(3), 'John 3');
    });
  });

  group('Bible passage parsing', () {
    test('parses normalized API verse data', () {
      final passage = BiblePassage.fromNormalizedMap({
        'reference': 'John 3:16',
        'translation_name': 'King James Version',
        'translation_id': 'kjv',
        'verses': [
          {
            'book_name': 'John',
            'chapter': 3,
            'verse': 16,
            'text': 'For God so loved the world...',
          },
        ],
      });

      expect(passage.reference, 'John 3:16');
      expect(passage.translationId, 'KJV');
      expect(passage.verses, hasLength(1));
      expect(passage.verses.single.reference, 'John 3:16');
      expect(passage.plainText, contains('16 For God so loved the world...'));
    });

    test('normalizes whitespace in verse text', () {
      final verse = BibleVerse.fromMap({
        'book_name': 'Psalms',
        'chapter': 23,
        'verse': 1,
        'text': '  The Lord   is my shepherd;  ',
      });

      expect(verse.text, 'The Lord is my shepherd;');
    });

    test('marks NIV as requiring a licensed provider', () {
      expect(BibleTranslation.niv.requiresLicensedProvider, isTrue);
      expect(BibleTranslation.kjv.requiresLicensedProvider, isFalse);
    });
  });
}
