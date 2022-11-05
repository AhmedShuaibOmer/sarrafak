part of 'theme_bloc.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
}

class AddChangeTheme extends ThemeEvent {
  final ThemingMode mode;
  final bool isLight;

  const AddChangeTheme(this.mode, this.isLight);

  @override
  List<Object> get props => [mode, isLight];
}

class AddToggleTheme extends ThemeEvent {
  const AddToggleTheme();

  @override
  List<Object> get props => [];
}
