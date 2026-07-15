import 'package:flutter/material.dart';

import 'package:churchsnap/core/widgets/churchsnap_screen.dart';
import 'package:churchsnap/features/giving/models/giving_currency.dart';
import 'package:churchsnap/features/giving/repositories/giving_currency_repository.dart';

class AdminGivingCurrencyScreen extends StatefulWidget {
  const AdminGivingCurrencyScreen({super.key, required this.churchId});

  final String churchId;

  @override
  State<AdminGivingCurrencyScreen> createState() =>
      _AdminGivingCurrencyScreenState();
}

class _AdminGivingCurrencyScreenState extends State<AdminGivingCurrencyScreen> {
  String? _defaultCode;
  Set<String>? _enabledCodes;
  bool _saving = false;

  GivingCurrencyRepository get _repository =>
      GivingCurrencyRepository(churchId: widget.churchId);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: StreamBuilder<GivingCurrencySettings>(
        stream: _repository.watchSettings(),
        initialData: GivingCurrencySettings.defaults,
        builder: (context, snapshot) {
          final saved = (snapshot.data ?? GivingCurrencySettings.defaults)
              .normalized();

          _enabledCodes ??= saved.enabledCurrencyCodes.toSet();
          _defaultCode ??= saved.defaultCurrencyCode;

          final enabledCodes = _enabledCodes!;
          final enabledCurrencies = GivingCurrency.supported
              .where((currency) => enabledCodes.contains(currency.code))
              .toList();

          if (enabledCurrencies.isEmpty) {
            enabledCodes.add(GivingCurrency.usd.code);
            enabledCurrencies.add(GivingCurrency.usd);
          }

          if (!enabledCodes.contains(_defaultCode)) {
            _defaultCode = enabledCurrencies.first.code;
          }

          final defaultCurrency = GivingCurrency.byCode(_defaultCode);

          return ChurchSnapScreen(
            title: 'Giving Currencies',
            subtitle:
                'Choose the default currency and currencies givers may select.',
            children: [
              const AppCard(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.currency_exchange_rounded),
                  ),
                  title: Text(
                    'Church-controlled options',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    'The default currency is selected first for givers. Enabled '
                    'currencies remain available for each individual gift. '
                    'ChurchSnap does not silently convert amounts.',
                  ),
                ),
              ),
              const SectionTitle(title: 'Default Currency'),
              DropdownButtonFormField<String>(
                key: ValueKey(_defaultCode),
                initialValue: _defaultCode,
                decoration: const InputDecoration(
                  labelText: 'Default giving currency',
                  prefixIcon: Icon(Icons.payments_rounded),
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
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() => _defaultCode = value);
                      },
              ),
              const SectionTitle(title: 'Currencies Givers May Select'),
              ...GivingCurrency.supported.map((currency) {
                final enabled = enabledCodes.contains(currency.code);
                final isDefault = currency.code == _defaultCode;

                return AppCard(
                  child: CheckboxListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    value: enabled,
                    title: Text(
                      '${currency.code} - ${currency.name}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      '${currency.symbol}  '
                      '${isDefault ? '- Default currency' : ''}',
                    ),
                    secondary: isDefault
                        ? const Icon(Icons.star_rounded)
                        : const Icon(Icons.currency_exchange_rounded),
                    onChanged: _saving
                        ? null
                        : (value) {
                            if (value == null) return;

                            setState(() {
                              if (value) {
                                enabledCodes.add(currency.code);
                              } else {
                                if (enabledCodes.length == 1) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'At least one currency must remain enabled.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                enabledCodes.remove(currency.code);

                                if (_defaultCode == currency.code) {
                                  _defaultCode = GivingCurrency.supported
                                      .firstWhere(
                                        (item) =>
                                            enabledCodes.contains(item.code),
                                      )
                                      .code;
                                }
                              }
                            });
                          },
                  ),
                );
              }),
              const SizedBox(height: 8),
              AppCard(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.visibility_rounded),
                  ),
                  title: const Text(
                    'Giver preview',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    '${defaultCurrency.formatMajorUnits(1250)} '
                    '${defaultCurrency.code} is selected by default. '
                    '${enabledCodes.length} currencies are enabled.',
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(_saving ? 'Saving...' : 'Save Giving Currencies'),
                ),
              ),
              if (snapshot.hasError) ...[
                const SizedBox(height: 12),
                const AppCard(
                  child: ListTile(
                    leading: Icon(Icons.warning_amber_rounded),
                    title: Text('Using local currency defaults'),
                    subtitle: Text(
                      'ChurchSnap could not load the saved currency settings. '
                      'Check Firestore rules and the network connection.',
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    final enabledCodes = _enabledCodes?.toList() ?? <String>['USD'];
    final defaultCode = _defaultCode ?? enabledCodes.first;

    setState(() => _saving = true);

    try {
      await _repository.saveSettings(
        GivingCurrencySettings(
          defaultCurrencyCode: defaultCode,
          enabledCurrencyCodes: enabledCodes,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Giving currencies saved.')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save currencies: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
