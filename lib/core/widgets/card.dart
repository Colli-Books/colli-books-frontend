import 'package:flutter/material.dart';

import '../theme/sizes.dart';

class cardInfoText extends StatelessWidget {
  final Container iconContainer;
  final Text titleText;
  final Text valueText;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const cardInfoText({
    super.key,
    required this.iconContainer,
    required this.titleText,
    required this.valueText,
    required this.iconBgColor,
    required this.iconColor,
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
            color: Colors.black,
            blurRadius: 10,
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
