import 'package:hive/hive.dart';

part 'medicine.g.dart';

@HiveType(typeId: 1)
class Medicine extends HiveObject {
  // id(유니크), name, image(optional), alarms
  // unique ai(int) UUID(String) millisecondsSinceEpoch(int)

  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? imagePath; // image path

  @HiveField(3)
  final List<String> alarms;

  @HiveField(4)
  bool? disable;

  @HiveField(5)
  List<int> weekdays;

  @HiveField(6)
  String? memo;

  Medicine({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.alarms,
    this.disable = false,
    required this.weekdays,
    this.memo,
  });

  @override
  String toString() {
    return 'id: $id, name: $name, imagePath: $imagePath, alarms: $alarms, disable: $disable, weekdays: $weekdays';
  }
}
