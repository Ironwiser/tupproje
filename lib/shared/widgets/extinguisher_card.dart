import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/extinguishers/domain/fire_extinguisher.dart';
import 'app_layout.dart';
import 'common_widgets.dart';

class ExtinguisherCard extends StatelessWidget {
  const ExtinguisherCard({
    super.key,
    required this.extinguisher,
    required this.onTap,
    this.compact = false,
    this.isLast = false,
  });

  final FireExtinguisher extinguisher;
  final VoidCallback onTap;
  final bool compact;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    if (compact) return _CorporateRow(extinguisher: extinguisher, onTap: onTap, isLast: isLast);
    return _TimelineCard(extinguisher: extinguisher, onTap: onTap, isLast: isLast);
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.extinguisher,
    required this.onTap,
    required this.isLast,
  });

  final FireExtinguisher extinguisher;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final days = extinguisher.daysUntilExpiry;
    final daysLabel = days < 0
        ? '${days.abs()} gün önce doldu'
        : days == 0
            ? 'Bugün doluyor'
            : '$days gün kaldı';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TimelineDot(color: extinguisher.status.color, isLast: isLast),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10),
                  decoration: AppDecorations.insetPanel(color: AppColors.surface),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ExtinguisherThumbnail(
                            photoPath: extinguisher.photoPath,
                            photoUrl: extinguisher.photoUrl,
                            photoStoragePath: extinguisher.photoStoragePath,
                            size: 40,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  extinguisher.name,
                                  style: textTheme.titleMedium?.copyWith(fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${extinguisher.location} · $daysLabel',
                                  style: textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(status: extinguisher.status, compact: true),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ExtinguisherTimeBar(
                        progress: extinguisher.remainingRatio,
                        color: extinguisher.status.color,
                        height: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CorporateRow extends StatelessWidget {
  const _CorporateRow({
    required this.extinguisher,
    required this.onTap,
    required this.isLast,
  });

  final FireExtinguisher extinguisher;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TimelineDot(color: extinguisher.status.color, isLast: isLast),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10),
                  decoration: AppDecorations.insetPanel(color: AppColors.surface),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ExtinguisherThumbnail(
                            photoPath: extinguisher.photoPath,
                            photoUrl: extinguisher.photoUrl,
                            photoStoragePath: extinguisher.photoStoragePath,
                            size: 40,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  extinguisher.name,
                                  style: textTheme.titleMedium?.copyWith(fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${extinguisher.location} · ${extinguisher.type}',
                                  style: textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(status: extinguisher.status, compact: true),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ExtinguisherTimeBar(
                        progress: extinguisher.remainingRatio,
                        color: extinguisher.status.color,
                        height: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExtinguisherMiniCard extends StatelessWidget {
  const ExtinguisherMiniCard({
    super.key,
    required this.extinguisher,
    required this.onTap,
    this.stacked = false,
  });

  final FireExtinguisher extinguisher;
  final VoidCallback onTap;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
        child: Ink(
          decoration: AppDecorations.panel(
            color: stacked ? AppColors.surface : null,
          ),
          child: Padding(
            padding: stacked
                ? const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10)
                : const EdgeInsets.all(AppSpacing.sm),
            child: stacked ? _buildStackedContent(context) : _buildCompactContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildStackedContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final days = extinguisher.daysUntilExpiry;
    final daysLabel = days < 0
        ? '${days.abs()} gün önce doldu'
        : days == 0
            ? 'Bugün doluyor'
            : '$days gün kaldı';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ExtinguisherThumbnail(
              photoPath: extinguisher.photoPath,
              photoUrl: extinguisher.photoUrl,
              photoStoragePath: extinguisher.photoStoragePath,
              size: 64,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    extinguisher.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    extinguisher.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    daysLabel,
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: extinguisher.status.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 18),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ExtinguisherTimeBar(
          progress: extinguisher.remainingRatio,
          color: extinguisher.status.color,
        ),
      ],
    );
  }

  Widget _buildCompactContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 160,
      height: 110,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExtinguisherThumbnail(
            photoPath: extinguisher.photoPath,
            photoUrl: extinguisher.photoUrl,
            photoStoragePath: extinguisher.photoStoragePath,
            size: 44,
          ),
          const Spacer(),
          Text(
            extinguisher.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium?.copyWith(fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '${extinguisher.daysUntilExpiry} gün',
            style: textTheme.bodySmall?.copyWith(
              color: extinguisher.status.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
