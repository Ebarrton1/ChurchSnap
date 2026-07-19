class WebAdminDonationAmount {
  const WebAdminDonationAmount._();

  static double? read(Map<String, dynamic> data) {
    final legacyAmount = _number(data['amount']);

    if (legacyAmount != null) {
      return legacyAmount;
    }

    final minorUnits = _number(data['amountCents'] ?? data['amountMinorUnits']);

    if (minorUnits == null) {
      return null;
    }

    return minorUnits / 100;
  }

  static double? _number(Object? value) {
    return switch (value) {
      final num number => number.toDouble(),
      final String text => double.tryParse(text.trim()),
      _ => null,
    };
  }
}
