import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/wallet/domain/repositories/deposit_repository.dart';
import 'dart:developer' as dev;
import 'deposit_event.dart';
import 'deposit_state.dart';

class DepositBloc extends Bloc<DepositEvent, DepositState> {
  final DepositRepository repository;

  DepositBloc({required this.repository}) : super(DepositInitial()) {
    on<SubmitDeposit>((event, emit) async {
      emit(DepositSubmitting());
      try {
        await repository.submitDeposit(
          uid: event.uid,
          userName: event.userName,
          userEmail: event.userEmail,
          amount: event.amount,
          method: event.method,
          transactionId: event.transactionId,
          submittedAt: event.submittedAt,
        );
        emit(DepositSubmitted());
      } catch (e) {
        dev.log('❌ [Deposit] Error: $e');
        emit(DepositError(e.toString()));
      }
    });

    on<LoadDepositHistory>((event, emit) async {
      emit(DepositLoading());
      try {
        await emit.forEach<List<Map<String, dynamic>>>(
          repository.watchDepositHistory(event.uid),
          onData: (requests) {
            double totalDeposited = 0;
            int pendingCount = 0;

            for (var req in requests) {
              if (req['status'] == 'approved') {
                totalDeposited += (req['amount'] ?? 0).toDouble();
              } else if (req['status'] == 'pending') {
                pendingCount++;
              }
            }

            return DepositHistoryLoaded(
              requests: requests,
              totalDeposited: totalDeposited,
              pendingCount: pendingCount,
            );
          },
          onError: (e, s) {
            dev.log('❌ [Deposit] Error: $e');
            return DepositError(e.toString());
          },
        );
      } catch (e) {
        emit(DepositError(e.toString()));
      }
    });
    on<AutoDepositRequested>((event, emit) async {
      emit(AutoDepositLoading());
      try {
        final url = Uri.parse('https://glorify-digital-business.shop/payment/deposit-create.php');
        
        final requestBody = jsonEncode({
          'uid': event.uid,
          'amount': event.amount,
        });

        dev.log('==== DEBUG DEPOSIT CREATE ====');
        dev.log('URL: $url');
        dev.log('Headers: {"Content-Type": "application/json"}');
        dev.log('Body: $requestBody');
        dev.log('==============================');

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: requestBody,
        );

        dev.log('==== DEBUG DEPOSIT RESPONSE ====');
        dev.log('Status Code: ${response.statusCode}');
        dev.log('Response Body: ${response.body}');
        dev.log('================================');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['paymentUrl'] != null) {
            emit(AutoDepositUrlReady(data['paymentUrl']));
          } else {
            emit(AutoDepositError(data['message'] ?? 'Unknown error occurred'));
          }
        } else {
          emit(AutoDepositError('Server returned status: ${response.statusCode}'));
        }
      } catch (e) {
        dev.log('❌ [DepositBloc] AutoDeposit error: $e');
        emit(AutoDepositError(e.toString()));
      }
    });
  }
}
