import 'package:flutter/material.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/check_in/models/check_in_record.dart';
import '../../features/check_in/repositories/check_in_repository.dart';

class AdminAttendanceScreen extends StatelessWidget {
  const AdminAttendanceScreen({super.key, required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context) {
    final repository = CheckInRepository(churchId: churchId);

    return Material(
      child: ChurchSnapScreen(
        title: 'Attendance',
        subtitle: 'View recent event check-ins for your church.',
        children: [
          StreamBuilder<List<CheckInRecord>>(
            stream: repository.watchAllRecentCheckIns(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AppCard(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return AppCard(
                  child: ListTile(
                    leading: const Icon(Icons.error_outline_rounded),
                    title: const Text('Unable to load attendance'),
                    subtitle: Text('${snapshot.error}'),
                  ),
                );
              }

              final checkIns = snapshot.data ?? <CheckInRecord>[];

              if (checkIns.isEmpty) {
                return const AppCard(
                  child: ListTile(
                    leading: Icon(Icons.event_busy_rounded),
                    title: Text('No check-ins yet'),
                    subtitle: Text('Member and QR check-ins will appear here.'),
                  ),
                );
              }

              return Column(
                children: checkIns.map((checkIn) {
                  return AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        child: Icon(Icons.how_to_reg_rounded),
                      ),
                      title: Text(
                        checkIn.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text('Event ID: ${checkIn.eventId}'),
                      trailing: const Icon(Icons.check_circle_rounded),
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
