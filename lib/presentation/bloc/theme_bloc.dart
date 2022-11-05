import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'theme_event.dart';
part 'theme_state.dart';

enum ThemingMode { light, dark }

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeState currentState = const ThemeState();
  ThemeBloc() : super(const ThemeState()) {
    on<AddToggleTheme>((event, emit) {
      currentState = ThemeState(
        mode: currentState.isLight ? ThemingMode.dark : ThemingMode.light,
        isLight: !currentState.isLight,
      );
      emit(currentState);
    });
  }
}
