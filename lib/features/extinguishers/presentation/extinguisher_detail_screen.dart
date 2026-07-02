import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
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
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
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
                          style: TextStyle(
                            color: extinguisher.status.color,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(extinguisher.type, style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 24),
                    const SectionLabel('Bilgiler'),
                    const SizedBox(height: 12),
                    Container(
                      decoration: AppDecorations.panel(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: 'Tüpü yeniledim',
                      color: AppColors.renewGreen,
                      icon: Icons.check,
                      onPressed: () => context.showSnackBar('Yenileme kaydı oluşturuldu'),
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Düzenle',
                      outlined: true,
                      onPressed: () => context.push('/extinguishers/${extinguisher.id}/edit'),
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

}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
