import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_earn/core/services/cloudinary_config_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/core/theme/app_theme.dart';
import 'package:global_earn/core/network/bloc/connectivity_bloc.dart';
import 'package:global_earn/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:global_earn/features/auth/presentation/bloc/auth_state.dart';
import 'package:global_earn/features/auth/presentation/bloc/login_bloc.dart';
import 'package:global_earn/features/auth/presentation/bloc/register_bloc.dart';
import 'package:global_earn/features/auth/presentation/screens/login_screen.dart';
import 'package:global_earn/features/auth/presentation/screens/register_screen.dart';
import 'package:global_earn/features/splash/presentation/screens/splash_screen.dart';
import 'package:global_earn/features/app_update/presentation/bloc/app_update_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';
import 'package:global_earn/firebase_options.dart';
import 'package:global_earn/service_locator.dart';
// course feature deleted
import 'package:global_earn/features/home/presentation/bloc/home_bloc.dart';
import 'package:global_earn/features/home/presentation/screens/home_screen.dart';
import 'package:global_earn/features/network/presentation/bloc/network_bloc.dart';
import 'package:global_earn/features/network/presentation/screens/network_screen.dart';
import 'package:global_earn/features/network/presentation/screens/upline_report_screen.dart';
import 'package:global_earn/features/network/presentation/screens/downline_report_screen.dart';
import 'package:global_earn/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:global_earn/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:global_earn/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:global_earn/features/change_password/presentation/screens/change_password_screen.dart';
import 'package:global_earn/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:global_earn/features/profile/presentation/screens/profile_screen.dart';
import 'package:global_earn/features/income_summary/presentation/bloc/income_summary_bloc.dart';
import 'package:global_earn/features/income_summary/presentation/screens/income_summary_screen.dart';
import 'package:global_earn/features/income_summary/domain/entities/filter_type.dart';
import 'package:global_earn/features/income_summary/presentation/screens/income_detail_screen.dart';
import 'package:global_earn/features/change_pin/presentation/bloc/change_pin_bloc.dart';
import 'package:global_earn/features/change_pin/presentation/screens/change_pin_screen.dart';
import 'package:global_earn/features/reviews/presentation/screens/reviews_screen.dart';
import 'package:global_earn/features/delete_account/presentation/screens/delete_account_screen.dart';
import 'package:global_earn/features/wallet/presentation/screens/voucher_balance_screen.dart';
import 'package:global_earn/features/wallet/presentation/screens/voucher_history_screen.dart';
import 'package:global_earn/features/wallet/presentation/bloc/voucher_bloc.dart';

import 'package:global_earn/features/wallet/presentation/screens/withdraw_balance_screen.dart';
import 'package:global_earn/features/wallet/presentation/screens/withdrawal_history_screen.dart';
import 'package:global_earn/features/wallet/presentation/screens/balance_transfer_screen.dart';
import 'package:global_earn/features/wallet/presentation/screens/all_transactions_screen.dart';
import 'package:global_earn/features/wallet/presentation/screens/add_balance_screen.dart';
import 'package:global_earn/features/wallet/presentation/screens/deposit_history_screen.dart';
import 'package:global_earn/features/home/presentation/screens/post_micro_job_screen.dart';
import 'package:global_earn/features/home/presentation/screens/micro_job_panel_screen.dart';
import 'package:global_earn/features/home/presentation/screens/job_detail_screen.dart';
import 'package:global_earn/features/home/presentation/screens/job_approval_screen.dart';
import 'package:global_earn/features/home/presentation/bloc/post_job_bloc.dart';
import 'package:global_earn/features/home/presentation/bloc/available_jobs_bloc.dart';
import 'package:global_earn/features/home/presentation/screens/submission_history_screen.dart';
import 'package:global_earn/features/home/presentation/bloc/submission_history_bloc.dart';
import 'package:global_earn/shared/widgets/bottom_nav_bar.dart';
import 'package:global_earn/features/home/presentation/screens/my_posted_jobs_history_screen.dart' as global_earn;
import 'features/home/presentation/bloc/subscription_bloc.dart';
// welcome_bonus, team_bonus_program, daily_bonus, target_bonus, weekly_bonus,
// monthly_bonus, yearly_bonus, leaderboard, typing_job, smm_sell, ads_view
// screens/blocs deleted — imports removed.
import 'package:global_earn/features/home/presentation/screens/team_bonus_screen.dart';
import 'package:global_earn/features/home/presentation/bloc/bonus_bloc.dart';
import 'package:global_earn/features/recharge/presentation/screens/recharge_main_screen.dart';
import 'package:global_earn/features/recharge/presentation/screens/recharge_add_balance_screen.dart';
import 'package:global_earn/features/recharge/presentation/screens/drive_offers_screen.dart';
import 'package:global_earn/features/recharge/presentation/screens/drive_history_screen.dart';
import 'package:global_earn/features/recharge/presentation/bloc/recharge_bloc.dart';
import 'package:global_earn/features/recharge/presentation/bloc/recharge_event.dart';
import 'package:global_earn/core/services/notification_service.dart';
import 'package:global_earn/features/support/presentation/screens/support_center_screen.dart';
import 'package:global_earn/features/support/presentation/bloc/support_bloc.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: BlocProvider<AppUpdateBloc>(
          create: (_) => sl<AppUpdateBloc>(),
          child: const SplashScreen(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const RegisterScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final showDialog = extra['showVerificationSuccessDialog'] == true;
            return CustomTransitionPage(
              key: state.pageKey,
              child: MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => HomeBloc()),
                  BlocProvider(create: (_) => sl<SubscriptionBloc>()),
                ],
                child: HomeScreen(showVerificationSuccessDialog: showDialog),
              ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 150),
          );
        },
      ),

        GoRoute(
          path: '/wallet',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const WalletScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 150),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider(
              create: (_) => sl<ProfileBloc>(),
              child: const ProfileScreen(),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 150),
          ),
        ),
        GoRoute(
          path: '/network',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider(
              create: (_) => NetworkBloc(userBloc: context.read<UserBloc>()),
              child: const NetworkScreen(),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 150),
          ),
        ),
        GoRoute(
          path: '/transactions',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider(
              create: (_) => TransactionsBloc(),
              child: const TransactionsScreen(),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 150),
          ),
        ),

      ],
    ),
    GoRoute(
      path: '/home/post-micro-job',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: BlocProvider(
          create: (_) => sl<PostJobBloc>(),
          child: const PostMicroJobScreen(),
        ),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    ),
    GoRoute(
      path: '/home/my-posted-jobs-history',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const global_earn.MyPostedJobsHistoryScreen(),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    ),
    GoRoute(
      path: '/home/micro-job-panel',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: BlocProvider(
          create: (_) => sl<AvailableJobsBloc>(),
          child: const MicroJobPanelScreen(),
        ),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    ),
    GoRoute(
      path: '/home/job-detail/:jobId',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: Builder(
            builder: (context) {
              final jobId = state.pathParameters['jobId']!;
              return JobDetailScreen(jobId: jobId);
            },
          ),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
          transitionDuration: const Duration(milliseconds: 150),
        );
      },
    ),
    GoRoute(
      path: '/home/job-approval',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const JobApprovalScreen(),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    ),
    GoRoute(
      path: '/home/submission-history',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: BlocProvider(
          create: (_) => sl<SubmissionHistoryBloc>(),
          child: const SubmissionHistoryScreen(),
        ),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    ),
    // /home/welcome-bonus removed — screen deleted
    GoRoute(
      path: '/home/team-bonus',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: BlocProvider(
          create: (_) => sl<BonusBloc>(),
          child: const TeamBonusScreen(),
        ),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    ),
    // /home/team-bonus-program removed — screen deleted
    // /home/daily-bonus removed — screen deleted
    // /home/target-bonus removed — screen deleted
    // /home/weekly-bonus removed — screen deleted
    // /home/rank-project removed — screen deleted
    // /home/monthly-bonus removed — screen deleted
    // /home/yearly-bonus removed — screen deleted
    // /home/typing-job removed — screen/folder deleted
    GoRoute(
      path: '/network/upline-report',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: Builder(
            builder: (context) {
              final referredBy = state.extra as String? ?? '';
              return UplineReportScreen(referredBy: referredBy);
            },
          ),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
          transitionDuration: const Duration(milliseconds: 150),
        );
      },
    ),
    GoRoute(
      path: '/network/downline-report',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: Builder(
            builder: (context) {
              final referCode = state.extra as String? ?? '';
              return DownlineReportScreen(referCode: referCode);
            },
          ),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
          transitionDuration: const Duration(milliseconds: 150),
        );
      },
    ),
    // /smm/instagram, /smm/facebook, /smm/gmail, /smm/history removed — smm_sell feature deleted
    GoRoute(
      path: '/change-password',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ChangePasswordScreen(),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    ),
    GoRoute(
      path: '/income-summary',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: BlocProvider(
          create: (_) => sl<IncomeSummaryBloc>(),
          child: const IncomeSummaryScreen(),
        ),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
        transitionDuration: const Duration(milliseconds: 150),
      ),
      routes: [
        GoRoute(
          path: 'detail',
          pageBuilder: (context, state) {
            final filterType = state.extra as FilterType;
            return CustomTransitionPage(
              key: state.pageKey,
              child: BlocProvider(
                create: (_) => sl<IncomeSummaryBloc>(),
                child: IncomeDetailScreen(filterType: filterType),
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
              transitionDuration: const Duration(milliseconds: 150),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/change-pin',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: BlocProvider(
          create: (_) => sl<ChangePinBloc>(),
          child: const ChangePinScreen(),
        ),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    ),
    GoRoute(
      path: '/reviews',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ReviewsScreen(),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    ),
    GoRoute(
      path: '/delete-account',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const DeleteAccountScreen(),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    ),
    GoRoute(
      path: '/support',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: BlocProvider(
          create: (_) => sl<SupportBloc>(),
          child: const SupportCenterScreen(),
        ),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    ),
    GoRoute(
      path: '/voucher-balance',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const VoucherBalanceScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    ),
    GoRoute(
      path: '/withdraw-balance',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const WithdrawBalanceScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    ),
    GoRoute(
      path: '/withdrawal-history',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const WithdrawalHistoryScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    ),
    GoRoute(
      path: '/balance-transfer',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const BalanceTransferScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    ),
    GoRoute(
      path: '/all-transactions',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AllTransactionsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    ),
    GoRoute(
      path: '/wallet/voucher-history',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const VoucherHistoryScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    ),
    GoRoute(
      path: '/wallet/add-balance',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AddBalanceScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    ),
    GoRoute(
      path: '/wallet/deposit-history',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const DepositHistoryScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    ),
    GoRoute(
      path: '/home/recharge',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: Builder(
          builder: (bCtx) {
            final uid =
                bCtx.read<UserBloc>().state is UserLoaded
                    ? (bCtx.read<UserBloc>().state as UserLoaded).user.uid
                    : '';
            return BlocProvider(
              create: (_) => sl<RechargeBloc>()
                ..add(WatchRechargeBalance(uid)),
              child: const RechargeMainScreen(),
            );
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ),
    GoRoute(
      path: '/home/drive-offers',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: Builder(
          builder: (bCtx) {
            final uid =
                bCtx.read<UserBloc>().state is UserLoaded
                    ? (bCtx.read<UserBloc>().state as UserLoaded).user.uid
                    : '';
            return BlocProvider(
              create: (_) => sl<RechargeBloc>()
                ..add(WatchRechargeBalance(uid)),
              child: const DriveOffersScreen(),
            );
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ),
    GoRoute(
      path: '/home/drive-offers/history',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const DriveHistoryScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ),
    GoRoute(
      path: '/home/recharge/add-balance',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: Builder(
          builder: (bCtx) {
            final uid =
                bCtx.read<UserBloc>().state is UserLoaded
                    ? (bCtx.read<UserBloc>().state as UserLoaded).user.uid
                    : '';
            return BlocProvider(
              create: (_) => sl<RechargeBloc>()
                ..add(WatchRechargeBalance(uid)),
              child: const RechargeAddBalanceScreen(),
            );
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ),
    // /home/ads-view removed — screen deleted
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      // Firebase already initialized (hot restart) — safe to ignore
    } else {
      rethrow;
    }
  }
  await CloudinaryConfigService.load();
  await setupLocator();

  // ── FCM: Initialize notification service (permissions, channel, listeners) ──
  // Wire up the tap callback so notifications navigate to /home.
  NotificationService.onNotificationTap = (message) {
    _router.go('/home');
  };
  await NotificationService.initialize();
  // ─────────────────────────────────────────────────────────────────────────

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.coral,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const LifeChangeApp());
}

class LifeChangeApp extends StatelessWidget {
  const LifeChangeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ConnectivityBloc>(create: (_) => ConnectivityBloc()),
        BlocProvider<UserBloc>(create: (_) => sl<UserBloc>()),
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<LoginBloc>(create: (_) => sl<LoginBloc>()),
        BlocProvider<RegisterBloc>(create: (_) => sl<RegisterBloc>()),
        BlocProvider<VoucherBloc>(create: (_) => sl<VoucherBloc>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          final currentPath = _router.routerDelegate.currentConfiguration.uri
              .toString();
          if (currentPath == '/') {
            return; // Let splash screen handle the initial navigation
          }

          if (state is AuthAuthenticated) {
            _router.go('/home');
            // ── FCM: Save token, subscribe to broadcast topic, watch refresh ──
            final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
            if (uid.isNotEmpty) {
              NotificationService.updateUserFcmToken(uid);
              NotificationService.subscribeToAllUsersTopic();
              NotificationService.setupTokenRefreshListener(uid);
            }
            // ─────────────────────────────────────────────────────────────────
          } else if (state is AuthUnauthenticated) {
            _router.go('/login');
          }
        },
        child: MaterialApp.router(
          title: 'Glorify Digital Business',
          theme: AppTheme.darkTheme,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

