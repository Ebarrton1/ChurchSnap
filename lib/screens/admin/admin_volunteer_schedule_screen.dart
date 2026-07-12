import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/members/models/church_member.dart';
import '../../features/members/providers/member_providers.dart';
import '../../features/ministries/models/ministry.dart';
import '../../features/ministries/providers/ministry_providers.dart';
import '../../features/volunteers/models/volunteer_assignment.dart';
import '../../features/volunteers/providers/volunteer_providers.dart';

class AdminVolunteerScheduleScreen extends ConsumerWidget {
  const AdminVolunteerScheduleScreen({super.key, required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volunteerService = ref.read(
      volunteerServiceByChurchProvider(churchId),
    );

    return Material(
      child: ChurchSnapScreen(
        title: 'Volunteer Schedule',
        subtitle: 'Assign volunteers to ministries.',
        children: [
          FilledButton.icon(
            onPressed: () => _openAssignmentDialog(context, ref),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Assignment'),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<VolunteerAssignment>>(
            stream: volunteerService.watchAssignments(),
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
                    title: const Text('Unable to load assignments'),
                    subtitle: Text('${snapshot.error}'),
                  ),
                );
              }

              final assignments = snapshot.data ?? <VolunteerAssignment>[];

              if (assignments.isEmpty) {
                return const AppCard(
                  child: Text('No volunteer assignments yet.'),
                );
              }

              return Column(
                children: assignments.map((assignment) {
                  return AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        child: Icon(Icons.volunteer_activism_rounded),
                      ),
                      title: Text(
                        assignment.memberName,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(
                        '${assignment.ministryName}\n'
                        '${assignment.role} • '
                        '${_formatDate(assignment.servingDate)}',
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            _deleteAssignment(context, ref, assignment);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
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

  Future<void> _openAssignmentDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _AssignmentDialog(churchId: churchId),
    );

    if (saved != true || !context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Volunteer assignment created.')),
    );
  }

  Future<void> _deleteAssignment(
    BuildContext context,
    WidgetRef ref,
    VolunteerAssignment assignment,
  ) async {
    try {
      await ref
          .read(volunteerServiceByChurchProvider(churchId))
          .deleteAssignment(assignment.id);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Volunteer assignment deleted.')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete assignment: $error')),
      );
    }
  }

  static String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Date not selected';
    }

    return '${date.month}/${date.day}/${date.year}';
  }
}

class _AssignmentDialog extends ConsumerStatefulWidget {
  const _AssignmentDialog({required this.churchId});

  final String churchId;

  @override
  ConsumerState<_AssignmentDialog> createState() => _AssignmentDialogState();
}

class _AssignmentDialogState extends ConsumerState<_AssignmentDialog> {
  final TextEditingController _roleController = TextEditingController();

  Ministry? _selectedMinistry;
  ChurchMember? _selectedMember;
  DateTime? _servingDate;

  bool _saving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ministryService = ref.read(
      ministryServiceByChurchProvider(widget.churchId),
    );

    final memberService = ref.read(
      memberServiceByChurchProvider(widget.churchId),
    );

    return AlertDialog(
      title: const Text('Add Assignment'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder<List<Ministry>>(
                stream: ministryService.watchMinistries(),
                builder: (context, snapshot) {
                  final ministries = snapshot.data ?? <Ministry>[];

                  return DropdownButtonFormField<Ministry>(
                    initialValue: _selectedMinistry,
                    decoration: const InputDecoration(labelText: 'Ministry'),
                    items: ministries.map((ministry) {
                      return DropdownMenuItem<Ministry>(
                        value: ministry,
                        child: Text(ministry.name),
                      );
                    }).toList(),
                    onChanged: _saving
                        ? null
                        : (value) {
                            setState(() {
                              _selectedMinistry = value;
                            });
                          },
                  );
                },
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<ChurchMember>>(
                stream: memberService.watchMembers(),
                builder: (context, snapshot) {
                  final members = (snapshot.data ?? <ChurchMember>[])
                      .where((member) => member.isActive)
                      .toList();

                  return DropdownButtonFormField<ChurchMember>(
                    initialValue: _selectedMember,
                    decoration: const InputDecoration(labelText: 'Volunteer'),
                    items: members.map((member) {
                      return DropdownMenuItem<ChurchMember>(
                        value: member,
                        child: Text(member.displayName),
                      );
                    }).toList(),
                    onChanged: _saving
                        ? null
                        : (value) {
                            setState(() {
                              _selectedMember = value;
                            });
                          },
                  );
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _roleController,
                enabled: !_saving,
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
                  _servingDate == null
                      ? 'Choose serving date'
                      : '${_servingDate!.month}/'
                            '${_servingDate!.day}/'
                            '${_servingDate!.year}',
                ),
                onTap: _saving ? null : _chooseDate,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _chooseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _servingDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _servingDate = picked;
    });
  }

  Future<void> _save() async {
    final ministry = _selectedMinistry;
    final member = _selectedMember;

    if (ministry == null || member == null) {
      setState(() {
        _errorMessage = 'Select both a ministry and a volunteer.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(volunteerServiceByChurchProvider(widget.churchId))
          .addAssignment(
            VolunteerAssignment(
              ministryId: ministry.id,
              ministryName: ministry.name,
              memberId: member.id,
              memberName: member.displayName,
              role: _roleController.text.trim().isEmpty
                  ? 'Volunteer'
                  : _roleController.text.trim(),
              servingDate: _servingDate,
            ),
          );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _saving = false;
        _errorMessage = 'Unable to create assignment: $error';
      });
    }
  }
}
