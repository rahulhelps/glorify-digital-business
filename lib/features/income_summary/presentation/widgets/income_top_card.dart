import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import '../../domain/entities/filter_type.dart';

class IncomeTopCard extends StatelessWidget {
  final FilterType filterType;
  final double amount;
  final DateTimeRange dateRange;

  const IncomeTopCard({
    super.key,
    required this.filterType,
    required this.amount,
    required this.dateRange,
  });

  String get _title => switch (filterType) {
        FilterType.today => 'আজকের দিনের ইনকাম',
        FilterType.yesterday => 'গতকালের ইনকাম',
        FilterType.sevenDays => 'গত ৭ দিনের ইনকাম',
        FilterType.thirtyDays => 'গত ৩০ দিনের ইনকাম',
        FilterType.allTime => 'সর্বমোট ইনকাম',
      };

  String get _dateText {
    final format = DateFormat('dd-MM-yyyy');
    if (filterType == FilterType.today) {
      return format.format(DateTime.now());
    } else if (filterType == FilterType.yesterday) {
      return format.format(DateTime.now().subtract(const Duration(days: 1)));
    }
    return '${format.format(dateRange.start.toLocal())} থেকে ${format.format(dateRange.end.toLocal())}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Stack(
          children: [
            // Layer 1 — full-card colored background icon
            Positioned.fill(
              child: Opacity(
                opacity: 0.20,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.white.withValues(alpha: 0.9),
                    BlendMode.modulate,
                  ),
                  child: Transform.scale(
                    scale: 2.2,
                    alignment: Alignment.centerRight,
                    child: Image.asset(
                      'assets/images/wallet_card.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            // Layer 2 — original content
            Padding(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _title,
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '৳ ${amount.toStringAsFixed(2)}',
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _dateText,
                    style: GoogleFonts.manrope(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
