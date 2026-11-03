import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/sizes.dart';

class SocialIcon extends StatelessWidget {
  final FaIconData icon;
  final Color color;
  final VoidCallback onTap;

  const SocialIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: FaIcon(icon, color: color, size: AppSizes.spacingLg),
    );
  }
}

class SummaryCardIcon extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const SummaryCardIcon({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconBgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd)
      ),
      child: Icon(icon, color: iconColor, size: 20)
    );
  }

}

class ActionCardIcon extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const ActionCardIcon({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 32),
    );
  }

}