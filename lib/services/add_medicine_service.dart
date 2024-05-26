import 'package:dory/main.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

// 알람 추가 기능 서비스      // 상태가 변경될때마다 리스너에게 알려주고 화면을 다시 그림
class AddMedicineService with ChangeNotifier {
  AddMedicineService(int updateMedicineId) {
    final isUpdate = updateMedicineId != -1; // 수정하기가 맞다
    if (isUpdate) {
      final updateAlarms = medicineRepository.medicineBox.values
          .singleWhere((medicine) => medicine.id == updateMedicineId)
          .alarms; // 리스트
      _alarms.clear();
      _alarms.addAll(updateAlarms);
    }
  }

  final _alarms = <String>{'08:00', '13:00', '17:00'};

  Set<String> get alarms => _alarms;

  void addNowAlarm() {
    final now = DateTime.now();
    final nowTime = DateFormat('HH:mm').format(now);
    _alarms.add(nowTime);
    notifyListeners(); // = setState() 변화가 있어 다시 그려줘 화면을 ChangeNotifier나 ValueNotifier와 같은 상태 관리 클래스에서 사용
  }

  void removeAlarm(String alarmTime) {
    _alarms.remove(alarmTime);
    notifyListeners();
  }

  void setAlarm({required String prevTime, required DateTime setTime}) {
    _alarms.remove(prevTime);

    final setTimeStr = DateFormat('HH:mm').format(setTime);
    _alarms.add(setTimeStr);
    notifyListeners();
  }
}
