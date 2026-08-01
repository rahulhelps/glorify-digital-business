import 'package:equatable/equatable.dart';

abstract class NetworkEvent extends Equatable {
  const NetworkEvent();

  @override
  List<Object> get props => [];
}

class NetworkStarted extends NetworkEvent {
  const NetworkStarted();
}

class NetworkRefreshRequested extends NetworkEvent {
  const NetworkRefreshRequested();
}
