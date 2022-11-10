part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
}

class AddHereMapIsReady extends HomeEvent {
  @override
  List<Object?> get props => [];
}

class AddMapboxMapIsReady extends HomeEvent {
  @override
  List<Object?> get props => [];
}
