import 'package:flutter/foundation.dart';

@immutable
sealed class TransactionsState {}

final class TransactionsInitial extends TransactionsState {}

final class TransactionsLoaded extends TransactionsState {}
