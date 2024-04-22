import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/my_groups/groups_bloc.dart';

void main() {
  group('LoadGroups', () {
    test('supports value comparison', () {
      expect(
        const LoadGroups(userId: '123'),
        const LoadGroups(userId: '123'),
      );
    });

    test('returns correct props', () {
      const event = LoadGroups(userId: '456');

      expect(event.props.length, 1);
      expect(event.props.first, '456');
    });
  });
}
