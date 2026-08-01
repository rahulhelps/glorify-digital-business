import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/auth/domain/repositories/auth_repository.dart';
import 'register_event.dart';
import 'package:global_earn/core/errors/invalid_refer_code_exception.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository _authRepository;

  RegisterBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());
    try {
      if (event.referredBy != null && event.referredBy!.isNotEmpty && event.referredBy!.length < 4) {
        emit(const RegisterFailure('রেফার কোড কমপক্ষে ৪ অক্ষর হতে হবে'));
        return;
      }
      final user = await _authRepository.register(
        name: event.name,
        phone: event.phone,
        email: event.email,
        password: event.password,
        referredBy: event.referredBy,
      );
      emit(RegisterSuccess(user));
    } on InvalidReferCodeException catch (e) {
      emit(RegisterFailure(e.message));
    } catch (e) {
      emit(RegisterFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
