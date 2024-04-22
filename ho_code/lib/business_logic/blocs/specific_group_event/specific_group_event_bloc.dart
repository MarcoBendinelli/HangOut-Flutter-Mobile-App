import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hang_out_app/data/models/event.dart';

import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';

part 'specific_group_event_event.dart';

part 'specific_group_event_state.dart';

class SpecificGroupEventBloc
    extends Bloc<SpecificGroupEventEvent, SpecificGroupEventState> {
  final MyGroupsRepository _groupsRepository;
  final MyEventsRepository _eventsRepository;

  SpecificGroupEventBloc(
      {required MyGroupsRepository groupsRepository,
      required MyEventsRepository eventsRepository})
      : _groupsRepository = groupsRepository,
        _eventsRepository = eventsRepository,
        super(SpecificGroupEventLoading()) {
    on<LoadSpecificGroup>(_onLoadSpecificGroup);
    on<LoadSpecificEvent>(_onLoadSpecificEvent);
  }

  Future<void> _onLoadSpecificGroup(
    LoadSpecificGroup event,
    Emitter<SpecificGroupEventState> emit,
  ) async {
    await emit.forEach(
      await _groupsRepository.getGroupWithId(event.groupId),
      onData: (Group groupData) => SpecificGroupEventLoaded(group: groupData),
      onError: (_, __) => SpecificGroupEventError(),
    );
  }

  Future<void> _onLoadSpecificEvent(
    LoadSpecificEvent event,
    Emitter<SpecificGroupEventState> emit,
  ) async {
    await emit.forEach(
      await _eventsRepository.getEventWithId(event.eventId),
      onData: (Event eventData) => SpecificGroupEventLoaded(event: eventData),
      onError: (_, __) => SpecificGroupEventError(),
    );
  }
}
