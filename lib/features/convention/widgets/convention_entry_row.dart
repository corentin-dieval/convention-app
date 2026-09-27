import 'package:flutter/material.dart';
import '../../../core/models/convention_entry.dart';

class ConventionEntryRow extends StatelessWidget {
  final ConventionEntry entry;
  final bool readOnly;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const ConventionEntryRow({
    super.key,
    required this.entry,
    required this.readOnly,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.itemName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '€${entry.priceSnapshot.toStringAsFixed(2)} / unité',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (!readOnly) ...[
              _QtyButton(icon: Icons.remove, onPressed: onDecrease),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '${entry.quantity}',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              _QtyButton(icon: Icons.add, onPressed: onIncrease),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.red,
                onPressed: onRemove,
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('× ${entry.quantity}'),
              ),
            ],
            const SizedBox(width: 4),
            SizedBox(
              width: 70,
              child: Text(
                '€${entry.lineTotal.toStringAsFixed(2)}',
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QtyButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton.filled(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
      ),
    );
  }
}
