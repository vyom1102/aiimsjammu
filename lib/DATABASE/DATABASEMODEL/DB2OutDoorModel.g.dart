// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DB2OutDoorModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DB2OutDoorModelAdapter extends TypeAdapter<DB2OutDoorModel> {
  @override
  final int typeId = 96;

  @override
  DB2OutDoorModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DB2OutDoorModel(
      responseBody: (fields[0] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, DB2OutDoorModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.responseBody);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DB2OutDoorModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
