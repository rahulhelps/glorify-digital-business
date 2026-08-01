import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/wallet/domain/repositories/withdraw_repository.dart';

part 'withdraw_event.dart';
part 'withdraw_state.dart';

class WithdrawBloc extends Bloc<WithdrawEvent, WithdrawState> {
  final WithdrawRepository repository;

  WithdrawBloc({required this.repository}) : super(WithdrawInitial()) {
    on<SelectPaymentMethod>((event, emit) {
      emit(
        WithdrawInitial(
          selectedMethod: event.method, 
          bankName: state.bankName,
          inputAmount: state.inputAmount,
          feeAmount: state.feeAmount,
          payableAmount: state.payableAmount,
        ),
      );
    });

    on<UpdateBankName>((event, emit) {
      emit(
        WithdrawInitial(
          selectedMethod: state.selectedMethod,
          bankName: event.bankName,
          inputAmount: state.inputAmount,
          feeAmount: state.feeAmount,
          payableAmount: state.payableAmount,
        ),
      );
    });

    on<AmountChangedEvent>((event, emit) {
      final input = double.tryParse(event.amountStr) ?? 0.0;
      final fee = input * 0.03;
      final payable = input - fee;

      emit(
        WithdrawInitial(
          selectedMethod: state.selectedMethod,
          bankName: state.bankName,
          inputAmount: input,
          feeAmount: fee,
          payableAmount: payable,
        ),
      );
    });

    on<SubmitWithdraw>((event, emit) async {
      emit(
        WithdrawLoading(
          selectedMethod: state.selectedMethod,
          bankName: state.bankName,
          inputAmount: state.inputAmount,
          feeAmount: state.feeAmount,
          payableAmount: state.payableAmount,
        ),
      );
      try {
        await repository.submitWithdrawRequest(
          uid: event.uid,
          userName: event.userName,
          amount: event.amount,
          method: event.method,
          accountNumber: event.accountNumber,
          earning: event.earning,
          voucher: event.voucher,
          referral: event.referral,
          bankName: event.bankName,
        );
        emit(
          WithdrawSuccess(
            selectedMethod: state.selectedMethod,
            bankName: state.bankName,
            inputAmount: state.inputAmount,
            feeAmount: state.feeAmount,
            payableAmount: state.payableAmount,
          ),
        );
      } catch (e) {
        emit(
          WithdrawError(
            e.toString(),
            selectedMethod: state.selectedMethod,
            bankName: state.bankName,
            inputAmount: state.inputAmount,
            feeAmount: state.feeAmount,
            payableAmount: state.payableAmount,
          ),
        );
      }
    });
  }
}
