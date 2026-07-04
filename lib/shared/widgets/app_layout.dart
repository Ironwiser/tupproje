import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// kırmızı üst bant, altta yuvarlatılmış beyaz alan
class RedHeaderScaffold extends StatelessWidget {
  const RedHeaderScaffold({
    super.key,
    required this.header,
    required this.body,
    this.headerHeight = 200,
    this.headerOverlap = AppDecorations.headerOverlap,
    this.headerBackgroundAsset,
    this.headerOverlayColors,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  final Widget header;
  final Widget body;
  final double headerHeight;
  final double headerOverlap;
  final String? headerBackgroundAsset;
  final List<Color>? headerOverlayColors;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight + top,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppDecorations.radiusXl),
              ),
              child: headerBackgroundAsset != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          headerBackgroundAsset!,
                          fit: BoxFit.cover,
                          cacheWidth: 1200,
                          errorBuilder: (_, _, _) => Container(
                            decoration: AppDecorations.redHeader(),
                          ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: headerOverlayColors ??
                                  [
                                    AppColors.primary.withValues(alpha: 0.18),
                                    AppColors.primary.withValues(alpha: 0.42),
                                  ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(decoration: AppDecorations.redHeader()),
            ),
          ),
          Column(
            children: [
              SizedBox(height: top),
              SizedBox(height: headerHeight - headerOverlap, child: ClipRect(child: header)),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: AppDecorations.contentSheet(),
                  child: body,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// kırmızı header içi başlık (geri / aksiyon opsiyonel)
class ThemedPageHeader extends StatelessWidget {
  const ThemedPageHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
    this.subtitle,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.xxs, AppSpacing.page, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              if (onBack != null) ...[
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceMuted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headerTitle().copyWith(fontSize: 20, height: 1.15),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (subtitle != null)
            Padding(
              padding: EdgeInsets.only(left: onBack != null ? 44 : 0, top: 2),
              child: Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.headerSubtitle().copyWith(fontSize: 12, height: 1.25),
              ),
            ),
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.action, this.onAction});

  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(text, style: AppTypography.sectionTitle()),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

class HeaderStatChip extends StatelessWidget {
  const HeaderStatChip({
    super.key,
    required this.value,
    required this.label,
    this.onTap,
    this.valueColor,
  });

  final String value;
  final String label;
  final VoidCallback? onTap;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: AppSpacing.xs),
      decoration: AppDecorations.statChipOnRed(),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.statValue(color: valueColor ?? AppColors.textPrimary).copyWith(
              fontSize: 16,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 10,
              height: 1.15,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );

    return Expanded(
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
                splashColor: AppColors.primary.withValues(alpha: 0.08),
                highlightColor: AppColors.primary.withValues(alpha: 0.04),
                child: content,
              ),
            ),
    );
  }
}

class TimelineDot extends StatelessWidget {
  const TimelineDot({super.key, required this.color, this.isLast = false});

  final Color color;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          if (!isLast)
            Expanded(
              child: Center(
                child: Container(width: 1.5, color: AppColors.border),
              ),
            ),
        ],
      ),
    );
  }
}

class FilterTabBar extends StatelessWidget {
  const FilterTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDecorations.pagePadding),
        itemCount: tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: (selected ? textTheme.labelLarge : textTheme.bodyMedium)!.copyWith(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                    color: selected ? AppColors.textPrimary : AppColors.textTertiary,
                  ),
                  child: Text(tabs[index]),
                ),
                const SizedBox(height: AppSpacing.xs),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  height: 2,
                  width: selected ? 20 : 0,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
