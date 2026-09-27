import 'package:flutter/material.dart';
import '../../core/models/convention.dart';
import '../../core/models/convention_entry.dart';
import '../../core/models/item.dart';
import '../../core/repositories/convention_repository.dart';
import '../../core/repositories/convention_entry_repository.dart';
import '../../core/repositories/item_repository.dart';

class ConventionProvider extends ChangeNotifier {
  final ConventionRepository _convRepo = ConventionRepository();
  final ConventionEntryRepository _entryRepo = ConventionEntryRepository();
  final ItemRepository _itemRepo = ItemRepository();

  List<Convention> _conventions = [];
  List<Convention> get conventions => _conventions;

  List<Item> _catalogueItems = [];
  List<Item> get catalogueItems => _catalogueItems;

  // Entries for the currently open convention detail screen
  List<ConventionEntry> _entries = [];
  List<ConventionEntry> get entries => _entries;

  double get grandTotal =>
      _entries.fold(0, (sum, e) => sum + e.lineTotal);

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  // ── Conventions ──────────────────────────────────────────────

  Future<void> loadConventions() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _conventions = await _convRepo.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Convention?> addConvention(Convention convention) async {
    try {
      final saved = await _convRepo.insert(convention);
      _conventions.insert(0, saved);
      notifyListeners();
      return saved;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateConvention(Convention convention) async {
    try {
      await _convRepo.update(convention);
      final idx = _conventions.indexWhere((c) => c.id == convention.id);
      if (idx != -1) _conventions[idx] = convention;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteConvention(int id) async {
    try {
      await _convRepo.delete(id);
      _conventions.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleClose(Convention convention) async {
    return updateConvention(
      convention.copyWith(isClosed: !convention.isClosed),
    );
  }

  // ── Entries for a convention ──────────────────────────────────

  Future<void> loadEntries(int conventionId) async {
    _loading = true;
    notifyListeners();
    try {
      _entries = await _entryRepo.getForConvention(conventionId);
      _catalogueItems = await _itemRepo.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearEntries() {
    _entries = [];
    notifyListeners();
  }

  Future<bool> addEntry({
    required int conventionId,
    required Item item,
    required int quantity,
  }) async {
    try {
      final entry = ConventionEntry(
        conventionId: conventionId,
        itemId: item.id!,
        itemName: item.name,
        quantity: quantity,
        priceSnapshot: item.unitPrice,
      );
      final saved = await _entryRepo.insert(entry);
      _entries.add(saved);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEntryQuantity(ConventionEntry entry, int newQty) async {
    if (newQty <= 0) return removeEntry(entry.id!);
    try {
      final updated = entry.copyWith(quantity: newQty);
      await _entryRepo.update(updated);
      final idx = _entries.indexWhere((e) => e.id == entry.id);
      if (idx != -1) _entries[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeEntry(int id) async {
    try {
      await _entryRepo.delete(id);
      _entries.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
