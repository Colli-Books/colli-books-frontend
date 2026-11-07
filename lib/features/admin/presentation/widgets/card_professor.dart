import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/sizes.dart';
import '../../data/models/teacher_model.dart';

class CardProfessor extends StatelessWidget {
  const CardProfessor({
    super.key,
    required this.teacher,
    this.onResendInvite,
    this.onDelete,
    this.resending = false,
    this.deleting = false,
  });

  final TeacherModel teacher;

  /// Só é usado para professores com convite pendente.
  final VoidCallback? onResendInvite;
  final bool resending;
  final VoidCallback? onDelete;
  final bool deleting;

  String get _initials {
    final name = teacher.fullName?.trim() ?? '';
    final source = name.isNotEmpty ? name : teacher.email.trim();
    final parts = source.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (name.isEmpty || parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  ({Color fg, Color bg}) get _badge => switch (teacher.status) {
    TeacherStatus.active => (
    fg: AppColors.activeBadgeText,
    bg: AppColors.activeBadgeText.withValues(alpha: 0.12),
    ),
    TeacherStatus.invitePending => (
    fg: AppColors.pendingBadgeText,
    bg: AppColors.pendingBadgeText.withValues(alpha: 0.12),
    ),
    _ => (fg: Colors.grey.shade700, bg: Colors.grey.shade300),
  };

  @override
  Widget build(BuildContext context) {
    final badge = _badge;
    final showEmail = teacher.displayName != teacher.email;
    final school = teacher.school?.trim() ?? '';
    final isPending = teacher.status == TeacherStatus.invitePending;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingMd),
      padding: const EdgeInsets.all(AppSizes.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  _initials,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (showEmail)
                      Text(
                        teacher.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    if (school.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          school,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                    if (isPending)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Aguardando o professor concluir o cadastro.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.spacingSm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badge.bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  teacher.status.label,
                  style: TextStyle(color: badge.fg, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: AppSizes.spacingSm),
              IconButton(
                key: ValueKey('teacher_delete_${teacher.id}'),
                tooltip: 'Excluir professor',
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.delete_outline, color: AppColors.danger),
                onPressed: deleting ? null : onDelete,
              ),
            ],
          ),
          if (isPending && onResendInvite != null) ...[
            const SizedBox(height: AppSizes.spacingMd),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: ValueKey('teacher_resend_${teacher.id}'),
                onPressed: resending ? null : onResendInvite,
                icon: resending
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Icon(Icons.forward_to_inbox_outlined, size: 18, color: AppColors.textPrimary),
                label: Text(
                  resending ? 'Gerando convite...' : 'Reenviar convite',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}