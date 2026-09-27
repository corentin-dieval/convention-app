import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app.dart';
import '../export_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeNotifier = context.watch<LocaleNotifier>();
    final export = ExportService();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          // ── Language ───────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            trailing: DropdownButton<String>(
              value: localeNotifier.locale.languageCode,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'fr', child: Text('Français')),
              ],
              onChanged: (code) {
                if (code != null) localeNotifier.setLocale(Locale(code));
              },
            ),
          ),
          const Divider(),

          // ── Export ─────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: Text(l10n.exportData),
            subtitle: Text(l10n.exportDataDesc),
            onTap: () => _export(context, export, l10n),
          ),

          // ── Import ─────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.download),
            title: Text(l10n.importData),
            subtitle: Text(l10n.importDataDesc),
            onTap: () => _import(context, export, l10n),
          ),
        ],
      ),
    );
  }

  Future<void> _export(
    BuildContext context,
    ExportService export,
    AppLocalizations l10n,
  ) async {
    try {
      await export.exportAndShare();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.exportSuccess)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.importError(e.toString()))));
      }
    }
  }

  Future<void> _import(
    BuildContext context,
    ExportService export,
    AppLocalizations l10n,
  ) async {
    // Confirm overwrite
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.importData),
        content: Text(l10n.importConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    if (!context.mounted) return;

    // Pick the JSON file
    try {
      // Use a simple text input fallback since file_picker adds more deps.
      // We ask the user to paste the JSON content.
      final controller = TextEditingController();
      final pasted = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.importData),
          content: TextField(
            controller: controller,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Paste JSON export content here…',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: Text(l10n.confirm),
            ),
          ],
        ),
      );

      if (pasted == null || pasted.trim().isEmpty) return;
      if (!context.mounted) return;

      await export.importFromJson(pasted.trim());

      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.importSuccess)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.importError(e.toString()))));
      }
    }
  }
}
