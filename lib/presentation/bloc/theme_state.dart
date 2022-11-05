part of 'theme_bloc.dart';

class ThemeState extends Equatable {
  final ThemingMode mode;
  final bool isLight;

  const ThemeState({this.mode = ThemingMode.light, this.isLight = true});

  @override
  List<Object> get props => [mode, isLight];
}
