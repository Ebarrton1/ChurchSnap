import 'package:flutter/material.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/attendance/models/attendance_record.dart';
import '../../features/attendance/repositories/attendance_history_repository.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({
    super.key,
    required this.memberId,
    required this.churchId,
  });

  final String memberId;
  final String churchId;

  @override
  Widget build(BuildContext context) {
    final repository = AttendanceHistoryRepository(churchId: churchId);

    return Material(
      child: ChurchSnapScreen(
        title: 'Attendance History',
        subtitle: 'Your recent church check-ins',
        children: [
          StreamBuilder<List<AttendanceRecord>>(
            stream: repository.watchMemberAttendance(memberId),
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
                    title: const Text('Unable to load attendance history'),
                    subtitle: Text('${snapshot.error}'),
                  ),
                );
              }

              final records = snapshot.data ?? <AttendanceRecord>[];

              if (records.isEmpty) {
                return const AppCard(
                  child: ListTile(
                    leading: Icon(Icons.event_busy_rounded),
                    title: Text('No attendance records found'),
                    subtitle: Text(
                      'Your check-ins will appear here '
                      'after attending events.',
                    ),
                  ),
                );
              }

              return Column(
                children: records.map((record) {
                  final checkedIn = record.checkedInAt;

                  final dateText = checkedIn == null
                      ? 'Date unavailable'
                      : '${checkedIn.month}/'
                            '${checkedIn.day}/'
                            '${checkedIn.year}  '
                            '${checkedIn.hour.toString().padLeft(2, '0')}:'
                            '${checkedIn.minute.toString().padLeft(2, '0')}';

                  return AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        child: Icon(Icons.check_circle_rounded),
                      ),
                      title: Text(
                        record.eventTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(dateText),
                      trailing: Chip(
                        label: Text(record.checkInMethod.toUpperCase()),
                      ),
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
