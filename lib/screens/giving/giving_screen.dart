import 'package:flutter/material.dart';

import '../../core/widgets/churchsnap_screen.dart';

class GivingScreen extends StatefulWidget {
  const GivingScreen({super.key});

  @override
  State<GivingScreen> createState() => _GivingScreenState();
}

class _GivingScreenState extends State<GivingScreen> {
  int amount = 25;
  String fund = 'Tithe & Offering';
  bool recurring = false;

  @override
  Widget build(BuildContext context) {
    return ChurchSnapScreen(
      title: 'Giving',
      subtitle: 'Support your church securely.',
      children: [
        const SectionTitle(title: 'Choose Amount'),
        Wrap(
          spacing: 10,
          children: [10, 25, 50, 100, 250].map((value) {
            return ChoiceChip(
              label: Text('\$$value'),
              selected: amount == value,
              onSelected: (_) => setState(() => amount = value),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          value: fund,
          decoration: const InputDecoration(
            labelText: 'Fund',
            border: OutlineInputBorder(),
          ),
          items: const [
            'Tithe & Offering',
            'Missions',
            'Building Fund',
            'Youth Ministry',
          ].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
          onChanged: (value) => setState(() => fund = value ?? fund),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: recurring,
          title: const Text('Make this recurring'),
          onChanged: (value) => setState(() => recurring = value),
        ),
        FilledButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Demo only: \$$amount gift to $fund is ready.'),
            ),
          ),
          icon: const Icon(Icons.lock_rounded),
          label: const Text('Continue Securely'),
        ),
      ],
    );
  }
}
