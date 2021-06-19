// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notificationstate.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationStateAdapter extends TypeAdapter<NotificationState> {
  @override
  final int typeId = 1;

  @override
  NotificationState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationState(
      asset: fields[0] as String,
      percentage: fields[1] as double,
      time: fields[2] as String,
      switchState: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationState obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.asset)
      ..writeByte(1)
      ..write(obj.percentage)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.switchState);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
