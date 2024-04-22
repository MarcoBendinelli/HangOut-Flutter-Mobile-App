import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/my_events/events_bloc.dart';

void main() {
  group('LoadEvents', () {
    test('supports value comparison', () {
      expect(
        const LoadEvents(userId: '123'),
        const LoadEvents(userId: '123'),
      );
    });

    test('returns correct props', () {
      const event = LoadEvents(userId: '456');

      expect(event.props.length, 1);
      expect(event.props.first, '456');
    });
  });
}
