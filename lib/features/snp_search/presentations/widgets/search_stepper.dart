import 'package:flutter/material.dart';
import 'package:varsight/core/constants/colors.dart';
import 'package:varsight/core/constants/sizes.dart';

class SearchStepperIndicator extends StatelessWidget {
  const SearchStepperIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StepItem(
          step: 1,
          title: 'Gathering data',
          description: 'Fetching genetic and clinical data...',
          isActive: true,
        ),
        const SizedBox(height: Sizes.spaceBtwItems),
        _StepItem(
          step: 2,
          title: 'Organizing information',
          description: 'Processing SNP associations and studies...',
          isActive: false,
        ),
        const SizedBox(height: Sizes.spaceBtwItems),
        _StepItem(
          step: 3,
          title: 'Generating insights',
          description: 'Creating personalized analysis...',
          isActive: false,
        ),
      ],
    );
  }
}

class _StepItem extends StatefulWidget {
  final int step;
  final String title;
  final String description;
  final bool isActive;

  const _StepItem({
    required this.step,
    required this.title,
    required this.description,
    required this.isActive,
  });

  @override
  State<_StepItem> createState() => _StepItemState();
}

class _StepItemState extends State<_StepItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.isActive ? 1.0 : 0.5,
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      widget.isActive
                          ? AppColors.primaryLight.withValues(
                            alpha: _animation.value,
                          )
                          : Colors.grey[300],
                ),
                child: Center(
                  child: Text(
                    widget.step.toString(),
                    style: TextStyle(
                      color: widget.isActive ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: Sizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color:
                        widget.isActive
                            ? AppColors.primaryLight
                            : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
