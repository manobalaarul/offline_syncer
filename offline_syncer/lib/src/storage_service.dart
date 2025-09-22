import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static const String boxName = 'offline_sync_box';
  late Box _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(boxName);
  }

  Future<void> addQueuedRequest(Map<String, dynamic> json) async {
    final id = Uuid().v4();
    await _box.put(id, json);
  }

  List<Map> getAllPending() {
    return _box.toMap().entries.map((e) => {
      'id': e.key,
      ...Map<String, dynamic>.from(e.value)
    }).toList();
  }

  Future<void> remove(String id) async => await _box.delete(id);

  Future<void> update(String id, Map<String, dynamic> payload) async {
    await _box.put(id, payload);
  }
}
