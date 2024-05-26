import 'dart:developer';

import 'package:dory/repositories/dory_hive.dart';
import 'package:hive/hive.dart';

import 'package:dory/models/medicine.dart';

class MedicineRepository {
  Box<Medicine>? _medicineBox; // hive.initializeHive(); 가 실행된 후에 box를 가져와야함

  Box<Medicine> get medicineBox {
    _medicineBox ??= Hive.box<Medicine>(DoryHiveBox.medicine);
    return _medicineBox!;
  }

  void addMedicine(Medicine medicine) async {
    int key = await medicineBox.add(medicine); // ai 키가 생김(자동으로 값이 1씩 증가함)

    log('[addMedicine] add (key:$key) $medicine');
    log('addMedicine result ${medicineBox.values.toList()}');
  }

  void deleteMedicine(int key) async {
    await medicineBox.delete(key);

    log('[deleteMedicine] delete (key:$key)');
    log('result ${medicineBox.values.toList()}');
  }

  void deleteAllMedicine() async {
    for (var key in medicineBox.keys) {
      await medicineBox.delete(key);
    }
    log('[deleteAllMedicine]');
    log('result ${medicineBox.values.toList()}');
  }

  void updateMedicine({
    required int key,
    required Medicine medicine,
  }) async {
    await medicineBox.put(key, medicine);

    log('[updateMedicine] update (key:$key) $medicine');
    log('result ${medicineBox.values.toList()}');
  }

  int get newId {
    final lastId = medicineBox.values.isEmpty ? 0 : medicineBox.values.last.id;
    return lastId + 1;
  }
}
