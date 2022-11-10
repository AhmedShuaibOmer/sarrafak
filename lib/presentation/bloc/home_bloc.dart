import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  bool _isHereMapIsReady = false;
  bool _isMapboxMapIsReady = false;

  HomeBloc() : super(HomeInitial()) {
    on<AddHereMapIsReady>((event, emit) {
      _isHereMapIsReady = true;
      if (_isMapboxMapIsReady) {
        emit(MapsLoadedState());
      }
    });
    on<AddMapboxMapIsReady>((event, emit) {
      _isMapboxMapIsReady = true;
      if (_isHereMapIsReady) {
        emit(MapsLoadedState());
      }
    });
  }
}
