import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/resources/models/church_resource.dart';
import '../../features/resources/providers/church_resource_providers.dart';
import 'pdf_resource_viewer_screen.dart';

class ResourceLibraryScreen extends ConsumerStatefulWidget {
  const ResourceLibraryScreen({super.key, required this.churchId});

  final String churchId;

  @override
  ConsumerState<ResourceLibraryScreen> createState() =>
      _ResourceLibraryScreenState();
}

class _ResourceLibraryScreenState extends ConsumerState<ResourceLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  ChurchResourceCategory? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resourcesAsync = ref.watch(
      publishedChurchResourcesByChurchProvider(widget.churchId),
    );

    return Material(
      child: ChurchSnapScreen(
        title: 'Resource Library',
        subtitle: 'Books, lessons, study guides, and ministry resources.',
        children: [
          AppCard(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search resources',
                hintText: 'Song book, Sabbath School, Bible study...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();

                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          const SectionTitle(title: 'Categories'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _selectedCategory == null,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                  ),
                ),
                ...ChurchResourceCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category.label),
                      selected: _selectedCategory == category,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const SectionTitle(title: 'Available Resources'),
          resourcesAsync.when(
            loading: () => const AppCard(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (error, _) => AppCard(
              child: ListTile(
                leading: const Icon(Icons.error_outline_rounded),
                title: const Text('Unable to load resources'),
                subtitle: Text('$error'),
              ),
            ),
            data: (resources) {
              final filtered = resources.where((resource) {
                if (_selectedCategory != null &&
                    resource.category != _selectedCategory) {
                  return false;
                }

                if (_searchQuery.isEmpty) {
                  return true;
                }

                final searchText = [
                  resource.title,
                  resource.description,
                  resource.category.label,
                  resource.fileName,
                ].join(' ').toLowerCase();

                return searchText.contains(_searchQuery);
              }).toList();

              if (filtered.isEmpty) {
                return const AppCard(
                  child: ListTile(
                    leading: Icon(Icons.library_books_outlined),
                    title: Text('No resources found'),
                    subtitle: Text(
                      'Published church resources will appear here.',
                    ),
                  ),
                );
              }

              return Column(
                children: filtered.map((resource) {
                  return _ResourceCard(
                    resource: resource,
                    onOpen: () => _openResource(resource),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openResource(ChurchResource resource) async {
    final uri = Uri.tryParse(resource.openUrl);

    if (uri == null) {
      _showMessage('This resource does not have a valid link.');
      return;
    }

    if (resource.isPdf) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => PdfResourceViewerScreen(resource: resource),
        ),
      );
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && mounted) {
      _showMessage('No app was available to open this resource.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({required this.resource, required this.onOpen});

  final ChurchResource resource;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final details = [
      resource.category.label,
      resource.kind.label,
      if (resource.sizeLabel.isNotEmpty) resource.sizeLabel,
    ].join(' | ');

    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(child: Icon(_resourceIcon(resource.category))),
        title: Text(
          resource.title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          resource.description.isEmpty
              ? details
              : '${resource.description}\n$details',
        ),
        isThreeLine: resource.description.isNotEmpty,
        trailing: const Icon(Icons.open_in_new_rounded),
        onTap: resource.canOpen ? onOpen : null,
      ),
    );
  }
}

IconData _resourceIcon(ChurchResourceCategory category) {
  return switch (category) {
    ChurchResourceCategory.songBook => Icons.music_note_rounded,
    ChurchResourceCategory.sundaySchool => Icons.school_rounded,
    ChurchResourceCategory.sabbathSchool => Icons.menu_book_rounded,
    ChurchResourceCategory.bibleStudy => Icons.auto_stories_rounded,
    ChurchResourceCategory.youth => Icons.groups_rounded,
    ChurchResourceCategory.children => Icons.child_care_rounded,
    ChurchResourceCategory.ministry => Icons.church_rounded,
    ChurchResourceCategory.other => Icons.folder_rounded,
  };
}
