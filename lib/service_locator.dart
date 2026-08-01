import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:global_earn/core/network/network_info.dart';
import 'package:global_earn/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:global_earn/features/auth/domain/repositories/auth_repository.dart';
import 'package:global_earn/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:global_earn/features/auth/presentation/bloc/login_bloc.dart';
import 'package:global_earn/features/auth/presentation/bloc/register_bloc.dart';
import 'package:global_earn/features/home/data/repositories/home_repository_impl.dart';
import 'package:global_earn/features/home/data/repositories/job_submit_repository_impl.dart';
import 'package:global_earn/features/home/data/repositories/subscription_repository_impl.dart';
import 'package:global_earn/features/home/domain/repositories/home_repository.dart';
import 'package:global_earn/features/home/domain/repositories/job_submit_repository.dart';
import 'package:global_earn/features/home/domain/repositories/subscription_repository.dart';
import 'package:global_earn/features/home/presentation/bloc/post_job_bloc.dart';
import 'package:global_earn/features/home/presentation/bloc/subscription_bloc.dart';
import 'package:global_earn/features/home/presentation/bloc/available_jobs_bloc.dart';
import 'package:global_earn/features/home/presentation/bloc/job_submit_bloc.dart';
import 'package:global_earn/features/home/data/repositories/job_approval_repository_impl.dart';
import 'package:global_earn/features/home/domain/repositories/job_approval_repository.dart';
import 'package:global_earn/features/home/presentation/bloc/job_approval_bloc.dart';
import 'package:global_earn/features/network/data/repositories/network_repository_impl.dart';
import 'package:global_earn/features/network/domain/repositories/network_repository.dart';
import 'package:global_earn/features/network/data/repositories/referral_bonus_repository_impl.dart';
import 'package:global_earn/features/network/domain/repositories/referral_bonus_repository.dart';
import 'package:global_earn/features/network/presentation/bloc/upline_report_bloc.dart';
import 'package:global_earn/features/network/presentation/bloc/downline_report_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:global_earn/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:global_earn/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:global_earn/features/home/presentation/bloc/submission_history_bloc.dart';
import 'package:global_earn/features/wallet/data/repositories/voucher_repository_impl.dart';
import 'package:global_earn/features/wallet/domain/repositories/voucher_repository.dart';
import 'package:global_earn/features/wallet/presentation/bloc/voucher_bloc.dart';
import 'package:global_earn/features/wallet/domain/repositories/withdraw_repository.dart';
import 'package:global_earn/features/wallet/data/repositories/withdraw_repository_impl.dart';
import 'package:global_earn/features/wallet/presentation/bloc/withdraw_bloc.dart';
import 'package:global_earn/features/wallet/presentation/bloc/withdraw_history_bloc.dart';
import 'package:global_earn/features/wallet/domain/repositories/transfer_repository.dart';
import 'package:global_earn/features/wallet/data/repositories/transfer_repository_impl.dart';
import 'package:global_earn/features/wallet/presentation/bloc/transfer_bloc.dart';
import 'package:global_earn/features/change_pin/domain/repositories/pin_repository.dart';
import 'package:global_earn/features/change_pin/data/repositories/pin_repository_impl.dart';
import 'package:global_earn/features/change_pin/presentation/bloc/change_pin_bloc.dart';
import 'package:global_earn/features/profile/domain/repositories/profile_repository.dart';
import 'package:global_earn/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:global_earn/features/profile/presentation/bloc/profile_bloc.dart';

import 'package:global_earn/features/wallet/presentation/bloc/transfer_history_bloc.dart';
import 'package:global_earn/features/change_password/domain/repositories/change_password_repository.dart';
import 'package:global_earn/features/change_password/data/repositories/change_password_repository_impl.dart';
import 'package:global_earn/features/change_password/presentation/bloc/change_password_bloc.dart';
import 'package:global_earn/features/reviews/domain/repositories/review_repository.dart';
import 'package:global_earn/features/reviews/data/repositories/review_repository_impl.dart';
import 'package:global_earn/features/reviews/presentation/bloc/reviews_bloc.dart';
import 'package:global_earn/features/delete_account/domain/repositories/delete_account_repository.dart';
import 'package:global_earn/features/delete_account/data/repositories/delete_account_repository_impl.dart';
import 'package:global_earn/features/delete_account/presentation/bloc/delete_account_bloc.dart';
import 'package:global_earn/features/wallet/domain/repositories/deposit_repository.dart';
import 'package:global_earn/features/wallet/data/repositories/deposit_repository_impl.dart';
import 'package:global_earn/features/wallet/presentation/bloc/deposit_bloc.dart';
import 'package:global_earn/features/home/domain/repositories/bonus_repository.dart';
import 'package:global_earn/features/home/data/repositories/bonus_repository_impl.dart';
import 'package:global_earn/features/home/presentation/bloc/bonus_bloc.dart';
// target_bonus, weekly_bonus, monthly_bonus, yearly_bonus bloc imports removed.
// typing_job, daily_bonus, smm_sell repos/blocs deleted — imports removed.
import 'package:global_earn/features/recharge/domain/repositories/recharge_repository.dart';
import 'package:global_earn/features/recharge/data/repositories/recharge_repository_impl.dart';
import 'package:global_earn/features/recharge/presentation/bloc/recharge_bloc.dart';
import 'package:global_earn/features/recharge/presentation/bloc/recharge_history_bloc.dart';
import 'package:global_earn/features/app_update/domain/repositories/app_update_repository.dart';
import 'package:global_earn/features/app_update/data/repositories/app_update_repository_impl.dart';
import 'package:global_earn/features/app_update/presentation/bloc/app_update_bloc.dart';
import 'package:global_earn/features/income_summary/domain/repositories/income_summary_repository.dart';
import 'package:global_earn/features/income_summary/data/repositories/income_summary_repository_impl.dart';
import 'package:global_earn/features/income_summary/presentation/bloc/income_summary_bloc.dart';
// ads_view bloc/repo deleted — imports removed.
import 'package:global_earn/features/support/data/repositories/support_repository.dart';
import 'package:global_earn/features/support/presentation/bloc/support_bloc.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => Connectivity());

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<NetworkRepository>(
    () => NetworkRepositoryImpl(firestore: sl()),
  );
  sl.registerLazySingleton<ReferralBonusRepository>(
    () => ReferralBonusRepositoryImpl(firestore: sl()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(firestore: sl(), auth: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      firestore: sl(),
      referralBonusRepository: sl(),
    ),
  );
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(firestore: sl()),
  );
  sl.registerLazySingleton<VoucherRepository>(
    () => VoucherRepositoryImpl(firestore: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<WithdrawRepository>(
    () => WithdrawRepositoryImpl(firestore: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<DepositRepository>(
    () => DepositRepositoryImpl(db: sl()),
  );
  sl.registerLazySingleton<JobSubmitRepository>(
    () =>
        JobSubmitRepositoryImpl(firestore: sl(), auth: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<JobApprovalRepository>(
    () => JobApprovalRepositoryImpl(firestore: sl(), auth: sl()),
  );

  sl.registerLazySingleton<TransferRepository>(
    () => TransferRepositoryImpl(firestore: sl()),
  );
  sl.registerLazySingleton<PinRepository>(
    () => PinRepositoryImpl(firestore: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(firestore: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(firestore: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<DeleteAccountRepository>(
    () => DeleteAccountRepositoryImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<ChangePasswordRepository>(
    () => ChangePasswordRepositoryImpl(firebaseAuth: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<BonusRepository>(
    () => BonusRepositoryImpl(firestore: sl(), auth: sl()),
  );
  // TypingJobRepository, DailyBonusRepository, SmmSellRepository deleted — registrations removed.
  sl.registerLazySingleton<RechargeRepository>(
    () => RechargeRepositoryImpl(db: sl()),
  );

  // Blocs
  sl.registerLazySingleton(() => UserBloc());
  sl.registerFactory(() => AuthBloc(authRepository: sl(), userBloc: sl()));
  sl.registerFactory(() => LoginBloc(authRepository: sl(), networkInfo: sl()));
  sl.registerFactory(() => RegisterBloc(authRepository: sl()));
  sl.registerFactory(() => SubscriptionBloc(
        subscriptionRepository: sl(),
        authRepository: sl(),
        userBloc: sl(),
      ));
  sl.registerFactory(
    () => PostJobBloc(
      homeRepository: sl(),
      auth: sl(),
      firestore: sl(),
      networkInfo: sl(),
      userBloc: sl(),
    ),
  );
  sl.registerFactory(
    () => AvailableJobsBloc(homeRepository: sl(), networkInfo: sl()),
  );
  sl.registerFactory(
    () => JobSubmitBloc(repository: sl(), auth: sl(), networkInfo: sl()),
  );
  sl.registerFactory(
    () => JobApprovalBloc(repository: sl(), networkInfo: sl()),
  );
  sl.registerFactory(
    () => WalletBloc(
      walletRepository: sl(),
      userBloc: sl(),
      networkInfo: sl(),
      auth: sl(),
    ),
  );
  sl.registerFactory(() => VoucherBloc(voucherRepository: sl()));
  sl.registerFactory(() => SubmissionHistoryBloc(repository: sl()));
  sl.registerFactory(() => WithdrawBloc(repository: sl()));
  sl.registerFactory(() => WithdrawHistoryBloc(repository: sl()));
  sl.registerFactory(() => DepositBloc(repository: sl()));
  sl.registerFactory(() => TransferBloc(repository: sl()));
  sl.registerFactory(() => TransferHistoryBloc(transferRepository: sl()));
  sl.registerFactory(() => ChangePinBloc(repository: sl()));
  sl.registerFactory(() => ProfileBloc(repository: sl(), userBloc: sl()));
  sl.registerFactory(() => ChangePasswordBloc(repository: sl()));
  sl.registerFactory(() => ReviewsBloc(repository: sl()));
  sl.registerFactory(() => DeleteAccountBloc(repository: sl()));
  sl.registerFactory(() => UplineReportBloc(networkRepository: sl()));
  sl.registerFactory(() => DownlineReportBloc(networkRepository: sl()));
  sl.registerFactory(() => BonusBloc(repository: sl<BonusRepository>()));
  // TargetBonusBloc, WeeklyBonusBloc, MonthlyBonusBloc, YearlyBonusBloc,
  // TypingJobBloc, DailyBonusBloc, LeaderboardBloc, SmmSellBloc deleted.
  sl.registerFactory(() => RechargeBloc(repository: sl(), authRepository: sl(), userBloc: sl()));
  sl.registerFactory(() => RechargeHistoryBloc(repository: sl()));

  // App Update
  sl.registerLazySingleton<AppUpdateRepository>(
    () => AppUpdateRepositoryImpl(firestore: sl()),
  );
  sl.registerFactory(() => AppUpdateBloc(repository: sl()));

  // AdsViewRepository / AdsViewBloc deleted — registration removed.

  // Support Center
  sl.registerLazySingleton<SupportRepository>(
    () => SupportRepositoryImpl(firestore: sl()),
  );
  sl.registerFactory(() => SupportBloc(repository: sl(), connectivity: sl()));

  sl.registerLazySingleton<IncomeSummaryRepository>(
    () => IncomeSummaryRepositoryImpl(db: sl()),
  );
  sl.registerFactory(
    () => IncomeSummaryBloc(
      repository: sl(),
      uid: sl<FirebaseAuth>().currentUser?.uid ?? '',
    ),
  );
}

