import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/auth/state/auth_controller.dart';
import '../../features/volunteers/models/volunteer_assignment.dart';
import '../../features/volunteers/providers/volunteer_providers.dart';

class MyScheduleScreen extends ConsumerWidget {
  final AuthController authController;

  const MyScheduleScreen({super.key, required this.authController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = authController.currentUser?.id ?? '';

    return ChurchSnapScreen(
      title: 'My Schedule',
      subtitle: 'Your upcoming volunteer assignments',
      children: [
        StreamBuilder<List<VolunteerAssignment>>(
          stream: ref
              .read(volunteerServiceProvider)
              .watchAssignmentsForMember(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppCard(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return AppCard(child: Text('Error: ${snapshot.error}'));
            }

            final assignments = snapshot.data ?? [];

            if (assignments.isEmpty) {
              return const AppCard(
                child: Text('You have no volunteer assignments.'),
              );
            }

            return Column(
              children: assignments.map((assignment) {
                return AppCard(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.volunteer_activism_rounded),
                    ),
                    title: Text(assignment.ministryName),
                    subtitle: Text(
                      '${assignment.role}\n'
                      '${assignment.servingDate?.month}/${assignment.servingDate?.day}/${assignment.servingDate?.year}',
                    ),
                    isThreeLine: true,
                    trailing: Chip(label: Text(assignment.status)),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
