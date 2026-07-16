import 'package:flutter/foundation.dart';

import '../data/bible_books.dart';
import '../models/bible_models.dart';
import '../repositories/bible_repository.dart';

class BibleReaderController extends ChangeNotifier {
  BibleReaderController({BibleRepository? repository})
    : _repository = repository ?? NetworkBibleRepository();

  final BibleRepository _repository;

  BibleTranslation _translation = BibleTranslation.kjv;
  BibleBook _book = bibleBookById('JHN');
  int _chapter = 3;
  double _fontSize = 18;
  bool _loading = false;
  BiblePassage? _passage;
  String? _errorMessage;

  BibleTranslation get translation => _translation;
  BibleBook get book => _book;
  int get chapter => _chapter;
  double get fontSize => _fontSize;
  bool get loading => _loading;
  BiblePassage? get passage => _passage;
  String? get errorMessage => _errorMessage;

  bool get canGoPrevious {
    return _chapter > 1 || bibleBookIndex(_book) > 0;
  }

  bool get canGoNext {
    final bookIndex = bibleBookIndex(_book);

    return _chapter < _book.chapterCount || bookIndex < bibleBooks.length - 1;
  }

  Future<void> initialize() => load();

  Future<void> selectTranslation(BibleTranslation translation) async {
    if (_translation == translation) {
      return;
    }

    _translation = translation;
    await load();
  }

  Future<void> selectBook(BibleBook book) async {
    if (_book.id == book.id) {
      return;
    }

    _book = book;
    _chapter = 1;
    await load();
  }

  Future<void> selectChapter(int chapter) async {
    final normalized = chapter.clamp(1, _book.chapterCount).toInt();

    if (_chapter == normalized) {
      return;
    }

    _chapter = normalized;
    await load();
  }

  void setFontSize(double value) {
    final normalized = value.clamp(14, 30).toDouble();

    if (_fontSize == normalized) {
      return;
    }

    _fontSize = normalized;
    notifyListeners();
  }

  Future<void> previousChapter() async {
    if (!canGoPrevious || _loading) {
      return;
    }

    if (_chapter > 1) {
      _chapter -= 1;
    } else {
      final previousBookIndex = bibleBookIndex(_book) - 1;
      _book = bibleBooks[previousBookIndex];
      _chapter = _book.chapterCount;
    }

    await load();
  }

  Future<void> nextChapter() async {
    if (!canGoNext || _loading) {
      return;
    }

    if (_chapter < _book.chapterCount) {
      _chapter += 1;
    } else {
      final nextBookIndex = bibleBookIndex(_book) + 1;
      _book = bibleBooks[nextBookIndex];
      _chapter = 1;
    }

    await load();
  }

  Future<void> load() async {
    _loading = true;
    _errorMessage = null;
    _passage = null;
    notifyListeners();

    try {
      _passage = await _repository.fetchChapter(
        translation: _translation,
        book: _book,
        chapter: _chapter,
      );
    } on BibleRepositoryException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage =
          'ChurchSnap was unable to load this chapter. Please try again.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
