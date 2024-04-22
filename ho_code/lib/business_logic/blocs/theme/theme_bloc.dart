import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'theme_event.dart';

///State is true if theme selected is dark
class ThemeBloc extends HydratedBloc<ThemeEvent, bool> {
  ThemeBloc({required bool initialValue}) : super(initialValue) {
    on<ThemeChanged>((event, emit) {
      emit(event.isThemeDark);
    });
  }

  @override
  bool fromJson(Map<String, dynamic> json) => json['value'] as bool;

  @override
  Map<String, bool> toJson(bool state) => {'value': state};
}
