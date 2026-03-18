import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';

/// Horizontal 1-2-3-4 step indicator used across the store setup flow.
class StepIndicator extends StatelessWidget {
  final int currentStep; // 1-based

  const StepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (i) {
        final step = i + 1;
        final isActive = step == currentStep;
        final isDone = step < currentStep;
        return Expanded(
          child: Row(
            children: [
              if (i > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isDone ? AppColors.primary : const Color(0xFFE0E0E0),
                  ),
                ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isActive || isDone
                      ? AppColors.primary
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive || isDone
                        ? AppColors.primary
                        : const Color(0xFFE0E0E0),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$step',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isActive || isDone
                        ? Colors.white
                        : const Color(0xFFBDBDBD),
                  ),
                ),
              ),
              if (i < 3 && i == 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: step < currentStep
                        ? AppColors.primary
                        : const Color(0xFFE0E0E0),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
