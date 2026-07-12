import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/prayer/providers/prayer_providers.dart';
import '../../models/prayer_request.dart';

class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key, required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayers = ref.watch(prayerRequestsByChurchProvider(churchId));

    return Material(
      child: ChurchSnapScreen(
        title: 'Prayer',
        subtitle: 'Share requests and pray together.',
        children: [
          FilledButton.icon(
            onPressed: () => _openPrayerForm(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Prayer Request'),
          ),
          const SizedBox(height: 18),
          const SectionTitle(title: 'Prayer Wall'),
          prayers.when(
            loading: () => const AppCard(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => AppCard(
              child: ListTile(
                leading: const Icon(Icons.error_outline_rounded),
                title: const Text('Unable to load prayer requests'),
                subtitle: Text('$error'),
              ),
            ),
            data: (requests) {
              if (requests.isEmpty) {
                return const AppCard(
                  child: ListTile(
                    leading: Icon(Icons.favorite_outline),
                    title: Text('No prayer requests yet'),
                    subtitle: Text('Be the first to submit a prayer request.'),
                  ),
                );
              }

              return Column(
                children: requests.map((request) {
                  return AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        child: Icon(Icons.favorite_rounded),
                      ),
                      title: Text(
                        request.name,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(request.request),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openPrayerForm(BuildContext context) async {
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PrayerRequestSheet(churchId: churchId),
    );

    if (submitted != true || !context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Prayer request submitted.')));
  }
}

class _PrayerRequestSheet extends ConsumerStatefulWidget {
  const _PrayerRequestSheet({required this.churchId});

  final String churchId;

  @override
  ConsumerState<_PrayerRequestSheet> createState() =>
      _PrayerRequestSheetState();
}

class _PrayerRequestSheetState extends ConsumerState<_PrayerRequestSheet> {
  final TextEditingController _controller = TextEditingController();

  bool _privateRequest = false;
  bool _saving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        8,
        22,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            enabled: !_saving,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Prayer request',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Private request'),
            subtitle: const Text(
              'Only church leaders can view private requests.',
            ),
            value: _privateRequest,
            onChanged: _saving
                ? null
                : (value) {
                    setState(() {
                      _privateRequest = value;
                    });
                  },
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Enter a prayer request before submitting.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(prayerServiceByChurchProvider(widget.churchId))
          .submitPrayerRequest(
            PrayerRequest(
              name: 'Anonymous',
              request: text,
              isPrivate: _privateRequest,
              published: !_privateRequest,
            ),
          );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _saving = false;
        _errorMessage = 'Unable to submit prayer request: $error';
      });
    }
  }
}
