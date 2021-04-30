// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assetbox.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AssetBoxAdapter extends TypeAdapter<AssetBox> {
  @override
  final int typeId = 0;

  @override
  AssetBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AssetBox(
      asset: fields[0] as String,
      action: fields[1] as String,
      price: fields[2] as String,
      amount: fields[3] as String,
      date: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AssetBox obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.asset)
      ..writeByte(1)
      ..write(obj.action)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
