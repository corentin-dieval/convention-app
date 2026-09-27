import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/models/item.dart';
import '../../../l10n/app_localizations.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: _ItemThumbnail(imagePath: item.imagePath),
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '€${item.unitPrice.toStringAsFixed(2)}  ·  ${l10n.stockLabel(item.stockQuantity)}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          color: Colors.red,
          tooltip: l10n.deleteItem,
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _ItemThumbnail extends StatelessWidget {
  final String? imagePath;
  const _ItemThumbnail({this.imagePath});

  @override
  Widget build(BuildContext context) {
    if (imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(imagePath!),
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const _Placeholder(),
        ),
      );
    }
    return const _Placeholder();
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.inventory_2_outlined, size: 24),
    );
  }
}
