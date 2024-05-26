// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_alarmtime.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicineAlarmTimeAdapter extends TypeAdapter<MedicineAlarmTime> {
  @override
  final int typeId = 3;

  @override
  MedicineAlarmTime read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicineAlarmTime(
      medicineKey: fields[0] as int,
      name: fields[1] as String,
      alarmTIme: fields[2] as String,
      imagePath: fields[4] as String?,
      checked: fields[3] as bool,
      disable: fields[5] as bool?,
      weekdays: (fields[6] as List).cast<int>(),
      addDate: fields[7] as DateTime,
      deleteDate: fields[8] as DateTime?,
      checkedDate: fields[9] as String,
    )..calendarCheckDate = (fields[10] as List).cast<String>();
  }

  @override
  void write(BinaryWriter writer, MedicineAlarmTime obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.medicineKey)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.alarmTIme)
      ..writeByte(3)
      ..write(obj.checked)
      ..writeByte(4)
      ..write(obj.imagePath)
      ..writeByte(5)
      ..write(obj.disable)
      ..writeByte(6)
      ..write(obj.weekdays)
      ..writeByte(7)
      ..write(obj.addDate)
      ..writeByte(8)
      ..write(obj.deleteDate)
      ..writeByte(9)
      ..write(obj.checkedDate)
      ..writeByte(10)
      ..write(obj.calendarCheckDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineAlarmTimeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
