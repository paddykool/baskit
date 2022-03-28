// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'baskit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BaskitAdapter extends TypeAdapter<Baskit> {
  @override
  final int typeId = 1;

  @override
  Baskit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Baskit(
      title: fields[0] as String,
      itemsList: (fields[1] as List).cast<Item>(),
    );
  }

  @override
  void write(BinaryWriter writer, Baskit obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.itemsList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaskitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
