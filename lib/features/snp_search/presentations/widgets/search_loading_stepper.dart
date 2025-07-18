import 'dart:async';
import 'package:flutter/material.dart';
import 'package:varsight/core/constants/colors.dart';
import 'package:varsight/features/snp_search/models/search_state.dart';

class SearchLoadingStepper extends StatelessWidget {
  final SearchStep currentStep;
  final DateTime stepStartTime;

  const SearchLoadingStepper({
    super.key,
    required this.currentStep,
    required this.stepStartTime,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Analyzing variant...',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        ...SearchStep.values.map((step) {
          final isCurrentStep = step == currentStep;
          final isPastStep = step.index < currentStep.index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isPastStep
                            ? isDarkMode
                                ? AppColors.primaryDark
                                : AppColors.primaryLight
                            : isCurrentStep
                            ? isDarkMode
                                ? AppColors.primaryDark.withValues(alpha: 0.2)
                                : AppColors.primaryLight.withValues(alpha: 0.2)
                            : const Color.fromARGB(255, 122, 122, 122),
                  ),
                  child:
                      isPastStep
                          ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                          : isCurrentStep
                          ? Center(child: _StepTimer(startTime: stepStartTime))
                          : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.label,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            isCurrentStep ? FontWeight.w600 : FontWeight.normal,
                        color:
                            isCurrentStep
                                ? isDarkMode
                                    ? AppColors.primaryDark
                                    : AppColors.primaryLight
                                : isDarkMode
                                ? Colors.white70
                                : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _StepTimer extends StatefulWidget {
  final DateTime startTime;

  const _StepTimer({required this.startTime});

  @override
  State<_StepTimer> createState() => _StepTimerState();
}

class _StepTimerState extends State<_StepTimer> {
  late Timer _timer;
  late Duration _elapsed;

  @override
  void initState() {
    super.initState();
    _elapsed = DateTime.now().difference(widget.startTime);
    _timer = Timer.periodic(const Duration(milliseconds: 100), _updateElapsed);
  }

  void _updateElapsed(Timer timer) {
    setState(() {
      _elapsed = DateTime.now().difference(widget.startTime);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final seconds = _elapsed.inMilliseconds / 1000.0;
    return Text(
      '${seconds.toStringAsFixed(1)}s',
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }
}
