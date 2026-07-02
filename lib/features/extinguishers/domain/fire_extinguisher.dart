import 'extinguisher_status.dart';

class FireExtinguisher {
  const FireExtinguisher({
    required this.id,
    required this.name,
    required this.type,
    required this.brand,
    required this.purchaseDate,
    required this.expiryDate,
    required this.location,
    this.photoPath,
    this.photoUrl,
    this.photoStoragePath,
    this.serialNumber,
    this.notes,
    this.companyId,
  });

  final String id;
  final String name;
  final String type;
  final String brand;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final String location;
  final String? photoPath;
  final String? photoUrl;
  final String? photoStoragePath;
  final String? serialNumber;
  final String? notes;
  final String? companyId;

  int get daysUntilExpiry => expiryDate.difference(DateTime.now()).inDays;

  ExtinguisherStatus get status => ExtinguisherStatus.fromExpiryDate(expiryDate);

  double get remainingRatio {
    final totalDays = expiryDate.difference(purchaseDate).inDays;
    if (totalDays <= 0) return 0;
    final remaining = daysUntilExpiry.clamp(0, totalDays);
    return remaining / totalDays;
  }

  FireExtinguisher copyWith({
    String? id,
    String? name,
    String? type,
    String? brand,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    String? location,
    String? photoPath,
    String? photoUrl,
    String? photoStoragePath,
    String? serialNumber,
    String? notes,
    String? companyId,
  }) {
    return FireExtinguisher(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      location: location ?? this.location,
      photoPath: photoPath ?? this.photoPath,
      photoUrl: photoUrl ?? this.photoUrl,
      photoStoragePath: photoStoragePath ?? this.photoStoragePath,
      serialNumber: serialNumber ?? this.serialNumber,
      notes: notes ?? this.notes,
      companyId: companyId ?? this.companyId,
    );
  }
}
