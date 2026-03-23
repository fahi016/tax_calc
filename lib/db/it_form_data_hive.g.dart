// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'it_form_data_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItFormDataHiveAdapter extends TypeAdapter<ItFormDataHive> {
  @override
  final int typeId = 0;

  @override
  ItFormDataHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItFormDataHive(
      name: fields[0] as String,
      pen: fields[1] as String,
      pan: fields[2] as String,
      designation: fields[3] as String,
      institution: fields[4] as String,
      localBodyType: fields[5] as String,
      basicPayMarch2026: fields[6] as String,
      nextIncrementMonth: fields[7] as int,
      bpAfterIncrement: fields[8] as String,
      otherIncome: fields[9] as String,
      taxAlreadyPaid: fields[10] as String,
      daPercent: fields[11] as String,
      remainingMonths: fields[12] as String,
      // Graceful fallback for existing saved data that pre-dates this field
      relief: fields[13] as String? ?? '0',
    );
  }

  @override
  void write(BinaryWriter writer, ItFormDataHive obj) {
    writer
      ..writeByte(14) // total fields
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.pen)
      ..writeByte(2)
      ..write(obj.pan)
      ..writeByte(3)
      ..write(obj.designation)
      ..writeByte(4)
      ..write(obj.institution)
      ..writeByte(5)
      ..write(obj.localBodyType)
      ..writeByte(6)
      ..write(obj.basicPayMarch2026)
      ..writeByte(7)
      ..write(obj.nextIncrementMonth)
      ..writeByte(8)
      ..write(obj.bpAfterIncrement)
      ..writeByte(9)
      ..write(obj.otherIncome)
      ..writeByte(10)
      ..write(obj.taxAlreadyPaid)
      ..writeByte(11)
      ..write(obj.daPercent)
      ..writeByte(12)
      ..write(obj.remainingMonths)
      ..writeByte(13)
      ..write(obj.relief);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItFormDataHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}