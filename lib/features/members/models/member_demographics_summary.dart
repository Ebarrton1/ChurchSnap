class DemographicCount {
  const DemographicCount({required this.label, required this.count});

  final String label;
  final int count;
}

class MemberDemographicsSummary {
  const MemberDemographicsSummary({
    required this.totalMembers,
    required this.adults,
    required this.childrenAndYouth,
    required this.unknownAge,
    required this.completeProfiles,
    required this.missingAnyDemographic,
    required this.missingDateOfBirth,
    required this.missingGender,
    required this.missingMaritalStatus,
    required this.inactiveRecords,
    required this.excludedVisitors,
    required this.genderCounts,
    required this.maritalStatusCounts,
    required this.ageGroupCounts,
  });

  static const empty = MemberDemographicsSummary(
    totalMembers: 0,
    adults: 0,
    childrenAndYouth: 0,
    unknownAge: 0,
    completeProfiles: 0,
    missingAnyDemographic: 0,
    missingDateOfBirth: 0,
    missingGender: 0,
    missingMaritalStatus: 0,
    inactiveRecords: 0,
    excludedVisitors: 0,
    genderCounts: <String, int>{
      'Male': 0,
      'Female': 0,
      'Other': 0,
      'Not provided': 0,
    },
    maritalStatusCounts: <String, int>{
      'Single': 0,
      'Married': 0,
      'Divorced': 0,
      'Widowed': 0,
      'Separated': 0,
      'Other': 0,
      'Not provided': 0,
    },
    ageGroupCounts: <String, int>{
      'Children (0-12)': 0,
      'Teens (13-17)': 0,
      'Young Adults (18-35)': 0,
      'Adults (36-64)': 0,
      'Seniors (65+)': 0,
      'Date of birth missing': 0,
    },
  );

  final int totalMembers;
  final int adults;
  final int childrenAndYouth;
  final int unknownAge;
  final int completeProfiles;
  final int missingAnyDemographic;
  final int missingDateOfBirth;
  final int missingGender;
  final int missingMaritalStatus;
  final int inactiveRecords;
  final int excludedVisitors;
  final Map<String, int> genderCounts;
  final Map<String, int> maritalStatusCounts;
  final Map<String, int> ageGroupCounts;

  double get completionRate {
    if (totalMembers == 0) {
      return 0;
    }

    return completeProfiles / totalMembers;
  }

  List<DemographicCount> get genderBreakdown => _orderedCounts(
    genderCounts,
    const <String>['Male', 'Female', 'Other', 'Not provided'],
  );

  List<DemographicCount> get maritalStatusBreakdown =>
      _orderedCounts(maritalStatusCounts, const <String>[
        'Single',
        'Married',
        'Divorced',
        'Widowed',
        'Separated',
        'Other',
        'Not provided',
      ]);

  List<DemographicCount> get ageGroupBreakdown =>
      _orderedCounts(ageGroupCounts, const <String>[
        'Children (0-12)',
        'Teens (13-17)',
        'Young Adults (18-35)',
        'Adults (36-64)',
        'Seniors (65+)',
        'Date of birth missing',
      ]);

  factory MemberDemographicsSummary.fromRecords({
    required Map<String, Map<String, dynamic>> members,
    required Map<String, Map<String, dynamic>> privateProfiles,
    DateTime? now,
  }) {
    final effectiveNow = now ?? DateTime.now();

    var totalMembers = 0;
    var adults = 0;
    var childrenAndYouth = 0;
    var unknownAge = 0;
    var completeProfiles = 0;
    var missingAnyDemographic = 0;
    var missingDateOfBirth = 0;
    var missingGender = 0;
    var missingMaritalStatus = 0;
    var inactiveRecords = 0;
    var excludedVisitors = 0;

    final genderCounts = <String, int>{
      'Male': 0,
      'Female': 0,
      'Other': 0,
      'Not provided': 0,
    };

    final maritalStatusCounts = <String, int>{
      'Single': 0,
      'Married': 0,
      'Divorced': 0,
      'Widowed': 0,
      'Separated': 0,
      'Other': 0,
      'Not provided': 0,
    };

    final ageGroupCounts = <String, int>{
      'Children (0-12)': 0,
      'Teens (13-17)': 0,
      'Young Adults (18-35)': 0,
      'Adults (36-64)': 0,
      'Seniors (65+)': 0,
      'Date of birth missing': 0,
    };

    for (final entry in members.entries) {
      final member = entry.value;
      final role = _key(member['role']);

      if (role == 'visitor' || role == 'guest') {
        excludedVisitors += 1;
        continue;
      }

      if (member['isActive'] == false) {
        inactiveRecords += 1;
        continue;
      }

      totalMembers += 1;

      final profile = privateProfiles[entry.key] ?? const <String, dynamic>{};

      final dateOfBirth = _dateFromValue(profile['dateOfBirth']);
      final gender = _genderLabel(profile['gender']);
      final maritalStatus = _maritalStatusLabel(profile['maritalStatus']);

      genderCounts[gender] = (genderCounts[gender] ?? 0) + 1;
      maritalStatusCounts[maritalStatus] =
          (maritalStatusCounts[maritalStatus] ?? 0) + 1;

      final hasDateOfBirth = dateOfBirth != null;
      final hasGender = gender != 'Not provided';
      final hasMaritalStatus = maritalStatus != 'Not provided';

      if (!hasDateOfBirth) {
        missingDateOfBirth += 1;
      }

      if (!hasGender) {
        missingGender += 1;
      }

      if (!hasMaritalStatus) {
        missingMaritalStatus += 1;
      }

      if (hasDateOfBirth && hasGender && hasMaritalStatus) {
        completeProfiles += 1;
      } else {
        missingAnyDemographic += 1;
      }

      final age = dateOfBirth == null
          ? null
          : _ageOn(dateOfBirth, effectiveNow);

      if (age == null || age < 0 || age > 120) {
        unknownAge += 1;
        ageGroupCounts['Date of birth missing'] =
            (ageGroupCounts['Date of birth missing'] ?? 0) + 1;
      } else if (age <= 12) {
        childrenAndYouth += 1;
        ageGroupCounts['Children (0-12)'] =
            (ageGroupCounts['Children (0-12)'] ?? 0) + 1;
      } else if (age <= 17) {
        childrenAndYouth += 1;
        ageGroupCounts['Teens (13-17)'] =
            (ageGroupCounts['Teens (13-17)'] ?? 0) + 1;
      } else if (age <= 35) {
        adults += 1;
        ageGroupCounts['Young Adults (18-35)'] =
            (ageGroupCounts['Young Adults (18-35)'] ?? 0) + 1;
      } else if (age <= 64) {
        adults += 1;
        ageGroupCounts['Adults (36-64)'] =
            (ageGroupCounts['Adults (36-64)'] ?? 0) + 1;
      } else {
        adults += 1;
        ageGroupCounts['Seniors (65+)'] =
            (ageGroupCounts['Seniors (65+)'] ?? 0) + 1;
      }
    }

    return MemberDemographicsSummary(
      totalMembers: totalMembers,
      adults: adults,
      childrenAndYouth: childrenAndYouth,
      unknownAge: unknownAge,
      completeProfiles: completeProfiles,
      missingAnyDemographic: missingAnyDemographic,
      missingDateOfBirth: missingDateOfBirth,
      missingGender: missingGender,
      missingMaritalStatus: missingMaritalStatus,
      inactiveRecords: inactiveRecords,
      excludedVisitors: excludedVisitors,
      genderCounts: Map<String, int>.unmodifiable(genderCounts),
      maritalStatusCounts: Map<String, int>.unmodifiable(maritalStatusCounts),
      ageGroupCounts: Map<String, int>.unmodifiable(ageGroupCounts),
    );
  }

  static List<DemographicCount> _orderedCounts(
    Map<String, int> source,
    List<String> order,
  ) {
    return order
        .map(
          (label) => DemographicCount(label: label, count: source[label] ?? 0),
        )
        .toList(growable: false);
  }

  static String _genderLabel(dynamic value) {
    final normalized = _key(value);

    if (normalized == 'male' || normalized == 'man') {
      return 'Male';
    }

    if (normalized == 'female' || normalized == 'woman') {
      return 'Female';
    }

    if (normalized.isEmpty ||
        normalized == 'unknown' ||
        normalized == 'notspecified' ||
        normalized == 'prefernottosay' ||
        normalized == 'prefernottoanswer') {
      return 'Not provided';
    }

    return 'Other';
  }

  static String _maritalStatusLabel(dynamic value) {
    final normalized = _key(value);

    switch (normalized) {
      case 'single':
        return 'Single';
      case 'married':
        return 'Married';
      case 'divorced':
        return 'Divorced';
      case 'widowed':
        return 'Widowed';
      case 'separated':
        return 'Separated';
      case '':
      case 'unknown':
      case 'notspecified':
      case 'prefernottosay':
      case 'prefernottoanswer':
        return 'Not provided';
      default:
        return 'Other';
    }
  }

  static DateTime? _dateFromValue(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value.trim());
    }

    if (value != null) {
      try {
        final dynamic converted = value.toDate();

        if (converted is DateTime) {
          return converted;
        }
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  static int _ageOn(DateTime dateOfBirth, DateTime now) {
    var age = now.year - dateOfBirth.year;
    final birthdayHasOccurred =
        now.month > dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day >= dateOfBirth.day);

    if (!birthdayHasOccurred) {
      age -= 1;
    }

    return age;
  }

  static String _key(dynamic value) {
    return (value?.toString() ?? '').trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '',
    );
  }
}
