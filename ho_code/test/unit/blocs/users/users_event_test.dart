import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/users/users_bloc.dart';

void main() {
  group('UsersEvent', () {
    test('LoadUsers event should have the correct props (0)', () {
      const event = LoadUsers();

      expect(event.props, []);
      expect(event.props.length, 0);
    });
  });
}
