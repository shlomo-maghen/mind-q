import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/queue_item.dart';
import '../services/notification_service.dart';
import '../services/queue_repository.dart';
import 'settings_provider.dart';

final _repo = QueueRepository();
const _uuid = Uuid();

class QueueNotifier extends AsyncNotifier<List<QueueItem>> {
  @override
  Future<List<QueueItem>> build() => _repo.loadAll();

  Future<void> add(String text) async {
    final item = QueueItem(
      id: _uuid.v4(),
      text: text.trim(),
      createdAt: DateTime.now(),
    );
    final current = state.valueOrNull ?? [];
    // Append to end — FIFO: oldest stays at top of list
    final updated = [...current, item];
    state = AsyncData(updated);
    await _repo.saveAll(updated);
    await _scheduleNotification(updated.length);
  }

  Future<void> edit(String id, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final current = state.valueOrNull ?? [];
    final updated = current
        .map((e) => e.id == id ? e.copyWith(text: trimmed) : e)
        .toList();
    state = AsyncData(updated);
    await _repo.saveAll(updated);
  }

  Future<void> remove(String id) async {
    final current = state.valueOrNull ?? [];
    final updated = current.where((e) => e.id != id).toList();
    state = AsyncData(updated);
    await _repo.saveAll(updated);
    if (updated.isEmpty && !kIsWeb) {
      await NotificationService.instance.cancel();
    }
  }

  Future<void> _scheduleNotification(int count) async {
    if (kIsWeb) return;
    final settings = ref.read(settingsProvider).valueOrNull;
    if (settings == null || !settings.enabled) return;
    await NotificationService.instance.schedule(count, settings.delayMinutes);
  }
}

final queueProvider =
    AsyncNotifierProvider<QueueNotifier, List<QueueItem>>(QueueNotifier.new);
