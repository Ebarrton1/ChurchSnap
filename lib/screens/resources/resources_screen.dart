import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/resources/controllers/bible_reader_controller.dart';
import '../../features/resources/data/bible_books.dart';
import '../../features/resources/models/bible_models.dart';
import 'resource_library_screen.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key, required this.churchId});

  final String churchId;
  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  late final BibleReaderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BibleReaderController();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Resources')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return ChurchSnapScreen(
            title: 'Bible Reader',
            subtitle: 'Read Scripture and grow in the Word.',
            children: [
              AppCard(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.library_books_rounded),
                  ),
                  title: const Text(
                    'Church Resource Library',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: const Text(
                    'Open song books, Sunday School, Sabbath School, '
                    'study guides, and other church resources.',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            ResourceLibraryScreen(churchId: widget.churchId),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              const _BibleWelcomeCard(),
              const SectionTitle(title: 'Translation'),
              _TranslationSelector(controller: _controller),
              const SizedBox(height: 8),
              const SectionTitle(title: 'Choose a Passage'),
              _PassageSelector(controller: _controller),
              const SizedBox(height: 12),
              _ChapterNavigation(controller: _controller),
              const SizedBox(height: 8),
              _FontSizeControl(controller: _controller),
              const SizedBox(height: 8),
              _PassageContent(controller: _controller),
              const SizedBox(height: 4),
              _TranslationNotice(translation: _controller.translation),
            ],
          );
        },
      ),
    );
  }
}

class _BibleWelcomeCard extends StatelessWidget {
  const _BibleWelcomeCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: EdgeInsets.zero,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF031A2E), colorScheme.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 74,
                height: 74,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(24),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withAlpha(48)),
                ),
                child: Image.asset(
                  'assets/icons/bible.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'THE WORD OF GOD',
                      style: TextStyle(
                        color: Color(0xFF7DD3FC),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.3,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Read the Bible anywhere',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Browse all 66 books and move chapter by chapter.',
                      style: TextStyle(
                        color: Color(0xFFD5E7F6),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TranslationSelector extends StatelessWidget {
  const _TranslationSelector({required this.controller});

  final BibleReaderController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<BibleTranslation>(
              segments: BibleTranslation.values
                  .map((translation) {
                    return ButtonSegment<BibleTranslation>(
                      value: translation,
                      label: Text(translation.abbreviation),
                      icon: Icon(
                        translation == BibleTranslation.kjv
                            ? Icons.menu_book_rounded
                            : Icons.verified_user_rounded,
                      ),
                    );
                  })
                  .toList(growable: false),
              selected: {controller.translation},
              showSelectedIcon: false,
              onSelectionChanged: (selection) {
                controller.selectTranslation(selection.first);
              },
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                controller.translation == BibleTranslation.kjv
                    ? Icons.check_circle_rounded
                    : Icons.verified_user_rounded,
                size: 21,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  controller.translation == BibleTranslation.kjv
                      ? 'King James Version is available now.'
                      : 'NIV requires a licensed provider and secure '
                            'ChurchSnap server connection.',
                  style: const TextStyle(height: 1.35),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PassageSelector extends StatelessWidget {
  const _PassageSelector({required this.controller});

  final BibleReaderController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          DropdownButtonFormField<BibleBook>(
            key: ValueKey('book:${controller.book.id}'),
            initialValue: controller.book,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Book',
              prefixIcon: Icon(Icons.auto_stories_rounded),
              border: OutlineInputBorder(),
            ),
            items: bibleBooks
                .map(
                  (book) => DropdownMenuItem<BibleBook>(
                    value: book,
                    child: Text(book.name),
                  ),
                )
                .toList(growable: false),
            onChanged: controller.loading
                ? null
                : (book) {
                    if (book != null) {
                      controller.selectBook(book);
                    }
                  },
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<int>(
            key: ValueKey(
              'chapter:${controller.book.id}:${controller.chapter}',
            ),
            initialValue: controller.chapter,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Chapter',
              prefixIcon: Icon(Icons.format_list_numbered_rounded),
              border: OutlineInputBorder(),
            ),
            items: List<DropdownMenuItem<int>>.generate(
              controller.book.chapterCount,
              (index) {
                final chapter = index + 1;

                return DropdownMenuItem<int>(
                  value: chapter,
                  child: Text('Chapter $chapter'),
                );
              },
            ),
            onChanged: controller.loading
                ? null
                : (chapter) {
                    if (chapter != null) {
                      controller.selectChapter(chapter);
                    }
                  },
          ),
        ],
      ),
    );
  }
}

class _ChapterNavigation extends StatelessWidget {
  const _ChapterNavigation({required this.controller});

  final BibleReaderController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: controller.canGoPrevious && !controller.loading
                ? controller.previousChapter
                : null,
            icon: const Icon(Icons.chevron_left_rounded),
            label: const Text('Previous'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: controller.canGoNext && !controller.loading
                ? controller.nextChapter
                : null,
            icon: const Icon(Icons.chevron_right_rounded),
            label: const Text('Next'),
          ),
        ),
      ],
    );
  }
}

class _FontSizeControl extends StatelessWidget {
  const _FontSizeControl({required this.controller});

  final BibleReaderController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          const Icon(Icons.remove_rounded),
          Expanded(
            child: Slider(
              value: controller.fontSize,
              min: 14,
              max: 30,
              divisions: 8,
              label: '${controller.fontSize.round()}',
              onChanged: controller.setFontSize,
            ),
          ),
          const Icon(Icons.add_rounded),
        ],
      ),
    );
  }
}

class _PassageContent extends StatelessWidget {
  const _PassageContent({required this.controller});

  final BibleReaderController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.loading) {
      return const AppCard(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 28),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading Scripture...'),
            ],
          ),
        ),
      );
    }

    final errorMessage = controller.errorMessage;

    if (errorMessage != null) {
      final isLicensingMessage = controller.translation == BibleTranslation.niv;

      return AppCard(
        child: Column(
          children: [
            Icon(
              isLicensingMessage
                  ? Icons.verified_user_rounded
                  : Icons.cloud_off_rounded,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              isLicensingMessage
                  ? 'NIV license required'
                  : 'Unable to load this chapter',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(height: 1.45),
            ),
            const SizedBox(height: 16),
            if (!isLicensingMessage)
              FilledButton.icon(
                onPressed: controller.load,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              )
            else
              OutlinedButton.icon(
                onPressed: () {
                  controller.selectTranslation(BibleTranslation.kjv);
                },
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text('Read KJV'),
              ),
          ],
        ),
      );
    }

    final passage = controller.passage;

    if (passage == null || passage.isEmpty) {
      return const AppCard(
        child: Text('Choose a book and chapter to begin reading.'),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      passage.reference,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      passage.translationName.isEmpty
                          ? controller.translation.displayName
                          : passage.translationName,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Copy chapter',
                onPressed: () => _copyChapter(context, passage),
                icon: const Icon(Icons.copy_all_rounded),
              ),
            ],
          ),
          const Divider(height: 28),
          ...passage.verses.map(
            (verse) => _VerseText(verse: verse, fontSize: controller.fontSize),
          ),
        ],
      ),
    );
  }

  Future<void> _copyChapter(BuildContext context, BiblePassage passage) async {
    await Clipboard.setData(ClipboardData(text: passage.plainText));

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${passage.reference} copied to the clipboard.'),
        ),
      );
  }
}

class _VerseText extends StatelessWidget {
  const _VerseText({required this.verse, required this.fontSize});

  final BibleVerse verse;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SelectableText.rich(
        TextSpan(
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: fontSize,
            height: 1.6,
          ),
          children: [
            TextSpan(
              text: '${verse.verse} ',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: fontSize * 0.72,
                fontWeight: FontWeight.w900,
              ),
            ),
            TextSpan(text: verse.text),
          ],
        ),
      ),
    );
  }
}

class _TranslationNotice extends StatelessWidget {
  const _TranslationNotice({required this.translation});

  final BibleTranslation translation;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          child: Icon(
            translation == BibleTranslation.kjv
                ? Icons.public_rounded
                : Icons.verified_user_rounded,
          ),
        ),
        title: Text(
          translation == BibleTranslation.kjv
              ? 'KJV availability'
              : 'NIV licensing',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          translation == BibleTranslation.kjv
              ? 'King James Version Scripture is loaded on demand. '
                    'An internet connection is required.'
              : 'ChurchSnap does not bundle or expose unlicensed NIV text. '
                    'The reader is ready for a licensed secure provider.',
        ),
      ),
    );
  }
}
