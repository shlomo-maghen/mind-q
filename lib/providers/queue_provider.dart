import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/queue_item.dart';
import '../services/queue_repository.dart';

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
  }

  Future<void> remove(String id) async {
    final current = state.valueOrNull ?? [];
    final updated = current.where((e) => e.id != id).toList();
    state = AsyncData(updated);
    await _repo.saveAll(updated);
  }
}

final queueProvider =
    AsyncNotifierProvider<QueueNotifier, List<QueueItem>>(QueueNotifier.new);
