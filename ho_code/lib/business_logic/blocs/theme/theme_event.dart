part of 'theme_bloc.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
}

class ThemeChanged extends ThemeEvent {
  final bool isThemeDark;
  const ThemeChanged({required this.isThemeDark});
  @override
  List<Object> get props => [isThemeDark];
}
