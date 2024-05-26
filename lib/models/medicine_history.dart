import 'package:hive/hive.dart';

part 'medicine_history.g.dart'; // 터미널에 flutter packages pub run build_runner build

@HiveType(typeId: 2)
class MedicineHistory extends HiveObject {
  // id(유니크), name, image(optional), alarms
  // unique ai(int) UUID(String) millisecondsSinceEpoch(int)

  @HiveField(0)
  final int medicineId;

  @HiveField(1)
  final String alarmTime;

  @HiveField(2)
  final DateTime takeTime; // image path

  @HiveField(3, defaultValue: -1)
  final int medicineKey;

  @HiveField(4, defaultValue: '삭제된 약입니다.')
  final String name;

  @HiveField(5)
  final String? imagePath;

  MedicineHistory({
    required this.medicineId,
    required this.alarmTime,
    required this.takeTime,
    required this.medicineKey,
    required this.name,
    required this.imagePath,
  });

  @override
  String toString() {
    return 'medicineId: $medicineId, medicineKey: $medicineKey, alarmTime: $alarmTime, takeTime: $takeTime, name: $name, imagePath: $imagePath';
  }
}
