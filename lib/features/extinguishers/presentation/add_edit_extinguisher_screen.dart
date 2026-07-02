import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../domain/fire_extinguisher.dart';
import '../providers/extinguisher_providers.dart';

class AddEditExtinguisherScreen extends ConsumerStatefulWidget {
  const AddEditExtinguisherScreen({super.key, this.id});

  final String? id;

  @override
  ConsumerState<AddEditExtinguisherScreen> createState() =>
      _AddEditExtinguisherScreenState();
}

class _AddEditExtinguisherScreenState extends ConsumerState<AddEditExtinguisherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _serialController = TextEditingController();
  final _notesController = TextEditingController();

  String _type = 'ABC Kuru Kimyevi';
  String _location = 'Mutfak';
  DateTime _purchaseDate = DateTime.now().subtract(const Duration(days: 365));
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 365));
  String? _photoPath;
  String? _existingPhotoUrl;
  Uint8List? _photoBytes;
  bool _isSaving = false;

  static const _types = ['ABC Kuru Kimyevi', 'CO2', 'Köpük', 'Su Bazlı'];
  static const _locations = ['Mutfak', 'Salon', 'Depo', 'Ofis - Kat 2', 'Üretim', 'Ofis Giriş'];

  bool get _isEditing => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    }
  }

  void _loadExisting() {
    final item = ref.read(extinguisherProvider.notifier).findById(widget.id!);
    if (item == null || !mounted) return;
    setState(() {
      _nameController.text = item.name;
      _brandController.text = item.brand;
      _serialController.text = item.serialNumber ?? '';
      _notesController.text = item.notes ?? '';
      _type = item.type;
      _location = item.location;
      _purchaseDate = item.purchaseDate;
      _expiryDate = item.expiryDate;
      _photoPath = item.photoPath;
      _existingPhotoUrl = item.photoUrl;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _serialController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 82,
    );
    if (file != null) {
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _photoPath = file.path;
        _photoBytes = bytes;
        _existingPhotoUrl = null;
      });
    }
  }

  Future<void> _pickDate(bool isPurchase) async {
    final initial = isPurchase ? _purchaseDate : _expiryDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isPurchase) {
          _purchaseDate = picked;
        } else {
          _expiryDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    FocusManager.instance.primaryFocus?.unfocus();
    await Future<void>.delayed(const Duration(milliseconds: 80));

    if (!mounted) return;
    setState(() => _isSaving = true);

    try {
      final extinguisher = FireExtinguisher(
        id: _isEditing ? widget.id! : const Uuid().v4(),
        name: _nameController.text.trim(),
        type: _type,
        brand: _brandController.text.trim(),
        purchaseDate: _purchaseDate,
        expiryDate: _expiryDate,
        location: _location,
        serialNumber: _serialController.text.trim().isEmpty ? null : _serialController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        companyId: null,
      );

      final notifier = ref.read(extinguisherProvider.notifier);
      final hasNewPhoto = _photoBytes != null;
      final localPhoto = hasNewPhoto
          ? _photoPath
          : (_photoPath != null &&
                  !_photoPath!.startsWith('http://') &&
                  !_photoPath!.startsWith('https://') &&
                  !_photoPath!.startsWith('blob:')
              ? _photoPath
              : null);

      if (_isEditing) {
        await notifier.update(
          extinguisher,
          localPhotoPath: localPhoto,
          photoBytes: _photoBytes,
        );
      } else {
        await notifier.add(
          extinguisher,
          localPhotoPath: localPhoto,
          photoBytes: _photoBytes,
        );
      }

      if (!mounted) return;
      context.showSnackBar(_isEditing ? 'Tüp güncellendi' : 'Tüp eklendi');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Kaydedilemedi: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(_isEditing ? 'Tüpü düzenle' : 'Yeni tüp'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.xs, AppSpacing.page, AppSpacing.lg),
          children: [
            DashedPhotoPicker(
              photoPath: _photoPath,
              photoUrl: _existingPhotoUrl,
              previewBytes: _photoBytes,
              onTap: _pickImage,
            ),
            const SizedBox(height: 24),
            FormSection(
              title: 'Temel bilgiler',
              child: Column(
                children: [
                  _field('Tüp adı', TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: 'Örn: Mutfak tüpü'),
                    validator: (v) => v == null || v.isEmpty ? 'Zorunlu' : null,
                  )),
                  const SizedBox(height: 14),
                  _field('Marka', TextFormField(
                    controller: _brandController,
                    decoration: const InputDecoration(hintText: 'Marka'),
                    validator: (v) => v == null || v.isEmpty ? 'Zorunlu' : null,
                  )),
                  const SizedBox(height: 14),
                  _field('Tür', DropdownButtonFormField<String>(
                    initialValue: _type,
                    decoration: const InputDecoration(),
                    items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setState(() => _type = v!),
                  )),
                  const SizedBox(height: 14),
                  _field('Konum', DropdownButtonFormField<String>(
                    initialValue: _location,
                    decoration: const InputDecoration(),
                    items: _locations.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                    onChanged: (v) => setState(() => _location = v!),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FormSection(
              title: 'Tarihler',
              child: Column(
                children: [
                  _field('Alım tarihi', _DateField(date: _purchaseDate, onTap: () => _pickDate(true))),
                  const SizedBox(height: 14),
                  _field('Son kullanma', _DateField(date: _expiryDate, onTap: () => _pickDate(false))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FormSection(
              title: 'Ek bilgi',
              child: Column(
                children: [
                  _field('Seri no', TextFormField(
                    controller: _serialController,
                    decoration: const InputDecoration(hintText: 'Opsiyonel'),
                  )),
                  const SizedBox(height: 14),
                  _field('Notlar', TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: 'Opsiyonel'),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Kaydet',
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: AppDecorations.insetPanel(color: AppColors.inputFill),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.calendar_month_outlined, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
