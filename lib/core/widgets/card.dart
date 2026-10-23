import 'package:flutter/material.dart';

import '../theme/sizes.dart';
import 'icon.dart';
import 'text.dart';

class SummaryCard extends StatelessWidget {
  final SummaryCardIcon iconContainer;
  final TitleText titleText;
  final SummaryValueText valueText;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.iconContainer,
    required this.titleText,
    required this.valueText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.spacingMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: AppSizes.radiusXMd,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.spacingMd),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    iconContainer,
                    const SizedBox(width: AppSizes.spacingMd),
                    titleText,
                  ],
                ),
                const SizedBox(height: AppSizes.spacingMd),
                valueText,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  final ActionCardIcon iconContainer;
  final TitleText titleText;
  final ActionCardDescriptionText descriptionText;
  final VoidCallback? onTap;

  const ActionCard({
    super.key,
    required this.iconContainer,
    required this.titleText,
    required this.descriptionText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: AppSizes.radiusXMd,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingLg,
              vertical: AppSizes.spacingXl,
            ),
            child: Column(
              children: [
                iconContainer,
                const SizedBox(height: AppSizes.spacingLg),
                titleText,
                const SizedBox(height: AppSizes.spacingXMd),
                descriptionText,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
