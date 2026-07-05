import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_layout.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../providers/extinguisher_providers.dart';

class ExtinguisherDetailScreen extends ConsumerWidget {
  const ExtinguisherDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extinguisher = ref.watch(extinguisherByIdProvider(id));

    if (extinguisher == null) {
      return RedHeaderScaffold(
        headerBackgroundAsset: AppAssets.dashboardHeaderBg,
        header: ThemedPageHeader(
          title: 'Tüp detayı',
          onBack: () => context.pop(),
        ),
        body: Container(
          color: AppColors.surfaceMuted,
          child: const Center(child: Text('Tüp bulunamadı')),
        ),
      );
    }

    final daysLabel = extinguisher.daysUntilExpiry < 0
        ? '${extinguisher.daysUntilExpiry.abs()} gün önce doldu'
        : '${extinguisher.daysUntilExpiry} gün kaldı';

    return RedHeaderScaffold(
      headerBackgroundAsset: AppAssets.dashboardHeaderBg,
      header: SizedBox(
        height: AppDecorations.pageHeaderContentHeight,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
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
                  Expanded(
                    child: Text(
                      extinguisher.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headerTitle().copyWith(fontSize: 20, height: 1.15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  ExtinguisherThumbnail(
                    photoPath: extinguisher.photoPath,
                    photoUrl: extinguisher.photoUrl,
                    photoStoragePath: extinguisher.photoStoragePath,
                    size: 56,
                  ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        extinguisher.type,
                        style: AppTypography.headerSubtitle().copyWith(fontSize: 12, height: 1.25),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        daysLabel,
                        style: AppTypography.headerTitle().copyWith(
                          fontSize: 14,
                          color: extinguisher.status.color,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: extinguisher.status, compact: true),
              ],
            ),
          ],
          ),
        ),
      ),
      body: Container(
        color: AppColors.surfaceMuted,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.lg),
          children: [
            const SectionLabel('Bilgiler'),
            const SizedBox(height: AppSpacing.xs),
            Container(
              decoration: AppDecorations.panel(color: AppColors.surface),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
              child: Column(
                children: [
                  _InfoRow('Alım', extinguisher.purchaseDate.formatted),
                  _divider(),
                  _InfoRow('Son kullanma', extinguisher.expiryDate.formatted),
                  _divider(),
                  _InfoRow('Konum', extinguisher.location),
                  _divider(),
                  _InfoRow('Marka', extinguisher.brand),
                  _divider(),
                  _InfoRow('Seri no', extinguisher.serialNumber ?? '—'),
                  if (extinguisher.notes != null && extinguisher.notes!.isNotEmpty) ...[
                    _divider(),
                    _InfoRow('Not', extinguisher.notes!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Tüpü yeniledim',
              color: AppColors.renewGreen,
              icon: Icons.check,
              onPressed: () => context.showSnackBar('Yenileme kaydı oluşturuldu'),
            ),
            const SizedBox(height: AppSpacing.xs),
            PrimaryButton(
              label: 'Düzenle',
              outlined: true,
              onPressed: () => context.push('/extinguishers/${extinguisher.id}/edit'),
            ),
            const SizedBox(height: AppSpacing.xs),
            PrimaryButton(
              label: 'Tüpü sil',
              outlined: true,
              color: AppColors.primary,
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, color: AppColors.border);

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüpü sil'),
        content: const Text('Bu tüp kalıcı olarak silinecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sil', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(extinguisherProvider.notifier).delete(id);
      if (!context.mounted) return;
      context.showSnackBar('Tüp silindi');
      context.pop();
    } catch (e) {
      if (context.mounted) {
        context.showSnackBar('Silinemedi: $e');
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
