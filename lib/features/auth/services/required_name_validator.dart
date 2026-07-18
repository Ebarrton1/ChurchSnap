class RequiredNamePrefill {
  const RequiredNamePrefill({required this.firstName, required this.lastName});

  final String firstName;
  final String lastName;
}

class RequiredNameValidator {
  const RequiredNameValidator._();

  static const int maximumPartLength = 60;

  static const Set<String> _placeholderNames = <String>{
    'churchsnap member',
    'guest visitor',
    'unknown user',
    'unnamed member',
    'test user',
  };

  static String normalize(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String? validatePart(String value, {required String label}) {
    final normalized = normalize(value);

    if (normalized.isEmpty) {
      return '$label is required.';
    }

    if (normalized.length > maximumPartLength) {
      return '$label must be $maximumPartLength characters or fewer.';
    }

    if (normalized.contains(RegExp(r'[\r\n\t]'))) {
      return '$label must be entered on one line.';
    }

    if (!normalized.contains(
      RegExp(r'[A-Za-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u00FF]'),
    )) {
      return '$label must contain at least one letter.';
    }

    return null;
  }

  static String? validateFullName({
    required String firstName,
    required String lastName,
  }) {
    final firstError = validatePart(firstName, label: 'First name');

    if (firstError != null) {
      return firstError;
    }

    final lastError = validatePart(lastName, label: 'Last name');

    if (lastError != null) {
      return lastError;
    }

    final displayName = buildDisplayName(
      firstName: firstName,
      lastName: lastName,
    ).toLowerCase();

    if (_placeholderNames.contains(displayName)) {
      return 'Please enter your actual first and last names.';
    }

    return null;
  }

  static String buildDisplayName({
    required String firstName,
    required String lastName,
  }) {
    return '${normalize(firstName)} ${normalize(lastName)}';
  }

  static RequiredNamePrefill splitDisplayName(String displayName) {
    final normalized = normalize(displayName);

    if (normalized.isEmpty ||
        _placeholderNames.contains(normalized.toLowerCase())) {
      return const RequiredNamePrefill(firstName: '', lastName: '');
    }

    final parts = normalized.split(' ');

    if (parts.length < 2) {
      return RequiredNamePrefill(firstName: normalized, lastName: '');
    }

    return RequiredNamePrefill(
      firstName: parts.first,
      lastName: parts.skip(1).join(' '),
    );
  }
}
