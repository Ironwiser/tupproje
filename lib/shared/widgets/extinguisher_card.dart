import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
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
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TimelineDot(color: extinguisher.status.color, isLast: isLast),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: AppDecorations.panel(),
                child: Row(
                  children: [
                    ExtinguisherThumbnail(
                      photoPath: extinguisher.photoPath,
                      photoUrl: extinguisher.photoUrl,
                      size: 56,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            extinguisher.name,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            extinguisher.location,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          StatusBadge(status: extinguisher.status, compact: true),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          extinguisher.daysUntilExpiry < 0
                              ? '${extinguisher.daysUntilExpiry.abs()}g'
                              : '${extinguisher.daysUntilExpiry}g',
                          style: TextStyle(
                            color: extinguisher.status.color,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        const Text('kalan', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
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
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TimelineDot(color: extinguisher.status.color, isLast: isLast),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: AppDecorations.insetPanel(color: AppColors.surface),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            extinguisher.name,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${extinguisher.location} · ${extinguisher.type}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(status: extinguisher.status, compact: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Yatay kaydırmalı özet kartı (dashboard).
class ExtinguisherMiniCard extends StatelessWidget {
  const ExtinguisherMiniCard({super.key, required this.extinguisher, required this.onTap});

  final FireExtinguisher extinguisher;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(14),
        decoration: AppDecorations.panel(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExtinguisherThumbnail(
              photoPath: extinguisher.photoPath,
              photoUrl: extinguisher.photoUrl,
              size: 48,
            ),
            const Spacer(),
            Text(
              extinguisher.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '${extinguisher.daysUntilExpiry} gün',
              style: TextStyle(color: extinguisher.status.color, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
