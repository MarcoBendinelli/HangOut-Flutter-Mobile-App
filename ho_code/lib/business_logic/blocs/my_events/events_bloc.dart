import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
part 'events_event.dart';
part 'events_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final MyEventsRepository _eventsRepository;

  EventsBloc({required MyEventsRepository eventsRepository})
      : _eventsRepository = eventsRepository,
        super(EventsLoading()) {
    on<LoadEvents>(_onLoadEvents);
  }

  Future<void> _onLoadEvents(
    LoadEvents event,
    Emitter<EventsState> emit,
  ) async {
    await emit.forEach(
      await _eventsRepository.getEventsOfUser(event.userId),
      onData: (List<Event> eventData) => EventsLoaded(events: eventData),
      onError: (_, __) => EventsError(),
    );
  }
}
