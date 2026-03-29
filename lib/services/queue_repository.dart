import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/queue_item.dart';

class QueueRepository {
  static const _key = 'queue_items';

  Future<List<QueueItem>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = json.decode(raw) as List<dynamic>;
    return list
        .map((e) => QueueItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<QueueItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      json.encode(items.map((e) => e.toJson()).toList()),
    );
  }
}
