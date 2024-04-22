import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/explore/explore_bloc.dart';
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
  group('ExploreBloc', () {
    final mockEvent = MockEvent();
    final mockGroup = MockGroup();
    final List<Event> testEvents = [mockEvent];
    final List<Group> testGroups = [mockGroup];
    const String userId = "userId";
    final categories = ['category1', 'category2'];
    late MyEventsRepository myEventsRepository;
    late MyGroupsRepository myGroupsRepository;
    setUp(() {
      myEventsRepository = MockEventsRepository();
      myGroupsRepository = MockGroupsRepository();
    });

    test('initial state is UsersLoading', () {
      expect(
        ExploreBloc(
                eventsRepository: myEventsRepository,
                groupsRepository: myGroupsRepository)
            .state,
        ExploreEventsLoading(),
      );
    });

    blocTest<ExploreBloc, ExploreState>(
      'emits [ExploreEventsLoaded] when LoadExploreEvents is added',
      build: () {
        final Stream<List<Event>> testEventsStream = Stream.value(testEvents);

        when(() =>
                myEventsRepository.getNonParticipatingEventsOfUser(userId, []))
            .thenAnswer((_) async => testEventsStream);
        return ExploreBloc(
            eventsRepository: myEventsRepository,
            groupsRepository: myGroupsRepository);
      },
      act: (bloc) => bloc.add(const LoadExploreEvents(userId: userId)),
      expect: () => [ExploreEventsLoaded(events: testEvents)],
      verify: (_) {
        verify(() =>
                myEventsRepository.getNonParticipatingEventsOfUser(userId, []))
            .called(1);
      },
    );

    blocTest<ExploreBloc, ExploreState>(
      'emits [ExploreGroupsLoaded] when LoadExploreGroups is added',
      build: () {
        final Stream<List<Group>> testGroupsStream = Stream.value(testGroups);

        when(() =>
                myGroupsRepository.getNonParticipatingGroupOfUser(userId, []))
            .thenAnswer((_) async => testGroupsStream);
        return ExploreBloc(
            eventsRepository: myEventsRepository,
            groupsRepository: myGroupsRepository);
      },
      act: (bloc) => bloc.add(const LoadExploreGroups(userId: userId)),
      expect: () => [ExploreGroupsLoaded(groups: testGroups)],
      verify: (_) {
        verify(() =>
                myGroupsRepository.getNonParticipatingGroupOfUser(userId, []))
            .called(1);
      },
    );

    blocTest<ExploreBloc, ExploreState>(
      'emits [ExploreLoadingError] when events repository throws error',
      build: () {
        final Stream<List<Event>> testEventsStreamError = Stream.error(Error());

        when(() =>
                myEventsRepository.getNonParticipatingEventsOfUser(userId, []))
            .thenAnswer((_) async => testEventsStreamError);
        return ExploreBloc(
            eventsRepository: myEventsRepository,
            groupsRepository: myGroupsRepository);
      },
      act: (bloc) => bloc.add(const LoadExploreEvents(userId: userId)),
      expect: () => [ExploreLoadingError()],
    );

    blocTest<ExploreBloc, ExploreState>(
      'emits [ExploreLoadingError] when groups repository throws error',
      build: () {
        final Stream<List<Group>> testGroupsStreamError = Stream.error(Error());
        when(() =>
                myGroupsRepository.getNonParticipatingGroupOfUser(userId, []))
            .thenAnswer((_) async => testGroupsStreamError);
        return ExploreBloc(
            eventsRepository: myEventsRepository,
            groupsRepository: myGroupsRepository);
      },
      act: (bloc) => bloc.add(const LoadExploreGroups(userId: userId)),
      expect: () => [ExploreLoadingError()],
    );

    group('last categories', () {
      late ExploreBloc bloc;

      setUp(() {
        final Stream<List<Event>> testEventsStream = Stream.value(testEvents);
        final Stream<List<Group>> testGroupsStream = Stream.value(testGroups);
        when(() => myEventsRepository.getNonParticipatingEventsOfUser(
            any(), any())).thenAnswer((_) async => testEventsStream);
        when(() =>
                myGroupsRepository.getNonParticipatingGroupOfUser(any(), any()))
            .thenAnswer((_) async => testGroupsStream);
        bloc = ExploreBloc(
            eventsRepository: myEventsRepository,
            groupsRepository: myGroupsRepository);
      });

      test('initial value of lastCat should be an empty list', () {
        expect(bloc.lastCat, []);
      });

      test('lastCat should update with new categories on [LoadExploreEvents]',
          () async {
        bloc.add(LoadExploreEvents(userId: 'user1', categories: categories));
        await expectLater(bloc.stream, emits(isA<ExploreEventsLoaded>()));
        expect(bloc.lastCat, categories);
      });
      test('lastCat should update with new categories on [LoadExploreGroups]',
          () async {
        bloc.add(LoadExploreGroups(userId: 'user1', categories: categories));
        await expectLater(bloc.stream, emits(isA<ExploreGroupsLoaded>()));
        expect(bloc.lastCat, categories);
      });
    });
  });
}
