import 'dart:developer';

import 'package:dory/models/medicine_history.dart';
import 'package:dory/repositories/dory_hive.dart';
import 'package:hive/hive.dart';

// 아마 복용한 약 목록

class MedicineHistoryRepository {
  Box<MedicineHistory>?
      _historyBox; // hive.initializeHive(); 가 실행된 후에 box를 가져와야함

  Box<MedicineHistory> get historyBox {
    _historyBox ??= Hive.box<MedicineHistory>(DoryHiveBox.medicineHistory);
    return _historyBox!;
  }

  void addHistory(MedicineHistory history) async {
    int key = await historyBox.add(history); // ai 키가 생김(자동으로 값이 1씩 증가함)

    log('[addHistory] add (key:$key) $history');
    log('result ${historyBox.values.toList()} \n');
  }

  void deleteHistory(int key) async {
    await historyBox.delete(key);

    log('[deleteHistory] delete (key:$key)');
    log('result ${historyBox.values.toList()} \n');
  }

  void deleteAllHistory(Iterable<int> keys) async {
    await historyBox.deleteAll(keys);

    log('[deleteAllHistory] delete (key:$keys)');
    log('result ${historyBox.values.toList()} \n');
  }

  void clearAllHistory() async {
    await historyBox.clear();

    log('clearAllHistory result ${historyBox.values.toList()} \n');
  }

  void updateHistory({
    required int key,
    required MedicineHistory history,
  }) async {
    await historyBox.put(key, history);

    log('[updateHistory] update (key:$key) $history');
    log('result ${historyBox.values.toList()} \n');
  }
}
