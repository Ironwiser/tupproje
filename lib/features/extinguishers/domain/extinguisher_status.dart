import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum ExtinguisherStatus {
  ok('Uygun', AppColors.statusOk),
  approaching('Yaklaşıyor', AppColors.statusWarning),
  expired('Süresi Dolmuş', AppColors.statusExpired);

  const ExtinguisherStatus(this.label, this.color);
  final String label;
  final Color color;

  static ExtinguisherStatus fromExpiryDate(DateTime expiryDate) {
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    if (daysLeft < 0) return ExtinguisherStatus.expired;
    if (daysLeft <= 150) return ExtinguisherStatus.approaching;
    return ExtinguisherStatus.ok;
  }
}
