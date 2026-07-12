import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/auth/state/auth_controller.dart';
import '../../features/volunteers/models/volunteer_assignment.dart';
import '../../features/volunteers/providers/volunteer_providers.dart';

class MyScheduleScreen extends ConsumerWidget {
  const MyScheduleScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = authController.currentUser;
    final userId = currentUser?.id ?? '';

    final rawChurchId = currentUser?.churchId.trim() ?? '';

    final churchId = rawChurchId.isEmpty ? 'demo-church' : rawChurchId;

    final volunteerService = ref.read(
      volunteerServiceByChurchProvider(churchId),
    );

    return Material(
      child: ChurchSnapScreen(
        title: 'My Schedule',
        subtitle: 'Your upcoming volunteer assignments',
        children: [
          StreamBuilder<List<VolunteerAssignment>>(
            stream: volunteerService.watchAssignmentsForMember(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AppCard(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return AppCard(
                  child: Text(
                    'Unable to load schedule: '
                    '${snapshot.error}',
                  ),
                );
              }

              final assignments = snapshot.data ?? <VolunteerAssignment>[];

              if (assignments.isEmpty) {
                return const AppCard(
                  child: Text('You have no volunteer assignments.'),
                );
              }

              return Column(
                children: assignments.map((assignment) {
                  final date = assignment.servingDate;

                  return AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        child: Icon(Icons.volunteer_activism_rounded),
                      ),
                      title: Text(assignment.ministryName),
                      subtitle: Text(
                        '${assignment.role}\n'
                        '${date == null ? 'Date not selected' : '${date.month}/${date.day}/${date.year}'}',
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
      ),
    );
  }
}
