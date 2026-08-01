import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/auth/domain/repositories/auth_repository.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_event.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final UserBloc _userBloc;
  StreamSubscription<User?>? _userSubscription;

  AuthBloc({required AuthRepository authRepository, required UserBloc userBloc})
    : _authRepository = authRepository,
      _userBloc = userBloc,
      super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthUserChanged>(_onAuthUserChanged);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);

    _userSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      add(AuthUserChanged(user));
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Let AuthUserChanged handle the state.
  }

  Future<void> _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.firebaseUser != null) {
      try {
        final userModel = await _authRepository.getCurrentUser();
        if (userModel != null) {
          _userBloc.add(UserLoadedEvent(userModel));
          emit(const AuthAuthenticated());
        } else {
          emit(const AuthUnauthenticated());
        }
      } catch (_) {
        emit(const AuthUnauthenticated());
      }
    } else {
      _userBloc.add(UserClearedEvent());
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    _userBloc.add(UserClearedEvent());
    emit(const AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
