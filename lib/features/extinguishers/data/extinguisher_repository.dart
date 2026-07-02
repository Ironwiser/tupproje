import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_bootstrap.dart';
import '../domain/fire_extinguisher.dart';

class ExtinguisherRepository {
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
    required String userId,
  }) async {
    var photoUrl = extinguisher.photoUrl;

    if (localPhotoPath != null) {
      photoUrl = await _uploadPhoto(userId: userId, localPath: localPhotoPath);
    }

    final row = await _client
        .from('fire_extinguishers')
        .insert(_toRow(extinguisher, userId: userId, photoUrl: photoUrl))
        .select()
        .single();

    return _fromRow(row);
  }

  Future<FireExtinguisher> update({
    required FireExtinguisher extinguisher,
    String? localPhotoPath,
    required String userId,
  }) async {
    var photoUrl = extinguisher.photoUrl;

    if (localPhotoPath != null) {
      photoUrl = await _uploadPhoto(
        userId: userId,
        localPath: localPhotoPath,
        extinguisherId: extinguisher.id,
      );
    }

    final row = await _client
        .from('fire_extinguishers')
        .update({
          ..._toRow(extinguisher, userId: userId, photoUrl: photoUrl),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', extinguisher.id)
        .select()
        .single();

    return _fromRow(row);
  }

  Future<void> delete(String id) async {
    await _client.from('fire_extinguishers').delete().eq('id', id);
  }

  Future<String> _uploadPhoto({
    required String userId,
    required String localPath,
    String? extinguisherId,
  }) async {
    final file = File(localPath);
    final id = extinguisherId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final path = '$userId/$id.jpg';

    await _client.storage.from('extinguisher-photos').upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from('extinguisher-photos').getPublicUrl(path);
  }

  FireExtinguisher _fromRow(Map<String, dynamic> row) {
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
      photoUrl: row['photo_url'] as String?,
      companyId: row['company_id'] as String?,
    );
  }

  Map<String, dynamic> _toRow(
    FireExtinguisher extinguisher, {
    required String userId,
    String? photoUrl,
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
      'photo_url': photoUrl ?? extinguisher.photoUrl,
    };
  }

  String _dateOnly(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

final extinguisherRepositoryProvider = Provider<ExtinguisherRepository>((ref) {
  return ExtinguisherRepository();
});
