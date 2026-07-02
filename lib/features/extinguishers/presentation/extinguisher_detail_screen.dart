import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_spacing.dart';
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
      return Scaffold(
        appBar: AppBar(title: const Text('Tüp detayı')),
        body: const Center(child: Text('Tüp bulunamadı')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                extinguisher.name,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: AppColors.primary),
                  Center(
                    child: ExtinguisherThumbnail(
                      photoPath: extinguisher.photoPath,
                      photoUrl: extinguisher.photoUrl,
                      photoStoragePath: extinguisher.photoStoragePath,
                      size: 120,
                      square: false,
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.primary.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: AppDecorations.contentSheet(),
                padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.lg, AppSpacing.page, AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StatusBadge(status: extinguisher.status),
                        const Spacer(),
                        Text(
                          extinguisher.daysUntilExpiry < 0
                              ? '${extinguisher.daysUntilExpiry.abs()} gün önce doldu'
                              : '${extinguisher.daysUntilExpiry} gün kaldı',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: extinguisher.status.color,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(extinguisher.type, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.md),
                    const SectionLabel('Bilgiler'),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      decoration: AppDecorations.panel(),
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
            ),
          ),
        ],
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
