import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../convention_provider.dart';
import '../../../core/models/convention.dart';

class ConventionsScreen extends StatefulWidget {
  const ConventionsScreen({super.key});

  @override
  State<ConventionsScreen> createState() => _ConventionsScreenState();
}

class _ConventionsScreenState extends State<ConventionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConventionProvider>().loadConventions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<ConventionProvider>();

    if (provider.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
        provider.clearError();
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.conventionsTitle)),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.conventions.isEmpty
              ? Center(child: Text(l10n.noConventions))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: provider.conventions.length,
                  itemBuilder: (ctx, i) {
                    final convention = provider.conventions[i];
                    return _ConventionCard(
                      convention: convention,
                      onTap: () =>
                          context.push('/convention/${convention.id}'),
                      onDelete: () => _confirmDelete(
                          context, convention, l10n),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/convention/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Convention convention,
    AppLocalizations l10n,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConvention),
        content: Text(l10n.deleteItemConfirm(convention.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await context.read<ConventionProvider>().deleteConvention(convention.id!);
    }
  }
}

class _ConventionCard extends StatelessWidget {
  final Convention convention;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ConventionCard({
    required this.convention,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFmt = DateFormat.yMMMd();
    final dateStr = convention.endDate != null
        ? '${dateFmt.format(convention.startDate)} – ${dateFmt.format(convention.endDate!)}'
        : dateFmt.format(convention.startDate);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          convention.isClosed ? Icons.lock_outline : Icons.store,
          color: convention.isClosed ? Colors.grey : Theme.of(context).colorScheme.primary,
        ),
        title: Text(convention.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(dateStr),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(
                convention.isClosed ? l10n.conventionClosed : l10n.conventionOpen,
                style: const TextStyle(fontSize: 11),
              ),
              backgroundColor: convention.isClosed
                  ? Colors.grey.shade200
                  : Colors.green.shade100,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
