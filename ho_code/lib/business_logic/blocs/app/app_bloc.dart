import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hang_out_app/data/models/user.dart';
import 'package:hang_out_app/data/repositories/authentication_repository.dart';

part 'app_event.dart';

part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(
          authenticationRepository.currentUser.isNotEmpty
              ? AppState.authenticated(authenticationRepository.currentUser)
              : const AppState.unauthenticated(),
        ) {
    on<_AppUserChanged>(_onUserChanged);
    on<AppLogoutRequested>(_onLogoutRequested);
    on<DeleteRequested>(_onDeleteRequested);
    _userSubscription = _authenticationRepository.user.listen(
      (user) => add(_AppUserChanged(user)),
    );
  }

  final AuthenticationRepository _authenticationRepository;
  late final StreamSubscription<User> _userSubscription;

  Future<void> _onUserChanged(
      _AppUserChanged event, Emitter<AppState> emit) async {
    if (event.user.isNotEmpty) {
      await _authenticationRepository.saveUserToDB(event.user);
    }
    emit(
      event.user.isNotEmpty
          ? AppState.authenticated(event.user)
          : const AppState.unauthenticated(),
    );
  }

  void _onLogoutRequested(AppLogoutRequested event, Emitter<AppState> emit) {
    unawaited(_authenticationRepository.logOut());
  }

  void _onDeleteRequested(DeleteRequested event, Emitter<AppState> emit) {
    unawaited(_authenticationRepository.delete());
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
