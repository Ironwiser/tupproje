import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/supabase/supabase_bootstrap.dart';
import '../../core/theme/app_colors.dart';
import 'local_image.dart';

class StorageExtinguisherImage extends StatefulWidget {
  const StorageExtinguisherImage({
    super.key,
    this.storagePath,
    this.signedUrl,
    this.localPath,
    required this.size,
  });

  final String? storagePath;
  final String? signedUrl;
  final String? localPath;
  final double size;

  @override
  State<StorageExtinguisherImage> createState() => _StorageExtinguisherImageState();
}

class _StorageExtinguisherImageState extends State<StorageExtinguisherImage> {
  Uint8List? _bytes;
  bool _loadingStorage = false;
  bool _storageFailed = false;

  @override
  void initState() {
    super.initState();
    _downloadFromStorage();
  }

  @override
  void didUpdateWidget(covariant StorageExtinguisherImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storagePath != widget.storagePath ||
        oldWidget.signedUrl != widget.signedUrl ||
        oldWidget.localPath != widget.localPath) {
      _bytes = null;
      _storageFailed = false;
      _downloadFromStorage();
    }
  }

  Future<void> _downloadFromStorage() async {
    final path = widget.storagePath;
    if (path == null || path.isEmpty || !isSupabaseReady) return;

    setState(() {
      _loadingStorage = true;
      _storageFailed = false;
    });

    try {
      final bytes = await supabaseClient!.storage.from('extinguisher-photos').download(path);
      if (mounted) {
        setState(() => _bytes = bytes);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _storageFailed = true);
      }
    } finally {
      if (mounted) {
        setState(() => _loadingStorage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localPath = widget.localPath;
    if (localPath != null && localPath.isNotEmpty) {
      if (_isRemotePath(localPath)) {
        return Image.network(
          localPath,
          fit: BoxFit.cover,
          width: widget.size,
          height: widget.size,
          errorBuilder: (_, _, _) => _fallbackIcon(),
        );
      }
      return LocalImage(
        path: localPath,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
      );
    }

    if (_bytes != null) {
      return Image.memory(
        _bytes!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
      );
    }

    final signedUrl = widget.signedUrl;
    if (signedUrl != null && signedUrl.isNotEmpty && !_storageFailed) {
      return Image.network(
        signedUrl,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
        errorBuilder: (_, _, _) {
          if (widget.storagePath != null && !_loadingStorage) {
            _downloadFromStorage();
          }
          return _loadingStorage ? _loadingIndicator() : _fallbackIcon();
        },
      );
    }

    if (_loadingStorage) return _loadingIndicator();
    return _fallbackIcon();
  }

  bool _isRemotePath(String path) =>
      path.startsWith('http://') || path.startsWith('https://') || path.startsWith('blob:');

  Widget _loadingIndicator() => Center(
        child: SizedBox(
          width: widget.size * 0.4,
          height: widget.size * 0.4,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      );

  Widget _fallbackIcon() => Icon(
        Icons.local_fire_department,
        color: AppColors.primary,
        size: widget.size * 0.45,
      );
}
