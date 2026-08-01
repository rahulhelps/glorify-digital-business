import 'package:flutter/foundation.dart';

@immutable
sealed class TransactionsEvent {}

class LoadTransactions extends TransactionsEvent {}
