import 'package:flutter/material.dart';

import 'local_image_io.dart' if (dart.library.html) 'local_image_web.dart' as platform;

class LocalImage extends StatelessWidget {
  const LocalImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return platform.buildLocalImage(
      path,
      fit: fit,
      width: width,
      height: height,
    );
  }
}
