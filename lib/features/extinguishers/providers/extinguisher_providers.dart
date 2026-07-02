import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_bootstrap.dart';
import '../../auth/domain/user_type.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/providers/user_state_providers.dart';
import '../data/extinguisher_repository.dart';
import '../domain/extinguisher_status.dart';
import '../domain/fire_extinguisher.dart';

export '../../auth/providers/auth_providers.dart';
export '../../auth/providers/user_state_providers.dart';

class ExtinguisherNotifier extends StateNotifier<List<FireExtinguisher>> {
  ExtinguisherNotifier(this._ref) : super([]) {
    if (!isSupabaseReady) {
      state = _mockData;
    }
  }

  final Ref _ref;
  Future<void>? _loadFuture;

  static final _mockData = [
    FireExtinguisher(
      id: '1',
      name: 'Mutfak Tüpü',
      type: 'ABC Kuru Kimyevi',
      brand: 'Yangın Güvenlik',
      purchaseDate: DateTime(2022, 3, 15),
      expiryDate: DateTime.now().add(const Duration(days: 120)),
      location: 'Mutfak',
      serialNumber: 'YG-2022-00451',
      notes: 'Mutfak girişinin sağında',
    ),
    FireExtinguisher(
      id: '2',
      name: 'Salon Tüpü',
      type: 'ABC Kuru Kimyevi',
      brand: 'Güven Yangın',
      purchaseDate: DateTime(2021, 6, 1),
      expiryDate: DateTime.now().add(const Duration(days: 280)),
      location: 'Salon',
      serialNumber: 'GY-2021-00234',
    ),
    FireExtinguisher(
      id: '3',
      name: 'Depo Tüpü',
      type: 'CO2',
      brand: 'ProSafe',
      purchaseDate: DateTime(2020, 3, 10),
      expiryDate: DateTime.now().subtract(const Duration(days: 5)),
      location: 'Depo',
      serialNumber: 'PS-2020-00891',
      companyId: 'corp-1',
    ),
    FireExtinguisher(
      id: '4',
      name: 'Mutfak - Kat 2',
      type: 'ABC Kuru Kimyevi',
      brand: 'Yangın Güvenlik',
      purchaseDate: DateTime(2023, 8, 20),
      expiryDate: DateTime.now().add(const Duration(days: 45)),
      location: 'Mutfak - Kat 2',
      serialNumber: 'YG-2023-01102',
      companyId: 'corp-1',
    ),
    FireExtinguisher(
      id: '5',
      name: 'Üretim Alanı',
      type: 'Köpük',
      brand: 'Endüstri Yangın',
      purchaseDate: DateTime(2022, 11, 5),
      expiryDate: DateTime.now().add(const Duration(days: 90)),
      location: 'Üretim',
      serialNumber: 'EY-2022-00776',
      companyId: 'corp-1',
    ),
    FireExtinguisher(
      id: '6',
      name: 'Ofis Giriş',
      type: 'ABC Kuru Kimyevi',
      brand: 'Güven Yangın',
      purchaseDate: DateTime(2023, 1, 10),
      expiryDate: DateTime.now().add(const Duration(days: 200)),
      location: 'Ofis Giriş',
      serialNumber: 'GY-2023-00321',
      companyId: 'corp-1',
    ),
  ];

  Future<void> _load() async {
    if (!isSupabaseReady) {
      state = _mockData;
      return;
    }

    final auth = _ref.read(authRepositoryProvider);
    if (auth.currentUser == null) {
      state = [];
      return;
    }

    try {
      final profile = _ref.read(cachedProfileProvider) ?? await auth.fetchProfile();
      if (profile == null) {
        state = [];
        return;
      }

      final repo = _ref.read(extinguisherRepositoryProvider);
      final companyId = profile.userType == UserType.corporate ? profile.companyId : null;
      state = await repo.fetchAll(companyId: companyId);
    } catch (_) {
      state = [];
    }
  }

  Future<void> ensureLoaded() {
    _loadFuture ??= _load().whenComplete(() => _loadFuture = null);
    return _loadFuture!;
  }

  Future<void> refresh() {
    _loadFuture = null;
    return ensureLoaded();
  }

  void reset() {
    _loadFuture = null;
    state = isSupabaseReady ? [] : _mockData;
  }

  Future<void> add(
    FireExtinguisher extinguisher, {
    String? localPhotoPath,
    Uint8List? photoBytes,
  }) async {
    if (!isSupabaseReady || _ref.read(authRepositoryProvider).currentUser == null) {
      state = [...state, extinguisher.copyWith(photoPath: null)];
      return;
    }

    final user = _ref.read(authRepositoryProvider).currentUser!;
    final profile = _ref.read(cachedProfileProvider);
    final withCompany = extinguisher.copyWith(
      companyId: profile?.userType == UserType.corporate ? profile?.companyId : null,
    );

    final created = await _ref.read(extinguisherRepositoryProvider).create(
          extinguisher: withCompany,
          localPhotoPath: localPhotoPath,
          photoBytes: photoBytes,
          userId: user.id,
        );
    state = [created, ...state];
  }

  Future<void> update(
    FireExtinguisher extinguisher, {
    String? localPhotoPath,
    Uint8List? photoBytes,
  }) async {
    if (!isSupabaseReady || _ref.read(authRepositoryProvider).currentUser == null) {
      state = [
        for (final item in state)
          if (item.id == extinguisher.id) extinguisher else item,
      ];
      return;
    }

    final user = _ref.read(authRepositoryProvider).currentUser!;
    final updated = await _ref.read(extinguisherRepositoryProvider).update(
          extinguisher: extinguisher,
          localPhotoPath: localPhotoPath,
          photoBytes: photoBytes,
          userId: user.id,
        );
    state = [
      for (final item in state)
        if (item.id == updated.id) updated else item,
    ];
  }

  Future<void> delete(String id) async {
    if (isSupabaseReady && _ref.read(authRepositoryProvider).currentUser != null) {
      await _ref.read(extinguisherRepositoryProvider).delete(id);
    }
    state = state.where((item) => item.id != id).toList();
  }

  FireExtinguisher? findById(String id) {
    try {
      return state.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}

final extinguisherProvider =
    StateNotifierProvider<ExtinguisherNotifier, List<FireExtinguisher>>(
  ExtinguisherNotifier.new,
);

final extinguisherByIdProvider = Provider.family<FireExtinguisher?, String>(
  (ref, id) => ref.watch(extinguisherProvider.notifier).findById(id),
);

enum ExtinguisherFilter { all, ok, approaching, expired }

final extinguisherFilterProvider =
    StateProvider<ExtinguisherFilter>((ref) => ExtinguisherFilter.all);

final locationFilterProvider = StateProvider<String?>((ref) => null);

final filteredExtinguishersProvider = Provider<List<FireExtinguisher>>((ref) {
  final items = ref.watch(extinguisherProvider);
  final filter = ref.watch(extinguisherFilterProvider);
  final locationFilter = ref.watch(locationFilterProvider);
  final userType = ref.watch(userTypeProvider);

  var filtered = userType == UserType.corporate
      ? items.where((e) => e.companyId != null).toList()
      : items.where((e) => e.companyId == null).toList();

  if (locationFilter != null) {
    filtered = filtered.where((e) => e.location == locationFilter).toList();
  }

  return switch (filter) {
    ExtinguisherFilter.all => filtered,
    ExtinguisherFilter.ok =>
      filtered.where((e) => e.status == ExtinguisherStatus.ok).toList(),
    ExtinguisherFilter.approaching =>
      filtered.where((e) => e.status == ExtinguisherStatus.approaching).toList(),
    ExtinguisherFilter.expired =>
      filtered.where((e) => e.status == ExtinguisherStatus.expired).toList(),
  };
});

final corporateLocationsProvider = Provider<List<String>>((ref) {
  final items = ref.watch(extinguisherProvider).where((e) => e.companyId != null);
  return items.map((e) => e.location).toSet().toList()..sort();
});
