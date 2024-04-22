import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';

part 'users_event.dart';

part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UserRepository _userRepository;

  UsersBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(UsersLoading()) {
    on<LoadUsers>(_onLoadUsers);
  }

  Future<void> _onLoadUsers(
    LoadUsers event,
    Emitter<UsersState> emit,
  ) async {
    await emit.forEach(
      _userRepository.getAllUsers(),
      onData: (List<UserData> userData) => UsersLoaded(users: userData),
      onError: (_, __) => UsersError(),
    );
  }
}
