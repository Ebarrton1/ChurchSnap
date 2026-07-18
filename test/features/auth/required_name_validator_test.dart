import 'package:churchsnap/features/auth/services/required_name_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RequiredNameValidator', () {
    test('requires both first and last names', () {
      expect(
        RequiredNameValidator.validateFullName(
          firstName: '',
          lastName: 'Barrett',
        ),
        'First name is required.',
      );

      expect(
        RequiredNameValidator.validateFullName(
          firstName: 'Everton',
          lastName: '',
        ),
        'Last name is required.',
      );
    });

    test('normalizes repeated whitespace', () {
      expect(
        RequiredNameValidator.buildDisplayName(
          firstName: '  Mary   Ann ',
          lastName: '  Johnson  ',
        ),
        'Mary Ann Johnson',
      );
    });

    test('rejects placeholder account names', () {
      expect(
        RequiredNameValidator.validateFullName(
          firstName: 'ChurchSnap',
          lastName: 'Member',
        ),
        'Please enter your actual first and last names.',
      );
    });

    test('prefills a stored full display name', () {
      final prefill = RequiredNameValidator.splitDisplayName(
        'Everton A. Barrett',
      );

      expect(prefill.firstName, 'Everton');
      expect(prefill.lastName, 'A. Barrett');
    });

    test('does not prefill the default placeholder', () {
      final prefill = RequiredNameValidator.splitDisplayName(
        'ChurchSnap Member',
      );

      expect(prefill.firstName, isEmpty);
      expect(prefill.lastName, isEmpty);
    });

    test('accepts apostrophes and hyphens', () {
      expect(
        RequiredNameValidator.validateFullName(
          firstName: "Anne-Marie",
          lastName: "O'Neil",
        ),
        isNull,
      );
    });
  });
}
