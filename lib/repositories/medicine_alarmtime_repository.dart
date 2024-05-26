import 'dart:developer';

import 'package:dory/models/medicine_alarmtime.dart';
import 'package:hive/hive.dart';

import 'dory_hive.dart';

class MedicineAlarmTimeRepository {
  Box<MedicineAlarmTime>? _alarmTimeBox;

  Box<MedicineAlarmTime> get alarmTimeBox {
    _alarmTimeBox ??=
        Hive.box<MedicineAlarmTime>(DoryHiveBox.medicineAlarmTime);
    return _alarmTimeBox!;
  }

  void addAlramTime(MedicineAlarmTime alarmTime) async {
    int key = await alarmTimeBox.add(alarmTime); // ai 키가 생김(자동으로 값이 1씩 증가함)

    log('[addAlramTime] add (key:$key) $alarmTime');
    log('addAlarmTime result ${alarmTimeBox.values.toList()} \n');
  }

  void deleteAllAlramTime() async {
    await alarmTimeBox.clear();

    log('[deleteAllAlramTime]');
    log('result ${alarmTimeBox.values.toList()}');
  }

  void deleteAlarmTime(int key) async {
    await alarmTimeBox.delete(key);

    log('[deleteAlramTime] delete (key:$key)');
    log('result ${alarmTimeBox.values.toList()}');
  }

  void updateMedicineAlramTime({
    required int key,
    required MedicineAlarmTime alarmTime,
  }) async {
    await alarmTimeBox.put(key, alarmTime);

    log('[updateAlarmTIme] update (key:$key) $alarmTime');
    log('result ${alarmTimeBox.values.toList()}');
  }
}
