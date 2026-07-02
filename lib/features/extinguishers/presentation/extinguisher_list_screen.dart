import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/domain/user_type.dart';
import '../providers/extinguisher_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/app_layout.dart';
import '../../../shared/widgets/extinguisher_card.dart';

class ExtinguisherListScreen extends ConsumerWidget {
  const ExtinguisherListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(filteredExtinguishersProvider);
    final filter = ref.watch(extinguisherFilterProvider);
    final locationFilter = ref.watch(locationFilterProvider);
    final isCorporate = ref.watch(userTypeProvider) == UserType.corporate;
    final locations = ref.watch(corporateLocationsProvider);

    final filterIndex = ExtinguisherFilter.values.indexOf(filter);
    final tabs = ExtinguisherFilter.values.map(_filterLabel).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isCorporate ? 'Tüp envanteri' : 'Tüplerim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/extinguishers/add'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCorporate) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _FilterDropdown<String?>(
                      value: locationFilter,
                      hint: 'Tüm lokasyonlar',
                      items: [null, ...locations],
                      labelBuilder: (v) => v ?? 'Tüm lokasyonlar',
                      onChanged: (v) => ref.read(locationFilterProvider.notifier).state = v,
                    ),
                  ),
                ],
              ),
            ),
          ],
          FilterTabBar(
            tabs: tabs,
            selectedIndex: filterIndex,
            onSelected: (i) =>
                ref.read(extinguisherFilterProvider.notifier).state = ExtinguisherFilter.values[i],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department_outlined, size: 48, color: AppColors.primary.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        const Text('Henüz tüp eklenmemiş', style: TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.push('/extinguishers/add'),
                          child: const Text('İlk tüpü ekle'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ExtinguisherCard(
                        extinguisher: item,
                        compact: isCorporate,
                        isLast: index == items.length - 1,
                        onTap: () => context.push('/extinguishers/${item.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        mode: isCorporate ? BottomNavMode.corporate : BottomNavMode.individual,
      ),
    );
  }

  String _filterLabel(ExtinguisherFilter filter) => switch (filter) {
        ExtinguisherFilter.all => 'Tümü',
        ExtinguisherFilter.ok => 'Uygun',
        ExtinguisherFilter.approaching => 'Yaklaşan',
        ExtinguisherFilter.expired => 'Dolmuş',
      };
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  final T value;
  final String hint;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: AppDecorations.insetPanel(color: AppColors.surface),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.expand_more, size: 20),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(labelBuilder(e), style: const TextStyle(fontSize: 13))))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
