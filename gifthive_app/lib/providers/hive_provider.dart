import 'package:flutter/material.dart';
import '../models/hive.dart';
import '../models/gift.dart';
import '../services/api_services.dart';

class HiveProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<Hive> _hives = [];
  bool _loading = false;
  String? _error;

  List<Hive> get hives => _hives;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadHives(String token) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _hives = await _api.getHives(token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addHive(String token, String name) async {
    final hive = await _api.createHive(token, name);
    _hives.add(hive);
    notifyListeners();
  }

  Future<void> deleteHive(String token, String hiveId) async {
    await _api.deleteHive(token, hiveId);
    _hives.removeWhere((h) => h.id == hiveId);
    notifyListeners();
  }

  Future<void> addGift(String token, String hiveId, String giftName, List<String> tags) async {
    final gift = await _api.addGift(token, hiveId, giftName, tags);
    final idx = _hives.indexWhere((h) => h.id == hiveId);
    if (idx != -1) {
      _hives[idx] = Hive(
        id: _hives[idx].id,
        name: _hives[idx].name,
        gifts: [..._hives[idx].gifts, gift],
      );
      notifyListeners();
    }
  }

  Future<void> toggleBought(String token, String hiveId, Gift gift) async {
    final updated = await _api.updateGift(token, gift.id, {'bought': !gift.bought});
    final hiveIdx = _hives.indexWhere((h) => h.id == hiveId);
    if (hiveIdx != -1) {
      final gifts = _hives[hiveIdx].gifts.map((g) => g.id == gift.id ? updated : g).toList();
      _hives[hiveIdx] = Hive(id: _hives[hiveIdx].id, name: _hives[hiveIdx].name, gifts: gifts);
      notifyListeners();
    }
  }

  Future<void> deleteGift(String token, String hiveId, String giftId) async {
    await _api.deleteGift(token, giftId);
    final hiveIdx = _hives.indexWhere((h) => h.id == hiveId);
    if (hiveIdx != -1) {
      final gifts = _hives[hiveIdx].gifts.where((g) => g.id != giftId).toList();
      _hives[hiveIdx] = Hive(id: _hives[hiveIdx].id, name: _hives[hiveIdx].name, gifts: gifts);
      notifyListeners();
    }
  }
}
