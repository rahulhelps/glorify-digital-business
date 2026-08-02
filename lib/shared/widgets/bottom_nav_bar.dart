// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import 'package:go_router/go_router.dart';
// import 'package:global_earn/core/constants/app_colors.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:global_earn/core/constants/app_strings.dart';
// import 'package:global_earn/shared/widgets/app_drawer.dart';
//
// // ─────────────────────────────────────────────────────────────────────────────
// // AppShell
// // ─────────────────────────────────────────────────────────────────────────────
//
// /// Persistent shell.
// ///
// /// The header row + segmented pill tab bar both live inside ONE unified
// /// gradient card ([UnifiedTopHeader]). No Positioned/overlap tricks.
// ///
// /// [AppBottomNavBar] and [FloatingTopNavBar] are preserved below but unused.
// class AppShell extends StatelessWidget {
//   final Widget child;
//
//   const AppShell({super.key, required this.child});
//
//   static const _routes = ['/home', '/wallet', '/profile', '/network'];
//
//   int _indexFor(BuildContext context) {
//     final loc = GoRouterState.of(context).uri.toString();
//     final i = _routes.indexWhere((r) => loc.startsWith(r));
//     return i < 0 ? 0 : i;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final index = _indexFor(context);
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       drawer: const AppDrawer(),
//       // No outer SafeArea here — the header gradient must paint behind
//       // the status bar. SafeArea is applied INSIDE the header row only.
//       body: Column(
//         children: [
//           UnifiedTopHeader(
//             currentIndex: index,
//             onTap: (i) => context.go(_routes[i]),
//           ),
//           Expanded(child: child),
//         ],
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // HeaderCurveClipper
// // ─────────────────────────────────────────────────────────────────────────────
//
// /// Draws a smooth wave/swoosh bottom edge instead of a plain rounded corner.
// class HeaderCurveClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     path.lineTo(0, size.height - 36);
//     path.quadraticBezierTo(
//       size.width * 0.5,
//       size.height + 18,
//       size.width,
//       size.height - 36,
//     );
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }
//
//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // UnifiedTopHeader
// // ─────────────────────────────────────────────────────────────────────────────
//
// class UnifiedTopHeader extends StatelessWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTap;
//
//   const UnifiedTopHeader({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//   });
//
//   static const _tabs = [
//     (Icons.home_outlined, Icons.home, 'ড্যাশবোর্ড'),
//     (
//       Icons.account_balance_wallet_outlined,
//       Icons.account_balance_wallet,
//       'ওয়ালেট',
//     ),
//     (Icons.person_outline, Icons.person, 'প্রোফাইল'),
//     (Icons.group_outlined, Icons.group, 'নেটওয়ার্ক'),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
//
//     return ClipPath(
//       clipper: HeaderCurveClipper(),
//       child: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         // SafeArea INSIDE, so the gradient still paints behind the status
//         // bar, but the icons/title/pill sit below the notch/status bar.
//         child: SafeArea(
//           bottom: false,
//           child: Padding(
//             padding: const EdgeInsets.only(bottom: 44),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SizedBox(
//                   height: 56,
//                   child: Row(
//                     children: [
//                       IconButton(
//                         onPressed: () => Scaffold.of(context).openDrawer(),
//                         icon: const Icon(
//                           Icons.menu,
//                           color: Colors.white,
//                           size: 26,
//                         ),
//                       ),
//                       Expanded(
//                         child: Center(
//                           child: Text(
//                             AppStrings.dashboardTitle,
//                             style: GoogleFonts.manrope(
//                               fontSize: 20,
//                               fontWeight: FontWeight.w700,
//                               color: Colors.white,
//                               letterSpacing: 1.0,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           IconButton(
//                             onPressed: () {},
//                             icon: const Icon(
//                               Icons.notifications_outlined,
//                               color: Colors.white,
//                               size: 26,
//                             ),
//                           ),
//                           Positioned(
//                             top: 12,
//                             right: 12,
//                             child: Container(
//                               width: 8,
//                               height: 8,
//                               decoration: BoxDecoration(
//                                 color: AppColors.secondary,
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   color: const Color(0xFF42A5F5),
//                                   width: 1,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(width: 8),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: _PillTabBar(
//                     currentIndex: currentIndex,
//                     tabs: _tabs,
//                     onTap: onTap,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// /// One continuous rounded-bottom gradient card that contains:
// ///   1. Header row (hamburger → title → notification)
// ///   2. Inset white pill segmented tab bar (4 tabs)
// ///
// /// The pill has horizontal margins so the blue card edge is visible on both
// /// sides — matching the reference layout.
// // class UnifiedTopHeader extends StatelessWidget {
// //   final int currentIndex;
// //   final ValueChanged<int> onTap;
// //
// //   const UnifiedTopHeader({
// //     super.key,
// //     required this.currentIndex,
// //     required this.onTap,
// //   });
// //
// //   // Tab definitions (icon pair + Bangla label)
// //   static const _tabs = [
// //     (Icons.home_outlined, Icons.home, 'ড্যাশবোর্ড'),
// //     (Icons.person_outline, Icons.person, 'প্রোফাইল'),
// //     (
// //       Icons.account_balance_wallet_outlined,
// //       Icons.account_balance_wallet,
// //       'ওয়ালেট',
// //     ),
// //     (Icons.group_outlined, Icons.group, 'নেটওয়ার্ক'),
// //   ];
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     // Keep status-bar icons white (SafeArea in AppShell handles the inset).
// //     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
// //
// //     // ClipPath draws the smooth arch at the bottom instead of a plain
// //     // BorderRadius — matches the ModyChat-style continuous curved edge.
// //     return ClipPath(
// //       clipper: _HeaderCurveClipper(),
// //       child: Container(
// //         decoration: const BoxDecoration(
// //           gradient: LinearGradient(
// //             colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
// //             begin: Alignment.topLeft,
// //             end: Alignment.bottomRight,
// //           ),
// //         ),
// //         // No inner SafeArea — outer SafeArea in AppShell handles the inset.
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             // ── Header row ───────────────────────────────────────────────
// //             SizedBox(
// //               height: 56,
// //               child: Row(
// //                 children: [
// //                   // Hamburger — opens Scaffold drawer
// //                   IconButton(
// //                     onPressed: () => Scaffold.of(context).openDrawer(),
// //                     icon: const Icon(
// //                       Icons.menu,
// //                       color: Colors.white,
// //                       size: 26,
// //                     ),
// //                   ),
// //
// //                   // Title
// //                   Expanded(
// //                     child: Center(
// //                       child: Text(
// //                         AppStrings.dashboardTitle,
// //                         style: GoogleFonts.manrope(
// //                           fontSize: 20,
// //                           fontWeight: FontWeight.w700,
// //                           color: Colors.white,
// //                           letterSpacing: 1.0,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //
// //                   // Notification icon with dot
// //                   Stack(
// //                     alignment: Alignment.center,
// //                     children: [
// //                       IconButton(
// //                         onPressed: () {},
// //                         icon: const Icon(
// //                           Icons.notifications_outlined,
// //                           color: Colors.white,
// //                           size: 26,
// //                         ),
// //                       ),
// //                       Positioned(
// //                         top: 12,
// //                         right: 12,
// //                         child: Container(
// //                           width: 8,
// //                           height: 8,
// //                           decoration: BoxDecoration(
// //                             color: AppColors.secondary,
// //                             shape: BoxShape.circle,
// //                             border: Border.all(
// //                               color: const Color(0xFF42A5F5),
// //                               width: 1,
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(width: 8),
// //                 ],
// //               ),
// //             ),
// //
// //             const SizedBox(height: 10),
// //
// //             // ── Inset white pill tab bar ──────────────────────────────────
// //             // Horizontal margin shows the blue card edge on both sides.
// //             Padding(
// //               padding: const EdgeInsets.symmetric(horizontal: 20),
// //               child: _PillTabBar(
// //                 currentIndex: currentIndex,
// //                 tabs: _tabs,
// //                 onTap: onTap,
// //               ),
// //             ),
// //
// //             // Extra bottom space so the arch curve fits within the container
// //             // height — the clipper uses this room to draw the 52px deep arch.
// //             const SizedBox(height: 52),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // _HeaderCurveClipper
// // ─────────────────────────────────────────────────────────────────────────────
//
// /// Clips the header to have a smooth quadratic Bézier arch at the bottom,
// /// matching the ModyChat-style continuous curved edge.
// ///
// /// The arch dips 52 px below the side anchor points at the center:
// ///   • Sides: size.height - 52  (flat)
// ///   • Center control point: size.width/2, size.height  (deepest point)
// ///
// /// Adjust [_archDepth] to make the arch deeper or shallower.
// // class _HeaderCurveClipper extends CustomClipper<Path> {
// //   static const double _archDepth = 52.0;
// //
// //   @override
// //   Path getClip(Size size) {
// //     final path = Path();
// //
// //     // Top-left → top-right (flat top)
// //     path.moveTo(0, 0);
// //     path.lineTo(size.width, 0);
// //
// //     // Right side down to the right anchor of the arch
// //     path.lineTo(size.width, size.height - _archDepth);
// //
// //     // Smooth quadratic arch: control point at center-bottom pulls the edge
// //     // downward, ending at the left anchor at the same height as the right.
// //     path.quadraticBezierTo(
// //       size.width / 2, size.height,   // control point — center, full depth
// //       0, size.height - _archDepth,   // end — left anchor
// //     );
// //
// //     path.close();
// //     return path;
// //   }
// //
// //   @override
// //   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// // }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // _PillTabBar  (private helper)
// // ─────────────────────────────────────────────────────────────────────────────
// class _HeaderCurveClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//
//     path.lineTo(0, size.height - 55);
//
//     // True S-curve: two control points on OPPOSITE sides of the curve
//     // creates the flowing wave shape (not a symmetric single dip).
//     path.cubicTo(
//       size.width * 0.25, size.height,       // pulls DOWN on the left
//       size.width * 0.75, size.height - 90,  // pulls UP on the right
//       size.width, size.height - 40,
//     );
//
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }
//
//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
// }
// /// White pill container with 4 animated segmented tabs.
// ///
// /// • Selected tab: [AppColors.primary] highlight pill, icon + label in white.
// /// • Unselected tabs: transparent, icon + label in [AppColors.textSecondary].
// class _PillTabBar extends StatelessWidget {
//   final int currentIndex;
//   final List<(IconData, IconData, String)> tabs;
//   final ValueChanged<int> onTap;
//
//   const _PillTabBar({
//     required this.currentIndex,
//     required this.tabs,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: Row(
//         children: List.generate(tabs.length, (i) {
//           final tab = tabs[i];
//           final isSelected = i == currentIndex;
//
//           return Expanded(
//             child: GestureDetector(
//               onTap: () => onTap(i),
//               behavior: HitTestBehavior.opaque,
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 220),
//                 curve: Curves.easeInOut,
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 8,
//                   horizontal: 4,
//                 ),
//                 decoration: BoxDecoration(
//                   color: isSelected ? AppColors.primary : Colors.transparent,
//                   borderRadius: BorderRadius.circular(24),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 200),
//                       child: Icon(
//                         isSelected ? tab.$2 : tab.$1,
//                         key: ValueKey(isSelected),
//                         color: isSelected
//                             ? Colors.white
//                             : AppColors.textSecondary,
//                         size: 20,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       tab.$3,
//                       style: GoogleFonts.hindSiliguri(
//                         fontSize: 10,
//                         fontWeight: isSelected
//                             ? FontWeight.w600
//                             : FontWeight.w500,
//                         color: isSelected
//                             ? Colors.white
//                             : AppColors.textSecondary,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // FloatingTopNavBar  (unused — kept for reference)
// // ─────────────────────────────────────────────────────────────────────────────
//
// /// Previously used as an overlay floating pill on top of HomeAppBar.
// /// Superseded by [UnifiedTopHeader]. Kept for reference only.
// class FloatingTopNavBar extends StatelessWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTap;
//
//   const FloatingTopNavBar({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//   });
//
//   static const _tabs = [
//     (Icons.home_outlined, Icons.home, 'ড্যাশবোর্ড'),
//     (
//       Icons.account_balance_wallet_outlined,
//       Icons.account_balance_wallet,
//       'ওয়ালেট',
//     ),
//     (Icons.person_outline, Icons.person, 'প্রোফাইল'),
//     (Icons.group_outlined, Icons.group, 'নেটওয়ার্ক'),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(30),
//         boxShadow: const [
//           BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 8)),
//         ],
//       ),
//       child: Row(
//         children: List.generate(_tabs.length, (i) {
//           final tab = _tabs[i];
//           final isSelected = i == currentIndex;
//           return Expanded(
//             child: GestureDetector(
//               onTap: () => onTap(i),
//               behavior: HitTestBehavior.opaque,
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 220),
//                 curve: Curves.easeInOut,
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//                 decoration: BoxDecoration(
//                   color: isSelected ? AppColors.primary : Colors.transparent,
//                   borderRadius: BorderRadius.circular(24),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       isSelected ? tab.$2 : tab.$1,
//                       color: isSelected ? Colors.white : AppColors.textSecondary,
//                       size: 22,
//                     ),
//                     if (isSelected) ...[
//                       const SizedBox(height: 2),
//                       Text(
//                         tab.$3,
//                         style: GoogleFonts.hindSiliguri(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // AppBottomNavBar  (unused — kept for reference)
// // ─────────────────────────────────────────────────────────────────────────────
//
// /// Curved bottom nav bar. Superseded by [UnifiedTopHeader].
// /// Kept for future reference — not wired into [AppShell].
// class AppBottomNavBar extends StatefulWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTap;
//
//   const AppBottomNavBar({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//   });
//
//   static const _tabs = [
//     (Icons.home_outlined, Icons.home, 'ড্যাশবোর্ড'),
//     (
//       Icons.account_balance_wallet_outlined,
//       Icons.account_balance_wallet,
//       'ওয়ালেট',
//     ),
//     (Icons.person_outline, Icons.person, 'প্রোফাইল'),
//     (Icons.group_outlined, Icons.group, 'নেটওয়ার্ক'),
//   ];
//
//   @override
//   State<AppBottomNavBar> createState() => _AppBottomNavBarState();
// }
//
// class _AppBottomNavBarState extends State<AppBottomNavBar> {
//   final GlobalKey<CurvedNavigationBarState> _navKey =
//       GlobalKey<CurvedNavigationBarState>();
//
//   @override
//   void didUpdateWidget(AppBottomNavBar oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.currentIndex != widget.currentIndex) {
//       _navKey.currentState?.setPage(widget.currentIndex);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final items = AppBottomNavBar._tabs.asMap().entries.map((entry) {
//       final i = entry.key;
//       final tab = entry.value;
//       final isSelected = i == widget.currentIndex;
//       const unselectedColor = Colors.white70;
//
//       return Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             isSelected ? tab.$2 : tab.$1,
//             color: isSelected ? Colors.white : unselectedColor,
//             size: 24,
//           ),
//           const SizedBox(height: 2),
//           Text(
//             tab.$3,
//             style: GoogleFonts.hindSiliguri(
//               fontSize: 10,
//               fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//               color: isSelected ? Colors.white : unselectedColor,
//             ),
//           ),
//         ],
//       );
//     }).toList();
//
//     return CurvedNavigationBar(
//       key: _navKey,
//       index: widget.currentIndex,
//       items: items,
//       color: AppColors.primary,
//       buttonBackgroundColor: AppColors.primaryDark,
//       backgroundColor: Colors.transparent,
//       animationCurve: Curves.easeInOut,
//       animationDuration: const Duration(milliseconds: 300),
//       height: 62,
//       onTap: widget.onTap,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_earn/core/constants/app_strings.dart';
import 'package:global_earn/shared/widgets/app_drawer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppShell
// ─────────────────────────────────────────────────────────────────────────────

/// Persistent shell.
///
/// The header row + segmented pill tab bar both live inside ONE unified
/// gradient card ([UnifiedTopHeader]). No Positioned/overlap tricks.
///
/// [AppBottomNavBar] and [FloatingTopNavBar] are preserved below but unused.
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const _routes = ['/home', '/wallet', '/profile', '/network'];

  int _indexFor(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final i = _routes.indexWhere((r) => loc.startsWith(r));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final index = _indexFor(context);
    return Scaffold(
      // The gradient container in the Stack now extends behind the curved corners.
      backgroundColor: Colors.transparent,
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // Bottom layer: header fills from top, provides the blue background
          // that the white content overlaps against.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: UnifiedTopHeader(
              currentIndex: index,
              onTap: (i) => context.go(_routes[i]),
            ),
          ),
          // Top layer: white content body with curved top corners that
          // overlap the blue header, creating the nested pocket look.
          Column(
            children: [
              // Spacer that matches the header height minus the overlap amount.
              // The curved white container will sit on top of the bottom
              // portion of the header.
              Builder(
                builder: (context) {
                  final topInset = MediaQuery.of(context).padding.top;
                  // Header height with reduced 10px vertical gap above the pill
                  // + 18px breathing gap before the white container.
                  final overlapTop = topInset + 20 + 10 + 10 + 56 + 40 + 18.0;
                  return SizedBox(height: overlapTop);
                },
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                  ),
                  child: child,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UnifiedTopHeader
// ─────────────────────────────────────────────────────────────────────────────

/// One continuous S-curve gradient card that contains:
///   1. Header row (hamburger → title → notification)
///   2. Inset white pill segmented tab bar (4 tabs)
///
/// The pill has horizontal margins so the blue card edge is visible on both
/// sides — matching the reference layout.
class UnifiedTopHeader extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const UnifiedTopHeader({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _tabs = [
    (Icons.home_outlined, Icons.home, 'ড্যাশবোর্ড'),
    (
      Icons.account_balance_wallet_outlined,
      Icons.account_balance_wallet,
      'ওয়ালেট',
    ),
    (Icons.person_outline, Icons.person, 'প্রোফাইল'),
    (Icons.group_outlined, Icons.group, 'নেটওয়ার্ক'),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final topInset = MediaQuery.of(context).padding.top;
    // Header total height with refined 15px gap above the pill
    // +100 extra height to ensure the gradient extends seamlessly behind the white curved container.
    final totalHeight = topInset + 56 + 15 + 56 + 40 + 100.0;

    return Container(
        height: totalHeight,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                primary: false,
                leading: IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                centerTitle: true,
                title: Text(
                  AppStrings.dashboardTitle,
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                actions: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryDark,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _PillTabBar(
                  currentIndex: currentIndex,
                  tabs: _tabs,
                  onTap: onTap,
                ),
              ),
            ],
          ),
        ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _PillTabBar  (private helper)
// ─────────────────────────────────────────────────────────────────────────────

/// White pill container with 4 animated segmented tabs.
///
/// • Selected tab: [AppColors.primary] highlight pill, icon + label in white.
/// • Unselected tabs: transparent, icon + label in [AppColors.textSecondary].
class _PillTabBar extends StatelessWidget {
  final int currentIndex;
  final List<(IconData, IconData, String)> tabs;
  final ValueChanged<int> onTap;

  const _PillTabBar({
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (i) {
          final tab = tabs[i];
          final isSelected = i == currentIndex;

          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isSelected ? tab.$2 : tab.$1,
                      key: ValueKey(isSelected),
                      color: isSelected ? Colors.white : Colors.white60,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    height: 3,
                    width: isSelected ? 20 : 0,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FloatingTopNavBar  (unused — kept for reference)
// ─────────────────────────────────────────────────────────────────────────────

/// Previously used as an overlay floating pill on top of HomeAppBar.
/// Superseded by [UnifiedTopHeader]. Kept for reference only.
class FloatingTopNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingTopNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _tabs = [
    (Icons.home_outlined, Icons.home, 'ড্যাশবোর্ড'),
    (
      Icons.account_balance_wallet_outlined,
      Icons.account_balance_wallet,
      'ওয়ালেট',
    ),
    (Icons.person_outline, Icons.person, 'প্রোফাইল'),
    (Icons.group_outlined, Icons.group, 'নেটওয়ার্ক'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final tab = _tabs[i];
          final isSelected = i == currentIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                padding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? tab.$2 : tab.$1,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      size: 22,
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 2),
                      Text(
                        tab.$3,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppBottomNavBar  (unused — kept for reference)
// ─────────────────────────────────────────────────────────────────────────────

/// Curved bottom nav bar. Superseded by [UnifiedTopHeader].
/// Kept for future reference — not wired into [AppShell].
class AppBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _tabs = [
    (Icons.home_outlined, Icons.home, 'ড্যাশবোর্ড'),
    (
      Icons.account_balance_wallet_outlined,
      Icons.account_balance_wallet,
      'ওয়ালেট',
    ),
    (Icons.person_outline, Icons.person, 'প্রোফাইল'),
    (Icons.group_outlined, Icons.group, 'নেটওয়ার্ক'),
  ];

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar> {
  final GlobalKey<CurvedNavigationBarState> _navKey =
  GlobalKey<CurvedNavigationBarState>();

  @override
  void didUpdateWidget(AppBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _navKey.currentState?.setPage(widget.currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = AppBottomNavBar._tabs.asMap().entries.map((entry) {
      final i = entry.key;
      final tab = entry.value;
      final isSelected = i == widget.currentIndex;
      const unselectedColor = Colors.white70;

      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? tab.$2 : tab.$1,
            color: isSelected ? Colors.white : unselectedColor,
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            tab.$3,
            style: GoogleFonts.hindSiliguri(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : unselectedColor,
            ),
          ),
        ],
      );
    }).toList();

    return CurvedNavigationBar(
      key: _navKey,
      index: widget.currentIndex,
      items: items,
      color: AppColors.primary,
      buttonBackgroundColor: AppColors.primaryDark,
      backgroundColor: Colors.transparent,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      height: 62,
      onTap: widget.onTap,
    );
  }
}