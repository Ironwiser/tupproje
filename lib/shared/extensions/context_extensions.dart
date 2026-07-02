import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateFormatting on DateTime {
  String get formatted => DateFormat('dd.MM.yyyy').format(this);
}

extension BuildContextExtensions on BuildContext {
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
