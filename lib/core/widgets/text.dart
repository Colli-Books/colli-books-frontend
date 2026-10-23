import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';

class TitleText extends StatelessWidget {
  final String title;

  const TitleText({
    super.key,
    required this.title,
});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: AppSizes.fontTitle,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class SummaryValueText extends StatelessWidget {
  final String value;

  const SummaryValueText({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: AppSizes.fontSummaryValue,
        fontWeight: FontWeight.w800,
        height: 1.0,
      ),
    );
  }
}

class ActionCardDescriptionText extends StatelessWidget {
  final String description;

  const ActionCardDescriptionText({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: AppSizes.fontBody,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
    );
  }
}