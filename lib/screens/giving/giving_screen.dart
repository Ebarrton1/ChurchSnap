import 'package:flutter/material.dart';
import 'package:churchsnap/core/navigation/churchsnap_navigation.dart';

import 'package:churchsnap/core/widgets/churchsnap_screen.dart';
import 'package:churchsnap/features/auth/state/auth_controller.dart';
import 'package:churchsnap/features/giving/models/giving_currency.dart';
import 'package:churchsnap/features/giving/models/giving_fund.dart';
import 'package:churchsnap/features/giving/models/standard_giving_funds.dart';
import 'package:churchsnap/features/giving/repositories/giving_currency_repository.dart';
import 'package:churchsnap/features/giving/repositories/giving_repository.dart';
import 'package:churchsnap/features/giving/repositories/giving_submission_repository.dart';
import 'package:churchsnap/screens/profile/giving_history_screen.dart';

class GivingScreen extends StatefulWidget {
  const GivingScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  State<GivingScreen> createState() => _GivingScreenState();
}

class _GivingScreenState extends State<GivingScreen> {
  static const _presetAmounts = <int>[10, 25, 50, 100, 250];

  static const _fallbackFunds = StandardGivingFunds.fallbackFunds;

  final TextEditingController _customAmountController = TextEditingController();

  int _selectedAmount = 50;
  String? _selectedFundId;
  String? _selectedCurrencyCode;
  bool _recurring = false;
  bool _submitting = false;

  String get _churchId {
    final value = widget.authController.currentUser?.churchId.trim() ?? '';
    return value.isEmpty ? 'demo-church' : value;
  }

  bool get _isVisitor => widget.authController.currentUser?.role == 'visitor';

  int get _amountMinorUnits {
    final customValue = double.tryParse(
      _customAmountController.text.trim().replaceAll(',', ''),
    );

    if (customValue != null && customValue > 0) {
      return (customValue * 100).round();
    }

    return _selectedAmount * 100;
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final givingRepository = GivingRepository(churchId: _churchId);
    final currencyRepository = GivingCurrencyRepository(churchId: _churchId);

    return StreamBuilder<GivingCurrencySettings>(
      stream: currencyRepository.watchSettings(),
      initialData: GivingCurrencySettings.defaults,
      builder: (context, currencySnapshot) {
        final settings =
            (currencySnapshot.data ?? GivingCurrencySettings.defaults)
                .normalized();
        final enabledCurrencies = settings.enabledCurrencies;
        final requestedCode = _selectedCurrencyCode;
        final selectedCurrency =
            requestedCode != null && settings.isEnabled(requestedCode)
            ? GivingCurrency.byCode(requestedCode)
            : settings.defaultCurrency;

        return Material(
          child: ChurchSnapScreen(
            title: 'Giving',
            subtitle: 'Choose the amount, fund, and currency you are giving.',
            children: [
              AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/icons/giving.png',
                      width: 72,
                      height: 72,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const CircleAvatar(
                            radius: 34,
                            child: Icon(
                              Icons.volunteer_activism_rounded,
                              size: 34,
                            ),
                          ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your generosity makes ministry possible',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Choose the currency you are actually giving. An '
                            'administrator will confirm the amount and currency '
                            'received.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SectionTitle(title: 'Choose Currency'),
              DropdownButtonFormField<String>(
                key: ValueKey(selectedCurrency.code),
                initialValue: selectedCurrency.code,
                decoration: const InputDecoration(
                  labelText: 'Gift currency',
                  prefixIcon: Icon(Icons.currency_exchange_rounded),
                ),
                items: enabledCurrencies
                    .map(
                      (currency) => DropdownMenuItem<String>(
                        value: currency.code,
                        child: Text(
                          '${currency.code} - ${currency.name} '
                          '(${currency.symbol})',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _submitting
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() => _selectedCurrencyCode = value);
                      },
              ),
              const SizedBox(height: 10),
              AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(Icons.info_outline_rounded),
                  ),
                  title: Text(
                    '${selectedCurrency.code} - ${selectedCurrency.name}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    selectedCurrency.code == settings.defaultCurrencyCode
                        ? 'This is the church default currency. You may select '
                              'another enabled currency above.'
                        : 'You selected this currency for this gift. No automatic '
                              'exchange-rate conversion will be applied.',
                  ),
                ),
              ),
              const SectionTitle(title: 'Choose Amount'),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _presetAmounts.map((amount) {
                  return ChoiceChip(
                    label: Text(selectedCurrency.formatWholeAmount(amount)),
                    selected:
                        _customAmountController.text.trim().isEmpty &&
                        _selectedAmount == amount,
                    onSelected: _submitting
                        ? null
                        : (_) {
                            setState(() {
                              _selectedAmount = amount;
                              _customAmountController.clear();
                            });
                          },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _customAmountController,
                enabled: !_submitting,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Custom amount',
                  prefixText: '${selectedCurrency.symbol} ',
                  prefixIcon: const Icon(Icons.payments_rounded),
                  helperText:
                      'Enter an amount greater than zero in '
                      '${selectedCurrency.code}.',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SectionTitle(title: 'Choose Fund'),
              StreamBuilder<List<GivingFund>>(
                stream: givingRepository.watchActiveFunds(),
                builder: (context, snapshot) {
                  final funds = snapshot.hasData && snapshot.data!.isNotEmpty
                      ? snapshot.data!
                      : _fallbackFunds;

                  final selectedFund = funds.firstWhere(
                    (fund) => fund.id == _selectedFundId,
                    orElse: () => funds.first,
                  );

                  _selectedFundId ??= selectedFund.id;

                  return Column(
                    children: [
                      DropdownButtonFormField<String>(
                        key: ValueKey(selectedFund.id),
                        initialValue: selectedFund.id,
                        decoration: const InputDecoration(
                          labelText: 'Giving fund',
                          prefixIcon: Icon(Icons.account_balance_rounded),
                        ),
                        items: funds
                            .map(
                              (fund) => DropdownMenuItem<String>(
                                value: fund.id,
                                child: Text(fund.name),
                              ),
                            )
                            .toList(),
                        onChanged: _submitting
                            ? null
                            : (value) {
                                setState(() => _selectedFundId = value);
                              },
                      ),
                      const SizedBox(height: 10),
                      AppCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            child: Icon(Icons.info_outline_rounded),
                          ),
                          title: Text(
                            selectedFund.name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            selectedFund.description.isEmpty
                                ? 'Support this church fund.'
                                : selectedFund.description,
                          ),
                        ),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _recurring,
                        title: const Text(
                          'Make this recurring',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: const Text(
                          'The future payment provider will control the schedule.',
                        ),
                        onChanged: _submitting
                            ? null
                            : (value) => setState(() => _recurring = value),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _submitting
                              ? null
                              : () => _reviewAndSubmit(
                                  selectedFund,
                                  selectedCurrency,
                                ),
                          icon: _submitting
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.fact_check_rounded),
                          label: Text(
                            _submitting
                                ? 'Submitting...'
                                : 'Submit Gift for Confirmation',
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isVisitor
                      ? null
                      : () {
                          final member = widget.authController.currentUser;
                          if (member == null) return;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GivingHistoryScreen(
                                churchId: _churchId,
                                memberId: member.id,
                              ),
                            ),
                          );
                        },
                  icon: const Icon(Icons.receipt_long_rounded),
                  label: Text(
                    _isVisitor
                        ? 'Giving History is for members'
                        : 'Giving History',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const AppCard(
                child: ListTile(
                  leading: Icon(Icons.verified_user_rounded),
                  title: Text(
                    'Confirmation workflow',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    'Submitting records your stated gift amount and currency. '
                    'It does not collect payment or mark the gift as received. '
                    'A church administrator must confirm or reject it.',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _reviewAndSubmit(
    GivingFund fund,
    GivingCurrency currency,
  ) async {
    final member = widget.authController.currentUser;
    final amountMinorUnits = _amountMinorUnits;

    if (member == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in before submitting a gift.')),
      );
      return;
    }

    if (amountMinorUnits <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid gift amount.')),
      );
      return;
    }

    final amount = currency.formatMinorUnits(amountMinorUnits);
    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.fact_check_rounded),
          title: const Text('Review Gift Submission'),
          content: Text(
            '$amount ${currency.code}\n'
            'Fund: ${fund.name}\n'
            'Type: ${_recurring ? 'Recurring' : 'One-time'}\n\n'
            'The church administrator will confirm the actual amount and '
            'currency received. No exchange-rate conversion will be made.',
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
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    if (shouldSubmit != true || !mounted) {
      return;
    }

    setState(() => _submitting = true);

    try {
      final repository = GivingSubmissionRepository(churchId: _churchId);

      await repository.submit(
        giverId: member.id,
        giverName: member.displayName,
        fundId: fund.id,
        fundName: fund.name,
        amountMinorUnits: amountMinorUnits,
        currency: currency,
        recurring: _recurring,
      );

      if (!mounted) return;

      setState(() {
        _customAmountController.clear();
        _selectedAmount = 50;
        _recurring = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$amount ${currency.code} was submitted for administrator '
            'confirmation.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gift submission failed: $error')));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}
