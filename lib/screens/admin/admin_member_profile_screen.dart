import 'package:flutter/material.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/members/models/church_member.dart';

class AdminMemberProfileScreen extends StatelessWidget {
  final ChurchMember member;

  const AdminMemberProfileScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return ChurchSnapScreen(
      title: member.displayName,
      subtitle: 'Member profile',
      children: [
        AppCard(
          child: Column(
            children: [
              CircleAvatar(
                radius: 38,
                child: Text(
                  member.displayName.isNotEmpty
                      ? member.displayName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                member.displayName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(member.email),
              const SizedBox(height: 12),
              Chip(label: Text(member.role)),
            ],
          ),
        ),
        AppCard(
          child: ListTile(
            leading: const Icon(Icons.phone_rounded),
            title: const Text('Phone'),
            subtitle: Text(member.phone.isEmpty ? 'Not added' : member.phone),
          ),
        ),
        AppCard(
          child: ListTile(
            leading: const Icon(Icons.verified_user_rounded),
            title: const Text('Status'),
            subtitle: Text(member.isActive ? 'Active' : 'Inactive'),
          ),
        ),
        AppCard(
          child: ListTile(
            leading: const Icon(Icons.event_available_rounded),
            title: const Text('Attendance History'),
            subtitle: const Text('Coming soon'),
          ),
        ),
      ],
    );
  }
}
