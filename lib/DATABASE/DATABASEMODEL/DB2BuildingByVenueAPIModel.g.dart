// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DB2BuildingByVenueAPIModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DB2BuildingByVenueAPIModelAdapter
    extends TypeAdapter<DB2BuildingByVenueAPIModel> {
  @override
  final int typeId = 70;

  @override
  DB2BuildingByVenueAPIModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DB2BuildingByVenueAPIModel(
      responseBody: (fields[0] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, DB2BuildingByVenueAPIModel obj) {
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
      other is DB2BuildingByVenueAPIModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
