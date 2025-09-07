import 'package:flutter_test/flutter_test.dart';
import 'package:list_firebase/app/utils/validators/validation.dart';


void main() {
  group('TValidator', () {
    test('validateEmptyText', () {
      expect(TValidator.validateEmptyText('Name', ''), 'Name is required.');
      expect(TValidator.validateEmptyText('Name', null), 'Name is required.');
      expect(TValidator.validateEmptyText('Name', 'abc'), null);
    });

    test('validateUsername', () {
      expect(TValidator.validateUsername(''), 'Username is required.');
      expect(TValidator.validateUsername('a'), 'Username is not valid.');
      expect(TValidator.validateUsername('_abc'), 'Username is not valid.');
      expect(TValidator.validateUsername('abc_'), 'Username is not valid.');
      expect(TValidator.validateUsername('abc'), null);
      expect(TValidator.validateUsername('user-123'), null);
    });

    test('validateEmail', () {
      expect(TValidator.validateEmail(''), 'Email is required.');
      expect(TValidator.validateEmail('abc'), 'Invalid email address.');
      expect(TValidator.validateEmail('abc@mail.com'), null);
    });

    test('validatePassword', () {
      expect(TValidator.validatePassword(''), 'Password is required.');
      expect(TValidator.validatePassword('abc'), 'Password must be at least 6 characters long.');
      expect(TValidator.validatePassword('abcdef'), 'Password must contain at least one uppercase letter.');
      expect(TValidator.validatePassword('ABCDEF'), 'Password must contain at least one number.');
      expect(TValidator.validatePassword('Abcdef1'), 'Password must contain at least one special character.');
      expect(TValidator.validatePassword('Abcdef1!'), null);
    });

    test('validateMaxLength', () {
      expect(TValidator.validateMaxLength('abcdef', 5, fieldName: 'Nome'),
          'Nome não pode ter mais de 5 caracteres.');
      expect(TValidator.validateMaxLength('abc', 5, fieldName: 'Nome'), null);
    });

    test('validatePhoneNumber', () {
      expect(TValidator.validatePhoneNumber(''), 'Phone number is required.');
      expect(TValidator.validatePhoneNumber('123456789'), 'Invalid phone number format (12 digits required).');
      expect(TValidator.validatePhoneNumber('123456789012'), null);
    });

    test('validateConfirmPassword', () {
      expect(
          TValidator.validateConfirmPassword(password: 'abc', confirmPassword: ''),
          'Confirm password is required');
      expect(
          TValidator.validateConfirmPassword(password: 'abc', confirmPassword: 'abcd'),
          'Passwords do not match');
      expect(
          TValidator.validateConfirmPassword(password: 'abc', confirmPassword: 'abc'),
          null);
    });
  });
}
