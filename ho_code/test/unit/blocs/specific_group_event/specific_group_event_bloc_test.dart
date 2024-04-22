import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/specific_group_event/specific_group_event_bloc.dart';

import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockEventsRepository extends Mock implements MyEventsRepository {}

class MockGroupsRepository extends Mock implements MyGroupsRepository {}

class MockEvent extends Mock implements Event {}

class MockGroup extends Mock implements Group {}

void main() {
  group('specificGroupEventBloc', () {
    final mockEvent = MockEvent();
    final mockGroup = MockGroup();
    final Event testEvent = mockEvent;
    final Group testGroup = mockGroup;
    const String eventId = "eventId";
    const String groupId = "groupId";

    late MyEventsRepository myEventsRepository;
    late MyGroupsRepository myGroupsRepository;
    setUp(() {
      myEventsRepository = MockEventsRepository();
      myGroupsRepository = MockGroupsRepository();
    });

    test('initial state is UsersLoading', () {
      expect(
        SpecificGroupEventBloc(groupsRepository: myGroupsRepository,eventsRepository: myEventsRepository).state,
        SpecificGroupEventLoading(),
      );
    });

    blocTest<SpecificGroupEventBloc, SpecificGroupEventState>(
      'emits [SpecificGroupEventLoaded] when LoadSpecificEvent is added',
      build: () {
        final Stream<Event> testEventsStream = Stream.value(testEvent);

        when(() => myEventsRepository.getEventWithId(eventId))
            .thenAnswer((_) async => testEventsStream);
        return SpecificGroupEventBloc(
            eventsRepository: myEventsRepository,
            groupsRepository: myGroupsRepository);
      },
      act: (bloc) => bloc.add(const LoadSpecificEvent(eventId: eventId)),
      expect: () => [SpecificGroupEventLoaded(event: testEvent)],
      verify: (_) {
        verify(() => myEventsRepository.getEventWithId(eventId)).called(1);
        verifyNever(() => myGroupsRepository.getGroupWithId(eventId));
      },
    );

    blocTest<SpecificGroupEventBloc, SpecificGroupEventState>(
      'emits [SpecificGroupEventLoaded] when LoadSpecificGroup is added',
      build: () {
        final Stream<Group> testGroupsStream = Stream.value(testGroup);

        when(() => myGroupsRepository.getGroupWithId(groupId))
            .thenAnswer((_) async => testGroupsStream);
        return SpecificGroupEventBloc(
            eventsRepository: myEventsRepository,
            groupsRepository: myGroupsRepository);
      },
      act: (bloc) => bloc.add(const LoadSpecificGroup(groupId: groupId)),
      expect: () => [SpecificGroupEventLoaded(group: testGroup)],
      verify: (_) {
        verify(() => myGroupsRepository.getGroupWithId(groupId)).called(1);
        verifyNever(() => myEventsRepository.getEventWithId(eventId));
      },
    );

     blocTest<SpecificGroupEventBloc, SpecificGroupEventState>(
      'emits [SpecificGroupEventError] when events repository throws error',
      build: () {
        final Stream<Event> testEventsStreamError = Stream.error(Error());

        when(() =>
                myEventsRepository.getEventWithId(any()))
            .thenAnswer((_) async => testEventsStreamError);
        return SpecificGroupEventBloc(
            eventsRepository: myEventsRepository,
            groupsRepository: myGroupsRepository);
      },
      act: (bloc) => bloc.add(const LoadSpecificEvent(eventId: eventId)),
      expect: () => [SpecificGroupEventError()],
    );

    blocTest<SpecificGroupEventBloc, SpecificGroupEventState>(
      'emits [SpecificGroupEventError] when groups repository throws error',
      build: () {
        final Stream<Group> testGroupStreamError = Stream.error(Error());

        when(() =>
                myGroupsRepository.getGroupWithId(any()))
            .thenAnswer((_) async => testGroupStreamError);
        return SpecificGroupEventBloc(
            eventsRepository: myEventsRepository,
            groupsRepository: myGroupsRepository);
      },
      act: (bloc) => bloc.add(const LoadSpecificGroup(groupId: eventId)),
      expect: () => [SpecificGroupEventError()],
    );
  });
}
