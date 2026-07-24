import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';

class InstructorEarningsScreen extends StatelessWidget {
  const InstructorEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Earnings', style: AppTypography.headlineMdMobile.copyWith(
              color: AppColors.textOnSurface(brightness), fontWeight: FontWeight.w700,
            )),
            const SizedBox(height: 24),
            // Total earnings
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.cardAll,
                boxShadow: [BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20, offset: const Offset(0, 8),
                )],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Earnings', style: AppTypography.bodySm.copyWith(
                    color: Colors.white70,
                  )),
                  const SizedBox(height: 8),
                  Text('\$45,280', style: AppTypography.displayLgMobile.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700,
                  )),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.arrow_upward_rounded, color: AppColors.brandGreen, size: 16),
                    const SizedBox(width: 4),
                    Text('+18% from last month', style: AppTypography.bodySm.copyWith(
                      color: AppColors.brandGreen,
                    )),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Withdraw button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.account_balance_wallet_rounded, size: 18),
                label: Text('Withdraw Funds', style: AppTypography.headlineSmMobile.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w700,
                )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandOrange,
                  foregroundColor: Colors.white,
                  minimumSize: Size.fromHeight(48),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text('Payment History', style: AppTypography.headlineSm.copyWith(
              color: AppColors.textOnSurface(brightness),
            )),
            const SizedBox(height: 16),
            _PaymentRow(type: 'Course Sale', amount: '+\$49.99', date: 'Today', status: 'Completed'),
            _PaymentRow(type: 'Course Sale', amount: '+\$49.99', date: 'Yesterday', status: 'Completed'),
            _PaymentRow(type: 'Withdrawal', amount: '-\$5,000', date: '5 days ago', status: 'Completed'),
            _PaymentRow(type: 'Course Sale', amount: '+\$129.99', date: '1 week ago', status: 'Completed'),
            _PaymentRow(type: 'Refund', amount: '-\$49.99', date: '2 weeks ago', status: 'Processed'),
          ],
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String type, amount, date, status;
  const _PaymentRow({required this.type, required this.amount, required this.date, required this.status});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isPositive = amount.startsWith('+');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest(brightness),
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border(brightness)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: (isPositive ? AppColors.brandGreen : AppColors.brandRed).withValues(alpha: 0.1),
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(
              isPositive ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isPositive ? AppColors.brandGreen : AppColors.brandRed,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type, style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w500, color: AppColors.textOnSurface(brightness),
                )),
                Text(date, style: AppTypography.bodySm.copyWith(
                  color: AppColors.outline(brightness), fontSize: 12,
                )),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: AppTypography.numericTabular.copyWith(
                fontWeight: FontWeight.w700,
                color: isPositive ? AppColors.brandGreen : AppColors.brandRed,
                fontSize: 15,
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.brandGreen.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: Text(status, style: AppTypography.labelCaps.copyWith(
                  color: AppColors.brandGreen, fontSize: 9,
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
