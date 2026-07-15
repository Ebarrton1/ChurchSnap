import 'package:flutter/material.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/auth/state/auth_controller.dart';
import '../../features/giving/models/giving_fund.dart';
import '../../features/giving/repositories/giving_repository.dart';
import '../profile/giving_history_screen.dart';

class GivingScreen extends StatefulWidget {
  const GivingScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  State<GivingScreen> createState() => _GivingScreenState();
}

class _GivingScreenState extends State<GivingScreen> {
  static const _presetAmounts = <int>[10, 25, 50, 100, 250];
  static const _fallbackFunds = <GivingFund>[
    GivingFund(
      id: 'tithe-offering',
      name: 'Tithe & Offering',
      description: 'Support the general ministry and mission of the church.',
      sortOrder: 10,
    ),
    GivingFund(
      id: 'missions',
      name: 'Missions',
      description: 'Support local and global mission work.',
      sortOrder: 20,
    ),
    GivingFund(
      id: 'building-fund',
      name: 'Building Fund',
      description: 'Help maintain and improve church facilities.',
      sortOrder: 30,
    ),
    GivingFund(
      id: 'youth-ministry',
      name: 'Youth Ministry',
      description: 'Invest in children, teens, and young adults.',
      sortOrder: 40,
    ),
  ];

  final TextEditingController _customAmountController = TextEditingController();

  int _selectedAmount = 50;
  String? _selectedFundId;
  bool _recurring = false;

  String get _churchId {
    final value = widget.authController.currentUser?.churchId.trim() ?? '';
    return value.isEmpty ? 'demo-church' : value;
  }

  bool get _isVisitor => widget.authController.currentUser?.role == 'visitor';

  int get _amountCents {
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
    final repository = GivingRepository(churchId: _churchId);

    return Material(
      child: ChurchSnapScreen(
        title: 'Giving',
        subtitle: 'Support your church with clarity and confidence.',
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
                        child: Icon(Icons.volunteer_activism_rounded, size: 34),
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
                        'Choose a fund and review your gift. ChurchSnap never stores card or bank details in Firestore.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SectionTitle(title: 'Choose Amount'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _presetAmounts.map((amount) {
              return ChoiceChip(
                label: Text('\$$amount'),
                selected:
                    _customAmountController.text.trim().isEmpty &&
                    _selectedAmount == amount,
                onSelected: (_) {
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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Custom amount',
              prefixText: '\$ ',
              prefixIcon: Icon(Icons.attach_money_rounded),
              helperText: 'Enter a dollar amount greater than zero.',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SectionTitle(title: 'Choose Fund'),
          StreamBuilder<List<GivingFund>>(
            stream: repository.watchActiveFunds(),
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
                    onChanged: (value) {
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
                      'The payment provider will control the recurring schedule.',
                    ),
                    onChanged: (value) => setState(() => _recurring = value),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _reviewGift(selectedFund),
                      icon: const Icon(Icons.lock_rounded),
                      label: const Text('Review Secure Gift'),
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
                _isVisitor ? 'Giving History is for members' : 'Giving History',
              ),
            ),
          ),
          const SizedBox(height: 8),
          const AppCard(
            child: ListTile(
              leading: Icon(Icons.verified_user_rounded),
              title: Text(
                'Payment safety',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                'This foundation does not collect card numbers, bank details, or mark a gift as paid. A certified payment provider will be connected next.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _reviewGift(GivingFund fund) async {
    final amountCents = _amountCents;

    if (amountCents <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid gift amount.')),
      );
      return;
    }

    final amount = (amountCents / 100).toStringAsFixed(2);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.lock_rounded),
          title: const Text('Gift Review'),
          content: Text(
            '\$$amount to ${fund.name}\n\n'
            '${_recurring ? 'Recurring gift requested.' : 'One-time gift requested.'}\n\n'
            'No payment has been taken. The secure payment-provider connection is the next integration step.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}
