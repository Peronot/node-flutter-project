import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class MiniChart extends StatelessWidget {
  final List<int> values; // length 7 (Mon-Sun)
  final List<String> labels;
  final int maxValue;

  const MiniChart({
    super.key,
    required this.values,
    required this.labels,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final max = maxValue == 0 ? 1 : maxValue;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(values.length, (i) {
        final h = (values[i] / max) * 120;
        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                labels[i],
                style: const TextStyle(fontSize: 11, color: AppColors.textLight),
              )
            ],
          ),
        );
      }),
    );
  }
}
