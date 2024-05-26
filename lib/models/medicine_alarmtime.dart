import 'package:hive/hive.dart';

part 'medicine_alarmtime.g.dart';

@HiveType(typeId: 3)
class MedicineAlarmTime extends HiveObject {
  MedicineAlarmTime({
    required this.medicineKey,
    required this.name,
    required this.alarmTIme,
    required this.imagePath,
    this.checked = false,
    this.disable = false,
    required this.weekdays,
    required this.addDate,
    this.deleteDate,
    this.checkedDate = '',
  });

  @HiveField(0)
  final int medicineKey;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String alarmTIme;

  @HiveField(3)
  bool checked;

  @HiveField(4)
  final String? imagePath;

  @HiveField(5)
  bool? disable;

  @HiveField(6)
  List<int> weekdays;

  @HiveField(7)
  DateTime addDate;

  @HiveField(8)
  DateTime? deleteDate;

  @HiveField(9)
  String checkedDate;

  @HiveField(10)
  List<String> calendarCheckDate = [];

  @override
  String toString() {
    return 'medicineKey: $medicineKey, name: $name, alarmTIme: $alarmTIme, imagePath: $imagePath, checked: $checked, addDate: $addDate, deleteDate: $deleteDate, checkDate: $checkedDate, checkList: $calendarCheckDate';
  }
}
