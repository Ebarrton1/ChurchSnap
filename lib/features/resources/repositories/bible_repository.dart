import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/bible_models.dart';

abstract interface class BibleRepository {
  Future<BiblePassage> fetchChapter({
    required BibleTranslation translation,
    required BibleBook book,
    required int chapter,
  });
}

class NetworkBibleRepository implements BibleRepository {
  NetworkBibleRepository({http.Client? httpClient, String? licensedProxyUrl})
    : _httpClient = httpClient ?? http.Client(),
      _licensedProxyUrl =
          licensedProxyUrl ??
          const String.fromEnvironment('CHURCHSNAP_BIBLE_PROXY_URL');

  final http.Client _httpClient;
  final String _licensedProxyUrl;
  final Map<String, Future<BiblePassage>> _cache = {};

  @override
  Future<BiblePassage> fetchChapter({
    required BibleTranslation translation,
    required BibleBook book,
    required int chapter,
  }) {
    if (chapter < 1 || chapter > book.chapterCount) {
      return Future<BiblePassage>.error(
        BibleRepositoryException(
          'Chapter $chapter is not valid for ${book.name}.',
        ),
      );
    }

    final cacheKey = '${translation.name}:${book.id}:$chapter';

    return _cache.putIfAbsent(cacheKey, () async {
      try {
        switch (translation) {
          case BibleTranslation.kjv:
            return await _fetchKjvChapter(book: book, chapter: chapter);
          case BibleTranslation.niv:
            return await _fetchLicensedNivChapter(book: book, chapter: chapter);
        }
      } catch (_) {
        _cache.remove(cacheKey);
        rethrow;
      }
    });
  }

  Future<BiblePassage> _fetchKjvChapter({
    required BibleBook book,
    required int chapter,
  }) async {
    final encodedReference = Uri.encodeComponent(book.referenceFor(chapter));
    final uri = Uri.parse('https://bible-api.com/$encodedReference').replace(
      queryParameters: const {
        'translation': 'kjv',
        'single_chapter_book_matching': 'indifferent',
      },
    );

    final data = await _getJson(uri);
    final passage = BiblePassage.fromNormalizedMap(data);

    if (passage.isEmpty) {
      throw const BibleRepositoryException(
        'The selected KJV chapter did not contain any verses.',
      );
    }

    return BiblePassage(
      reference: passage.reference,
      translationName: passage.translationName.isEmpty
          ? BibleTranslation.kjv.displayName
          : passage.translationName,
      translationId: 'KJV',
      verses: passage.verses,
      copyrightNotice: passage.copyrightNotice.isEmpty
          ? 'King James Version - Public Domain.'
          : passage.copyrightNotice,
    );
  }

  Future<BiblePassage> _fetchLicensedNivChapter({
    required BibleBook book,
    required int chapter,
  }) async {
    final configuredUrl = _licensedProxyUrl.trim();

    if (configuredUrl.isEmpty) {
      throw const BibleLicensingException(
        'NIV access is prepared but not yet activated. ChurchSnap must use '
        'a licensed Bible provider through a secure server connection before '
        'the complete New International Version can be displayed.',
      );
    }

    final baseUri = Uri.tryParse(configuredUrl);

    if (baseUri == null || baseUri.scheme != 'https' || baseUri.host.isEmpty) {
      throw const BibleRepositoryException(
        'The configured ChurchSnap Bible proxy must be a valid HTTPS URL.',
      );
    }

    final basePath = baseUri.path.endsWith('/')
        ? baseUri.path.substring(0, baseUri.path.length - 1)
        : baseUri.path;

    final uri = baseUri.replace(
      path: '$basePath/passage',
      queryParameters: {
        'translation': 'niv',
        'book': book.id,
        'chapter': '$chapter',
      },
    );

    final data = await _getJson(uri);
    final passage = BiblePassage.fromNormalizedMap(data);

    if (passage.isEmpty) {
      throw const BibleRepositoryException(
        'The licensed NIV provider returned no verses.',
      );
    }

    return BiblePassage(
      reference: passage.reference,
      translationName: passage.translationName.isEmpty
          ? BibleTranslation.niv.displayName
          : passage.translationName,
      translationId: 'NIV',
      verses: passage.verses,
      copyrightNotice: passage.copyrightNotice,
    );
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    late final http.Response response;

    try {
      response = await _httpClient
          .get(
            uri,
            headers: const <String, String>{'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const BibleRepositoryException(
        'The Bible service took too long to respond. Please try again.',
      );
    } on http.ClientException {
      throw const BibleRepositoryException(
        'ChurchSnap could not reach the Bible service. Check your internet '
        'connection and try again.',
      );
    } catch (_) {
      throw const BibleRepositoryException(
        'The Bible connection was interrupted. Please try again.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode == 429) {
        throw const BibleRepositoryException(
          'The Bible service is receiving too many requests. Please wait a '
          'moment and try again.',
        );
      }

      throw BibleRepositoryException(
        'The Bible service returned error ${response.statusCode}.',
      );
    }

    Object? decoded;

    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const BibleRepositoryException(
        'The Bible service returned an unreadable response.',
      );
    }

    if (decoded is! Map) {
      throw const BibleRepositoryException(
        'The Bible service returned an unexpected response.',
      );
    }

    return Map<String, dynamic>.from(decoded);
  }
}
