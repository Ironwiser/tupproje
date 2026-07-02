import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../shared/widgets/common_widgets.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'Premium',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                  ),
                  PremiumBadge(),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: AppDecorations.contentSheet(),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: AppDecorations.bentoTile(accent: AppColors.primary, filled: true),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.phone_in_talk, color: Colors.white, size: 36),
                        SizedBox(height: 12),
                        Text(
                          'Otomatik arama',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Kritik dönemde sizi arayarak uyarır.',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _FeatureItem('Son kullanma tarihine 1 ay kala arama'),
                  const _FeatureItem('Haftada bir otomatik arama'),
                  const _FeatureItem('Kritik dönemde ekstra uyarı'),
                  const _FeatureItem('SMS hatırlatmaları dahil'),
                  const _FeatureItem('Sınırsız tüp ekleme'),
                  const Spacer(),
                  PrimaryButton(
                    label: 'Planları gör',
                    onPressed: () => context.push('/subscription'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.check, color: AppColors.primary, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15, height: 1.35))),
        ],
      ),
    );
  }
}
