// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hivenotification.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveNotificationAdapter extends TypeAdapter<HiveNotification> {
  @override
  final int typeId = 3;

  @override
  HiveNotification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveNotification(
      asset: fields[0] as String,
      time: fields[1] as String,
      percent: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, HiveNotification obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.asset)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.percent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveNotificationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
