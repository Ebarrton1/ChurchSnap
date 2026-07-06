import 'package:flutter/material.dart';

import '../../core/constants/church_config.dart';
import '../../core/widgets/churchsnap_screen.dart';

class ChurchSettingsScreen extends StatelessWidget {
  const ChurchSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChurchSnapScreen(
      title: 'Church Settings',
      subtitle: 'Configure worship language and church branding.',
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Primary Worship Day',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              ...WorshipDay.values.map(
                (day) => RadioListTile<WorshipDay>(
                  value: day,
                  groupValue: churchConfig.worshipDay,
                  onChanged: null,
                  title: Text(day.name),
                ),
              ),
              const Text(
                'This is wired as a read-only starter. Connect it to Firebase/Firestore in v2.1.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
