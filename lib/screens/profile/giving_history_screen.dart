import 'package:flutter/material.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/giving/models/donation_record.dart';
import '../../features/giving/repositories/giving_repository.dart';

class GivingHistoryScreen extends StatelessWidget {
  const GivingHistoryScreen({
    super.key,
    required this.churchId,
    required this.memberId,
  });

  final String churchId;
  final String memberId;

  @override
  Widget build(BuildContext context) {
    final repository = GivingRepository(churchId: churchId);

    return Material(
      child: ChurchSnapScreen(
        title: 'Giving History',
        subtitle: 'Verified contributions recorded by your church.',
        children: [
          StreamBuilder<List<DonationRecord>>(
            stream: repository.watchMemberDonations(memberId),
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
                    title: const Text('Unable to load giving history'),
                    subtitle: Text('${snapshot.error}'),
                  ),
                );
              }

              final records = snapshot.data ?? const <DonationRecord>[];
              final verified = records
                  .where((record) => record.status == 'completed')
                  .toList();
              final totalCents = verified.fold<int>(
                0,
                (sum, record) => sum + record.amountCents,
              );

              if (records.isEmpty) {
                return const AppCard(
                  child: ListTile(
                    leading: Icon(Icons.receipt_long_rounded),
                    title: Text('No contributions recorded yet'),
                    subtitle: Text(
                      'Verified contributions will appear here after they are recorded by the church or a payment webhook.',
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  AppCard(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.savings_rounded),
                      ),
                      title: const Text(
                        'Verified total',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        '${verified.length} completed contribution(s)',
                      ),
                      trailing: Text(
                        _formatMoney(totalCents),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  ...records.map(
                    (record) => AppCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          child: Icon(_statusIcon(record.status)),
                        ),
                        title: Text(
                          record.fundName,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        subtitle: Text(
                          [
                            _formatDate(record.receivedAt ?? record.createdAt),
                            _formatStatus(record.status),
                            if (record.reference.isNotEmpty)
                              'Ref: ${record.reference}',
                            if (record.description.isNotEmpty)
                              'Description: ${record.description}',
                          ].where((value) => value.isNotEmpty).join(' • '),
                        ),
                        trailing: Text(
                          _formatMoney(record.amountCents),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  static String _formatMoney(int amountCents) {
    return '\$${(amountCents / 100).toStringAsFixed(2)}';
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return 'Date pending';

    final local = date.toLocal();
    return '${local.month}/${local.day}/${local.year}';
  }

  static String _formatStatus(String status) {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'refunded':
        return 'Refunded';
      case 'voided':
        return 'Voided';
      default:
        return status;
    }
  }

  static IconData _statusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.schedule_rounded;
      case 'refunded':
        return Icons.undo_rounded;
      case 'voided':
        return Icons.block_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }
}
