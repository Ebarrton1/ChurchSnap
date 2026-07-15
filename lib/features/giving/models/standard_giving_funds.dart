import 'giving_fund.dart';

class StandardGivingFunds {
  const StandardGivingFunds._();

  static const tithe = GivingFund(
    id: 'tithe',
    name: 'Tithe',
    description: 'Return tithe as a dedicated act of worship and faithfulness.',
    sortOrder: 10,
  );

  static const offering = GivingFund(
    id: 'offering',
    name: 'Offering',
    description:
        'Give a freewill offering to support the church and its ministries.',
    sortOrder: 15,
  );

  static const donation = GivingFund(
    id: 'donation',
    name: 'Donation',
    description:
        'Give a general donation to support church ministry and community needs.',
    sortOrder: 18,
  );

  static const fallbackFunds = <GivingFund>[
    tithe,
    offering,
    donation,
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

  static List<GivingFund> separateLegacyFund(Iterable<GivingFund> source) {
    final result = source
        .where((fund) => !isLegacyCombinedFund(id: fund.id, name: fund.name))
        .toList();

    final hasTithe = result.any(
      (fund) => isTithe(id: fund.id, name: fund.name),
    );
    final hasOffering = result.any(
      (fund) => isOffering(id: fund.id, name: fund.name),
    );
    final hasDonation = result.any(
      (fund) => isDonation(id: fund.id, name: fund.name),
    );

    if (!hasTithe) {
      result.add(tithe);
    }

    if (!hasOffering) {
      result.add(offering);
    }

    if (!hasDonation) {
      result.add(donation);
    }

    result.sort((left, right) {
      final orderComparison = left.sortOrder.compareTo(right.sortOrder);

      if (orderComparison != 0) {
        return orderComparison;
      }

      return left.name.toLowerCase().compareTo(right.name.toLowerCase());
    });

    return result;
  }

  static bool isTithe({required String id, required String name}) {
    return _key(id) == 'tithe' || _key(name) == 'tithe';
  }

  static bool isOffering({required String id, required String name}) {
    return _key(id) == 'offering' || _key(name) == 'offering';
  }

  static bool isDonation({required String id, required String name}) {
    return _key(id) == 'donation' || _key(name) == 'donation';
  }

  static bool isLegacyCombinedFund({required String id, required String name}) {
    final idKey = _key(id);
    final nameKey = _key(name);

    return idKey == 'titheoffering' ||
        idKey == 'titheandofferings' ||
        nameKey == 'titheoffering' ||
        nameKey == 'titheandoffering' ||
        nameKey == 'tithesandoffering' ||
        nameKey == 'titheandofferings' ||
        nameKey == 'legacytitheoffering' ||
        nameKey == 'legacytitheandoffering';
  }

  static String _key(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }
}
