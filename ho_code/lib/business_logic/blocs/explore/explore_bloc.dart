import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
part 'explore_event.dart';
part 'explore_state.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final MyEventsRepository _eventsRepository;
  final MyGroupsRepository _groupsRepository;
  List<String> lastCat = [];

  ExploreBloc(
      {required MyGroupsRepository groupsRepository,
      required MyEventsRepository eventsRepository})
      : _groupsRepository = groupsRepository,
        _eventsRepository = eventsRepository,
        super(ExploreEventsLoading()) {
    on<LoadExploreEvents>(_onLoadEvents);
    on<LoadExploreGroups>(_onLoadGroups);
  }

  Future<void> _onLoadEvents(
    LoadExploreEvents event,
    Emitter<ExploreState> emit,
  ) async {
    if (event.categories != null) {
      lastCat = event.categories!;
    }
    await emit.forEach(
      await _eventsRepository.getNonParticipatingEventsOfUser(
          event.userId, lastCat),
      onData: (List<Event> eventData) => ExploreEventsLoaded(events: eventData),
      onError: (_, __) => ExploreLoadingError(),
    );
  }

  Future<void> _onLoadGroups(
    LoadExploreGroups event,
    Emitter<ExploreState> emit,
  ) async {
    if (event.categories != null) {
      lastCat = event.categories!;
    }
    await emit.forEach(
      await _groupsRepository.getNonParticipatingGroupOfUser(
          event.userId, lastCat),
      onData: (List<Group> groupData) => ExploreGroupsLoaded(groups: groupData),
      onError: (_, __) => ExploreLoadingError(),
    );
  }
}
