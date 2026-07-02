import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';

Widget buildLocalImage(
  String path, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
}) {
  if (path.startsWith('blob:') ||
      path.startsWith('http://') ||
      path.startsWith('https://')) {
    return Image.network(
      path,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, _, _) => Icon(
        Icons.broken_image_outlined,
        size: (width ?? height ?? 48) * 0.45,
      ),
    );
  }

  return FutureBuilder<Uint8List>(
    future: XFile(path).readAsBytes(),
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return SizedBox(
          width: width,
          height: height,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }

      if (snapshot.hasError || !snapshot.hasData) {
        final iconSize = (width ?? height ?? 48) * 0.45;
        return Icon(Icons.broken_image_outlined, size: iconSize);
      }

      return Image.memory(
        snapshot.data!,
        fit: fit,
        width: width,
        height: height,
      );
    },
  );
}
