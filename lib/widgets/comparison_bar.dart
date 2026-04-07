import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ComparisonBar extends StatelessWidget {
  final double bodyValue;
  final double outsideValue;
  final String unit;
  final String label;
  final Color color;

  const ComparisonBar({
    super.key,
    required this.bodyValue,
    required this.outsideValue,
    required this.unit,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = [bodyValue, outsideValue].reduce((a, b) => a > b ? a : b);
    final bodyPercent = bodyValue / maxValue;
    final outsidePercent = outsideValue / maxValue;
    final difference = bodyValue - outsideValue;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.cardBackground,
            AppTheme.cardBackground.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label Comparison',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          // Body value row
          _buildBarRow(
            'Body',
            bodyValue,
            unit,
            bodyPercent,
            color,
          ),
          const SizedBox(height: 12),
          // Outside value row
          _buildBarRow(
            'Outside',
            outsideValue,
            unit,
            outsidePercent,
            AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          // Difference
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Difference: ',
                style: const TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 12,
                ),
              ),
              Text(
                '${difference > 0 ? '+' : ''}${difference.toStringAsFixed(1)}$unit',
                style: TextStyle(
                  color: difference > 0 ? color : AppTheme.cyan,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarRow(
    String label,
    double value,
    String unit,
    double percent,
    Color barColor,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 11,
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.cardBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percent.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${value.toStringAsFixed(1)}$unit',
          style: TextStyle(
            color: barColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}