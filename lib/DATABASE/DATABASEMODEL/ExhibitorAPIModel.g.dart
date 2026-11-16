// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ExhibitorAPIModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExhibitorAPIModelAdapter extends TypeAdapter<ExhibitorAPIModel> {
  @override
  final int typeId = 81;

  @override
  ExhibitorAPIModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExhibitorAPIModel(
      responseBody: (fields[0] as List).cast<dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ExhibitorAPIModel obj) {
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
      other is ExhibitorAPIModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
