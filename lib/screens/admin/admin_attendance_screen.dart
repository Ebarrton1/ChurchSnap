import 'package:flutter/material.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/check_in/models/check_in_record.dart';
import '../../features/check_in/repositories/check_in_repository.dart';

class AdminAttendanceScreen extends StatelessWidget {
  const AdminAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = CheckInRepository();

    return ChurchSnapScreen(
      title: 'Attendance',
      subtitle: 'View recent event check-ins.',
      children: [
        StreamBuilder<List<CheckInRecord>>(
          stream: repository.watchAllRecentCheckIns(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppCard(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final checkIns = snapshot.data ?? <CheckInRecord>[];

            if (checkIns.isEmpty) {
              return const AppCard(child: Text('No check-ins yet.'));
            }

            return Column(
              children: checkIns.map((checkIn) {
                return AppCard(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.how_to_reg_rounded),
                    ),
                    title: Text(checkIn.displayName),
                    subtitle: Text('Event ID: ${checkIn.eventId}'),
                    trailing: const Icon(Icons.check_circle_rounded),
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
