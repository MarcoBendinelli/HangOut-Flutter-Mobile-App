import 'package:bloc_test/bloc_test.dart';
import 'package:hang_out_app/business_logic/blocs/my_events/events_bloc.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEventsRepository extends Mock implements MyEventsRepository {}

class MockEvent extends Mock implements Event {}

void main() {
  group('EventsBloc', () {
    final event = MockEvent();
    final List<Event> testEvents = [event];
    final Stream<List<Event>> testEventsStream = Stream.value(testEvents);
    final Stream<List<Event>> testEventsStreamError = Stream.error(Error());
    const String userId = "userId";
    late MyEventsRepository myEventsRepository;

    setUp(() {
      myEventsRepository = MockEventsRepository();
    });

    test('initial state is EventsLoading', () {
      expect(
        EventsBloc(eventsRepository: myEventsRepository).state,
        EventsLoading(),
      );
    });

    blocTest<EventsBloc, EventsState>(
      'getEventsOfUser success',
      setUp: () => when(() => myEventsRepository.getEventsOfUser(userId))
          .thenAnswer((_) async => testEventsStream),
      build: () => EventsBloc(
        eventsRepository: myEventsRepository,
      ),
      act: (bloc) => bloc.add(const LoadEvents(userId: userId)),
      expect: () => [
        EventsLoaded(events: testEvents),
      ],
      verify: (_) {
        verify(() => myEventsRepository.getEventsOfUser(userId)).called(1);
      },
    );

    blocTest<EventsBloc, EventsState>(
      'getEventsOfUser error',
      setUp: () =>
          when(() => myEventsRepository.getEventsOfUser(userId)).thenAnswer(
        (_) async => testEventsStreamError,
      ),
      build: () => EventsBloc(
        eventsRepository: myEventsRepository,
      ),
      act: (bloc) => bloc.add(const LoadEvents(userId: userId)),
      expect: () => [
        EventsError(),
      ],
      verify: (_) {
        verify(() => myEventsRepository.getEventsOfUser(userId)).called(1);
      },
    );
  });
}
