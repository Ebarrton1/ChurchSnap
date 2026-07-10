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
              AbsorbPointer(
                child: RadioGroup<WorshipDay>(
                  groupValue: churchConfig.worshipDay,
                  onChanged: (_) {},
                  child: Column(
                    children: WorshipDay.values.map((day) {
                      return RadioListTile<WorshipDay>(
                        value: day,
                        title: Text(day.name),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const Text(
                'This is wired as a read-only starter. Connect it to '
                'Firebase/Firestore in v2.1.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
