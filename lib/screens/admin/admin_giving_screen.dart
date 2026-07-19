import 'package:flutter/material.dart';
import 'package:churchsnap/core/navigation/churchsnap_navigation.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/giving/models/donation_record.dart';
import '../../features/giving/models/giving_fund.dart';
import '../../features/giving/repositories/giving_repository.dart';

class AdminGivingScreen extends StatelessWidget {
  const AdminGivingScreen({super.key, required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context) {
    final repository = GivingRepository(churchId: churchId);

    return Material(
      child: ChurchSnapScreen(
        title: 'Giving Administration',
        subtitle: 'Manage funds and verified contribution records.',
        children: [
          const AppCard(
            child: ListTile(
              leading: Icon(Icons.security_rounded),
              title: Text(
                'Financial records are admin-controlled',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                'Members can only view their own verified contributions. Card and bank details must never be stored here.',
              ),
            ),
          ),
          const SectionTitle(title: 'Giving Funds'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () => _showFundDialog(context, repository),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Fund'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    await repository.createStarterFunds();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Starter funds created.')),
                    );
                  } catch (error) {
                    if (!context.mounted) return;
                    _showError(
                      context,
                      'Unable to create starter funds: $error',
                    );
                  }
                },
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Create Starter Funds'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          StreamBuilder<List<GivingFund>>(
            stream: repository.watchAllFunds(),
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
                    title: const Text('Unable to load giving funds'),
                    subtitle: Text('${snapshot.error}'),
                  ),
                );
              }

              final funds = snapshot.data ?? const <GivingFund>[];

              if (funds.isEmpty) {
                return const AppCard(
                  child: ListTile(
                    leading: Icon(Icons.account_balance_rounded),
                    title: Text('No giving funds configured'),
                    subtitle: Text(
                      'Create starter funds or add a custom church fund.',
                    ),
                  ),
                );
              }

              return Column(
                children: funds.map((fund) {
                  return AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        child: Icon(
                          fund.active
                              ? Icons.volunteer_activism_rounded
                              : Icons.visibility_off_rounded,
                        ),
                      ),
                      title: Text(
                        fund.name,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(
                        [
                          if (fund.description.isNotEmpty) fund.description,
                          fund.active ? 'Active' : 'Hidden',
                          'Order ${fund.sortOrder}',
                        ].join(' • '),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            await _showFundDialog(
                              context,
                              repository,
                              existingFund: fund,
                            );
                          } else if (value == 'delete') {
                            await _confirmDeleteFund(context, repository, fund);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.edit_rounded),
                              title: Text('Edit'),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.delete_outline_rounded),
                              title: Text('Delete'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SectionTitle(title: 'Verified Contributions'),
          FilledButton.icon(
            onPressed: () => _showDonationDialog(context, repository),
            icon: const Icon(Icons.receipt_long_rounded),
            label: const Text('Record Contribution'),
          ),
          const SizedBox(height: 14),
          StreamBuilder<List<DonationRecord>>(
            stream: repository.watchAllDonations(),
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
                    title: const Text('Unable to load contributions'),
                    subtitle: Text('${snapshot.error}'),
                  ),
                );
              }

              final records = snapshot.data ?? const <DonationRecord>[];

              if (records.isEmpty) {
                return const AppCard(
                  child: ListTile(
                    leading: Icon(Icons.receipt_long_rounded),
                    title: Text('No contributions recorded'),
                    subtitle: Text(
                      'Completed payments and verified offline gifts will appear here.',
                    ),
                  ),
                );
              }

              return Column(
                children: records.map((record) {
                  return AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        child: Icon(_statusIcon(record.status)),
                      ),
                      title: Text(
                        record.memberName.isEmpty
                            ? record.memberId
                            : record.memberName,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(
                        [
                          record.fundName,
                          _formatDate(record.receivedAt ?? record.createdAt),
                          _formatStatus(record.status),
                          if (record.reference.isNotEmpty)
                            'Ref: ${record.reference}',
                          if (record.description.isNotEmpty)
                            'Description: ${record.description}',
                        ].join(' • '),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatMoney(record.amountCents),
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          IconButton(
                            tooltip: 'Edit contribution',
                            onPressed: () => _showDonationDialog(
                              context,
                              repository,
                              existingDonation: record,
                            ),
                            icon: const Icon(Icons.edit_rounded),
                          ),
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

  static Future<void> _showFundDialog(
    BuildContext context,
    GivingRepository repository, {
    GivingFund? existingFund,
  }) async {
    final result = await showDialog<_FundFormResult>(
      context: context,
      builder: (_) => _FundDialog(existingFund: existingFund),
    );

    if (result == null || !context.mounted) return;

    final fund = GivingFund(
      id: existingFund?.id ?? '',
      name: result.name,
      description: result.description,
      active: result.active,
      sortOrder: result.sortOrder,
    );

    try {
      if (existingFund == null) {
        await repository.addFund(fund);
      } else {
        await repository.updateFund(fund);
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existingFund == null
                ? 'Giving fund added.'
                : 'Giving fund updated.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      _showError(context, 'Unable to save giving fund: $error');
    }
  }

  static Future<void> _confirmDeleteFund(
    BuildContext context,
    GivingRepository repository,
    GivingFund fund,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Giving Fund?'),
        content: Text(
          'Delete "${fund.name}"? Existing contribution records will keep their stored fund name.',
        ),
        actions: [
          TextButton(
            onPressed: () => ChurchSnapNavigation.closeAllWindows(
              dialogContext,
              result: false,
            ),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => ChurchSnapNavigation.closeAllWindows(
              dialogContext,
              result: true,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await repository.deleteFund(fund.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Giving fund deleted.')));
    } catch (error) {
      if (!context.mounted) return;
      _showError(context, 'Unable to delete giving fund: $error');
    }
  }

  static Future<void> _showDonationDialog(
    BuildContext context,
    GivingRepository repository, {
    DonationRecord? existingDonation,
  }) async {
    final funds = await repository.watchAllFunds().first;
    if (!context.mounted) return;

    final result = await showDialog<_DonationFormResult>(
      context: context,
      builder: (_) =>
          _DonationDialog(funds: funds, existingDonation: existingDonation),
    );

    if (result == null || !context.mounted) return;

    final donation = DonationRecord(
      id: existingDonation?.id ?? '',
      memberId: result.memberId,
      memberName: result.memberName,
      fundId: result.fundId,
      fundName: result.fundName,
      amountCents: result.amountCents,
      currency: 'USD',
      status: result.status,
      recurring: result.recurring,
      reference: result.reference,
      description: result.description,
      receivedAt: existingDonation?.receivedAt ?? DateTime.now(),
      createdAt: existingDonation?.createdAt,
    );

    try {
      if (existingDonation == null) {
        await repository.addDonation(donation);
      } else {
        await repository.updateDonation(donation);
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existingDonation == null
                ? 'Contribution recorded.'
                : 'Contribution updated.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      _showError(context, 'Unable to save contribution: $error');
    }
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

class _FundDialog extends StatefulWidget {
  const _FundDialog({this.existingFund});

  final GivingFund? existingFund;

  @override
  State<_FundDialog> createState() => _FundDialogState();
}

class _FundDialogState extends State<_FundDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _sortOrderController;
  late bool _active;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final fund = widget.existingFund;
    _nameController = TextEditingController(text: fund?.name ?? '');
    _descriptionController = TextEditingController(
      text: fund?.description ?? '',
    );
    _sortOrderController = TextEditingController(
      text: '${fund?.sortOrder ?? 0}',
    );
    _active = fund?.active ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingFund == null ? 'Add Fund' : 'Edit Fund'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Fund name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _sortOrderController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Display order'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _active,
              title: const Text('Active'),
              onChanged: (value) => setState(() => _active = value),
            ),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    final sortOrder = int.tryParse(_sortOrderController.text.trim()) ?? 0;

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Enter a fund name.');
      return;
    }

    Navigator.pop(
      context,
      _FundFormResult(
        name: name,
        description: _descriptionController.text.trim(),
        active: _active,
        sortOrder: sortOrder,
      ),
    );
  }
}

class _DonationDialog extends StatefulWidget {
  const _DonationDialog({required this.funds, this.existingDonation});

  final List<GivingFund> funds;
  final DonationRecord? existingDonation;

  @override
  State<_DonationDialog> createState() => _DonationDialogState();
}

class _DonationDialogState extends State<_DonationDialog> {
  late final TextEditingController _memberIdController;
  late final TextEditingController _memberNameController;
  late final TextEditingController _amountController;
  late final TextEditingController _referenceController;
  late final TextEditingController _descriptionController;
  late String _fundId;
  late String _status;
  late bool _recurring;
  String? _errorMessage;

  List<GivingFund> get _availableFunds {
    if (widget.funds.isNotEmpty) return widget.funds;

    return const [
      GivingFund(
        id: 'general',
        name: 'General Giving',
        description: 'General contribution',
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    final donation = widget.existingDonation;
    final funds = _availableFunds;

    _memberIdController = TextEditingController(text: donation?.memberId ?? '');
    _memberNameController = TextEditingController(
      text: donation?.memberName ?? '',
    );
    _amountController = TextEditingController(
      text: donation == null ? '' : donation.amount.toStringAsFixed(2),
    );
    _referenceController = TextEditingController(
      text: donation?.reference ?? '',
    );
    _descriptionController = TextEditingController(
      text: donation?.description ?? '',
    );

    final existingFundId = donation?.fundId ?? '';
    _fundId = funds.any((fund) => fund.id == existingFundId)
        ? existingFundId
        : funds.first.id;
    _status = donation?.status ?? 'completed';
    _recurring = donation?.recurring ?? false;
  }

  @override
  void dispose() {
    _memberIdController.dispose();
    _memberNameController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final funds = _availableFunds;

    return AlertDialog(
      title: Text(
        widget.existingDonation == null
            ? 'Record Contribution'
            : 'Edit Contribution',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _memberIdController,
              decoration: const InputDecoration(
                labelText: 'Member ID',
                helperText: 'Use the Firebase member UID.',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _memberNameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Member name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _fundId,
              decoration: const InputDecoration(labelText: 'Fund'),
              items: funds
                  .map(
                    (fund) => DropdownMenuItem<String>(
                      value: fund.id,
                      child: Text(fund.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _fundId = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'refunded', child: Text('Refunded')),
                DropdownMenuItem(value: 'voided', child: Text('Voided')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _status = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _referenceController,
              decoration: const InputDecoration(
                labelText: 'Reference',
                helperText: 'Receipt, check, or processor reference.',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              minLines: 2,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Donation description (optional)',
                helperText: 'Purpose, dedication, or giver message.',
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _recurring,
              title: const Text('Recurring contribution'),
              onChanged: (value) => setState(() => _recurring = value),
            ),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  void _save() {
    final memberId = _memberIdController.text.trim();
    final memberName = _memberNameController.text.trim();
    final amount = double.tryParse(
      _amountController.text.trim().replaceAll(',', ''),
    );

    if (memberId.isEmpty) {
      setState(() => _errorMessage = 'Enter the member ID.');
      return;
    }

    if (memberName.isEmpty) {
      setState(() => _errorMessage = 'Enter the member name.');
      return;
    }

    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Enter a valid amount.');
      return;
    }

    final fund = _availableFunds.firstWhere((item) => item.id == _fundId);

    Navigator.pop(
      context,
      _DonationFormResult(
        memberId: memberId,
        memberName: memberName,
        fundId: fund.id,
        fundName: fund.name,
        amountCents: (amount * 100).round(),
        status: _status,
        recurring: _recurring,
        reference: _referenceController.text.trim(),
        description: _descriptionController.text.trim(),
      ),
    );
  }
}

class _FundFormResult {
  const _FundFormResult({
    required this.name,
    required this.description,
    required this.active,
    required this.sortOrder,
  });

  final String name;
  final String description;
  final bool active;
  final int sortOrder;
}

class _DonationFormResult {
  const _DonationFormResult({
    required this.memberId,
    required this.memberName,
    required this.fundId,
    required this.fundName,
    required this.amountCents,
    required this.status,
    required this.recurring,
    required this.reference,
    required this.description,
  });

  final String memberId;
  final String memberName;
  final String fundId;
  final String fundName;
  final int amountCents;
  final String status;
  final bool recurring;
  final String reference;
  final String description;
}
