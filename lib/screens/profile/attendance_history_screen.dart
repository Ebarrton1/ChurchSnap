import 'package:flutter/material.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/attendance/models/attendance_record.dart';
import '../../features/attendance/repositories/attendance_history_repository.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key, required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context) {
    final repository = AttendanceHistoryRepository();

    return ChurchSnapScreen(
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
              return const AppCard(
                child: ListTile(
                  leading: Icon(Icons.error_outline),
                  title: Text('Unable to load attendance history'),
                ),
              );
            }

            final records = snapshot.data ?? [];

            if (records.isEmpty) {
              return const AppCard(
                child: ListTile(
                  leading: Icon(Icons.event_busy),
                  title: Text('No attendance records found'),
                  subtitle: Text(
                    'Your check-ins will appear here after attending events.',
                  ),
                ),
              );
            }

            return Column(
              children: records.map((record) {
                final checkedIn = record.checkedInAt;

                return AppCard(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.check_circle_rounded),
                    ),
                    title: Text(
                      record.eventTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      checkedIn == null
                          ? 'Date unavailable'
                          : '${checkedIn.month}/${checkedIn.day}/${checkedIn.year}'
                                '  ${checkedIn.hour.toString().padLeft(2, '0')}:'
                                '${checkedIn.minute.toString().padLeft(2, '0')}',
                    ),
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
    );
  }
}
