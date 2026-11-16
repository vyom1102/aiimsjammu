// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DB2BuildingByVenueMapAPIModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DB2BuildingByVenueMapAPIModelAdapter
    extends TypeAdapter<DB2BuildingByVenueMapAPIModel> {
  @override
  final int typeId = 77;

  @override
  DB2BuildingByVenueMapAPIModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DB2BuildingByVenueMapAPIModel(
      responseBody: (fields[0] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, DB2BuildingByVenueMapAPIModel obj) {
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
      other is DB2BuildingByVenueMapAPIModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
