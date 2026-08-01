import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/core/network/network_info.dart';
import 'package:global_earn/features/auth/domain/repositories/auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;
  final NetworkInfo _networkInfo;

  LoginBloc({
    required AuthRepository authRepository,
    required NetworkInfo networkInfo,
  }) : _authRepository = authRepository,
       _networkInfo = networkInfo,
       super(const LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());
    try {
      final user = await _authRepository.login(
        event.identifier,
        event.password,
      );
      emit(LoginSuccess(user));
    } catch (e) {
      emit(LoginFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(ForgotPasswordLoading());
    try {
      // Check internet
      if (!await _networkInfo.isConnected) {
        emit(const ForgotPasswordError('ইন্টারনেট সংযোগ নেই'));
        return;
      }
      await FirebaseAuth.instance.sendPasswordResetEmail(email: event.email);
      debugPrint('✅ [ForgotPassword] Reset email sent to: ${event.email}');
      emit(ForgotPasswordSuccess());
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [ForgotPassword] Error: ${e.code}');
      final message = switch (e.code) {
        'user-not-found' => 'এই ইমেইলে কোনো অ্যাকাউন্ট নেই',
        'invalid-email' => 'সঠিক ইমেইল ঠিকানা দিন',
        'too-many-requests' =>
          'অনেকবার চেষ্টা হয়েছে, কিছুক্ষণ পর আবার চেষ্টা করুন',
        _ => 'কিছু একটা সমস্যা হয়েছে, আবার চেষ্টা করুন',
      };
      emit(ForgotPasswordError(message));
    } catch (e) {
      emit(const ForgotPasswordError('কিছু একটা সমস্যা হয়েছে'));
    }
  }
}
