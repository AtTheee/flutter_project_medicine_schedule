// 저장된 약들의 모든 알람 List를 위한 모델

class MedicineAlarm {
  MedicineAlarm(
      {required this.id,
      required this.name,
      required this.imagePath,
      required this.alarmTIme,
      required this.key});

  final int id;

  final String name;

  final String? imagePath; // image path

  final String alarmTIme;

  final int key;
}
