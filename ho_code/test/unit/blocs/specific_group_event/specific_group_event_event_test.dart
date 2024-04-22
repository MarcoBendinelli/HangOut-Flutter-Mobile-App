import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/specific_group_event/specific_group_event_bloc.dart';

void main() {
  group('SpecificGroupEventEvent', () {
    test('LoadSpecificGroup event should be equatable', () {
      const event1 = LoadSpecificGroup(groupId: 'group1');
      const event2 = LoadSpecificGroup(groupId: 'group1');
      const event3 = LoadSpecificGroup(groupId: 'group2');

      expect(event1, event2);
      expect(event1 == event3, false);
    });

    test('LoadSpecificEvent event should be equatable', () {
      const event1 = LoadSpecificEvent(eventId: 'event1');
      const event2 = LoadSpecificEvent(eventId: 'event1');
      const event3 = LoadSpecificEvent(eventId: 'event2');

      expect(event1, event2);
      expect(event1 == event3, false);
    });
  });
}
