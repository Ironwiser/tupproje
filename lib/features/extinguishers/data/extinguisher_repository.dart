import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_bootstrap.dart';
import '../domain/fire_extinguisher.dart';

class ExtinguisherRepository {
  static const _photoBucket = 'extinguisher-photos';

  SupabaseClient get _client {
    final client = supabaseClient;
    if (client == null) {
      throw StateError('Supabase yapılandırılmamış');
    }
    return client;
  }

  Future<List<FireExtinguisher>> fetchAll({String? companyId}) async {
    var query = _client.from('fire_extinguishers').select();

    if (companyId != null) {
      query = query.eq('company_id', companyId);
    } else {
      query = query.isFilter('company_id', null);
    }

    final rows = await query.order('created_at', ascending: false);
    return rows.map(_fromRow).toList();
  }

  Future<FireExtinguisher> create({
    required FireExtinguisher extinguisher,
    String? localPhotoPath,
    Uint8List? photoBytes,
    required String userId,
  }) async {
    String? storagePath;
    final hasPhoto = photoBytes != null ||
        (localPhotoPath != null && !_isRemoteUrl(localPhotoPath));

    if (hasPhoto) {
      try {
        storagePath = await _uploadPhoto(
          userId: userId,
          extinguisherId: extinguisher.id,
          bytes: photoBytes,
          localPath: localPhotoPath,
        );
      } catch (_) {
        storagePath = null;
      }
    }

    final row = await _client
        .from('fire_extinguishers')
        .insert(_toRow(extinguisher, userId: userId, photoStoragePath: storagePath))
        .select()
        .single();

    return _fromRow(row);
  }

  Future<FireExtinguisher> update({
    required FireExtinguisher extinguisher,
    String? localPhotoPath,
    Uint8List? photoBytes,
    required String userId,
  }) async {
    final updates = <String, dynamic>{
      'name': extinguisher.name,
      'type': extinguisher.type,
      'brand': extinguisher.brand,
      'purchase_date': _dateOnly(extinguisher.purchaseDate),
      'expiry_date': _dateOnly(extinguisher.expiryDate),
      'location': extinguisher.location,
      'serial_number': extinguisher.serialNumber,
      'notes': extinguisher.notes,
      'company_id': extinguisher.companyId,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final hasPhoto = photoBytes != null ||
        (localPhotoPath != null && !_isRemoteUrl(localPhotoPath));

    if (hasPhoto) {
      updates['photo_url'] = await _uploadPhoto(
        userId: userId,
        extinguisherId: extinguisher.id,
        bytes: photoBytes,
        localPath: localPhotoPath,
      );
    }

    final row = await _client
        .from('fire_extinguishers')
        .update(updates)
        .eq('id', extinguisher.id)
        .select()
        .single();

    return _fromRow(row);
  }

  Future<void> delete(String id) async {
    final row = await _client
        .from('fire_extinguishers')
        .select('photo_url')
        .eq('id', id)
        .maybeSingle();

    final storagePath = _normalizeStoragePath(row?['photo_url'] as String?);
    if (storagePath != null) {
      try {
        await _client.storage.from(_photoBucket).remove([storagePath]);
      } catch (_) {
        // kayıt silinsin, storage hatası engel olmasın
      }
    }

    await _client.from('fire_extinguishers').delete().eq('id', id);
  }

  Future<String> _uploadPhoto({
    required String userId,
    required String extinguisherId,
    Uint8List? bytes,
    String? localPath,
  }) async {
    final path = '$userId/$extinguisherId.jpg';
    final data = bytes ?? await XFile(localPath!).readAsBytes();

    await _client.storage.from(_photoBucket).uploadBinary(
          path,
          data,
          fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
        );

    return path;
  }

  FireExtinguisher _fromRow(Map<String, dynamic> row) {
    final storagePath = _normalizeStoragePath(row['photo_url'] as String?);

    return FireExtinguisher(
      id: row['id'] as String,
      name: row['name'] as String,
      type: row['type'] as String,
      brand: row['brand'] as String,
      purchaseDate: DateTime.parse(row['purchase_date'] as String),
      expiryDate: DateTime.parse(row['expiry_date'] as String),
      location: row['location'] as String,
      serialNumber: row['serial_number'] as String?,
      notes: row['notes'] as String?,
      photoStoragePath: storagePath,
      companyId: row['company_id'] as String?,
    );
  }

  Map<String, dynamic> _toRow(
    FireExtinguisher extinguisher, {
    required String userId,
    String? photoStoragePath,
  }) {
    return {
      'id': extinguisher.id,
      'user_id': userId,
      'company_id': extinguisher.companyId,
      'name': extinguisher.name,
      'type': extinguisher.type,
      'brand': extinguisher.brand,
      'purchase_date': _dateOnly(extinguisher.purchaseDate),
      'expiry_date': _dateOnly(extinguisher.expiryDate),
      'location': extinguisher.location,
      'serial_number': extinguisher.serialNumber,
      'notes': extinguisher.notes,
      'photo_url': ?photoStoragePath,
    };
  }

  String? _normalizeStoragePath(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!_isRemoteUrl(value)) return value;

    const markers = [
      '/object/public/$_photoBucket/',
      '/object/sign/$_photoBucket/',
      '/$_photoBucket/',
    ];

    for (final marker in markers) {
      final index = value.indexOf(marker);
      if (index == -1) continue;
      var path = value.substring(index + marker.length);
      final queryIndex = path.indexOf('?');
      if (queryIndex != -1) {
        path = path.substring(0, queryIndex);
      }
      return path.isEmpty ? null : path;
    }

    return null;
  }

  bool _isRemoteUrl(String value) => value.startsWith('http://') || value.startsWith('https://');

  String _dateOnly(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

final extinguisherRepositoryProvider = Provider<ExtinguisherRepository>((ref) {
  return ExtinguisherRepository();
});
