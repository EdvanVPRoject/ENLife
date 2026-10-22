import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/models/vault_item.dart';
import '../data/services/storage_service.dart';

class VaultProvider extends ChangeNotifier {
  final StorageService _storage;
  List<VaultItem> _items = [];

  VaultProvider(this._storage);

  List<VaultItem> get items => List.unmodifiable(_items);

  List<VaultItem> get expiringSoonItems => _items.where((i) => i.isExpiringSoon).toList();

  Future<void> load() async {
    _items = await _storage.getVaultItems();
    notifyListeners();
  }

  Future<void> addItem({
    required String title,
    required String numberOrCode,
    required String holderName,
    required VaultCategory category,
    DateTime? expiryDate,
    String? notes,
  }) async {
    final newItem = VaultItem(
      id: const Uuid().v4(),
      title: title,
      numberOrCode: numberOrCode,
      holderName: holderName,
      category: category,
      expiryDate: expiryDate,
      notes: notes,
    );
    _items.add(newItem);
    await _storage.saveVaultItems(_items);
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    await _storage.saveVaultItems(_items);
    notifyListeners();
  }
}
