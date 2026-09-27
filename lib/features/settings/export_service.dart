import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;
import '../../core/models/convention.dart';
import '../../core/models/convention_entry.dart';
import '../../core/models/item.dart';
import '../../core/repositories/convention_entry_repository.dart';
import '../../core/repositories/convention_repository.dart';
import '../../core/repositories/item_repository.dart';

class ExportService {
  final ItemRepository _itemRepo = ItemRepository();
  final ConventionRepository _convRepo = ConventionRepository();
  final ConventionEntryRepository _entryRepo = ConventionEntryRepository();

  /// Export all data to a JSON file and share it.
  Future<void> exportAndShare() async {
    final items = await _itemRepo.getAll();
    final conventions = await _convRepo.getAll();
    final allEntries = <Map<String, dynamic>>[];

    for (final c in conventions) {
      final entries = await _entryRepo.getForConvention(c.id!);
      allEntries.addAll(entries.map((e) => e.toJson()));
    }

    final payload = {
      'exported_at': DateTime.now().toIso8601String(),
      'version': 1,
      'items': items.map((i) => i.toJson()).toList(),
      'conventions': conventions.map((c) => c.toJson()).toList(),
      'convention_entries': allEntries,
    };

    final jsonString =
        const JsonEncoder.withIndent('  ').convert(payload);

    final tmpDir = await getTemporaryDirectory();
    final fileName =
        'convention_app_export_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${tmpDir.path}/$fileName');
    await file.writeAsString(jsonString);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Convention App export',
    );
  }

  /// Import data from a JSON string (replaces all existing data).
  Future<void> importFromJson(String jsonString) async {
    final Map<String, dynamic> payload =
        jsonDecode(jsonString) as Map<String, dynamic>;

    final rawItems =
        (payload['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final rawConventions =
        (payload['conventions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final rawEntries =
        (payload['convention_entries'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    final items = rawItems.map(Item.fromJson).toList();
    final conventions = rawConventions.map(Convention.fromJson).toList();
    final entries = rawEntries.map(ConventionEntry.fromJson).toList();

    // Clear existing data in safe order
    await _entryRepo.deleteAll();
    await _convRepo.deleteAll();
    await _itemRepo.deleteAll();

    // Re-insert preserving original IDs
    await _itemRepo.insertAll(items);
    await _convRepo.insertAll(conventions);
    await _entryRepo.insertAll(entries);
  }
}
