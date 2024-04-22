import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hang_out_app/data/models/event.dart';

void main() {
  group('Event class get methods', () {
    late Event event;

    setUp(() {
      final date = Timestamp.fromDate(DateTime(2022, 10, 30, 18, 30));
      event = Event(
        id: '123',
        name: 'Test Event',
        category: 'Test Category',
        numParticipants: 5,
        photo: 'https://example.com/test.jpg',
        date: date,
        private: true,
        description: 'Test description',
        creatorId: '456',
        location: const GeoPoint(0, 0),
        locationName: 'Test location',
      );
    });

    test('getDayName() returns correct day name', () {
      expect(event.getDayName(), 'Sunday');
    });

    test('getDay() returns correct day', () {
      expect(event.getDay(), '30');
    });

    test('getMonth() returns correct month', () {
      expect(event.getMonth(), 'Oct');
    });

    test('getYear() returns correct year', () {
      expect(event.getYear(), '2022');
    });

    test('getHour() returns correct hour format', () {
      expect(event.getHour(), '6:30PM');
    });
  });
}
