import 'package:finance_app/features/budget/data/models/budget_snapshot.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BudgetSnapshotRepository {
  static const String _boxName = 'budget_snapshots';

  Future<Box<BudgetMonthSnapshot>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<BudgetMonthSnapshot>(_boxName);
    }
    return await Hive.openBox<BudgetMonthSnapshot>(_boxName);
  }

  Future<void> saveSnapshot(BudgetMonthSnapshot snapshot) async {
    final box = await _getBox();
    await box.put(snapshot.id, snapshot);
  }

  Future<BudgetMonthSnapshot?> getSnapshot(String id) async {
    final box = await _getBox();
    return box.get(id);
  }

  Future<List<BudgetMonthSnapshot>> getAllSnapshots() async {
    final box = await _getBox();
    return box.values.toList()
      ..sort((a, b) => b.month.compareTo(a.month)); // Most recent first
  }

  Future<List<BudgetMonthSnapshot>> getRecentSnapshots(int count) async {
    final all = await getAllSnapshots();
    return all.take(count).toList();
  }

  Future<BudgetMonthSnapshot?> getLatestSnapshot() async {
    final all = await getAllSnapshots();
    return all.isEmpty ? null : all.first;
  }

  Future<List<BudgetMonthSnapshot>> getSnapshotsForYear(int year) async {
    final all = await getAllSnapshots();
    return all.where((s) => s.month.year == year).toList();
  }

  Future<void> deleteSnapshot(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  Future<void> deleteAll() async {
    final box = await _getBox();
    await box.clear();
  }
}
