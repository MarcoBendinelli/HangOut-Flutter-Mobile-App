import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/notifications/notifications_bloc.dart';

void main() {
  group('LoadGroups', () {
    test('supports value comparison', () {
      expect(
        const LoadNotifications(userId: '123'),
        const LoadNotifications(userId: '123'),
      );
    });

    test('returns correct props', () {
      const event = LoadNotifications(userId: '456');

      expect(event.props.length, 1);
      expect(event.props.first, '456');
    });
  });
}
