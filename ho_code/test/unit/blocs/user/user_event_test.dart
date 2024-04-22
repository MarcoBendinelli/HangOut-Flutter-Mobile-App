import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';

void main() {
  group('UserEvent', () {
    const userId = 'userId';

    test('LoadUser event should have the correct props', () {
      const event = LoadUser(userId: userId);

      expect(event.props, [userId]);
      expect(event.props.length, 1);
    });
  });
}
