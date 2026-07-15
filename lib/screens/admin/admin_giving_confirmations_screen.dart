import 'package:flutter/material.dart';

import 'package:churchsnap/core/widgets/churchsnap_screen.dart';
import 'package:churchsnap/features/giving/models/giving_currency.dart';
import 'package:churchsnap/features/giving/models/giving_submission.dart';
import 'package:churchsnap/features/giving/repositories/giving_currency_repository.dart';
import 'package:churchsnap/features/giving/repositories/giving_submission_repository.dart';

class AdminGivingConfirmationsScreen extends StatelessWidget {
  const AdminGivingConfirmationsScreen({super.key, required this.churchId});

  final String churchId;

  @override
  Widget build(BuildContext context) {
    final repository = GivingSubmissionRepository(churchId: churchId);
    final currencyRepository = GivingCurrencyRepository(churchId: churchId);

    return Material(
      child: StreamBuilder<GivingCurrencySettings>(
        stream: currencyRepository.watchSettings(),
        initialData: GivingCurrencySettings.defaults,
        builder: (context, settingsSnapshot) {
          final settings =
              (settingsSnapshot.data ?? GivingCurrencySettings.defaults)
                  .normalized();

          return StreamBuilder<List<GivingSubmission>>(
            stream: repository.watchAll(),
            builder: (context, snapshot) {
              final submissions = snapshot.data ?? const <GivingSubmission>[];
              final pending = submissions
                  .where(
                    (submission) =>
                        submission.status == GivingSubmissionStatus.pending,
                  )
                  .toList();
              final completed = submissions
                  .where(
                    (submission) =>
                        submission.status != GivingSubmissionStatus.pending,
                  )
                  .toList();

              return ChurchSnapScreen(
                title: 'Gift Confirmations',
                subtitle:
                    'Verify the actual amount and currency received by the church.',
                children: [
                  AppCard(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.pending_actions_rounded),
                      ),
                      title: Text(
                        '${pending.length} awaiting confirmation',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: const Text(
                        'Submitted currencies are never converted automatically. '
                        'Confirm exactly what the church received.',
                      ),
                    ),
                  ),
                  const SectionTitle(title: 'Awaiting Confirmation'),
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData)
                    const Center(child: CircularProgressIndicator())
                  else if (pending.isEmpty)
                    const AppCard(
                      child: ListTile(
                        leading: Icon(Icons.verified_rounded),
                        title: Text('No pending gift submissions'),
                        subtitle: Text(
                          'New giver submissions will appear here.',
                        ),
                      ),
                    )
                  else
                    ...pending.map(
                      (submission) => _SubmissionCard(
                        submission: submission,
                        onConfirm: () =>
                            _confirm(context, repository, submission, settings),
                        onReject: () =>
                            _reject(context, repository, submission),
                      ),
                    ),
                  const SectionTitle(title: 'Recently Reviewed'),
                  if (completed.isEmpty)
                    const AppCard(
                      child: ListTile(
                        leading: Icon(Icons.history_rounded),
                        title: Text('No reviewed submissions yet'),
                      ),
                    )
                  else
                    ...completed
                        .take(25)
                        .map(
                          (submission) =>
                              _SubmissionCard(submission: submission),
                        ),
                  if (snapshot.hasError) ...[
                    const SizedBox(height: 12),
                    AppCard(
                      child: ListTile(
                        leading: const Icon(Icons.error_outline_rounded),
                        title: const Text('Unable to load gift submissions'),
                        subtitle: Text('${snapshot.error}'),
                      ),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirm(
    BuildContext context,
    GivingSubmissionRepository repository,
    GivingSubmission submission,
    GivingCurrencySettings settings,
  ) async {
    final amountController = TextEditingController(
      text: (submission.amountMinorUnits / 100).toStringAsFixed(2),
    );
    final noteController = TextEditingController();
    var selectedCode = submission.currencyCode;

    if (!settings.isEnabled(selectedCode)) {
      selectedCode = settings.defaultCurrencyCode;
    }

    final result = await showDialog<_ConfirmationResult>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final selectedCurrency = GivingCurrency.byCode(selectedCode);

            return AlertDialog(
              icon: const Icon(Icons.fact_check_rounded),
              title: const Text('Confirm Gift Received'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Submitted: ${submission.submittedAmountLabel} '
                        '${submission.currencyCode}\n'
                        'Giver: ${submission.giverName}\n'
                        'Fund: ${submission.fundName}',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCode,
                      decoration: const InputDecoration(
                        labelText: 'Currency actually received',
                      ),
                      items: settings.enabledCurrencies
                          .map(
                            (currency) => DropdownMenuItem<String>(
                              value: currency.code,
                              child: Text(
                                '${currency.code} - ${currency.symbol}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => selectedCode = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Amount actually received',
                        prefixText: '${selectedCurrency.symbol} ',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Administrator note (optional)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Changing the confirmation currency records what was '
                      'received. It does not calculate or claim an exchange rate.',
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
                  onPressed: () {
                    final amount = double.tryParse(
                      amountController.text.trim().replaceAll(',', ''),
                    );

                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text('Enter a valid confirmed amount.'),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      _ConfirmationResult(
                        amountMinorUnits: (amount * 100).round(),
                        currencyCode: selectedCode,
                        note: noteController.text.trim(),
                      ),
                    );
                  },
                  child: const Text('Confirm Received'),
                ),
              ],
            );
          },
        );
      },
    );

    amountController.dispose();
    noteController.dispose();

    if (result == null || !context.mounted) {
      return;
    }

    try {
      await repository.confirm(
        submission: submission,
        confirmedAmountMinorUnits: result.amountMinorUnits,
        confirmedCurrency: GivingCurrency.byCode(result.currencyCode),
        adminNote: result.note,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gift receipt confirmed.')));
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Confirmation failed: $error')));
    }
  }

  Future<void> _reject(
    BuildContext context,
    GivingSubmissionRepository repository,
    GivingSubmission submission,
  ) async {
    final noteController = TextEditingController();

    final shouldReject = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.cancel_outlined),
          title: const Text('Reject Gift Submission'),
          content: TextField(
            controller: noteController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Reason or note (optional)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );

    final note = noteController.text.trim();
    noteController.dispose();

    if (shouldReject != true || !context.mounted) {
      return;
    }

    try {
      await repository.reject(submission: submission, adminNote: note);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift submission rejected.')),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Rejection failed: $error')));
    }
  }
}

class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({
    required this.submission,
    this.onConfirm,
    this.onReject,
  });

  final GivingSubmission submission;
  final VoidCallback? onConfirm;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final confirmedLabel = submission.confirmedAmountLabel;
    final statusLabel = switch (submission.status) {
      GivingSubmissionStatus.pending => 'Awaiting confirmation',
      GivingSubmissionStatus.confirmed => 'Confirmed',
      GivingSubmissionStatus.rejected => 'Rejected',
    };

    final confirmedText = confirmedLabel == null
        ? ''
        : '\nConfirmed: $confirmedLabel '
              '${submission.confirmedCurrencyCode ?? submission.currencyCode}';
    final noteText = submission.adminNote?.isNotEmpty == true
        ? '\nNote: ${submission.adminNote}'
        : '';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              child: Icon(switch (submission.status) {
                GivingSubmissionStatus.pending => Icons.pending_actions_rounded,
                GivingSubmissionStatus.confirmed => Icons.verified_rounded,
                GivingSubmissionStatus.rejected => Icons.cancel_rounded,
              }),
            ),
            title: Text(
              submission.giverName,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(
              'Submitted: ${submission.submittedAmountLabel} '
              '${submission.currencyCode}\n'
              'Fund: ${submission.fundName}\n'
              'Type: ${submission.recurring ? 'Recurring' : 'One-time'}\n'
              'Status: $statusLabel'
              '$confirmedText'
              '$noteText',
            ),
          ),
          if (submission.status == GivingSubmissionStatus.pending) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onConfirm,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ConfirmationResult {
  const _ConfirmationResult({
    required this.amountMinorUnits,
    required this.currencyCode,
    required this.note,
  });

  final int amountMinorUnits;
  final String currencyCode;
  final String note;
}
