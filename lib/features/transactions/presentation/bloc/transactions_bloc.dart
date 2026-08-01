import 'package:flutter_bloc/flutter_bloc.dart';
import 'transactions_event.dart';
import 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  TransactionsBloc() : super(TransactionsInitial()) {
    on<LoadTransactions>((event, emit) {
      emit(TransactionsLoaded());
    });
  }
}
