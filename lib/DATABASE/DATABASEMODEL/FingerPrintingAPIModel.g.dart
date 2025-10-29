// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'FingerPrintingAPIModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FingerPrintingAPIModelAdapter
    extends TypeAdapter<FingerPrintingAPIModel> {
  @override
  final int typeId = 71;

  @override
  FingerPrintingAPIModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FingerPrintingAPIModel(
      responseBody: (fields[0] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, FingerPrintingAPIModel obj) {
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
      other is FingerPrintingAPIModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
