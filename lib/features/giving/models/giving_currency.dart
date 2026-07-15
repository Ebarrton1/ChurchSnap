class GivingCurrency {
  const GivingCurrency({
    required this.code,
    required this.name,
    required this.symbol,
    this.symbolBeforeAmount = true,
  });

  final String code;
  final String name;
  final String symbol;
  final bool symbolBeforeAmount;

  static const usd = GivingCurrency(
    code: 'USD',
    name: 'US Dollar',
    symbol: r'$',
  );

  static const supported = <GivingCurrency>[
    usd,
    GivingCurrency(code: 'JMD', name: 'Jamaican Dollar', symbol: r'J$'),
    GivingCurrency(code: 'CAD', name: 'Canadian Dollar', symbol: r'CA$'),
    GivingCurrency(code: 'GBP', name: 'British Pound', symbol: '\u00A3'),
    GivingCurrency(code: 'EUR', name: 'Euro', symbol: '\u20AC'),
    GivingCurrency(
      code: 'TTD',
      name: 'Trinidad and Tobago Dollar',
      symbol: r'TT$',
    ),
    GivingCurrency(code: 'BSD', name: 'Bahamian Dollar', symbol: r'B$'),
    GivingCurrency(code: 'BBD', name: 'Barbadian Dollar', symbol: r'Bds$'),
    GivingCurrency(code: 'XCD', name: 'East Caribbean Dollar', symbol: r'EC$'),
    GivingCurrency(code: 'GYD', name: 'Guyanese Dollar', symbol: r'G$'),
    GivingCurrency(code: 'NGN', name: 'Nigerian Naira', symbol: '\u20A6'),
    GivingCurrency(code: 'GHS', name: 'Ghanaian Cedi', symbol: 'GH\u20B5'),
    GivingCurrency(code: 'ZAR', name: 'South African Rand', symbol: 'R'),
  ];

  static GivingCurrency byCode(String? rawCode) {
    final code = rawCode?.trim().toUpperCase() ?? '';

    for (final currency in supported) {
      if (currency.code == code) {
        return currency;
      }
    }

    return usd;
  }

  static GivingCurrency fromMap(Map<String, dynamic>? data) {
    final rawCode = data?['currencyCode'];
    return byCode(rawCode is String ? rawCode : null);
  }

  Map<String, Object> toMap() {
    return {
      'currencyCode': code,
      'currencyName': name,
      'currencySymbol': symbol,
      'symbolBeforeAmount': symbolBeforeAmount,
    };
  }

  String formatMinorUnits(int amountMinorUnits) {
    return formatMajorUnits(amountMinorUnits / 100);
  }

  String formatWholeAmount(num amount) {
    return formatMajorUnits(amount);
  }

  String formatMajorUnits(num amount) {
    final fixed = amount.toStringAsFixed(2);
    final parts = fixed.split('.');
    final groupedWhole = _groupThousands(parts.first);
    final formattedNumber = '$groupedWhole.${parts.last}';

    if (symbolBeforeAmount) {
      return '$symbol$formattedNumber';
    }

    return '$formattedNumber $symbol';
  }

  static String _groupThousands(String digits) {
    final isNegative = digits.startsWith('-');
    final source = isNegative ? digits.substring(1) : digits;
    final buffer = StringBuffer();

    for (var index = 0; index < source.length; index++) {
      if (index > 0 && (source.length - index) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(source[index]);
    }

    final grouped = buffer.toString();
    return isNegative ? '-$grouped' : grouped;
  }
}

class GivingCurrencySettings {
  const GivingCurrencySettings({
    required this.defaultCurrencyCode,
    required this.enabledCurrencyCodes,
  });

  final String defaultCurrencyCode;
  final List<String> enabledCurrencyCodes;

  static const defaults = GivingCurrencySettings(
    defaultCurrencyCode: 'USD',
    enabledCurrencyCodes: ['USD'],
  );

  GivingCurrency get defaultCurrency =>
      GivingCurrency.byCode(defaultCurrencyCode);

  List<GivingCurrency> get enabledCurrencies {
    final currencies = <GivingCurrency>[];
    final seen = <String>{};

    for (final code in enabledCurrencyCodes) {
      final currency = GivingCurrency.byCode(code);

      if (seen.add(currency.code)) {
        currencies.add(currency);
      }
    }

    if (currencies.isEmpty) {
      return [GivingCurrency.usd];
    }

    return currencies;
  }

  bool isEnabled(String code) {
    final normalized = code.trim().toUpperCase();
    return enabledCurrencies.any((currency) => currency.code == normalized);
  }

  GivingCurrencySettings normalized() {
    final enabled = enabledCurrencies.map((currency) => currency.code).toList();
    final normalizedDefault = isEnabled(defaultCurrencyCode)
        ? GivingCurrency.byCode(defaultCurrencyCode).code
        : enabled.first;

    return GivingCurrencySettings(
      defaultCurrencyCode: normalizedDefault,
      enabledCurrencyCodes: enabled,
    );
  }

  static GivingCurrencySettings fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return defaults;
    }

    final legacyCode = data['currencyCode'];
    final rawDefault = data['defaultCurrencyCode'];
    final defaultCode = rawDefault is String
        ? rawDefault
        : legacyCode is String
        ? legacyCode
        : 'USD';

    final rawEnabled = data['enabledCurrencyCodes'];
    final enabledCodes = rawEnabled is List
        ? rawEnabled.whereType<String>().toList()
        : <String>[defaultCode];

    return GivingCurrencySettings(
      defaultCurrencyCode: defaultCode,
      enabledCurrencyCodes: enabledCodes,
    ).normalized();
  }

  Map<String, Object> toMap() {
    final settings = normalized();
    final defaultCurrency = settings.defaultCurrency;

    return {
      'defaultCurrencyCode': settings.defaultCurrencyCode,
      'enabledCurrencyCodes': settings.enabledCurrencyCodes,
      // Legacy fields remain during migration for older installed builds.
      'currencyCode': defaultCurrency.code,
      'currencyName': defaultCurrency.name,
      'currencySymbol': defaultCurrency.symbol,
      'symbolBeforeAmount': defaultCurrency.symbolBeforeAmount,
    };
  }
}
