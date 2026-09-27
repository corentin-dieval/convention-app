import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/models/item.dart';
import '../refill_provider.dart';

class ItemFormScreen extends StatefulWidget {
  final int? itemId;
  const ItemFormScreen({super.key, this.itemId});

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();

  String? _imagePath;
  bool _saving = false;

  bool get _isNew => widget.itemId == null;

  @override
  void initState() {
    super.initState();
    if (!_isNew) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadItem());
    }
  }

  Future<void> _loadItem() async {
    final provider = context.read<RefillProvider>();
    final item = provider.items.firstWhere(
      (i) => i.id == widget.itemId,
      orElse: () => Item(
        id: widget.itemId,
        name: '',
        description: '',
        unitPrice: 0,
        stockQuantity: 0,
      ),
    );
    setState(() {
      _nameCtrl.text = item.name;
      _descCtrl.text = item.description;
      _priceCtrl.text = item.unitPrice.toString();
      _stockCtrl.text = item.stockQuantity.toString();
      _imagePath = item.imagePath;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final provider = context.read<RefillProvider>();
    final path = await provider.pickImage(source);
    if (path != null) setState(() => _imagePath = path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<RefillProvider>();

    final item = Item(
      id: widget.itemId,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      unitPrice: double.parse(_priceCtrl.text.trim()),
      stockQuantity: int.parse(_stockCtrl.text.trim()),
      imagePath: _imagePath,
    );

    final ok = _isNew
        ? await provider.addItem(item)
        : await provider.updateItem(item);

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? l10n.addItem : l10n.editItem),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ImagePicker(
                imagePath: _imagePath,
                onPickGallery: () => _pickImage(ImageSource.gallery),
                onPickCamera: () => _pickImage(ImageSource.camera),
                onRemove: () => setState(() => _imagePath = null),
                l10n: l10n,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: l10n.itemName),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: InputDecoration(labelText: l10n.itemDescription),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                decoration: InputDecoration(
                  labelText: l10n.itemPrice,
                  prefixText: '€ ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                  final n = double.tryParse(v.trim());
                  if (n == null || n < 0) return l10n.invalidPrice;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockCtrl,
                decoration: InputDecoration(labelText: l10n.itemStock),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 0) return l10n.invalidNumber;
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePicker extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final VoidCallback onRemove;
  final AppLocalizations l10n;

  const _ImagePicker({
    required this.imagePath,
    required this.onPickGallery,
    required this.onPickCamera,
    required this.onRemove,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (imagePath != null)
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(imagePath!),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 80),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
                onPressed: onRemove,
                tooltip: l10n.removeImage,
              ),
            ],
          )
        else
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: Icon(Icons.image, size: 48)),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPickGallery,
                icon: const Icon(Icons.photo_library),
                label: Text(l10n.pickFromGallery),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPickCamera,
                icon: const Icon(Icons.camera_alt),
                label: Text(l10n.pickFromCamera),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
