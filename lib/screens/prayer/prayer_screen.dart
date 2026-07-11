import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/prayer/providers/prayer_providers.dart';
import '../../models/prayer_request.dart';

class PrayerScreen extends ConsumerStatefulWidget {
  const PrayerScreen({super.key, required this.churchId});

  final String churchId;

  @override
  ConsumerState<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends ConsumerState<PrayerScreen> {
  @override
  Widget build(BuildContext context) {
    final prayers = ref.watch(prayerRequestsByChurchProvider(widget.churchId));

    return ChurchSnapScreen(
      title: 'Prayer',
      subtitle: 'Share requests and pray together.',
      children: [
        FilledButton.icon(
          onPressed: _openPrayerForm,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Prayer Request'),
        ),
        const SizedBox(height: 18),
        const SectionTitle(title: 'Prayer Wall'),
        prayers.when(
          loading: () =>
              const AppCard(child: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) =>
              const AppCard(child: Text('Unable to load prayer requests.')),
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
                    leading: CircleAvatar(
                      child: Icon(
                        request.isPrivate
                            ? Icons.lock_rounded
                            : Icons.favorite_rounded,
                      ),
                    ),
                    title: Text(
                      request.isPrivate ? 'Private Request' : request.name,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      request.isPrivate
                          ? 'Shared privately with church leaders.'
                          : request.request,
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  void _openPrayerForm() {
    final controller = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            8,
            22,
            MediaQuery.of(sheetContext).viewInsets.bottom + 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Prayer request',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final text = controller.text.trim();

                    if (text.isEmpty) return;

                    await ref
                        .read(prayerServiceByChurchProvider(widget.churchId))
                        .submitPrayerRequest(
                          PrayerRequest(
                            name: 'Anonymous',
                            request: text,
                            isPrivate: false,
                          ),
                        );

                    if (!sheetContext.mounted) return;

                    Navigator.pop(sheetContext);
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(controller.dispose);
  }
}
