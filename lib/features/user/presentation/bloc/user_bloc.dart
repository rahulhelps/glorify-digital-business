import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<UserLoadedEvent>((event, emit) {
      emit(UserLoaded(event.user));
    });

    on<UserClearedEvent>((event, emit) {
      emit(UserInitial());
    });
  }
}
