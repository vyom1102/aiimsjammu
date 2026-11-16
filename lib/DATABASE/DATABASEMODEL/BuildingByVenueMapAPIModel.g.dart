// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BuildingByVenueMapAPIModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BuildingByVenueMapAPIModelAdapter
    extends TypeAdapter<BuildingByVenueMapAPIModel> {
  @override
  final int typeId = 75;

  @override
  BuildingByVenueMapAPIModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BuildingByVenueMapAPIModel(
      responseBody: (fields[0] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, BuildingByVenueMapAPIModel obj) {
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
      other is BuildingByVenueMapAPIModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
