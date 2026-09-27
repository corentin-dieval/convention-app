import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../core/models/item.dart';
import '../../core/repositories/item_repository.dart';

class RefillProvider extends ChangeNotifier {
  final ItemRepository _repo = ItemRepository();
  final ImagePicker _picker = ImagePicker();

  List<Item> _items = [];
  List<Item> get items => _items;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Future<void> loadItems() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _repo.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> addItem(Item item) async {
    try {
      final saved = await _repo.insert(item);
      _items.add(saved);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateItem(Item item) async {
    try {
      await _repo.update(item);
      final idx = _items.indexWhere((i) => i.id == item.id);
      if (idx != -1) _items[idx] = item;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteItem(int id) async {
    try {
      await _repo.delete(id);
      _items.removeWhere((i) => i.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<String?> pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (picked == null) return null;
      final docsDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(docsDir.path, 'item_images'));
      await imagesDir.create(recursive: true);
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}';
      final destPath = p.join(imagesDir.path, fileName);
      await File(picked.path).copy(destPath);
      return destPath;
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

