import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/volunteers/models/volunteer_assignment.dart';
import '../../features/volunteers/providers/volunteer_providers.dart';

class AdminVolunteerScheduleScreen extends ConsumerWidget {
  const AdminVolunteerScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volunteerService = ref.read(volunteerServiceProvider);

    return ChurchSnapScreen(
      title: 'Volunteer Schedule',
      subtitle: 'Assign volunteers to ministries.',
      children: [
        FilledButton.icon(
          onPressed: () => _showAssignmentDialog(context, ref),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Assignment'),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<VolunteerAssignment>>(
          stream: volunteerService.watchAssignments(),
          builder: (context, snapshot) {
            final assignments = snapshot.data ?? [];

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppCard(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (assignments.isEmpty) {
              return const AppCard(
                child: Text('No volunteer assignments yet.'),
              );
            }

            return Column(
              children: assignments.map((assignment) {
                return AppCard(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.volunteer_activism_rounded),
                    ),
                    title: Text(assignment.memberName),
                    subtitle: Text(
                      '${assignment.ministryName}\n${assignment.role}',
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

  void _showAssignmentDialog(BuildContext context, WidgetRef ref) {
    final ministryController = TextEditingController();
    final memberController = TextEditingController();
    final roleController = TextEditingController();

    DateTime? servingDate;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Assignment'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: ministryController,
                      decoration: const InputDecoration(
                        labelText: 'Ministry name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: memberController,
                      decoration: const InputDecoration(
                        labelText: 'Volunteer name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: roleController,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        hintText: 'Greeter, Usher, Camera, Worship Team',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_month_rounded),
                      title: Text(
                        servingDate == null
                            ? 'Choose serving date'
                            : '${servingDate!.month}/${servingDate!.day}/${servingDate!.year}',
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: servingDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 1),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );

                        if (picked != null) {
                          setDialogState(() => servingDate = picked);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    await ref
                        .read(volunteerServiceProvider)
                        .addAssignment(
                          VolunteerAssignment(
                            ministryId: '',
                            ministryName: ministryController.text.trim(),
                            memberId: '',
                            memberName: memberController.text.trim(),
                            role: roleController.text.trim().isEmpty
                                ? 'Volunteer'
                                : roleController.text.trim(),
                            servingDate: servingDate,
                          ),
                        );

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      ministryController.dispose();
      memberController.dispose();
      roleController.dispose();
    });
  }
}
