import 'package:flutter/material.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../models/prayer_request.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  final requests = <PrayerRequest>[
    const PrayerRequest(
      name: 'Church Family',
      request: 'Pray for healing, strength, and unity this week.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
        ...requests.map(
          (request) => AppCard(
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
          ),
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
      builder: (context) => Padding(
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
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isNotEmpty)
                    setState(
                      () => requests.insert(
                        0,
                        PrayerRequest(name: 'Anonymous', request: text),
                      ),
                    );
                  Navigator.pop(context);
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(controller.dispose);
  }
}
